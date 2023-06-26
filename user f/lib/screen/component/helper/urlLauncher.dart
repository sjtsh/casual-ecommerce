import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:flutter/foundation.dart';
import 'package:ezdeliver/screen/component/fakeclass.dart'
    if (dart.library.js) "dart:js" as js;

Uri defaultUri = Uri(
    scheme: Uri.base.scheme,
    port: Uri.base.port,
    host: Uri.base.host,
    fragment: null,
    query: ''
    // fragment: 'numbers'
    );

Future<bool> launchApp(String packageName) async {
  if (kIsWeb) {
    js.context.callMethod("openLink", []);
    return true;
  } else {
    var url = Uri(
        scheme: 'https',
        host: 'play.google.com',
        path: 'store/apps/details',
        queryParameters: {"id": packageName}
        // fragment: 'numbers'
        );
    try {
      var newUrl =
          url.replace(scheme: "pasalko", host: "techwol", path: "", query: '');
      var canLaunch =
          await launchLink(uri: newUrl, mode: LaunchMode.externalApplication);
      if (!canLaunch) {
        return await launchLink(uri: url, blank: true);
      }
      return canLaunch;
    } catch (e) {
      return await launchLink(uri: url);
    }
  }
}

Future<bool> launchLink(
    {required Uri uri, bool blank = true, LaunchMode? mode}) async {
  if (await canLaunchUrl(uri)) {
    return await launchUrl(uri,
        mode: mode ?? LaunchMode.platformDefault,
        webOnlyWindowName: !blank ? "_self" : "_blank");
  } else {
    return false;
  }
}
