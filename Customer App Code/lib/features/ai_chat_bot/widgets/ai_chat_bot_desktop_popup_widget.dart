import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/controllers/ai_chat_bot_controller.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/domain/models/ai_chat_conversation_model.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_conversation_card_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_conversation_shimmer_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_conversation_view_widget.dart';
import 'package:stackfood_multivendor/features/ai_chat_bot/widgets/ai_chat_suggestion_chips_widget.dart';
import 'package:stackfood_multivendor/util/dimensions.dart';
import 'package:stackfood_multivendor/util/styles.dart';

class AiChatBotDesktopPopupWidget extends StatefulWidget {
  const AiChatBotDesktopPopupWidget({super.key});

  @override
  State<AiChatBotDesktopPopupWidget> createState() => _AiChatBotDesktopPopupWidgetState();
}

class _AiChatBotDesktopPopupWidgetState extends State<AiChatBotDesktopPopupWidget> {
  static const double _popupWidth = 400;
  static const double _popupHeight = 500;

  final ScrollController _listScrollController = ScrollController();

  bool _open = false;
  bool _showDetail = false;
  int? _activeConversationId;
  String? _activeConversationTitle;
  int? _activeConversationMessagesCount;
  String? _initialMessage;

  @override
  void dispose() {
    _listScrollController.dispose();
    super.dispose();
  }

  void _togglePopup() {
    setState(() => _open = !_open);
    if (_open) {
      _showDetail = false;
      Get.find<AiChatBotController>().getConversationList(1, reload: true);
    }
  }

  void _openConversation({int? conversationId, String? title, String? initialMessage, int? messagesCount}) {
    setState(() {
      _activeConversationId = conversationId;
      _activeConversationTitle = title;
      _activeConversationMessagesCount = messagesCount;
      _initialMessage = initialMessage;
      _showDetail = true;
    });
  }

  void _backToList() {
    setState(() {
      _showDetail = false;
      _activeConversationTitle = null;
      _activeConversationMessagesCount = null;
      _initialMessage = null;
    });
    Get.find<AiChatBotController>().getConversationList(1, reload: true);
  }

