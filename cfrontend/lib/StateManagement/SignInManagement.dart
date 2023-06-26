import 'dart:async';
import 'package:ezdelivershop/BackEnd/ApiService.dart';
import 'package:ezdelivershop/BackEnd/Entities/Detail.dart';
import 'package:ezdelivershop/Components/keys.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../BackEnd/Services/AuthService.dart';
import '../Components/snackbar/customsnackbar.dart';
import 'NotSearchingProductManagement.dart';

class SignInManagement with ChangeNotifier, DiagnosticableTreeMixin {
  String? _printable;

  String? get printable => _printable;

  set printable(String? value) {
    _printable = value;
    notifyListeners();
  }

  bool success = true;

  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  String? mobileErrorText;
  String? passwordErrorText;
  bool _passwordVisible = false;
  bool _rememberMe = true;
  LoginData? _loginData;

  String? _authToken;
  String? refreshToken;

  // bool canStartRadiusChange = true;
  // double? startingRadius;

  String? get authToken => _authToken;
  String? loginDateTime;

  set authToken(String? value) {
    _authToken = value;
    notifyListeners();
  }

  Future getShopData() async {
    _loginData ??= await AuthService().getShop();
    print(_loginData?.staff.shop?.first.id);

    CustomKeys.messengerKey.currentContext!
            .read<NotSearchingProductManagement>()
            .shopId ??=
        _loginData?.staff.shop?.isEmpty ?? true
            ? null
            : _loginData?.staff.shop?.first.id;
    // if (_loginData?.staff?.shop?.openingTime != null &&
    //     _loginData?.staff?.shop?.openingTime != null) {
    //   checkShopTime(_loginData!.staff!.shop!.openingTime!,
    //       _loginData!.staff!.shop!.closingTime!);
    // }
    notifyListeners();
  }

  ///allow to login between opening and closing time
  //DateTime? openTime;
  //   DateTime? closeTime;
  // checkShopTime(DateTime openingTime, DateTime closingTime) {
  //   //2022-2-02 11:00:00
  //
  //   final now = DateTime.now();
  //   if (now.isBefore(openingTime)) {
  //     logout(CustomKeys.context!);
  //     CustomSnackBar().info("The store has not yet opened");
  //   } else if (now.isAfter(closingTime)) {
  //     logout(CustomKeys.context!);
  //     CustomSnackBar().info("The store is closed");
  //   }
  // }

  Future<void> logout(BuildContext context) async {
    if (await AuthService().isConnection()) {
      String? phoneNumber = _loginData?.user.phone;
      await AuthService().logout();
      await logoutFromWrongProduction(context);
      await SharedPreferences.getInstance()
          .then((value) => value.setString("phone", phoneNumber ?? ""));
    } else {
      CustomSnackBar().error("Could not log out");
    }
  }

  Future<void> logoutFromWrongProduction(BuildContext context) async {
    while (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    passwordController.clear();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    // OrderSocket.socket?.dispose();
    // OrderSocket.socket = null;
    // context.read<NewOrderManagement>().newDeliveryOrders = [];
    // context.read<NewOrderManagement>().newOrders = [];
    loginData = null;
    authToken = null;
    loginDateTime = null;
    refreshToken = null;
  }

  phoneValidation() {
    bool myPersonalValidation = false;
    RegExp intValid = RegExp(r'^([0-9]{10})+$');
    if (phoneController.text.trim() == "") {
      mobileErrorText = "Please enter Number";
    } else if (intValid.hasMatch(phoneController.text.trim())) {
      mobileErrorText = null;
      myPersonalValidation = true;
    } else {
      mobileErrorText = "Phone number must contain 10 digits";
    }
    notifyListeners();
    return myPersonalValidation;
  }

  passwordValidation() {
    if (passwordController.text.trim() == "" ||
        passwordController.text.isEmpty) {
      passwordErrorText = "Please enter password";
      notifyListeners();
    } else {
      passwordErrorText = null;
      notifyListeners();
    }
  }

  signInValidation() {
    bool myPersonalValidation = true;
    if (phoneController.text == "" || phoneController.text.isEmpty) {
      mobileErrorText = "Please username or phone";
      myPersonalValidation = false;
    } else {
      mobileErrorText = null;
      notifyListeners();
    }
    if (passwordController.text == "" || passwordController.text.isEmpty) {
      passwordErrorText = "Please enter password";
      myPersonalValidation = false;
      notifyListeners();
    } else {
      passwordErrorText = null;
      notifyListeners();
    }
    return myPersonalValidation;
  }

  bool get rememberMe => _rememberMe;

  set rememberMe(bool value) {
    _rememberMe = value;
    notifyListeners();
  }

  bool get passwordVisible => _passwordVisible;

  set passwordVisible(bool value) {
    _passwordVisible = value;
    notifyListeners();
  }

  LoginData? get loginData => _loginData;

  set loginData(LoginData? value) {
    _loginData = value;
    notifyListeners();
  }

  Future<void> setPrefs(
      String accessToken, String refreshToken, SharedPreferences prefs) async {
    await prefs.setString("token", accessToken);
    await prefs.setString("refresh_token", refreshToken);
  }

  getFromPrefs(SharedPreferences preferences) async {
    loginDateTime = preferences.getString("loginTime");
    if (loginDateTime != null) {
      if (loginDateTime.toString().substring(0, 10) !=
          DateTime.now().toString().substring(0, 10)) {
        CustomSnackBar().info("Session timeout, Please login again.");
        preferences.remove("token");
        preferences.remove("refresh_token");
        preferences.remove("loginTime");
        return;
      }
    }
    authToken = preferences.getString("token");
    refreshToken = preferences.getString("refresh_token");
    ApiService.authToken = authToken;
    ApiService.refreshToken = refreshToken;
  }

// flipSwitchStatus(bool value, BuildContext context) {
//   if (shop?.categories.isEmpty ?? true) {
//     StaticService.showDialogBox(
//         context: context,
//         child: CustomDialog(
//           containerHeight: 170,
//           elevatedButtonText: "OK",
//           textFirst: "Cannot turn on?",
//           textSecond:
//               "You need to select at least one category in order to start receiving orders",
//           onPressedElevated: () {
//             Navigator.pop(context);
//             StaticService.pushPage(
//                 context: context,
//                 route: CategoriesScreenBuilder(
//                     context.read<SignInManagement>().shop!.categories,
//                     isFromSignup: false));
//           },
//         ));
//     return;
//   }
//   if (!value) {
//     StaticService.showDialogBox(
//         context: context,
//         child: CustomDialog(
//             containerHeight: 170,
//             outlinedButtonText: "Cancel",
//             elevatedButtonText: "OK",
//             textFirst: "Are you sure?",
//             textSecond: "You won't be able to get new orders.",
//             onPressedElevated: () {
//               context.read<SignInManagement>().changeAvailability(value);
//               ExceptionHandling.catchExceptions(
//                   function: () async =>
//                       await AuthService().shopAvailability(value));
//               Navigator.of(context).pop();
//             }));
//   } else {
//     context.read<SignInManagement>().changeAvailability(value);
//     ExceptionHandling.catchExceptions(function: () async {
//       await AuthService().shopAvailability(value);
//     });
//     NewOrderManagement newManagement = context.read<NewOrderManagement>();
//     OrderService()
//         .getNewOrder()
//         .then((value) => newManagement.newOrders = value);
//   }
// }
}
