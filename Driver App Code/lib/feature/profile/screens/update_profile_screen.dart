import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_app_bar_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_drop_down_button.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_image_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_snackbar_widget.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_text_field_widget.dart';
import 'package:stackfood_multivendor_driver/feature/auth/controllers/auth_controller.dart';
import 'package:stackfood_multivendor_driver/feature/auth/domain/models/shift_model.dart';
import 'package:stackfood_multivendor_driver/feature/profile/controllers/profile_controller.dart';
import 'package:stackfood_multivendor_driver/feature/profile/domain/models/profile_model.dart';
import 'package:stackfood_multivendor_driver/feature/splash/controllers/splash_controller.dart';
import 'package:stackfood_multivendor_driver/helper/date_converter_helper.dart';
import 'package:stackfood_multivendor_driver/helper/phone_number_helper.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/common/widgets/custom_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class UpdateProfileScreen extends StatefulWidget {
  final ProfileModel profileModel;
  const UpdateProfileScreen({super.key, required this.profileModel});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final FocusNode _firstNameFocus = FocusNode();
  final FocusNode _lastNameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();

  String? _countryCode;

  @override
  void initState() {
    super.initState();

    _countryCode = CountryCode.fromCountryCode(
      Get.find<SplashController>().configModel!.country!,
    ).code;
    _splitPhone(Get.find<ProfileController>().profileModel!.phone!);

    _firstNameController.text = widget.profileModel.fName ?? '';
    _lastNameController.text = widget.profileModel.lName ?? '';
    _emailController.text = widget.profileModel.email ?? '';
    Get.find<ProfileController>().initData();
    Get.find<ProfileController>().initShiftSelection(widget.profileModel);
  }

  void _splitPhone(String? phone) async {
    if (phone != null && phone.isNotEmpty) {
      _countryCode = 'DZ';
      _phoneController.text = PhoneNumberHelper.normalizeLocal(phone);
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(title: 'edit_profile'.tr),

      body: GetBuilder<ProfileController>(
        builder: (profileController) {
          return Padding(
            padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: 30),

                        Center(
                          child: Stack(
                            children: [
                              ClipOval(
                                child: profileController.pickedFile != null
                                    ? GetPlatform.isWeb
                                          ? Image.network(
                                              profileController
                                                  .pickedFile!
                                                  .path,
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                          : Image.file(
                                              File(
                                                profileController
                                                    .pickedFile!
                                                    .path,
                                              ),
                                              width: 100,
                                              height: 100,
                                              fit: BoxFit.cover,
                                            )
                                    : CustomImageWidget(
                                        image:
                                            '${profileController.profileModel!.imageFullUrl}',
                                        height: 100,
                                        width: 100,
                                        fit: BoxFit.cover,
                                      ),
                              ),

                              Positioned(
                                bottom: 0,
                                right: 0,
                                top: 0,
                                left: 0,
                                child: InkWell(
                                  onTap: () => profileController.pickImage(),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 1,
                                        color: Theme.of(context).cardColor,
                                      ),
                                    ),
                                    child: Container(
                                      margin: const EdgeInsets.all(25),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          width: 2,
                                          color: Colors.white,
                                        ),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Dimensions.paddingSizeOverLarge),

                        CustomTextFieldWidget(
                          hintText: 'first_name'.tr,
                          labelText: 'first_name'.tr,
                          controller: _firstNameController,
                          focusNode: _firstNameFocus,
                          nextFocus: _lastNameFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                          isRequired: true,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeOverLarge),

                        CustomTextFieldWidget(
                          hintText: 'last_name'.tr,
                          labelText: 'last_name'.tr,
                          controller: _lastNameController,
                          focusNode: _lastNameFocus,
                          nextFocus: _emailFocus,
                          inputType: TextInputType.name,
                          capitalization: TextCapitalization.words,
                          isRequired: true,
                          prefixIcon: Icons.person,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeOverLarge),

                        CustomTextFieldWidget(
                          hintText: 'email'.tr,
                          labelText: 'email'.tr,
                          controller: _emailController,
                          focusNode: _emailFocus,
                          nextFocus: _phoneFocus,
                          inputType: TextInputType.emailAddress,
                          isRequired: true,
                          prefixIcon: Icons.email,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeOverLarge),

                        CustomTextFieldWidget(
                          hintText: 'xxx-xxx-xxxxx'.tr,
                          controller: _phoneController,
                          focusNode: _phoneFocus,
                          inputType: TextInputType.phone,
                          inputAction: TextInputAction.done,
                          isPhone: true,
                          countryDialCode: _countryCode,
                          labelText: 'phone'.tr,
                          isRequired: true,
                          isEnabled: false,
                        ),
                        const SizedBox(height: Dimensions.paddingSizeDefault),

                        (profileController.profileModel?.earnings == 1 &&
                                profileController.shifts != null &&
                                profileController.shifts!.isNotEmpty)
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(
                                    height: Dimensions.paddingSizeLarge,
                                  ),

                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      CustomDropdownButton(
                                        hintText: 'working_shift'.tr,
                                        borderColor: Theme.of(
                                          context,
                                        ).disabledColor,
                                        borderWidth: 0.2,
                                        dropdownMenuItems: profileController.shifts!.map((
                                          shift,
                                        ) {
                                          bool isSelected = profileController
                                              .selectedShifts
                                              .any(
                                                (deliveryManShift) =>
                                                    deliveryManShift.id ==
                                                    shift.id,
                                              );
                                          bool isFullDay = shift.isFullDay == 1;
                                          bool hasFullDay = profileController
                                              .selectedShifts
                                              .any(
                                                (deliveryManShift) =>
                                                    deliveryManShift
                                                        .isFullDay ==
                                                    1,
                                              );
                                          bool hasOtherShifts =
                                              profileController.selectedShifts
                                                  .any(
                                                    (deliveryManShift) =>
                                                        deliveryManShift
                                                            .isFullDay !=
                                                        1,
                                                  );
                                          bool shouldDisable =
                                              isSelected ||
                                              (isFullDay && hasOtherShifts) ||
                                              (!isFullDay && hasFullDay);

                                          return DropdownItem<ShiftModel>(
                                            value: shift,
                                            enabled: !shouldDisable,
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: Dimensions
                                                        .paddingSizeSmall,
                                                    horizontal: Dimensions
                                                        .paddingSizeExtraSmall,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: isSelected
                                                    ? Theme.of(
                                                        context,
                                                      ).hintColor.withValues(
                                                        alpha: 0.1,
                                                      )
                                                    : null,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      Dimensions.radiusSmall,
                                                    ),
                                              ),
                                              child: Text(
                                                '${shift.name} (${DateConverter.timeStringToTime(shift.startTime!)} - ${DateConverter.timeStringToTime(shift.endTime!)})',
                                                style: isSelected
                                                    ? robotoMedium.copyWith(
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                      )
                                                    : robotoRegular.copyWith(
                                                        color: shouldDisable
                                                            ? Theme.of(
                                                                context,
                                                              ).hintColor
                                                            : Theme.of(context)
                                                                  .textTheme
                                                                  .bodyLarge
                                                                  ?.color,
                                                        fontSize: Dimensions
                                                            .fontSizeDefault,
                                                      ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          );
                                        }).toList(),
                                        selectedValue: null,
                                        selectedItemBuilder: (BuildContext context) {
                                          return (profileController.shifts ??
                                                  [])
                                              .map((shift) {
                                                return RichText(
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text:
                                                            'working_shift'.tr,
                                                        style: robotoRegular
                                                            .copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeDefault,
                                                              color: Theme.of(
                                                                context,
                                                              ).disabledColor,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              })
                                              .toList();
                                        },
                                        onChanged: (value) {
                                          if (value != null &&
                                              !profileController.selectedShifts
                                                  .any(
                                                    (s) => s.id == value.id,
                                                  )) {
                                            profileController.toggleShift(
                                              value,
                                            );
                                          }
                                        },
                                      ),

                                      Positioned(
                                        left: 10,
                                        top: -10,
                                        child: Container(
                                          color: Theme.of(context).cardColor,
                                          padding: const EdgeInsets.all(2),
                                          child: Row(
                                            children: [
                                              Text(
                                                'working_shift'.tr,
                                                style: robotoRegular.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall,
                                                  color: Theme.of(
                                                    context,
                                                  ).hintColor,
                                                ),
                                              ),
                                              Text(
                                                ' *',
                                                style: robotoRegular.copyWith(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.error,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  profileController.selectedShifts.isNotEmpty
                                      ? Column(
                                          children: [
                                            const SizedBox(
                                              height:
                                                  Dimensions.paddingSizeSmall,
                                            ),
                                            Wrap(
                                              spacing: 5,
                                              runSpacing: 0,
                                              children: List.generate(
                                                profileController
                                                    .selectedShifts
                                                    .length,
                                                growable: true,
                                                (index) {
                                                  final shift = profileController
                                                      .selectedShifts[index];
                                                  return Chip(
                                                    label: Text(
                                                      shift.name ?? '',
                                                      style: robotoMedium
                                                          .copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .textTheme
                                                                    .bodyLarge
                                                                    ?.color,
                                                          ),
                                                    ),
                                                    labelPadding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 0,
                                                        ),
                                                    deleteIcon: Icon(
                                                      Icons.close,
                                                      size: 18,
                                                      color: Theme.of(context)
                                                          .textTheme
                                                          .bodyLarge
                                                          ?.color,
                                                    ),
                                                    onDeleted: () {
                                                      profileController
                                                          .removeShift(shift);
                                                    },
                                                    backgroundColor:
                                                        Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                              alpha: 0.3,
                                                            ),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            Dimensions
                                                                .radiusExtraLarge,
                                                          ),
                                                      side: BorderSide(
                                                        color: Theme.of(context)
                                                            .disabledColor
                                                            .withValues(
                                                              alpha: 0.01,
                                                            ),
                                                      ),
                                                    ),
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: Dimensions
                                                              .paddingSizeExtraSmall,
                                                          vertical: 4,
                                                        ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        )
                                      : SizedBox.shrink(),

                                  const SizedBox(
                                    height: Dimensions.paddingSizeSmall,
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),

                CustomButtonWidget(
                  isLoading: profileController.isLoading,
                  buttonText: 'update_profile'.tr,
                  onPressed: () => _updateProfile(profileController),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateProfile(ProfileController profileController) async {
    String firstName = _firstNameController.text.trim();
    String lastName = _lastNameController.text.trim();
    String email = _emailController.text.trim();
    String phoneNumber = PhoneNumberHelper.normalizeLocal(
      _phoneController.text,
    );
    if (profileController.profileModel!.fName == firstName &&
        profileController.profileModel!.lName == lastName &&
        profileController.profileModel!.phone == phoneNumber &&
        profileController.profileModel!.email == _emailController.text &&
        profileController.pickedFile == null) {
      showCustomSnackBar('change_something_to_update'.tr);
    } else if (firstName.isEmpty) {
      showCustomSnackBar('enter_your_first_name'.tr);
    } else if (lastName.isEmpty) {
      showCustomSnackBar('enter_your_last_name'.tr);
    } else if (email.isEmpty) {
      showCustomSnackBar('enter_email_address'.tr);
    } else if (!GetUtils.isEmail(email)) {
      showCustomSnackBar('enter_a_valid_email_address'.tr);
    } else if (phoneNumber.isEmpty) {
      showCustomSnackBar('enter_phone_number'.tr);
    } else if (!PhoneNumberHelper.isValidLocalMobile(phoneNumber)) {
      showCustomSnackBar('enter_a_valid_phone_number'.tr);
    } else if (widget.profileModel.earnings == 1 &&
        profileController.selectedShifts.isEmpty) {
      showCustomSnackBar('please_select_shifts'.tr);
    } else {
      ProfileModel updatedUser = ProfileModel(
        fName: firstName,
        lName: lastName,
        email: email,
        phone: phoneNumber,
        shiftIds: profileController.getSelectedShiftIds(),
      );
      await profileController.updateUserInfo(
        updatedUser,
        Get.find<AuthController>().getUserToken(),
      );
    }
  }
}
