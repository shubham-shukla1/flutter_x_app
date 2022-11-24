import 'dart:io';

import 'package:clevertap_plugin/clevertap_plugin.dart';

import '../../shared/app_logging/app_log_helper.dart';
import '../common_analytics_service/app_analytics_service.dart';

class CleverTapService {
  // final CleverTapPlugin _cleverTapPlugin = CleverTapPlugin();

  static String channelId = 'channelId';
  static String channelName = 'App ';
  static String channelDesc = 'App\'s  general notifications';
  static int channelImp = 4;

  static void createNotificationChannel() {
    // Follow android notification importance values
    // https://developer.android.com/training/notify-user/channels

    CleverTapPlugin.createNotificationChannel(
      channelId, // channel id
      channelName, // channel name
      channelDesc, // channel description
      channelImp, // Android notification importance
      true, // show badge
    );
  }

  static void initializeInbox() {
    CleverTapPlugin.initializeInbox();
  }

  static Future<void> registerForPush() async {
    if (Platform.isIOS) {
      CleverTapPlugin.registerForPush();
    }
  }

  static void setDebugLevel({int level = 3}) {
    CleverTapPlugin.setDebugLevel(level);
  }

  static Future<void> onUserLogin(Map<String, dynamic> user) async {
    CleverTapPlugin.onUserLogin(user);
  }

  static void registerProfile(Map<String, dynamic> profile) {
    CleverTapPlugin.profileSet(profile);
  }

  static void setFCMPush(String argumentParam) {
    AppLog.log('FCM : $argumentParam');
    CleverTapPlugin.setPushToken(argumentParam);
  }

  static void setPushClicked() {
    CleverTapPlugin _cleverTapPlugin = CleverTapPlugin();
    _cleverTapPlugin.setCleverTapPushAmpPayloadReceivedHandler(
      (map) {
        // AppAnalyticsService.instance
        //     .techTestEvent('push  handler');
        CleverTapPlugin.createNotification(map);
      },
    );
    // _cleverTapPlugin.setCleverTapPushClickedPayloadReceivedHandler((map) {
    //   AppLog.log('Notification clicked : $map');
    // });
  }

  static Future<void> recordEvent(String eventName,
      {Map<String, dynamic>? properties}) {
    return CleverTapPlugin.recordEvent(
      _removeSpace(eventName),
      properties != null ? properties : Map<String, dynamic>(),
    );
  }

  static String _removeSpace(String param) {
    // param = param.replaceAll('-', '_');
    // param = param.replaceAll(' ', '_');
    return param.length > 512 ? param.substring(0, 512) : param;
  }
}

class CTPropertyName {
  static const String USER_ID = 'User Id';
  static const String IDENTITY = 'Identity';
  static const String USER_NAME = 'User Name';
  static const String USER_TYPE = 'User Type';

  // static String get USER_FCM_TOKEN =>
  //     Platform.isAndroid ? 'User FCM Token' : 'User FCM Token ios';
  static const String PROFILE_TYPE = 'Profile Type';
  static const String NAME = 'Name';
  static const String PHONE = 'Phone';
  static const String EMAIL = 'Email';
  static const String DOB = 'DOB';
  static const String GENDER = 'Gender';
  static const String LOCATION = 'Location';
}
