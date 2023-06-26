import 'package:flutter/material.dart';

class AppButtonPrimary extends StatefulWidget {
  final Function? onPressedFunction;
  final Function? onDisabledPressed;
  final String? text;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? buttonColor;
  final double? borderRadius;
  final bool? isdisable;

  const AppButtonPrimary(
      {Key? key,
      required this.onPressedFunction,
      this.onDisabledPressed,
      required this.text,
      this.icon,
      this.width,
      this.height,
      this.buttonColor,
      this.borderRadius,
      this.isdisable})
      : super(key: key);

  @override
  State<AppButtonPrimary> createState() => _AppButtonPrimaryState();
}

class _AppButtonPrimaryState extends State<AppButtonPrimary> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      disabledColor: Theme.of(context).primaryColor.withOpacity(0.5),
      onPressed: () async {
        if (isLoading == false) {
          setState(() => isLoading = true);
          try {
            if (widget.isdisable ?? false) {
              if (widget.onDisabledPressed != null) {
                Future.value(await widget.onDisabledPressed!())
                    .timeout(const Duration(seconds: 15));
              }
            } else {
              if (widget.onPressedFunction != null) {
                Future.value(await widget.onPressedFunction!())
                    .timeout(const Duration(seconds: 15));
              }
            }
          } on Exception catch (_, e) {
            print("$e $_");
          }
          if (mounted) {
            setState(() => isLoading = false);
          }
        }
      },
      splashColor: Theme.of(context).splashColor,
      color:( widget.isdisable ?? false)
          ? Theme.of(context).primaryColor.withOpacity(0.5)
          : Theme.of(context).primaryColor,
      textTheme: ButtonTextTheme.primary,
      minWidth: widget.width ?? 200,
      height: widget.height ?? 46,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 3)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          widget.icon == null
              ? Container()
              : Row(
                  children: [
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                  ],
                ),
          isLoading
              ? const Center(
                  child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      )),
                )
              : Text(
                  widget.text ?? "does something",
                  textAlign: TextAlign.center,
              style:Theme.of(context).textTheme.bodyText1?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
        ],
      ),
    );
  }
}
