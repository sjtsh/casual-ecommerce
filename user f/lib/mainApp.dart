import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/loader/loader.dart';
import 'package:flutter/gestures.dart';

class MainApp extends ConsumerStatefulWidget {
  const MainApp({this.payload, super.key});
  final String? payload;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MainAppState();
}
//{"a":"b", "0":true}

class _MainAppState extends ConsumerState<MainApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    CustomKeys.appState = WidgetsBinding.instance.lifecycleState;

    // internetCheck.onStatusChange.listen((event) {
    //   if (InternetConnectionStatus.connected == event) {
    //     if (!Api.hasInternet) {
    //       Api.setInternetStatus(true);
    //     }
    //   } else {
    //     Api.setInternetStatus(false);
    //   }
    // });
    if (!UniversalPlatform.isWeb && !UniversalPlatform.isDesktop) {
      cloudMessaging.init();
    }
    CustomKeys.navigatorkey = GlobalKey<NavigatorState>();
    CustomKeys.messengerKey = GlobalKey<ScaffoldMessengerState>();
    // CustomKeys.context = context;
    CustomKeys.ref = ref;
    CustomKeys.cartKey = GlobalKey();
    CustomKeys.cartAppBarKey = GlobalKey();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    CustomKeys.appState = WidgetsBinding.instance.lifecycleState;
    if (state == AppLifecycleState.inactive) {
      print('app inactive');
    } else if (state == AppLifecycleState.resumed) {
      // }

      try {
        var themeService = ref.read(customThemeServiceProvider);
        themeService.switchThemeMode(themeService.themeMode);
        if (ref.read(userChangeProvider).loggedInUser.value != null) {
          Utilities.futureDelayed(5, () async {
            // await CustomLocation.determinePosition();

            var permission = await Geolocator.checkPermission();
            if (permission == LocationPermission.always ||
                permission == LocationPermission.whileInUse) {
              var address = ref.read(locationServiceProvider).currentAddress;
              ref.read(locationServiceProvider).setCurrentLocation(
                  location: address != null
                      ? CustomLocation.emptyPosition(
                          latlng: LatLng(address.location.coordinates.last,
                              address.location.coordinates.first))
                      : null);
            } else {
              CustomLocation.locationPermissionDialog("Goto to App Settings",
                  "Location permission denied\nLocation permission is required for this app.",
                  function: () async {
                await Geolocator.openAppSettings();
              }, permissions: permission);
            }
            CustomCloudMessaging.requestPermission();
          });

          // ref.read(productCategoryServiceProvider).fetchTrendingProducts();

          // ref.read(locationServiceProvider).setCurrentLocation();
          ref.read(cartServiceProvider).loadCart();
          ref.read(orderHistoryServiceProvider).fetchOrders(clear: true);
          // ref.read(customSocketProvider).connect();
          // if (productCategoryService.selectedCategory != null) {
          //   productCategoryService
          //       .selectCategory(productCategoryService.selectedCategory!);
        }
      } catch (e) {
        print(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final thememode = ref.watch(customThemeServiceProvider).themeMode;

    return ScreenUtilInit(
      // designSize: UniversalPlatform.isAndroid
      //     ? const Size(390, 844)
      //     : const Size(1920, 1080),
      designSize: const Size(390, 844),

      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          scrollBehavior: MyCustomScrollBehavior(),
          navigatorKey: CustomKeys.navigatorkey,

          // scaffoldMessengerKey:,
          debugShowCheckedModeBanner: false,
          title: 'Faasto',
          // initialRoute: '/',
          // themeMode: thememode,
          themeMode: thememode,
          darkTheme: CustomTheme.darkTheme,
          theme: CustomTheme.lightTheme,
          home: Loader(
            payload: widget.payload,
          ),
          initialRoute: "/",

          // home: const Scaffold(body: Loader())
        );
      },
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
