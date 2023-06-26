import 'dart:async';


enum MessageType { success, error, info }

class ExceptionHandling {
  // static Color successBackground = const Color(0xffC9DCCD);
  // static Color successColor = const Color(0xff28A745);
  // static Color infoBackground = const Color(0xffCDD2D6);
  // static Color infoColor = const Color(0xff40667D);
  // static Color errorBackground = const Color(0xffE4CBCD);
  // static Color errorColor = const Color(0xffDC3545);

  static Future<bool> catchExceptions({required Function() function}) async {
    try {
      await function();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
