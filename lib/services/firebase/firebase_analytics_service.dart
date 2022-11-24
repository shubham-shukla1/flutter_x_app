import 'package:firebase_analytics/firebase_analytics.dart';

class FirebaseAnalyticsService {
  static FirebaseAnalyticsService _instance =
      FirebaseAnalyticsService._internal();

  FirebaseAnalyticsService._internal();

  factory FirebaseAnalyticsService() {
    return _instance;
  }

  static FirebaseAnalyticsService get instance => _instance;

  final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;

  /// This function will remove white spaces because firebase isn't allowing to use
  Future<void> sendEvent(String eventName,
      {Map<String, dynamic>? appProperties}) {
    return _firebaseAnalytics.logEvent(
      name: _removeSpace(eventName),
      parameters: appProperties ?? <String, dynamic>{},
    );
  }

  String _removeSpace(String param) {
    param = param.replaceAll('-', '_');
    param = param.replaceAll(' ', '_');
    return param.length > 40 ? param.substring(0, 40) : param;
  }
}
