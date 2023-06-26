import 'package:ezdeliver/screen/component/snackbar/snackbarcontents.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CustomSnackBar {
  Set<String> snackActive = {};

  state(String message, GlobalKey<ScaffoldMessengerState> s,
      BuildContext context) {
    s.currentState?.showSnackBar(SnackBar(
        // behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xffFFE8E8),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.sr())),
        duration: Duration(milliseconds: 100000),
        elevation: 0,
        content: CustomSnackBarContent(
          icon: Icons.cancel,
          message: message,
          color: CustomTheme.errorColor,
        )));
  }

  success(dynamic message, {BuildContext? c}) {
    showSnackBar(
        message: message,
        color: const Color(0xffEFFFF7),
        // snackbar: false,
        content: CustomSnackBarContent(
          icon: Icons.check_circle_outline,
          message: message.toString(),
          color: CustomTheme.successColor,
        ));
  }

  error(dynamic message, {BuildContext? c}) {
    showSnackBar(
        c: c,
        message: message.toString(),
        color: const Color(0xffFFE8E8),
        content: CustomSnackBarContent(
          icon: Icons.cancel,
          message: message.toString(),
          color: CustomTheme.errorColor,
        ));
  }

  info(dynamic message, {BuildContext? c}) {
    showSnackBar(
        message: message,
        color: const Color(0xffE1F1FF),
        content: CustomSnackBarContent(
          color: const Color(0xff1400FF),
          icon: Icons.info,
          message: message.toString(),
        ));
  }

  noInternet({BuildContext? c}) {
    showSnackBar(
        message: "No Internet Connection!",
        color: const Color(0xffFFE8E8),
        content: const CustomSnackBarContent(
          color: CustomTheme.errorColor,
          icon: Icons.info,
          message: "No Internet Connection!",
        ));
  }

  warning(dynamic message, {BuildContext? c}) {
    showSnackBar(
        message: message,
        color: const Color(0xffFFFAE0),
        content: CustomSnackBarContent(
          color: const Color(0xffFFC700),
          icon: Icons.warning,
          message: message.toString(),
        ));
  }

  Flushbar flushbar(message, {BuildContext? c}) {
    BuildContext context;
    if (c != null) {
      context = c;
    } else {
      context = CustomKeys.navigatorkey.currentContext!;
    }
    // ignore: avoid_single_cascade_in_expression_statements
    return Flushbar(
      reverseAnimationCurve: Curves.bounceIn,
      dismissDirection: FlushbarDismissDirection.VERTICAL,
      borderRadius: BorderRadius.circular(4.sr()),
      messageColor: const Color(0xff1400FF),
      backgroundColor: const Color(0xffE1F1FF),
      icon: const Icon(
        Icons.info,
        color: Color(0xff1400FF),
      ),
      animationDuration: const Duration(milliseconds: 15),
      flushbarPosition: FlushbarPosition.TOP,
      message: message,
      duration: const Duration(seconds: 1),
    )..show(context);
  }

  floatingNotification(dynamic message, Function onTap,
      {int duration = 100000, BuildContext? c}) {
    showSnackBar(
        message: message,
        color: const Color(0xffE1F1FF),
        duration: duration,
        snackbar: false,
        content: GestureDetector(
          onTap: () {
            onTap();
            ScaffoldMessenger.of(CustomKeys.context)
                .hideCurrentSnackBar(reason: SnackBarClosedReason.action);
          },
          child: CustomSnackBarContent(
            color: const Color(0xff1400FF),
            icon: Icons.info_outline,
            message: message.toString(),
          ),
        ));
  }

  Future showSnackBar(
      {required Widget content,
      required Color color,
      int duration = 100000,
      bool snackbar = true,
      required String message,
      BuildContext? c}) async {
    // CustomKeys()().ref!.read(snackVisibleProvider.state).state = true;
    BuildContext context;
    if (c != null) {
      context = c;
    } else {
      context = CustomKeys.navigatorkey.currentContext!;
    }
    if (snackActive.contains(message)) {
      return null;
    }
    snackActive.add(message);
    await ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          // behavior: SnackBarBehavior.floating,
          padding: EdgeInsets.symmetric(
            horizontal: 5.sw(),
            vertical: 0.sh(),
          ),
          backgroundColor: color,

          behavior:
              snackbar ? SnackBarBehavior.fixed : SnackBarBehavior.floating,
          margin: snackbar
              ? null
              : EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height -
                      kBottomNavigationBarHeight * 1.35),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.sr())),
          duration: Duration(milliseconds: snackbar ? 500 : duration),
          dismissDirection:
              snackbar ? DismissDirection.down : DismissDirection.up,
          elevation: 0,
          content: content,
        ))
        .closed;
    snackActive.remove(message);
    // CustomKeys()().ref!.read(snackVisibleProvider.state).state = false;
  }
}
