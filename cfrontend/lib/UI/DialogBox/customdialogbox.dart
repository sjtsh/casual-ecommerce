import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/SpacePalette.dart';
import 'package:ezdelivershop/Components/Issue/IssueScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Components/CustomTheme.dart';
import '../../Components/Widgets/Button.dart';
import '../../Components/Widgets/ButtonOutline.dart';
import '../../Components/keys.dart';

class CustomDialogBox {
  CustomDialogBox._();

  static confirm(Function onConfirm) {
    final context = CustomKeys.context!;
    dailog(
        context,
        CustomDialog(
            elevatedButtonText: "Ok",
            onPressedElevated: () {
              onConfirm();
            }));
  }

  static alertMessage(Function onConfirm,
      {required String title, required String message}) {
    final context = CustomKeys.context!;
    dailog(
        context,
        CustomDialog(
          elevatedButtonText: "Ok",
          textFirst: title,
          textSecond: message,
          onCancel: () {
            return Future.value(false);
          },
          onPressedElevated: () {
            onConfirm();
          },
          outlinedButtonText: null,
        ));
  }

  static loading(bool show) {
    final context = CustomKeys.context!;
    final Widget child = Center(
      child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          )),
    );
    if (show) {
      dailog(context, child, barrier: false);
    } else {
      Navigator.pop(context);
    }
  }

  static dailog(BuildContext context, Widget widget, {bool barrier = true}) {
    showDialog(
        barrierDismissible: barrier,
        barrierColor: Theme.of(context).primaryColor.withOpacity(0.25),
        context: context,
        builder: (_) {
          return widget;
        });
  }

  static Widget force({required String title, required String message}) {
    return IssueScreen(
      image: "assets/issue/server_not_responding.png",
      title: title,
      subTitle: message,
    );
  }
}

class CustomDialog extends StatelessWidget {
  CustomDialog(
      {Key? key,
      this.outlinedButtonText = 'Cancel',
      required this.elevatedButtonText,
      required this.onPressedElevated,
      this.onCancel,
      this.width,
      this.height,
      this.containerHeight,
      this.textFirst = 'Are you sure you want to ',
      this.textSecond = '',
      this.noButtons = false})
      : super(key: key);

  final String elevatedButtonText, textFirst, textSecond;
  final String? outlinedButtonText;
  final Function() onPressedElevated;
  final Future<bool> Function()? onCancel;
  final double? width, height;
  final double? containerHeight;

  final double defaultHeight = 42;
  final double defaultWidth = 86;
  final bool noButtons;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: WillPopScope(
        onWillPop: () {
          if (onCancel == null) {
            return Future.value(true);
          } else {
            return Future.value(false);
          }
        },
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 30),
            height: containerHeight ?? (noButtons ? 100 : 180),
            decoration: BoxDecoration(
                color: context.watch<CustomTheme>().isDarkMode
                    ? ColorPalette.darkContainerColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    textFirst,
                    textAlign: TextAlign.center,
                    style: Theme.of(context)
                        .textTheme
                        .headline5
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  SpacePalette.spaceMedium,
                  Text(
                    textSecond,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                  const Spacer(),
                  noButtons
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            if (outlinedButtonText != null) ...[
                              Expanded(
                                child: AppButtonOutline(
                                  borderRadius: 4,
                                  width: width ?? defaultWidth,
                                  height: height ?? defaultHeight,
                                  onPressedFunction: () {
                                    if (onCancel != null) onCancel!();
                                    Navigator.of(context).pop(false);
                                  },
                                  text: outlinedButtonText,
                                ),
                              ),
                              // SizedBox(
                              //   width: 40.98,
                              // ),
                            ],
                            SpacePalette.spaceLarge,
                            Expanded(
                              child: AppButtonPrimary(
                                borderRadius: 4,
                                width: width ?? defaultWidth,
                                height: height ?? defaultHeight,
                                onPressedFunction: onPressedElevated,
                                text: elevatedButtonText,
                              ),
                            ),
                          ],
                        )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
