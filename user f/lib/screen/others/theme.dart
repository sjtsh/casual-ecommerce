import 'dart:ui' as ui;

import 'package:ezdeliver/screen/component/helper/exporter.dart';

import 'package:flutter/scheduler.dart';

final customThemeServiceProvider =
    ChangeNotifierProvider<CustomThemeState>((ref) {
  return CustomThemeState._();
});

const themeKey = "theme";

class CustomThemeState extends ChangeNotifier {
  CustomThemeState._() {
    loadTheme();
  }

  ThemeMode themeMode =
      UniversalPlatform.isAndroid ? ThemeMode.system : ThemeMode.light;
  late bool isDarkMode;

  loadTheme() async {
    var theme = storage.read(themeKey);
    if (theme == null) {
      switchThemeMode(themeMode);
    } else {
      if (theme) {
        switchThemeMode(ThemeMode.dark);
      } else {
        switchThemeMode(ThemeMode.light);
      }
    }
  }

  saveTheme(ThemeMode mode) {
    if (mode == ThemeMode.system) {
      storage.write(themeKey, null);
    } else if (mode == ThemeMode.dark) {
      storage.write(themeKey, true);
    }
    if (mode == ThemeMode.light) storage.write(themeKey, false);
  }

  bool checkSystemThemeMode() {
    return SchedulerBinding.instance.window.platformBrightness ==
        ui.Brightness.dark;
  }

  ThemeMode switchThemeMode(ThemeMode mode) {
    themeMode = mode;
    if (ThemeMode.system == mode) {
      var m = checkSystemThemeMode();
      // if (m) {
      //   CustomTheme.statusDark();
      // } else {
      //   CustomTheme.statusLight();
      // }

      isDarkMode = m;
    } else if (ThemeMode.light == mode) {
      // CustomTheme.statusLight();
      isDarkMode = false;
    } else {
      // CustomTheme.statusDark();
      isDarkMode = true;
    }

    if (isDarkMode) {
      CustomTheme.statusDark();
    } else {
      CustomTheme.statusLight();
    }
    saveTheme(mode);
    Future.delayed(const Duration(milliseconds: 5), () {
      notifyListeners();
    });

    return mode;
  }
}

class CustomTheme {
  CustomTheme._();

  static bool get darkMode =>
      CustomKeys.ref.read(customThemeServiceProvider).isDarkMode;

  // static const Color primaryColor = Color(0xFFFF2E00);
  static Color get primaryColor => !darkMode
      ? const Color(0xFF7E30B5)
      : const Color.fromARGB(255, 148, 75, 201);

  static Color blackColor = const Color(0xff312B26);

  static const Color whiteColor = Color(0xffFFFFFF);
  static const Color greyColor = Color(0xff8E8D8D);
  static const Color successColor = Color(0xff359F1B);
  static const Color errorColor = Color(0xffE71212);
  static const Color infoColor = Color(0xff1227E7);
  static const Color lightGreyColor = Color(0xffb1b1b1);
  static const Color emptyStarColor = Color(0xffDCDBDB);
  static const Color homeColor = Color(0xff74C1DA);
  static const Color workColor = Color(0xff4200FF);

  static Color getBlackColor({bool opposite = false}) => darkMode
      ? opposite
          ? blackColor
          : darkBlackColor
      : opposite
          ? darkBlackColor
          : blackColor;
  static Color getFilledPrimaryColor() =>
      primaryColor.withOpacity(darkMode ? 0.3 : 0.35);
  static Color darkBlackColor = const Color(0xfff3f3f3);

  static Color scaffoldbackGroundColor = const Color(0xffffffff);
  static Color darkScaffoldbackGroundColor = const Color(0xff1b1b1b);

  static Color backGroundColor = const Color(0xffffffff);
  static Color darkBackGroundColor = const Color(0xff363636);

  static Color tabBackGroundColor = const Color(0xff0072B1).withOpacity(0.1);

  static const Color starColor = Color(0xFFFBDF4F);

  // static ThemeData get lightTheme {
  //   var theme = darkMode ? ThemeData.light() : ThemeData.dark();

  //   return theme.;
  // }

