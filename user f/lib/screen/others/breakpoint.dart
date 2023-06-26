import 'package:ezdeliver/screen/component/helper/exporter.dart';

class BreakPoint {
  BreakPoint._internal();
  static late BuildContext context;
  static bool get isMobile {
    final size = MediaQuery.of(context).size;
    if (size.width < 640) return true;
    return false;
  }

  static bool get isTablet {
    final size = MediaQuery.of(context).size;
    if (size.width < 1007 && size.width > 640) return true;
    return false;
  }

  static bool get isDesktop {
    final size = MediaQuery.of(context).size;
    if (size.width > 1007) return true;
    return false;
  }
}
