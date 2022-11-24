import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';

import '../../shared/app_logging/app_log_helper.dart';

class FirebaseRemoteConfigService {
  static Future<void> setupFirebaseRemoteConfig() async {
    try {
      final FirebaseRemoteConfig remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 12),
        ),
      );

      await remoteConfig.setDefaults(
        <String, dynamic>{
          // 'android_version': '1.0.3',
          // 'ios_version': '1.0.3',
          'minimum_app_version': '1.0',
          'dev_minimum_app_version': '1.0',
          'latest_app_version': '1.0',
          'dev_latest_app_version': '1.0',
          'tc_link': 'terms and condition',
          'pp_link': 'privacy-policy',
          'files_download_in_progress': 'Please check in files app.',
          'resend_sec': 60,
          'notification_try_flag': true,
          'social_login': Platform.isIOS ? false : true,
          'social_button_signup': Platform.isIOS ? false : true,
          'meWithParam': 'meWithParam',
          'my_outside_urls': 'my_outside_urls',
          'my_outside_urls_platform': Platform.isIOS
              ? 'my_outside_urls_platform'
              : 'my_outside_urls_platform',
          'my_internal_scheme': Platform.isIOS
              ? 'creativecdn.com;bluekai.com;hotjar.com;doubleclick.net;tsdtocl.com;gum.criteo.com;-login.firebaseapp.com;google.com;cdn.blitzllama.com'
              : '',
          'inactive_web_pages_is_live': false,
          'my_login_pages': 'new/signin;login/login.php',
          'feature_flags':
              '{"notification_icon": true,"truecaller_popup":true}',
        },
      );

      List<InternetAddress> result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        await remoteConfig.fetchAndActivate();
      }
      // var connectivityResult = await (Connectivity().checkConnectivity());
      // if (connectivityResult == ConnectivityResult.mobile ||
      //     connectivityResult == ConnectivityResult.wifi) {
      //   await remoteConfig.fetchAndActivate();
      // }
    } on SocketException catch (e, _) {
      AppLog.log('No internet..', error: e);
    } on PlatformException catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
    } catch (e, stackTrace) {
      FirebaseCrashlytics.instance.recordError(e, stackTrace);
    }
  }
}