  static SystemUiOverlayStyle darkStatus = SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarColor: darkScaffoldbackGroundColor,
      statusBarIconBrightness: Brightness.light);

  static SystemUiOverlayStyle lightStatus = SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarColor: scaffoldbackGroundColor,
      statusBarIconBrightness: Brightness.dark);
  static statusDark() {
    if (UniversalPlatform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(lightStatus);
    } else {
      SystemChrome.setSystemUIOverlayStyle(darkStatus);
    }
  }

  static statusLight() {
    if (UniversalPlatform.isIOS) {
      SystemChrome.setSystemUIOverlayStyle(lightStatus.copyWith());
    } else {
      SystemChrome.setSystemUIOverlayStyle(lightStatus);
    }
  }

  static ThemeData get lightTheme => ThemeData().copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: scaffoldbackGroundColor,
      backgroundColor: backGroundColor,
      colorScheme: ColorScheme.light(secondary: primaryColor),
      appBarTheme: AppBarTheme(
          color: blackColor,
          foregroundColor: blackColor,
          systemOverlayStyle: lightStatus),
      checkboxTheme: CheckboxThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          side: BorderSide(width: 1.sw(), color: CustomTheme.getBlackColor()),
          checkColor: MaterialStateColor.resolveWith((states) => whiteColor),
          fillColor: MaterialStateColor.resolveWith((states) => primaryColor)),
      radioTheme: RadioThemeData(
          fillColor: MaterialStateColor.resolveWith((states) => primaryColor)),
      tooltipTheme: TooltipThemeData(
          showDuration: const Duration(seconds: 3),
          enableFeedback: true,
          padding: EdgeInsets.all(18.sr()),
          textStyle:
              kTextStyleInterRegular.copyWith(fontSize: 13, color: blackColor),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.sr()),
              // color: TooltipThemeData().d
              color: Colors.grey[300])),
      inputDecorationTheme: InputDecorationTheme(
          iconColor: CustomTheme.greyColor,
          floatingLabelStyle: kTextStyleInterRegular.copyWith(
              fontSize: 13, color: primaryColor),
          labelStyle:
              kTextStyleInterRegular.copyWith(fontSize: 13, color: greyColor),
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
          hintStyle:
              kTextStyleInterRegular.copyWith(fontSize: 13, color: greyColor)),
      textSelectionTheme: TextSelectionThemeData(cursorColor: primaryColor),
      textTheme: TextTheme(
        // headlineLarge: kTextWorkSans.copyWith(fontSize: 34, letterSpacing: 8),
        // headlineMedium:
        //     kTextWorkSans.copyWith(fontSize: 20, letterSpacing: -0.8),
        // bodyMedium: kTextWorkSans.copyWith(fontSize: 13, letterSpacing: -0.5),
        headline1:
            kTextStyleInterRegular.copyWith(fontSize: 32, color: blackColor),
        headline2:
            kTextStyleInterRegular.copyWith(fontSize: 26, color: blackColor),
        headline3:
            kTextStyleInterRegular.copyWith(fontSize: 22, color: blackColor),
        headline4:
            kTextStyleInterRegular.copyWith(fontSize: 20, color: blackColor),
        headline5:
            kTextStyleInterRegular.copyWith(fontSize: 15, color: blackColor),
        headline6:
            kTextStyleInterRegular.copyWith(fontSize: 14, color: blackColor),
        bodyText1:
            kTextStyleInterRegular.copyWith(fontSize: 13, color: blackColor),
        bodyText2:
            kTextStyleInterRegular.copyWith(fontSize: 11, color: blackColor),
        button: kTextStyleInterMedium.copyWith(fontSize: 15),
        subtitle1: kTextStyleInterRegular.copyWith(fontSize: 13),
      ).apply(bodyColor: blackColor));

  static ThemeData get darkTheme => ThemeData().copyWith(
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkScaffoldbackGroundColor,
      backgroundColor: darkBackGroundColor,
      colorScheme: ColorScheme.dark(secondary: primaryColor),
      radioTheme: RadioThemeData(
        fillColor: MaterialStateColor.resolveWith((states) => primaryColor),
        overlayColor: MaterialStateColor.resolveWith((states) => greyColor),
      ),
      appBarTheme: AppBarTheme(
          color: darkBlackColor,
          foregroundColor: darkBlackColor,
          // titleTextStyle: k,
          systemOverlayStyle: darkStatus),
      tooltipTheme: TooltipThemeData(
          showDuration: const Duration(seconds: 3),
          enableFeedback: true,
          padding: EdgeInsets.all(18.sr()),
          textStyle:
              kTextStyleInterRegular.copyWith(fontSize: 13, color: whiteColor),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.sr()),
              color: darkBackGroundColor)),
      checkboxTheme: CheckboxThemeData(
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          side: BorderSide(width: 1.sw(), color: CustomTheme.getBlackColor()),
          checkColor: MaterialStateColor.resolveWith((states) => whiteColor),
          fillColor: MaterialStateColor.resolveWith((states) => primaryColor)),
      inputDecorationTheme: InputDecorationTheme(
        iconColor: CustomTheme.greyColor,
        floatingLabelStyle:
            kTextStyleInterRegular.copyWith(fontSize: 13, color: primaryColor),
        labelStyle:
            kTextStyleInterRegular.copyWith(fontSize: 13, color: greyColor),
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
        hintStyle:
            kTextStyleInterRegular.copyWith(fontSize: 15, color: greyColor),
      ),
      textSelectionTheme: TextSelectionThemeData(cursorColor: primaryColor),
      textTheme: TextTheme(
        // headlineLarge: kTextWorkSans.copyWith(fontSize: 34, letterSpacing: 8),
        // headlineMedium:
        //     kTextWorkSans.copyWith(fontSize: 20, letterSpacing: -0.8),
        // bodyMedium: kTextWorkSans.copyWith(fontSize: 13, letterSpacing: -0.5),
        headline1: kTextStyleInterRegular.copyWith(
            fontSize: 32, color: darkBlackColor),
        headline2: kTextStyleInterRegular.copyWith(
            fontSize: 26, color: darkBlackColor),
        headline3: kTextStyleInterRegular.copyWith(
            fontSize: 22, color: darkBlackColor),
        headline4: kTextStyleInterRegular.copyWith(
            fontSize: 20, color: darkBlackColor),
        headline5: kTextStyleInterRegular.copyWith(
            fontSize: 15, color: darkBlackColor),
        headline6: kTextStyleInterRegular.copyWith(
            fontSize: 14, color: darkBlackColor),
        bodyText1: kTextStyleInterRegular.copyWith(
            fontSize: 13, color: darkBlackColor),
        bodyText2: kTextStyleInterRegular.copyWith(
            fontSize: 11, color: darkBlackColor),
        button:
            kTextStyleInterMedium.copyWith(fontSize: 15, color: darkBlackColor),
        subtitle1: kTextStyleInterRegular.copyWith(
            fontSize: 13, color: darkBlackColor),
      ).apply(bodyColor: darkBlackColor));
}

ThemeMode getThemeMode(bool? mode) {
  if (mode == null) return ThemeMode.system;

  if (mode) return ThemeMode.dark;

  return ThemeMode.light;
}
