import 'package:ezdelivershop/BackEnd/Services/OtpService/OtpService.dart';
import 'package:ezdelivershop/StateManagement/DeliveryRadiusManagement.dart';
import 'package:ezdelivershop/StateManagement/EditProductManagement.dart';
import 'package:ezdelivershop/StateManagement/ResetPasswordManageMent.dart';
import 'package:ezdelivershop/StateManagement/SignUpAndCameraManagement.dart';
import 'package:ezdelivershop/StateManagement/SplashScreenManagement.dart';
import 'package:ezdelivershop/StateManagement/StartDeliveryManagement.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../Components/CustomTheme.dart';
import '../StateManagement/NotSearchingProductManagement.dart';
import '../StateManagement/ProductShopManagement.dart';
import '../StateManagement/SearchingProductManagement.dart';
import '../StateManagement/SignInManagement.dart';

Widget withProvider({required Widget child}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ProductShopManagement()),
      ChangeNotifierProvider(create: (_) => TabProduct()),
      ChangeNotifierProvider(create: (_) => NotSearchingProductManagement()),
      ChangeNotifierProvider(create: (_) => SearchingProductManagement()),
      // ChangeNotifierProvider(create: (_) => SignUpAndCameraManagement()),
      ChangeNotifierProvider(create: (_) => DeliveryRadiusManagement()),
      ChangeNotifierProvider(create: (_) => CustomTheme()),
      ChangeNotifierProvider(create: (_) => ResetPasswordManagement()),
      ChangeNotifierProvider(create: (_) => OtpService()),
      ChangeNotifierProvider(create: (_) => SplashScreenManagement()),
      ChangeNotifierProvider(create: (_) => EditProductManagement()),
      ChangeNotifierProvider(create: (_) => SignInManagement()),
      // ChangeNotifierProvider(create: (_) => StartDeliveryManagement()),
    ],
    child: child,
  );
}
