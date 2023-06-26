import 'package:ezdeliver/screen/component/helper/exporter.dart';
// import 'package:ezdeliver/screen/component/socket/socket.dart';
// import 'package:ezdeliver/screen/orderHistory/services/orderHistoryService.dart';
// import 'package:ezdeliver/screen/users/component/userservice.dart';
// import 'package:ezdeliver/services/location.dart';

// import 'package:ezdeliver/services/pushnotification/pushnotification.dart';

class CustomApp extends ConsumerStatefulWidget {
  final Widget child;
  const CustomApp({Key? key, required this.child}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _CustomAppState();

  static rebirth(BuildContext context) {
    context.findAncestorStateOfType<_CustomAppState>()!.restartApp();
  }
}

class _CustomAppState extends ConsumerState<CustomApp> {
  Key _key = UniqueKey();

  void restartApp() {
    setState(() {
      _key = UniqueKey();
    });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: _key,
      child: widget.child,
    );
  }
}
