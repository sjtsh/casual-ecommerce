import 'package:ezdeliver/screen/component/helper/exporter.dart';
import 'package:ezdeliver/screen/models/categoryModel.dart';
import 'package:ezdeliver/screen/models/productModel.dart';
import 'package:ezdeliver/screen/others/customApp.dart';
import 'package:ezdeliver/screen/users/model/addressmodel.dart';

import '../model/user.dart';

final userChangeProvider = ChangeNotifierProvider<UserService>((ref) {
  return UserService._();
});
const String userStorageKey = "user";

class UserService extends ChangeNotifier {
  UserService._() {
    load();
  }

  late final loggedInUser = Property<User?>(null, notifyListeners);
  final signInPhoneController = TextEditingController();
  final signInPasswordController = TextEditingController();
  final forgotPasswordPhoneController = TextEditingController();
  final signUpNameController = TextEditingController();
  final signUpPasswordController = TextEditingController();
  final signUpPhoneController = TextEditingController();
  final changeNumberPhoneController = TextEditingController();
  final changeNumberPasswordController = TextEditingController();
  bool loadingAll = false;
  load() async {
    final userJson = storage.read(userStorageKey);
    // print(userJson);
    if (userJson != null) {
      loggedInUser.value = User.fromJson(userJson);
      Future.delayed(const Duration(milliseconds: 10), () {});
    }
  }

  loadingallFuncation() {
    loadingAll = !loadingAll;
  }

  clearControllerLogin() {
    Utilities.futureDelayed(5, () {
      signInPhoneController.clear();
      signInPasswordController.clear();
    });
  }

  clearControllerSignup() {
    Utilities.futureDelayed(5, () {
      signUpPhoneController.clear();
      signUpPasswordController.clear();
      signUpNameController.clear();
    });
  }

  store() async {
    await storage.write(userStorageKey, loggedInUser.value!.toJson());
    // print(loggedInUser.value!.mobile);
  }

  checkProductAvailability(Map<String, dynamic> data) {
    var oldData = loggedInUser.value;
    var products = loggedInUser.value!.favourites.products;
    if (products.isNotEmpty) {
      var productInFavouriteIndex =
          products.indexWhere((element) => element.id == data["_id"]);

      if (productInFavouriteIndex != -1) {
        oldData!.favourites.products[productInFavouriteIndex].deactivated =
            data["deactivated"];
        loggedInUser.value = oldData;
      }
    }
  }

  addressAddTolocal() {
    var address = loggedInUser.value!.address;
    for (int index = 0; index < 2; index++) {
      if (index == 0 && address.isEmpty) {
        var addressSingle = AddressModel.empty();
        addressSingle.label = "Home";
        address.add(addressSingle);
      }
      if (index == 1 && address.length == 1) {
        if (address[index - 1].label == "Home") {
          var addressSingle = AddressModel.empty();
          addressSingle.label = "Work";
          address.add(addressSingle);
        } else {
          var addressSingle = AddressModel.empty();
          addressSingle.label = "Home";
          address.insert(0, addressSingle);
        }
      }
    }

    notifyListeners();
  }

  Future<bool> loginWithToken() async {
    var response =
        await Api.get(endpoint: "user/auth", successCode: 200, refresh: true);
    if (response != null) {
      // print(response.body);
      var temp = jsonDecode(response.body);
      // if (temp.role == Roles.user.index) {
      //   throw "Normal Users cannot login in Video Manager";
      //
      // print(temp["accessToken"]);
      print("token :${temp["accessToken"]}");
      loggedInUser.value!.accessToken = temp["accessToken"];
      // loggedInUser.value = temp
      //   ..refreshToken = loggedInUser.value?.refreshToken;

      await store();

      notifyListeners();
    }
    return false;
  }

