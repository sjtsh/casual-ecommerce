import 'package:shared_preferences/shared_preferences.dart';

enum SharedPrefs {
  authToken,
  refreshToken,
  loginTime
}

extension PreferenceExtension on SharedPrefs {
  String get key {
    switch (this) {
      case SharedPrefs.authToken:
        return 'token';
      case SharedPrefs.refreshToken:
        return 'refresh_token';
      case SharedPrefs.loginTime:
        return 'loginTime';
      default:
        throw Exception('Invalid preference key');
    }
  }
}

class SharedPreferencesHelper {

  static SharedPreferences? preferences;

  static Future<void> init() async {
    preferences = await SharedPreferences.getInstance();
  }
  static Future<void> setStringPref(String key,String value) async {
     preferences?.setString(key, value);
  }

  static Future<String?> getStringPref(String key) async {
    return preferences?.getString(key);
  }

  static Future<void> setIntPref(String key,int value) async {
     preferences?.setInt(key, value);
  }

  static Future<int?> getIntPref(String key) async {
    return preferences?.getInt(key);
  }


  static Future<void> setBoolPref(String key,bool value) async {
    preferences?.setBool(key, value);
  }

  static Future<bool?> getBoolPref(String key) async {
    return preferences?.getBool(key);
  }

}
