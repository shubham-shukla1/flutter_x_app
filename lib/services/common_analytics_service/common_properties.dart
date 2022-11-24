class CommonProperties {
  static CommonProperties? instance;

  static CommonProperties getInstance() {
    if (instance == null) {
      instance = CommonProperties();
    }

    return instance!;
  }

  String? _userId;

  String? get userId => _userId ?? '';

  set userId(String? userId) {
    _userId = userId;
  }

  String? _name;

  String? get name => _name ?? '';

  set name(String? name) {
    _name = name;
  }

  String? _email;

  String? get email => _email ?? '';

  set email(String? email) {
    _email = email;
  }

  String? _phone;

  String? get phone => _phone ?? '';

  set phone(String? phone) {
    _phone = phone;
  }

  String? _appVersion;

  String? get appVersion => _appVersion ?? '';

  set appVersion(String? appVersion) {
    _appVersion = appVersion;
  }

  String? _deviceName;

  String? get deviceName => _deviceName ?? '';

  set deviceName(String? deviceName) {
    _deviceName = deviceName;
  }

  String? _osVersion;

  String? get osVersion => _osVersion ?? '';

  set osVersion(String? osVersion) {
    _osVersion = osVersion;
  }

  String? _sdkVersion;

  String? get sdkVersion => _sdkVersion ?? '';

  set sdkVersion(String? sdkVersion) {
    _sdkVersion = sdkVersion;
  }

  CommonProperties();
}
