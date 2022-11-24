import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static AppPreferences? _instance;
  static SharedPreferences? preference;

  static AppPreferences? get instance {
    if (_instance == null) {
      _instance = AppPreferences();
    }

    return _instance;
  }

  Future initPrefBox() async {
    if (preference == null) {
      preference = await SharedPreferences.getInstance();
    }
  }

  Future<bool>? setIsLogin(bool loginFlag) {
    return preference?.setBool(AppPrefKeys.isLogin, loginFlag);
  }

  bool? get isLogin => preference?.getBool(AppPrefKeys.isLogin) ?? false;

  Future<bool>? setLocale(String localeStr) {
    return preference?.setString(AppPrefKeys.language, localeStr);
  }

  String get authToken => preference?.getString(AppPrefKeys.authToken) ?? '';

  Future<bool>? setAuthToken(String gAccessToken) {
    return preference?.setString(AppPrefKeys.authToken, gAccessToken);
  }

  String get entityId => preference?.getString(AppPrefKeys.entityId) ?? '';

  Future<bool>? setEntityId(String entityId) {
    return preference?.setString(AppPrefKeys.entityId, entityId);
  }

  String get rawLoginUserJson =>
      preference?.getString(AppPrefKeys.rawLoginUserJson) ?? '';

  Future<bool>? setRawLoginUserJson(String rawLoginUserJson) {
    return preference?.setString(
        AppPrefKeys.rawLoginUserJson, rawLoginUserJson);
  }

  String get rawLoginUserDataJson =>
      preference?.getString(AppPrefKeys.rawLoginUserDataJson) ?? '';

  Future<bool>? setRawLoginUserDataJson(String rawLoginUserJson) {
    return preference?.setString(
        AppPrefKeys.rawLoginUserDataJson, rawLoginUserJson);
  }

  String get rawFirebaseJson =>
      preference?.getString(AppPrefKeys.rawFirebaseJson) ?? '';

  Future<bool>? setRawFirebaseJson(String rawFirebaseJson) {
    return preference?.setString(AppPrefKeys.rawFirebaseJson, rawFirebaseJson);
  }

  bool get isPhpPageCookieSet =>
      preference?.getBool(AppPrefKeys.phpPageCookie) ?? false;

  Future<bool>? setPhpPageCookie(bool flag) {
    return preference?.setBool(AppPrefKeys.phpPageCookie, flag);
  }

  bool get isOnceOnboardVisited =>
      preference?.getBool(AppPrefKeys.onceBoardVisited) ?? false;

  Future<bool>? setOnceOnboardVisited(bool flag) {
    return preference?.setBool(AppPrefKeys.onceBoardVisited, flag);
  }

  bool get isVeryFirstTime =>
      preference?.getBool(AppPrefKeys.veryFirstTime) ?? true;

  Future<bool>? setVeryFirstTime(bool flag) {
    return preference?.setBool(AppPrefKeys.veryFirstTime, flag);
  }
}

class AppPrefKeys {
  static String isLogin = 'is_login';
  static String language = 'language';
  static String authToken = 'auth_token';
  static String rawLoginUserJson = 'raw_user_json';
  static String rawLoginUserDataJson = 'raw_user_data_json';
  static String rawFirebaseJson = 'raw_firebase_json';
  static String entityId = 'entity_id';
  static String phpPageCookie = 'php_page_cookie';
  static String onceBoardVisited = 'once_onboard_visited';

  static String veryFirstTime = 'very_first_time';
}
