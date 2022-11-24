class FeatureConfigurationService {
  final Map<String, dynamic> configuration;

  FeatureConfigurationService(this.configuration);

  String getString(String key) =>
      configuration[key] != null ? configuration[key] as String : '';
  bool getBool(String key) =>
      configuration[key] != null ? configuration[key] as bool : false;

  bool get isNotificationEnabled => getBool('notification_icon');
  bool get isTCEnabled => getBool('truecaller_popup');
}
