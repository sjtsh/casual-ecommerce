import 'package:ezdeliver/mainApp.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';

import 'package:flutter_web_plugins/flutter_web_plugins.dart'
    if (dart.library.io) 'package:ezdeliver/screen/component/fakeclass.dart';
import 'package:ezdeliver/screen/others/customApp.dart';

void main() async {
  // storage.erase();
  var payload = await Pasalko.initialize();
  if (UniversalPlatform.isWeb) setUrlStrategy(PathUrlStrategy());
  runApp(CustomApp(
      child: ProviderScope(
          child: MainApp(
    payload: payload,
  ))));
}
