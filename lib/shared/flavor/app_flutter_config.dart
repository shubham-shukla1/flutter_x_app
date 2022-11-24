enum AppFlavor { prod, dev }

abstract class BaseAppFlavor {
  AppFlavor appFlavor = AppFlavor.prod;

  //starts with https:// or https://www
  String baseAPIURL = 'https://google.com';
  String baseAPIURL2 = 'base_url2';

  String systemEventUrl = 'system_event_url';

  bool isDevelopment = false;
}

/// Setup development Env.
class DevAppFlavor extends BaseAppFlavor {
  @override
  AppFlavor get appFlavor => AppFlavor.dev;
  //starts with https://dev or dev

  @override
  String get baseAPIURL => 'https://google.com';

  @override
  String get baseAPIURL2 => 'base_url2';

  @override
  String get systemEventUrl => 'system_event_url';

  @override
  bool get isDevelopment => true;
}

/// Setup production Env.
class ProdAppFlavor extends BaseAppFlavor {
  @override
  AppFlavor get appFlavor => super.appFlavor;

  @override
  String get baseAPIURL => super.baseAPIURL;

  @override
  String get baseAPIURL2 => super.baseAPIURL2;

  @override
  String get systemEventUrl => super.systemEventUrl;

  @override
  bool get isDevelopment => super.isDevelopment;
}

class AppFlavorConfig {
  static AppFlavorConfig? _instance;
  AppFlavor? appFlavor;
  String? baseURL;
  String? baseURL2;

  String? systemEventUrl;
  bool? isDevelopment;

  static AppFlavorConfig? get instance => _instance;

  AppFlavorConfig();

  static void setFlavor({
    AppFlavor? flavor = AppFlavor.dev,
  }) {
    if (_instance == null) {
      _instance = AppFlavorConfig();
      var baseFlavor =
          flavor == AppFlavor.dev ? DevAppFlavor() : ProdAppFlavor();
      _instance?.appFlavor = flavor;
      _instance?.baseURL = baseFlavor.baseAPIURL;
      _instance?.baseURL2 = baseFlavor.baseAPIURL2;

      _instance?.systemEventUrl = baseFlavor.systemEventUrl;

      _instance?.isDevelopment = baseFlavor.isDevelopment;
    }
  }
}
