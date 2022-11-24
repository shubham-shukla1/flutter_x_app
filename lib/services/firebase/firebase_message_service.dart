import 'dart:convert';

import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../shared/app_logging/app_log_helper.dart';
import '../../main_prod.dart';
import '../common_analytics_service/app_analytics_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Notification received
// Notification received - Foreground state START
// Notification received - Foreground state END case1
// Notification received - Foreground state END case2
//
//
// Notification received
// Notification received - Background/Terminated START
// Notification received - Background/Terminated END
class FirebaseMessageService {
  // FirebaseMessaging _messaging = FirebaseMessaging.instance;

  // Foreground
  static void setMessageWhileForeground() {
    AppLog.log('onMessage registered');
    FirebaseMessaging.onMessage.listen((event) async {
      AppLog.log('onMessage : ${event}');
      AppAnalyticsService.instance.notificationReceived();
      // AppAnalyticsService.instance
      //     .techTestEvent('Tech - notification received F START');
      if (event.notification == null) {
        try {
          // } else {
          var data = jsonEncode(event.data);
          CleverTapPlugin.createNotification(data);
          // AppAnalyticsService.instance
          //     .techTestEvent(' - dl ${event.data.keys.toString()}');
       
        } catch (e, stackTrace) {
          AppLog.log('message');
          FirebaseCrashlytics.instance.recordError(e, stackTrace);
        }
      } else {
        FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
            FlutterLocalNotificationsPlugin();

        const AndroidNotificationDetails androidPlatformChannelSpecifics =
            AndroidNotificationDetails(
          'user',
          'App ',
          channelDescription: 'App\'s  general notifications',
        );

        try {
          /*if (event.notification != null &&
              event.notification!.title == 'is_in_app_review') {
            final InAppReview inAppReview = InAppReview.instance;
            if (await inAppReview.isAvailable()) {
              inAppReview.requestReview();
            }
          } else {*/
          flutterLocalNotificationsPlugin.show(
            1,
            event.notification!.title,
            event.notification!.body,
            NotificationDetails(android: androidPlatformChannelSpecifics),
          );
          // AppAnalyticsService.instance
          //     .techTestEvent('Tech - ${event.notification.toString()}');
          // AppAnalyticsService.instance
          //     .techTestEvent('Tech - notification received F END case2');
          // }
        } catch (e, stackTrace) {
          AppLog.log('message');
          FirebaseCrashlytics.instance.recordError(e, stackTrace);
        }

        // AppAnalyticsService.instance
        //     .techTestEvent('onMessage data object is null');
        // AppAnalyticsService.instance
        //     .techTestEvent('${event.notification!.title!}');
      }
    });
  }

  // When app is terminated or background
  static Future setMessageWhileBackOrTerminated() async {
    AppLog.log('onBackgroundMessage registered');
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  // Background to click
  static void listenClickWhenClickedFromBG() {
    FirebaseMessaging.onMessageOpenedApp.listen(
      (event) {
        AppLog.log('onMessageOpenedApp : ${event}');
        // AppAnalyticsService.instance
        //     .techTestEvent('listenClickWhenClickedFromBG');
        // var data = jsonEncode(event.data);
        // CleverTapPlugin.createNotification(data);
      },
    );
  }

  // Terminated to click
  static void listenClickWhenClickedFromTerminated() {
    FirebaseMessaging.instance.getInitialMessage().then((value) {
      AppLog.log('getInitialMessage : ${value}');
      // AppAnalyticsService.instance
      //     .techTestEvent('listenClickWhenClickedFromTerminated');
      // var data = jsonEncode(value.data);
      // CleverTapPlugin.createNotification(data);
    });
  }
}
