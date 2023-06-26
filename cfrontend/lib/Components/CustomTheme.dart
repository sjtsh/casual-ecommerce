import 'package:ezdelivershop/Components/Constants/ColorPalette.dart';
import 'package:ezdelivershop/Components/Constants/TextStylePalette.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:shared_preferences/shared_preferences.dart';

class CustomTheme with ChangeNotifier {
  ThemeMode themeMode = ThemeMode.system;
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  checkTheme() {
    if (themeMode == ThemeMode.system) {
      _isDarkMode = checkSystemThemeMode();
      _isDarkMode ? statusDark() : statusLight();
      notifyListeners();
    }
  }

  set isDarkMode(bool value) {
    _isDarkMode = value;
    notifyListeners();
  }

  bool checkSystemThemeMode() {
    return SchedulerBinding.instance.window.platformBrightness ==
        ui.Brightness.dark;
  }

  initializeSelectedTheme(SharedPreferences preferences) async {
    int? themeVal = preferences.getInt("themeValue");
    if (themeVal != null) {
      if (themeVal == 1) {
        themeMode = ThemeMode.system;
        _isDarkMode = checkSystemThemeMode();
        _isDarkMode ? statusDark() : statusLight();
        notifyListeners();
      } else if (themeVal == 2) {
        themeMode = ThemeMode.dark;
        _isDarkMode = true;
        statusDark();
      } else {
        themeMode = ThemeMode.light;
        _isDarkMode = false;
        statusLight();
      }
    } else {
      themeMode = ThemeMode.system;
      checkTheme();
    }
    Future.delayed(const Duration(milliseconds: 5), () {
      notifyListeners();
    });
  }

  Future<ThemeMode> switchThemeMode(ThemeMode mode) async {
    themeMode = mode;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    if (ThemeMode.system == mode) {
      _isDarkMode = checkSystemThemeMode();
      notifyListeners();
      preferences.setInt("themeValue", 1);
    } else if (ThemeMode.light == mode) {
      _isDarkMode = false;
      preferences.setInt("themeValue", 3);
    } else {
      _isDarkMode = true;
      preferences.setInt("themeValue", 2);
    }
    apprehendMode();

    Future.delayed(const Duration(milliseconds: 10), () {
      notifyListeners();
    });
    return themeMode;
  }

  apprehendMode() => _isDarkMode ? statusDark() : statusLight();