  Future<bool> login(
      {required String phone,
      required String countryCode,
      required String password,
      required bool remember,
      required Map<String, dynamic> device}) async {
    var response = await Api.post(
      endpoint: "auth/login/user",
      body: jsonEncode({
        "phone": phone,
        "password": password,
        "device": device,
        "countryCode": countryCode
      }),
      successCode: 200,
    );

    if (response != null) {
      var temp = userFromJson(response.body);
      // if (temp.role == Roles.user.index) {
      //   throw "Normal Users cannot login in Video Manager";
      // }
      loggedInUser.value = temp;
      if (remember) {
        addressAddTolocal();
        await store();
      }

      notifyListeners();
      return true;
    }
    return false;
  }

  logoutFromServer() async {
    try {
      var deviceInfo = await CustomDeviceInfo.getDeviceInfo();
      // print(deviceInfo?.deviceId);
      var response = await Api.get(
        endpoint: "user/logout/${deviceInfo?.deviceId}",
        successCode: 200,
      );

      if (response != null) {
        CustomKeys.ref.read(customSocketProvider).disconnect();
        // CustomKeys.ref.read(customSocketProvider).;
        Utilities.futureDelayed(10, () {
          CustomApp.rebirth(CustomKeys.context);
          storage.erase();
        });
      }
    } catch (e) {
      CustomApp.rebirth(CustomKeys.context);
      storage.erase();
    }
  }

