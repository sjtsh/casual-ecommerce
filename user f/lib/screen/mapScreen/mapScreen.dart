import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/components/customAppBar.dart';
import 'package:ezdeliver/screen/yourLocation/components/map.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key, this.initialCoordinate});
  final LatLng? initialCoordinate;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: simpleAppBar(context, title: "Set Pin", search: false),
          body: MapWidget(
            pinMode: true,
            initialCoordinate: initialCoordinate,
          )),
    );
  }
}
