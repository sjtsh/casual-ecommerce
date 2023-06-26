import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/shop.dart';
import 'package:ezdeliver/screen/others/geocoding.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

/// Determine the current position of the device.
///
/// When the location services are not enabled or permissions
/// are denied the `Future` will return an error.
///
///
///p

final locationServiceProvider = ChangeNotifierProvider<LocationService>((ref) {
  return LocationService._();
});

class LocationService extends ChangeNotifier {
  LocationService._();

  init(BuildContext context) async {
    Future.delayed(const Duration(milliseconds: 10), () async {
      if (CustomKeys.ref.read(userChangeProvider).loggedInUser.value != null) {
        LocationPermission permission = await Geolocator.checkPermission();

        if (!await Geolocator.isLocationServiceEnabled()) {
          permissionEnums = LocationPermissionEnums.notEnabled;
          notifyListeners();
          // Utilities.pushPage(const YourLocation(), 15);
        } else if (permission == LocationPermission.denied) {
          permissionEnums = LocationPermissionEnums.denied;
          notifyListeners();
          // Utilities.pushPage(const YourLocation(), 15);
        } else if (permission == LocationPermission.deniedForever) {
          permissionEnums = LocationPermissionEnums.deniedForever;
          notifyListeners();
          // Utilities.pushPage(const YourLocation(), 15);
        } else if (permission == LocationPermission.unableToDetermine) {
          permissionEnums = LocationPermissionEnums.unableToDetermine;
          notifyListeners();
          // Utilities.pushPage(const YourLocation(), 15);
        } else {
          // await setCurrentLocation();
        }
      } else {
        // await setCurrentLocation();
      }
    });
  }

  Position? _currentLocation;
  CustomAddressData? _currentAddressDetail;
  AddressModel? _selectedAddress;
  Position? get location => _currentLocation;
  CustomAddressData? get locationDetail => _currentAddressDetail;
  AddressModel? get currentAddress => _selectedAddress;

  LocationPermissionEnums permissionEnums = LocationPermissionEnums.always;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final landmarkController = TextEditingController();

  clearController() {
    nameController.clear();
    phoneController.clear();
    phoneController.clear();
  }

  changeLocationPermissionEnums(
      LocationPermissionEnums locationPermissionEnums) {
    permissionEnums = locationPermissionEnums;
    notifyListeners();
  }

  set currentAddress(AddressModel? model) {
    _selectedAddress = model;
    // print(currentAddress!.fullAddress);
    setCurrentLocation(
        location: model != null
            ? CustomLocation.emptyPosition(
                latlng: LatLng(model.location.coordinates.last,
                    model.location.coordinates.first))
            : null,
        addressData: CustomAddressData.fromAddressModel(model));
    notifyListeners();
  }

  setCurrentLocation(
      {Position? location,
      CustomAddressData? addressData,
      bool current = true}) async {
    Utilities.futureDelayed(200, () async {
      clear();
      if (location == null) {
        // CustomKeys.ref.read(productCategoryServiceProvider).clearAll();
        _currentLocation =
            await CustomLocation.determinePosition(current: current);
        if (_currentLocation != null) {
          permissionEnums = LocationPermissionEnums.always;
          // if (CustomKeys.ref.read(userChangeProvider).loggedInUser.value !=
          //     null) {
          Utilities.loadall();
        }

        await setCurrentLocationAddressDetails(
            location: _currentLocation,
            addressData: addressData,
            current: current);
        notifyListeners();
      } else {
        _currentLocation = location;
        Utilities.loadall();
        // await CustomKeys.ref
        //     .read(productCategoryServiceProvider)
        //     .fetchCategories();
        // await CustomKeys.ref
        //     .read(productCategoryServiceProvider)
        //     .fetchTrendingProducts();
        // await CustomKeys.ref
        //     .read(productCategoryServiceProvider)
        //     .fetchAllSubCategoriesWithProducts();
        await setCurrentLocationAddressDetails(
            current: current, location: location, addressData: addressData);
        notifyListeners();
      }
    });
  }