  statusSplash() {
    return SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Color(0xff1A0503),
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  statusDark() {
    return SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: darkScaffoldbackGroundColor,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.light,
    ));
  }

  statusLight() {
    return SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: scaffoldbackGroundColor,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      // systemStatusBarContrastEnforced: true,
    ));
  }

  static const Color primaryColor = Color(0xFF7E30B5);

  // Color(0xFFFF2E20);
  static Color blackColor = const Color(0xff312B26);

  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color greyColor = Color(0xff8E8D8D);
  static const Color successColor = Color(0xff359F1B);
  static const Color errorColor = Color(0xffE71212);
  static const Color infoColor = Color(0xff1227E7);
  static const Color lightGreyColor = Color(0xffb1b1b1);

  Color getBlackColor({bool opposite = false}) => isDarkMode
      ? opposite
          ? blackColor
          : darkBlackColor
      : opposite
          ? darkBlackColor
          : blackColor;

  Color getFilledPrimaryColor() =>
      primaryColor.withOpacity(isDarkMode ? 0.3 : 0.35);
  static Color darkBlackColor = const Color(0xfff4f4f4);

  static Color scaffoldbackGroundColor = const Color(0xffffffff);
  static Color darkScaffoldbackGroundColor = const Color(0xff1b1b1b);

  static Color backGroundColor = const Color(0xffffffff);
  static Color darkBackGroundColor = const Color(0xff363636);

  static Color tabBackGroundColor = const Color(0xff0072B1).withOpacity(0.1);

  static const Color starColor = Color(0xFFFBDF4F);

  // static ThemeData get lightTheme {
  //   var theme = isDarkMode ? ThemeData.light() : ThemeData.dark();

  //   return theme.;
  // }

  ThemeData get lightTheme => ThemeData().copyWith(
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
      ),
      brightness: Brightness.light,
      appBarTheme: AppBarTheme(
        color: blackColor,
        foregroundColor: blackColor,
      ),
      primaryColor: primaryColor,
      popupMenuTheme: PopupMenuThemeData(
        textStyle: TextStyle(color: blackColor),
      ),
      scaffoldBackgroundColor: scaffoldbackGroundColor,
      backgroundColor: backGroundColor,
      colorScheme: const ColorScheme.light(secondary: primaryColor),
      iconTheme: IconThemeData(color: blackColor),
      radioTheme: RadioThemeData(
          fillColor: MaterialStateColor.resolveWith((states) => primaryColor)),
      inputDecorationTheme: InputDecorationTheme(
          disabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: Colors.black.withOpacity(0.1))),
          iconColor: CustomTheme.greyColor,
          floatingLabelStyle: TextStylePalette.kTextStyleInterRegular
              .copyWith(fontSize: 13, color: primaryColor),
          labelStyle: TextStylePalette.kTextStyleInterRegular
              .copyWith(fontSize: 13, color: greyColor),
          focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                  width: 1.5,
                  color: getFilledPrimaryColor().withOpacity(0.25))),
          focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: errorColor)),
          enabledBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(width: 1.5, color: getFilledPrimaryColor())),
          errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(width: 1.5, color: errorColor)),
          // filled: true,
          // fillColor: CustomTheme.backGroundColor,
          hintStyle: TextStylePalette.kTextStyleInterRegular
              .copyWith(fontSize: 13, color: greyColor)),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
      )),
      sliderTheme: const SliderThemeData(
          thumbColor: primaryColor, activeTrackColor: primaryColor),
      textTheme: TextTheme(
        // headlineLarge: kTextWorkSans.copyWith(fontSize: 34, letterSpacing: 8),
        // headlineMedium:
        //     kTextWorkSans.copyWith(fontSize: 20, letterSpacing: -0.8),
        // bodyMedium: kTextWorkSans.copyWith(fontSize: 13, letterSpacing: -0.5),
        headline1: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 32, color: blackColor),
        headline2: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 26, color: blackColor),
        headline3: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 22, color: blackColor),
        headline4: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 20, color: blackColor),
        headline5: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 15, color: blackColor),
        bodyText1: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 13, color: blackColor),
        bodyText2: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 11, color: blackColor),
        button: TextStylePalette.kTextStyleInterMedium.copyWith(fontSize: 15),
        subtitle1:
            TextStylePalette.kTextStyleInterRegular.copyWith(fontSize: 13),
      ).apply(bodyColor: blackColor));

  ThemeData get darkTheme => ThemeData().copyWith(
      checkboxTheme: CheckboxThemeData(
        checkColor: MaterialStateColor.resolveWith((states) => whiteColor),
        fillColor: MaterialStateColor.resolveWith((states) => primaryColor),
      ),

      appBarTheme: AppBarTheme(
        color: darkBlackColor,
        foregroundColor: darkBlackColor,
        // titleTextStyle: k,
      ),

      brightness: Brightness.light,
      primaryColor: primaryColor,
      canvasColor: const Color.fromRGBO(0, 0, 0, 1.0),
      popupMenuTheme: PopupMenuThemeData(
          textStyle: const TextStyle(color: whiteColor),
          color: ColorPalette.darkContainerColor),
      scaffoldBackgroundColor: darkScaffoldbackGroundColor,
      backgroundColor: darkBackGroundColor,
      colorScheme: const ColorScheme.dark(secondary: primaryColor),
      iconTheme: const IconThemeData(
        color: whiteColor,
      ),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateColor.resolveWith((states) => primaryColor),
        overlayColor: MaterialStateColor.resolveWith((states) => greyColor),
      ),
      inputDecorationTheme: InputDecorationTheme(
        disabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: ColorPalette.darkDisabledTextFieldColor)),
        iconColor: CustomTheme.greyColor,
        floatingLabelStyle: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 13, color: primaryColor),
        labelStyle: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 13, color: greyColor),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                width: 1.5, color: getFilledPrimaryColor().withOpacity(0.25))),
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: getFilledPrimaryColor())),
        errorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: errorColor)),
        focusedErrorBorder: const OutlineInputBorder(
            borderSide: BorderSide(width: 1.5, color: errorColor)),
        // filled: true,
        // fillColor: primaryColor.withOpacity(0.22),
        hintStyle: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 15, color: greyColor),
      ),
      textButtonTheme: TextButtonThemeData(
          style: ButtonStyle(
        foregroundColor: MaterialStateProperty.all<Color>(primaryColor),
      )),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: primaryColor,
      ),
      sliderTheme: const SliderThemeData(
          thumbColor: primaryColor, activeTrackColor: primaryColor),
      textTheme: TextTheme(
        // headlineLarge: kTextWorkSans.copyWith(fontSize: 34, letterSpacing: 8),
        // headlineMedium:
        //     kTextWorkSans.copyWith(fontSize: 20, letterSpacing: -0.8),
        // bodyMedium: kTextWorkSans.copyWith(fontSize: 13, letterSpacing: -0.5),
        headline1: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 32, color: darkBlackColor),
        headline2: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 26, color: darkBlackColor),
        headline3: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 22, color: darkBlackColor),
        headline4: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 20, color: darkBlackColor),
        headline5: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 15, color: darkBlackColor),
        bodyText1: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 13, color: darkBlackColor),
        bodyText2: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 11, color: darkBlackColor),
        button: TextStylePalette.kTextStyleInterMedium
            .copyWith(fontSize: 15, color: darkBlackColor),
        subtitle1: TextStylePalette.kTextStyleInterRegular
            .copyWith(fontSize: 13, color: darkBlackColor),
      ).apply(bodyColor: darkBlackColor));
}