  Future<void> _confirmDelete(AiChatConversation conversation) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('delete_conversation'.tr, style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge)),
        content: Text('delete_conversation_confirm'.tr, style: robotoRegular.copyWith(fontSize: Dimensions.fontSizeSmall)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text('cancel'.tr, style: robotoMedium.copyWith(color: Theme.of(context).hintColor)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('delete'.tr, style: robotoMedium.copyWith(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed != true || conversation.id == null) {
      return;
    }
    final bool ok = await Get.find<AiChatBotController>().deleteConversation(conversation.id!);
    showCustomSnackBar(ok ? 'conversation_deleted'.tr : 'sorry_something_went_wrong'.tr, isError: !ok);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [

        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, alignment: Alignment.bottomRight, child: child),
          ),
          child: _open ? _buildPopupCard(context) : const SizedBox.shrink(),
        ),

        if (_open) const SizedBox(height: Dimensions.paddingSizeSmall),
        if (!_open) _AiLauncherButton(onTap: _togglePopup),

      ],
    );
  }

  Widget _buildPopupCard(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height - 140;
    return Material(
      color: Theme.of(context).cardColor,
      elevation: 12,
      borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: _popupWidth,
        height: math.min(_popupHeight, maxHeight),
        child: Column(children: [
          _buildHeader(context),
          Expanded(
            child: _showDetail
                ? AiChatConversationViewWidget(
                    key: ValueKey('ai_chat_view_${_activeConversationId ?? 'new'}_${_initialMessage ?? ''}'),
                    conversationId: _activeConversationId,
                    initialMessage: _initialMessage,
                    messagesCount: _activeConversationMessagesCount,
                  )
                : _buildListView(context),
          ),
        ]),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeDefault,
        vertical: Dimensions.paddingSizeSmall,
      ),
      color: Theme.of(context).primaryColor,
      child: Row(children: [

        if (_showDetail)
          InkWell(
            onTap: _backToList,
            customBorder: const CircleBorder(),
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
            ),
          )
        else
          Container(
            height: 38, width: 38,
            decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
            child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 20),
          ),
        const SizedBox(width: Dimensions.paddingSizeSmall),

        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(
              'ai_assistant'.tr,
              style: robotoBold.copyWith(color: Colors.white, fontSize: Dimensions.fontSizeLarge),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
            if(_showDetail)
            Text(
              _activeConversationTitle?.isNotEmpty == true ? _activeConversationTitle! : 'new_chat'.tr,
              style: robotoRegular.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: Dimensions.fontSizeExtraSmall),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            )
            else
              Row(children: [
                Container(
                  height: 8, width: 8,
                  decoration: const BoxDecoration(color: Color(0xFF7CFF9E), shape: BoxShape.circle),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Text(
                  'online_replies_instantly'.tr,
                  style: robotoRegular.copyWith(color: Colors.white.withValues(alpha: 0.9), fontSize: Dimensions.fontSizeExtraSmall),
                ),
              ]),
          ]),
        ),

        InkWell(
          onTap: _togglePopup,
          customBorder: const CircleBorder(),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(Icons.close_rounded, color: Colors.white, size: 22),
          ),
        ),

      ]),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Column(children: [

      Expanded(
        child: GetBuilder<AiChatBotController>(builder: (controller) {
          if (controller.conversationModel == null) {
            return const AiChatConversationShimmerWidget();
          }
          final List<AiChatConversation> conversations = controller.conversationModel!.data ?? [];
          if (conversations.isEmpty) {
            return _buildEmptySuggestions(context);
          }

          return CustomScrollView(
            controller: _listScrollController,
            slivers: [

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeDefault,
                  Dimensions.paddingSizeDefault, Dimensions.paddingSizeExtraSmall,
                ),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    'recent_chats'.tr.toUpperCase(),
                    style: robotoMedium.copyWith(
                      fontSize: Dimensions.fontSizeExtraSmall,
                      color: Theme.of(context).hintColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final conversation = conversations[index];
                      final bool deleting = conversation.id != null && controller.isDeleting(conversation.id!);
                      return AiChatConversationCardWidget(
                        conversation: conversation,
                        isDeleting: deleting,
                        onTap: deleting ? null : () => _openConversation(conversationId: conversation.id, title: conversation.title, messagesCount: conversation.messagesCount),
                        onDelete: conversation.id == null ? null : () => _confirmDelete(conversation),
                      );
                    },
                    childCount: conversations.length,
                  ),
                ),
              ),

            ],
          );
        }),
      ),

      _buildNewChatButton(context),

    ]);
  }

  // Shown when there are no past conversations: a friendly welcome plus tappable
  // suggestions so the user can start a chat immediately instead of facing a
  // near-empty panel with only the "new chat" button.
  Widget _buildEmptySuggestions(BuildContext context) {
    return SingleChildScrollView(
      controller: _listScrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: Dimensions.paddingSizeLarge,
        vertical: Dimensions.paddingSizeExtraLarge,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [

        Container(
          height: 88, width: 88,
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
          child: Icon(Icons.auto_awesome_rounded, size: 44, color: Theme.of(context).primaryColor),
        ),
        const SizedBox(height: Dimensions.paddingSizeDefault),

        Text(
          'ask_anything'.tr,
          style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeExtraSmall),

        Text(
          'start_a_new_conversation_with_ai'.tr,
          style: robotoRegular.copyWith(
            fontSize: Dimensions.fontSizeSmall,
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: Dimensions.paddingSizeLarge),

        AiChatSuggestionChipsWidget(
          onSuggestionTap: (text) => _openConversation(conversationId: null, initialMessage: text),
        ),

      ]),
    );
  }

  Widget _buildNewChatButton(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: InkWell(
          onTap: () => _openConversation(conversationId: null),
          borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeDefault),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(Dimensions.radiusExtraLarge),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              const SizedBox(width: Dimensions.paddingSizeExtraSmall),
              Text('new_chat'.tr, style: robotoMedium.copyWith(color: Colors.white)),
            ]),
          ),
        ),
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Floating launcher button
// -----------------------------------------------------------------------------
class _AiLauncherButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AiLauncherButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final Color primary = Theme.of(context).primaryColor;
    const Color accent = Color(0xFF8E5BFF);
    return Tooltip(
      message: 'ai_chat_bot'.tr,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          height: 58, width: 58,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [primary, accent]),
            boxShadow: [
              BoxShadow(color: primary.withValues(alpha: 0.35), blurRadius: 18, spreadRadius: 1, offset: const Offset(0, 6)),
              BoxShadow(color: accent.withValues(alpha: 0.22), blurRadius: 24, spreadRadius: 2, offset: const Offset(0, 2)),
            ],
          ),
          child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 26),
        ),
      ),
    );
  }
}