  setCurrentLocationAddressDetails(
      {Position? location,
      CustomAddressData? addressData,
      bool current = true}) async {
    final selecteDeliveryAddress =
        CustomKeys.ref.read(cartServiceProvider).selectedDeliveryAddress.value;
    if (addressData == null) {
      _currentAddressDetail = await CustomLocation.getAddressFromLocation(
          location: location, current: current);
    } else {
      var a = addressData;

      a.current = current;
      // print("current in setCurrentLocationAddressDetails:${a.current}");
      _currentAddressDetail = a;
      // print(
      //     "setCurrentLocationAddressDetails : ${_currentAddressDetail!.current}");
    }
    if (selecteDeliveryAddress != null) {
      CustomKeys.ref.read(cartServiceProvider).selectedDeliveryAddress.value =
          selecteDeliveryAddress.copyWith(
              current: current,
              location: Location(
                  coordinates: [location!.longitude, location.latitude]),
              address: _currentAddressDetail!.displayName.split(",").first,
              fullAddress: _currentAddressDetail!.displayName,
              label: "Temp");
    }
    notifyListeners();
  }

  clear() {
    _currentLocation = null;
    _currentAddressDetail = null;
    // _selectedAddress = null;
    notifyListeners();
  }

  Future<Location> getOrderLocation({Location? location}) async {
    Location orderLocation;
    if (currentAddress != null) {
      orderLocation = Location(
          type: "point",
          coordinates: currentAddress!.location.coordinates.reversed.toList());
    } else {
      orderLocation =
          Location(type: "point", coordinates: location!.coordinates);
    }
    return orderLocation;
  }
}

enum LocationPermissionEnums {
  always,
  notEnabled,
  denied,
  deniedForever,
  whileInUse,
  unableToDetermine
}

class CustomLocation {
  CustomLocation._();

  static Future<Position> determinePosition(
      {BuildContext? context, bool current = true}) async {
    bool serviceEnabled;
    LocationPermission permission = LocationPermission.always;
    final locationService = CustomKeys.ref.read(locationServiceProvider);

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      locationService
          .changeLocationPermissionEnums(LocationPermissionEnums.notEnabled);

      locationPermissionDialog("Open location settings",
          "Location Services disabled.\nLocation is required for this app.",
          permissions: permission);

      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      locationService
          .changeLocationPermissionEnums(LocationPermissionEnums.denied);

      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        CustomKeys.ref
            .read(locationServiceProvider)
            .changeLocationPermissionEnums(LocationPermissionEnums.denied);

        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // // your App should show an explanatory UI now.

        locationPermissionDialog("Click here to allow",
            "Location permission denied.\nLocation is required for this app.",
            function: locationService.setCurrentLocation(),
            permissions: permission);

        return Future.error('Location permissions are denied');
      }
    } else if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      if (CustomKeys.ref.read(locationServiceProvider).permissionEnums !=
          LocationPermissionEnums.deniedForever) {
        CustomKeys.ref
            .read(locationServiceProvider)
            .changeLocationPermissionEnums(
                LocationPermissionEnums.deniedForever);
      }

      // locationPermissionDialog("Open settings",
      //     "Location services are denied for this app. Allow them in settings",
      //     permissions: permission);
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    CustomKeys.ref
        .read(locationServiceProvider)
        .changeLocationPermissionEnums(LocationPermissionEnums.always);
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
  }

  static Future<dynamic> locationPermissionDialog(
      String elevatedtext, String text,
      {required LocationPermission permissions, Function? function}) {
    return showModalBottomSheet(
        context: CustomKeys.navigatorkey.currentState != null
            ? CustomKeys.navigatorkey.currentState!.context
            : CustomKeys.context,
        builder: (context) {
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: 22.sw(), vertical: 30.sh()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                InfoMessage.noLocation(
                    boldTitle: text.split("\n").first,
                    title: text.split("\n").last),
                SizedBox(
                  height: 40.sh(),
                ),
                CustomElevatedButton(
                    onPressedElevated: () {
                      if (function != null) {
                        function();
                      } else {
                        if (permissions == LocationPermission.deniedForever) {
                          Geolocator.openAppSettings();
                        } else {
                          Geolocator.openLocationSettings();
                        }
                      }
                      Navigator.pop(context);
                    },
                    elevatedButtonText: elevatedtext),
              ],
            ),
          );
        });
  }

  static Future<CustomAddressData?> getAddressFromLocation(
      {Position? location, bool current = true}) async {
    location ??= await determinePosition();

    CustomAddressData? address = await CustomGeoCoder.findDetails(location);
    if (address == null) return null;
    return address.copywith(current: current);
  }

  static emptyPosition({required LatLng latlng}) => Position(
      longitude: latlng.longitude,
      latitude: latlng.latitude,
      timestamp: DateTime.now(),
      accuracy: 1,
      altitude: 1,
      heading: 1,
      speed: 1,
      speedAccuracy: 1);
}
// 111.119.49.118