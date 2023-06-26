import 'package:ezdeliver/screen/cart/cart.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/others/breakpoint.dart';
import 'package:ezdeliver/web/home/homepage.dart';

class WebHolder extends ConsumerStatefulWidget {
  const WebHolder({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _WebHolderState();
}

class _WebHolderState extends ConsumerState<WebHolder> {
  @override
  void initState() {
    super.initState();
    ref.read(locationServiceProvider).setCurrentLocation(
        location: CustomLocation.emptyPosition(
            latlng: const LatLng(27.708189, 85.318942)));
    BreakPoint.context = context;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
        key: CustomKeys.webScaffoldKey,
        endDrawer: SizedBox(
            width: 450.sw(),
            child: const Cart(
              newScreen: true,
            )),
        body: HomePage(
          size,
        ));
  }
}
