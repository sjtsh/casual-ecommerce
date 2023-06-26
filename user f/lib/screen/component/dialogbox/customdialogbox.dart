import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CustomDialogBox {
  CustomDialogBox._();

  static confirm(Function onConfirm) {
    final context = CustomKeys.navigatorkey.currentContext!;
    dailog(
        context,
        CustomDialog(
            elevatedButtonText: "Ok",
            onPressedElevated: () {
              onConfirm();
            }));
  }

  static alertMessage(Function onConfirm,
      {required String title, required String message}) async {
    final context = CustomKeys.navigatorkey.currentContext!;
    await dailog(
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

  static loading(bool show, {BuildContext? c}) {
    final context = c ?? CustomKeys.navigatorkey.currentContext!;
    final Widget child = Center(
      child: SizedBox(
          width: 20.sr(),
          height: 20.sr(),
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

  static dailog(BuildContext context, Widget widget,
      {bool barrier = true}) async {
    await showDialog(
        barrierDismissible: barrier,
        barrierColor: Theme.of(context).primaryColor.withOpacity(0.1),
        context: context,
        builder: (_) {
          return widget;
        });
  }
}

class CustomDialog extends StatelessWidget {
  CustomDialog(
      {Key? key,
      this.outlinedButtonText = 'Cancel',
      this.elevatedButtonText = "Confrim",
      required this.onPressedElevated,
      this.onCancel,
      this.width,
      this.height,
      this.textFirst = 'Are you sure you want to ',
      this.textSecond = '',
      this.title})
      : super(key: key);

  String elevatedButtonText, textFirst, textSecond;
  String? title;
  final String? outlinedButtonText;
  final Function onPressedElevated;
  final Future<bool> Function()? onCancel;
  double? width, height;

  // double defaultHeight = 31.4.sh();
  // double defaultWidth = 86.02.sh();

  @override
  Widget build(BuildContext context) {
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
            margin: EdgeInsets.symmetric(horizontal: 20.sw()),
            // height: 160.sh(),
            // width: size.width.sw() - 50.sw(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(7.sr()),
              color: Theme.of(context).backgroundColor,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 40.sw(),
                vertical: 27.sh(),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (title != null) ...[
                    Text(
                      title!,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    SizedBox(
                      height: 13.sh(),
                    ),
                  ],
                  Text(
                    textFirst + textSecond,
                    textAlign: TextAlign.center,
                    style: kTextStyleInterRegular.copyWith(
                      fontSize: 18.ssp(),
                      color: CustomTheme.greyColor,
                    ),
                  ),
                  SizedBox(
                    height: 23.sh(),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (outlinedButtonText != null) ...[
                        CustomOutlinedButton(
                          borderColor: Theme.of(context).primaryColor,
                          // width: width ?? defaultWidth,
                          // height: height ?? defaultHeight,
                          outlinedButtonText: outlinedButtonText!,
                          onPressedOutlined: () {
                            Navigator.pop(context);
                          },
                        ),
                        SizedBox(
                          width: 40.98.sw(),
                        ),
                      ],
                      CustomElevatedButton(
                        color: Theme.of(context).primaryColor,
                        // width: width ?? defaultWidth,
                        // height: height ?? defaultHeight,
                        onPressedElevated: () {
                          onPressedElevated();
                          Navigator.pop(context);
                        },
                        elevatedButtonText: elevatedButtonText,
                        // elevatedButtonTextStyle:
                        //     Theme.of(context).textTheme.bodyText2!.copyWith(
                        //           fontSize: 16.ssp(),
                        //           color: Colors.white,
                        //         ),
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
