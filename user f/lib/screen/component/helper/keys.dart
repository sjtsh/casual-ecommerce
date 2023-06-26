import 'package:ezdeliver/screen/component/helper/exporter.dart';

class CustomKeys {
  CustomKeys._internal();
  static GlobalKey<NavigatorState> navigatorkey = GlobalKey<NavigatorState>();
  static late GlobalKey<ScaffoldMessengerState> messengerKey;
  static GlobalKey<ScaffoldState> webScaffoldKey = GlobalKey<ScaffoldState>();
  static late WidgetRef ref;
  static BuildContext get context => navigatorkey.currentContext!;
  static late GlobalKey cartKey, cartAppBarKey;
  static init(WidgetRef ref, context) {
    ref = ref;
    // context = context;
  }

  static AppLifecycleState? appState;
}