  Future<bool> register(
      {required String name,
      required String phone,
      required String countryCode,
      required String password,
      required Map<String, dynamic> device}) async {
    try {
      var response = await Api.post(
          endpoint: "user",
          body: jsonEncode({
            "name": name,
            "phone": phone,
            "countryCode": countryCode,
            "password": password,
            "device": device
          }),
          throwError: true);

      if (response != null) {
        var temp = userFromJson(response.body);
        loggedInUser.value = temp;
        addressAddTolocal();
        await store();

        notifyListeners();

        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> resetPassword(
      {bool reset = true,
      String? phone,
      required String password,
      String? oldPassword,
      String? uid}) async {
    var url = reset ? "auth/password/user" : "user/password";
    print(url);
    print(oldPassword);
    var response = await Api.put(
      endpoint: url,
      body: reset
          ? jsonEncode({"phone": phone, "password": password, "uid": uid})
          : jsonEncode(
              {"newPassword": password, "currentPassword": oldPassword}),
    );

    if (response != null) {
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> changeNUmber({
    required String phone,
    required String password,
  }) async {
    var url = "user/phone";
    print(url);
    print(phone);
    print(password);
    var response = await Api.put(
      endpoint: url,
      body: jsonEncode({
        "phone": phone,
        "password": password,
      }),
    );

    if (response != null) {
      loggedInUser.value!.phone = phone;
      await store();
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> addAddress({
    required AddressModel address,
  }) async {
    try {
      var response = await Api.post(
        endpoint: "user/address",
        successCode: 200,
        body: jsonEncode(
          {
            "fullName": address.fullName,
            "phone": address.phone,
            "address": address.address,
            "fullAddress": address.fullAddress,
            "label": address.label,
            "location": address.location,
          },
        ),
      );
      // print(response!.body);
      if (response != null) {
        var temp = addressModelFromJson(response.body);
        // if (temp.role == Roles.user.index) {
        //   throw "Normal Users cannot login in Video Manager";
        // }
        loggedInUser.value!.address.clear();
        loggedInUser.value!.address = temp;
        addressAddTolocal();
        await store();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  bool checkProductFavourite(String id) {
    if (loggedInUser.value != null) {
      for (var element in loggedInUser.value!.favourites.products) {
        if (element.id == id) {
          return true;
        }
      }
    }
    return false;
  }

  bool checkCategoryFavourite(String id) {
    if (loggedInUser.value != null) {
      for (var element in loggedInUser.value!.favourites.categories) {
        if (element.id == id) {
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> addToFavourite({Product? product, Category? category}) async {
    try {
      var response = await Api.put(
          endpoint:
              "user/favourite/${product != null ? "product" : "category"}",
          body: jsonEncode(
              {"id": "${product != null ? product.id : category?.id}"}));
      if (response != null) {
        if (product != null) {
          // product.favourite = true;
          Product prod = product.copyWith(
              limit: product.limit,
              id: product.id,
              name: product.name,
              price: product.price,
              weight: product.weight,
              sku: product.sku,
              unit: product.unit,
              category: product.category,
              productId: null,
              favourite: true);
          if (loggedInUser.value!.favourites.categories
                  .indexWhere((element) => element.id == product.id) ==
              -1) {
            loggedInUser.value!.favourites.products.add(prod);
            notifyListeners();
          }

          await store();
        } else {
          // category!.favourite = true;
          Category cat = category!.copyWith(
              id: category.id,
              name: category.name,
              image: category.image,
              categoryId: null,
              favourite: true);
          if (loggedInUser.value!.favourites.categories
                  .indexWhere((element) => element.id == cat.id) ==
              -1) {
            loggedInUser.value!.favourites.categories.add(cat);
            notifyListeners();
          }
          await store();
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      // snack.error(e);
      rethrow;
      // return false;
    }
  }

  Future<bool> removeFromFavourite(
      {Product? product, Category? category}) async {
    var response = await Api.delete(
        endpoint: "user/favourite/${product != null ? "product" : "category"}",
        body: jsonEncode(
            {"id": "${product != null ? product.id : category?.id}"}));
    if (response != null) {
      if (product != null) {
        // int index = CustomKeys.ref
        //     .read(productCategoryServiceProvider)
        //     .trendingProducts!
        //     .indexWhere((element) => element.id == product.id);

        // CustomKeys.ref
        //     .read(productCategoryServiceProvider)
        //     .trendingProducts![index]
        //     .favourite = false;
        // print(product.id);

        loggedInUser.value!.favourites.products
            .removeWhere((e) => e.id == product.id);

        await store();
      } else {
        loggedInUser.value!.favourites.categories
            .removeWhere((e) => e.id == category!.id);
        await store();
      }
      notifyListeners();
      return true;
    } else {
      return false;
    }
  }

  Future<bool?> checkUser(String phone, String countryCode) async {
    // print("here");
    var response =
        await Api.get(endpoint: "auth/user?phone=$phone&code=$countryCode");
    if (response != null) {
      var decodedData = jsonDecode(response.body);
    
      
      return decodedData["newUser"];
    } else {
      return null;
    }
  }

  Future<bool> editAddress({
    required AddressModel address,
  }) async {
    // print(address.saved);
    try {
      var response = await Api.put(
        endpoint: "user/address/${address.id}",
        body: jsonEncode(
          {
            "fullName": address.fullName,
            "phone": address.phone,
            "address": address.address,
            "label": address.label,
          },
        ),
      );

      // print(response!.body);
      if (response != null) {
        var index = loggedInUser.value!.address
            .indexWhere((element) => element.id == address.id);
        if (index > -1) loggedInUser.value!.address[index] = address;
        addressAddTolocal();
        await store();

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> deleteAddress({
    required String id,
  }) async {
    var response = await Api.delete(endpoint: "user/address/$id");

    if (response != null) {
      var temp = addressModelFromJson(response.body);

      loggedInUser.value!.address.clear();
      loggedInUser.value!.address = temp;
      addressAddTolocal();
      await store();

      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> deleteAccount({required BuildContext context}) async {
    try {
      var response =
          await Api.delete(endpoint: "user/${loggedInUser.value!.id}");

      if (response != null) {
        logout(context);
        snack.success("Account deleted");
        notifyListeners();
        return true;
      }
    } catch (e) {
      snack.error(e.toString());
    }
    return false;
  }

  userUpdateRating(double avgRating, int count) {
    loggedInUser.value!.avgRating = avgRating.toDouble();
    loggedInUser.value!.rateCount = count;
    store();
    notifyListeners();
  }
}

class Property<T> {
  Property(T initialValue, this.notifyListeners) {
    _value = initialValue;
  }

  late T _value;
  final void Function() notifyListeners;

  T get value => _value;

  set value(T value) {
    if (_value != value) {
      _value = value;
      notifyListeners();
    }
  }
}
