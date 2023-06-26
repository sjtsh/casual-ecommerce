import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/CustomTheme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppDropDown extends StatelessWidget {
  final List? selectedItemBuilder;
  final Function(dynamic)? onchanged;
  final dynamic value;
  final double? hPadding;
  final double? borderRadius;
  final double? buttonWidth;
  final double? buttonHeight;
  final Color? buttonColor;
  final Color? textColor;
  final Color? iconEnabledColor;
  final String? hintText;
  final double? hintFontSize;
  final bool error;
  final double? iconSize;
  final IconData? dropdownIcon;
  final double? textWidth;
  final double? paddingRight;
  final double? paddingLeft;
  final Color? hintTextColor;
  final Color? iconColor;

  const AppDropDown(
      {Key? key,
      this.selectedItemBuilder,
      this.onchanged,
      this.value,
      this.hPadding,
      this.borderRadius,
      this.buttonWidth,
      this.buttonHeight,
      this.buttonColor,
      this.textColor,
      this.iconEnabledColor,
      this.hintText,
      this.hintTextColor,
      this.hintFontSize,
      this.error = false,
      this.iconSize,
      this.dropdownIcon,
      this.iconColor,
      this.paddingRight,
      this.paddingLeft,
      this.textWidth})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hPadding ?? 0),
      child: DropdownButtonHideUnderline(
        child: DropdownButton2(
          hint: Text(
            hintText ?? "",
            style: TextStyle(
              color: hintTextColor ?? Colors.black,
            ),
          ),
          buttonDecoration: BoxDecoration(
            color: buttonColor ?? Theme.of(context).primaryColor,
            border: Border.all(
                color: error
                    ? Colors.red
                    : Theme.of(context).primaryColor.withOpacity(.33),
                width: error ? 2 : 1),
            borderRadius: BorderRadius.circular(borderRadius ?? 0),
          ),
          selectedItemBuilder: (cxt) {
            return ((selectedItemBuilder ?? [])
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: SizedBox(
                      // width: textWidth ?? 50,
                      child: Text(
                        item.toString(),
                        overflow: TextOverflow.ellipsis,
                        style:  textColor!=null ? TextStyle(color: Colors.white) :Theme.of(context).textTheme.bodyText1,
                      ),
                    ),
                  ),
                )
                .toList());
          },
          items: ((selectedItemBuilder ?? []).map((item) {
            return DropdownMenuItem(
                value: item,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(item.toString())));
          }).toList()),
          value: value,
          onChanged: onchanged,
          offset: const Offset(0, 3),
          buttonHeight: buttonHeight ?? 40,
          buttonWidth: buttonWidth,
          buttonPadding: EdgeInsets.only(
              right: paddingRight ?? 14, left: paddingLeft ?? 14),
          icon: Icon(dropdownIcon ?? Icons.arrow_drop_down,
              color:iconColor??  Theme.of(context).primaryColor),
          iconSize: iconSize ?? 26,
// iconDisabledColor: Colors.black,
          iconEnabledColor: iconEnabledColor ?? Colors.white,
          itemHeight: 40,
          selectedItemHighlightColor:
              Theme.of(context).primaryColor.withOpacity(0.3),
          dropdownMaxHeight: 200,
          scrollbarAlwaysShow: true,
          scrollbarThickness: 0,
          dropdownDecoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topRight: Radius.zero,
              topLeft: Radius.zero,
              bottomRight: Radius.circular(4),
              bottomLeft: Radius.circular(4),
            ),
            color: context.watch<CustomTheme>().isDarkMode
                ? ColorPalette.darkContainerColor
                : Colors.white,
          ),
        ),
      ),
    );
  }
}
