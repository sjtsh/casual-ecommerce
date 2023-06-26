import 'package:ezdeliver/screen/cart/cart.dart';
import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/holder/holder.dart';
import 'package:ezdeliver/screen/profile/profilesettings.dart';
import 'package:ezdeliver/screen/search/searchService.dart';

class ResponsiveLayout {
  static bool get isDesktop =>
      MediaQuery.of(CustomKeys.context).size.width > 1000;
  static bool get isTablet =>
      MediaQuery.of(CustomKeys.context).size.width < 1000 &&
      MediaQuery.of(CustomKeys.context).size.width > 600;
  static bool get isMobile =>
      MediaQuery.of(CustomKeys.context).size.width < 600;

  static double margin([double factor = 0.10]) {
    return ResponsiveLayout.isMobile
        ? 0
        : ResponsiveLayout.isDesktop
            ? MediaQuery.of(CustomKeys.context).size.width * factor.sw()
            : MediaQuery.of(CustomKeys.context).size.width *
                factor.sw() *
                factor.sw();
  }

  static StateProvider<Widget> drawerWidgetProvider =
      StateProvider<Widget>((ref) {
    return const Cart(
      newScreen: true,
    );
  });

  static setWidget(Widget widget) {
    CustomKeys.ref.read(drawerWidgetProvider.notifier).state = widget;
  }

  static StateProvider<Widget> settingsWidgetProvider =
      StateProvider<Widget>((ref) {
    return ProfileSetting();
  });
  static setProfileWidget(Widget widget) {
    CustomKeys.ref.read(settingsWidgetProvider.notifier).state = widget;
  }

  static openCommonCart([bool? cart]) {
    if (cart != null) {
      setWidget(const Cart(
        newScreen: true,
      ));
    }
    CustomKeys.webScaffoldKey.currentState!.openEndDrawer();
  }

  // static StateProvider<Widget?> holderWidgetProvider =
  //     StateProvider<Widget?>((ref) {
  //   return defaultHolderWidget;
  // });

  static setHolderWidget(Widget? widget) {
    CustomKeys.ref.read(statelistProvider).holderwidget = widget;
    if (widget.toString() != "SearchPage") {
      CustomKeys.ref
          .read(
              CustomKeys.ref.read(searchServiceProvider).searchWebFieldProvider)
          .text = "";
    }
  }

  static Widget? defaultHolderWidget;
}

final statelistProvider = ChangeNotifierProvider<StatelistProvider>((ref) {
  return StatelistProvider();
});

class StatelistProvider extends ChangeNotifier {
  List<Widget> _holderwidgets = [];
  List<Widget> get holders => _holderwidgets;
  set holderwidget(Widget? widget) {
    if (widget == null) {
      _holderwidgets = [];
    } else {
      _holderwidgets.add(widget);
    }
    notifyListeners();
  }

  pop() {
    if (_holderwidgets.isNotEmpty) {
      _holderwidgets = [];
    } else {
      onBackPressed();
    }
    notifyListeners();
  }

  List<int> bottomTabsPressed = [0];
  DateTime? lastbackPressed;

  tabChanged(int i) {
    bottomTabsPressed.removeWhere((element) => element == i);
    bottomTabsPressed.add(i);
  }

  bool onBackPressed() {
    if (_holderwidgets.isNotEmpty) return false;
    if (bottomTabsPressed.length <= 1) return false;
    bottomTabsPressed.removeLast();
    handleNavigationClick(CustomKeys.context, bottomTabsPressed.last, null,
        throughPop: true);
    return true;
  }
}
