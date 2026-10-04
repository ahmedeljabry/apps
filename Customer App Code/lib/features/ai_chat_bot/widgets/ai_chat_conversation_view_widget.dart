import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/controllers/ai_chat_bot_controller.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_message_model.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_message_bubble_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_suggestion_chips_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

/// The shared AI conversation view (message list + welcome view + input bar +
/// send logic). Used by both the mobile full-screen details view and the
/// desktop popup so the chat behaves identically on every platform.
class AiChatConversationViewWidget extends StatefulWidget {
  final int? conversationId;
  final String? initialMessage;

  /// The conversation's known total message count (e.g. from the conversation
  /// list card that was tapped). Lets the initial load jump straight to the
  /// last page instead of the oldest one. Safe to leave null - the controller
  /// falls back to correcting itself from the live total.
  final int? messagesCount;

  /// Notifies the host when a brand new chat is assigned an id by the backend.
  final ValueChanged<int>? onConversationCreated;

  const AiChatConversationViewWidget({
    super.key,
    required this.conversationId,
    this.initialMessage,
    this.messagesCount,
    this.onConversationCreated,
  });

  @override
  State<AiChatConversationViewWidget> createState() => _AiChatConversationViewWidgetState();
}

class _AiChatConversationViewWidgetState extends State<AiChatConversationViewWidget> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _inputController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  int? _activeConversationId;

  @override
  void initState() {
    super.initState();
    _activeConversationId = widget.conversationId;
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_){
      _initCall();
    });
  }

  void _initCall() {
    final controller = Get.find<AiChatBotController>();
    if (_activeConversationId != null) {
      controller.getMessages(_activeConversationId!, messagesCount: widget.messagesCount, firstLoad: true);
    } else {
      controller.clearMessages();
    }
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _inputController.text = widget.initialMessage!;
        controller.toggleSendButtonActivity(true);
        _onSendPressed();
      });
    }
  }

  // Reverse list: scrolling towards maxScrollExtent reveals older history.
  void _onScroll() {
    if (!_scrollController.hasClients || _activeConversationId == null) {
      return;
    }
    final ScrollPosition position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - 150) {
      final controller = Get.find<AiChatBotController>();
      if (controller.hasMoreMessages && !controller.isLoadingMoreMessages) {
        controller.getMessages(_activeConversationId!, messagesCount: widget.messagesCount);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _inputController.dispose();
    _inputFocusNode.dispose();
    super.dispose();
  }

  Future<void> _onSendPressed() async {
    final String message = _inputController.text.trim();
    if (message.isEmpty) {
      showCustomSnackBar('write_something'.tr);
      return;
    }
    _inputController.clear();
    // Drop focus so the keyboard dismisses once the message is sent.
    _inputFocusNode.unfocus();
    final controller = Get.find<AiChatBotController>();
    controller.toggleSendButtonActivity(false);

    await controller.sendMessage(
      message: message,
      conversationId: _activeConversationId,
      onConversationIdAssigned: (id) {
        _activeConversationId = id;
        widget.onConversationCreated?.call(id);
      },
    );

    controller.getConversationList(1, reload: true);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AiChatBotController>(builder: (controller) {
      return Column(children: [

        Expanded(
          child: Builder(builder: (_) {
            final bool sending = controller.isSendingMessage;
            final List<AiChatMessage> messages = List<AiChatMessage>.from(
              controller.messageModel?.messages ?? const <AiChatMessage>[],
            );
            messages.sort((a, b) {
              final DateTime aTime = DateTime.tryParse(a.createdAt ?? '')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0);
              final DateTime bTime = DateTime.tryParse(b.createdAt ?? '')?.toUtc() ?? DateTime.fromMillisecondsSinceEpoch(0);
              return bTime.compareTo(aTime);
            });
            final bool hasMessages = messages.isNotEmpty;

            if (controller.messageModel == null && _activeConversationId != null && !sending) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!hasMessages && !sending) {
              if (_activeConversationId == null) {
                return AiChatWelcomeViewWidget(
                  onSuggestionTap: (text) {
                    _inputController.text = text;
                    _onSendPressed();
                  },
                );
              }
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
                  child: Text(
                    'no_message_found'.tr,
                    style: robotoRegular.copyWith(color: Theme.of(context).hintColor),
                  ),
                ),
              );
            }

            final bool loadingMore = controller.isLoadingMoreMessages;
            final int sendingOffset = sending ? 1 : 0;

            return ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
              itemCount: messages.length + sendingOffset + (loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (sending && index == 0) {
                  return const AiChatTypingBubbleWidget();
                }
                final int messageIndex = index - sendingOffset;
                if (loadingMore && messageIndex == messages.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                    child: Center(
                      child: SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return AiChatMessageBubbleWidget(message: messages[messageIndex]);
              },
            );
          }),
        ),

        AiChatInputBarWidget(
          controller: _inputController,
          focusNode: _inputFocusNode,
          isSending: controller.isSendingMessage,
          isActive: controller.isSendButtonActive,
          onChanged: (value) => controller.toggleSendButtonActivity(value.trim().isNotEmpty),
          onSubmit: _onSendPressed,
        ),

      ]);
    });
  }
}

class AiChatInputBarWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool isSending;
  final bool isActive;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;
  const AiChatInputBarWidget({
    super.key,
    required this.controller,
    this.focusNode,
    required this.isSending,
    required this.isActive,
    required this.onChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Dimensions.paddingSizeDefault,
          vertical: Dimensions.paddingSizeSmall,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [

          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
                border: Border.all(
                  color: Theme.of(context).disabledColor.withValues(alpha: 0.3),
                  width: 0.6,
                ),
              ),
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                onChanged: onChanged,
                textCapitalization: TextCapitalization.sentences,
                style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall),
                keyboardType: TextInputType.multiline,
                maxLines: 4,
                minLines: 1,
                inputFormatters: [LengthLimitingTextInputFormatter(Dimensions.messageInputLength)],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  isCollapsed: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
                  hintText: 'ask_anything'.tr,
                  hintStyle: robotoRegular.copyWith(
                    color: Theme.of(context).hintColor,
                    fontSize: Dimensions.fontSizeSmall,
                  ),
                ),
                onSubmitted: (_) => isSending ? null : onSubmit(),
              ),
            ),
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),

          InkWell(
            onTap: isSending ? null : onSubmit,
            canRequestFocus: false,
            customBorder: const CircleBorder(),
            child: Container(
              height: 35, width: 35,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isActive && !isSending)
                    ? Theme.of(context).primaryColor
                    : Theme.of(context).disabledColor.withValues(alpha: 0.4),
              ),
              alignment: Alignment.center,
              child: isSending
                  ? const SizedBox(
                      height: 18, width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 22),
            ),
          ),

        ]),
      ),
    );
  }
}

class AiChatWelcomeViewWidget extends StatelessWidget {
  final ValueChanged<String> onSuggestionTap;
  const AiChatWelcomeViewWidget({super.key, required this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeExtraLarge,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [

          Container(
            height: 110, width: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).primaryColor.withValues(alpha: 0.2),
                  Theme.of(context).primaryColor.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              size: 56,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            'ask_anything'.tr,
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeLarge),
            child: Text(
              'start_a_new_conversation_with_ai'.tr,
              style: robotoRegular.copyWith(
                fontSize: Dimensions.fontSizeSmall,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),

          AiChatSuggestionChipsWidget(onSuggestionTap: onSuggestionTap),

        ],
      ),
    );
  }
}
