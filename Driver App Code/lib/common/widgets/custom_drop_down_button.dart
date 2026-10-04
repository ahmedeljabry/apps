import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stackfood_multivendor_driver/util/dimensions.dart';
import 'package:stackfood_multivendor_driver/util/styles.dart';

class CustomDropdownButton<T> extends StatefulWidget {
  final List<String>? items;
  final bool showTitle;
  final bool isBorder;
  final String? hintText;
  final double? borderRadius;
  final double? borderWidth;
  final Color? backgroundColor;
  final Color? borderColor;
  final Function(T?)? onChanged;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;
  final FontWeight? titleFontWeight;
  final T? selectedValue;
  final List<DropdownItem<T>>? dropdownMenuItems;
  final List<Widget> Function(BuildContext)? selectedItemBuilder;

  const CustomDropdownButton({super.key, this.items, this.showTitle = true, this.isBorder = true, this.hintText, this.borderRadius,
    this.backgroundColor, this.onChanged, this.validator, this.onSaved, this.titleFontWeight, this.selectedValue,
    this.dropdownMenuItems, this.selectedItemBuilder, this.borderColor, this.borderWidth});

  @override
  State<CustomDropdownButton<T>> createState() => _CustomDropdownButtonState<T>();
}

class _CustomDropdownButtonState<T> extends State<CustomDropdownButton<T>> {
  late final ValueNotifier<T?> _valueListenable = ValueNotifier<T?>(widget.selectedValue);

  @override
  void didUpdateWidget(covariant CustomDropdownButton<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _valueListenable.value = widget.selectedValue;
    }
  }

  @override
  void dispose() {
    _valueListenable.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(widget.borderRadius ?? Dimensions.radiusDefault),
        border: Border.all(color: widget.borderColor ?? Theme.of(context).hintColor, width: widget.borderWidth??1),
      ),
      child: DropdownButtonFormField2<T>(
        isExpanded: true,
        valueListenable: _valueListenable,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeSmall),
          focusedBorder: _border(),
          enabledBorder: _border(),
          disabledBorder: _border(),
          focusedErrorBorder: _border(),
          errorBorder: _border(),
        ),
        hint: Text(widget.hintText ?? 'select_an_option'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault)),
        items: (widget.dropdownMenuItems ?? widget.items?.map((item) => DropdownItem<T>(
          value: item as T,
          child: Text(item.tr, style: robotoRegular.copyWith(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: Dimensions.fontSizeDefault)),
        )).toList()) ?? [
          DropdownItem<T>(
            value: null,
            child: Text('no_data_available'.tr, style: robotoRegular.copyWith(color: Theme.of(context).hintColor, fontSize: Dimensions.fontSizeDefault),
            ),
          )
        ],
        validator: widget.validator ?? (value) {
          if (value == null) {
            return 'please_select_an_option'.tr;
          }
          return null;
        },
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        selectedItemBuilder: widget.selectedItemBuilder,
        buttonStyleData: const FormFieldButtonStyleData(padding: EdgeInsets.only(right: 8)),
        iconStyleData: IconStyleData(icon: Icon(Icons.keyboard_arrow_down, color: Theme.of(context).hintColor)),
        dropdownStyleData: DropdownStyleData(
          maxHeight: 300,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
        ),
        menuItemStyleData: const MenuItemStyleData(padding: EdgeInsets.symmetric(horizontal: 16)),
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(widget.borderRadius ?? Dimensions.radiusDefault)),
      borderSide: BorderSide(width: 1, color: widget.isBorder ? Theme.of(context).hintColor.withValues(alpha: 0.2) : Colors.transparent),
    );
  }
}