import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/holder.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';
import 'package:ezdeliver/screen/welcomeScreen/welcomeScreen.dart';
import 'package:ezdeliver/web/webHolder.dart';

final loginStateProvider = StateProvider<bool>((ref) {
  var user = storage.read("user");
  if (user != null) {
    ref.read(userChangeProvider);

    return true;
  }

  return false;
});

class Loader extends ConsumerStatefulWidget {
  const Loader({this.payload, super.key});
  final String? payload;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoaderState();
}

class _LoaderState extends ConsumerState<Loader> {
  @override
  void initState() {
    super.initState();
    initalSetup();
  }

  initalSetup() async {
    final isLogin = ref.read(loginStateProvider);
    // print(isLogin);
    CustomKeys.init(ref, context);
    // BreakPoint.context = context;
    // final remoteConfig = FirebaseRemoteConfig.instance;

    Future.delayed(const Duration(milliseconds: 2), () async {
      if (!isLogin) {
        Navigator.of(CustomKeys.navigatorkey.currentContext!).pushReplacement(
          MaterialPageRoute(
              settings: const RouteSettings(name: ""),
              builder: (context) {
                return UniversalPlatform.isWeb || UniversalPlatform.isDesktop
                    ? Holder(
                        payload: widget.payload,
                      )
                    : const WelcomeScreen();
              }),
        );
      } else {
        await ref.read(userChangeProvider).loginWithToken();
        Navigator.of(CustomKeys.navigatorkey.currentContext!).pushReplacement(
          MaterialPageRoute(
              settings: const RouteSettings(name: ""),
              builder: (context) {
                return
                    // UniversalPlatform.isWeb || UniversalPlatform.isDesktop
                    //     ? const WebHolder()
                    //     :
                    Holder(
                  payload: widget.payload,
                );
                // return Holder(
                //   payload: widget.payload,
                // );
              }),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Container());
  }
}
