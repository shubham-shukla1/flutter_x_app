import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_x_app/shared/app_logging/app_log_helper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../shared/common_importer.dart';
import '../../model/login/login_user_response.dart';
import '../../services/clevertap/clevertap_service.dart';
import '../../services/common_analytics_service/app_analytics_service.dart';
import '../../services/common_analytics_service/common_properties.dart';
import '../../services/local_pref/app_pref.dart';
import '../../services/network/network_service.dart';

part 'general_state.dart';

class GeneralCubit extends Cubit<GeneralState> {
  GeneralCubit() : super(GeneralInitial());

  Future<UserStatus?> performAfterLogin(
      {LoginUserResponse? loginUserResponse, required String loginVia}) async {
    CookieManager cManager = CookieManager.instance();
    await cManager.setCookie(
      // url: Uri.parse(AppFlavorConfig.instance!.HomePageURL!),
      url: Uri.parse('https://..org'),
      name: 'u_auth',
      value: AppPreferences.instance!.authToken,
    );
    await cManager.setCookie(
      // url: Uri.parse(AppFlavorConfig.instance!.HomePageURL!),
      url: Uri.parse('https://..org'), name: 'platform',
      value: Platform.isAndroid ? 'android' : 'ios',
    );

    try {
      PackageInfo snapShot = await PackageInfo.fromPlatform();

      await cManager.setCookie(
        // url: Uri.parse(AppFlavorConfig.instance!.HomePageURL!),
        url: Uri.parse('https://..org'), name: 'app_version',
        value: '${snapShot.version}',
      );
    } catch (e) {
      AppLog.log('${e.toString()}');
    }

    if (Platform.isAndroid) {
      String? fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) CleverTapService.setFCMPush(fcmToken);
    }

    if (loginUserResponse != null) {
      Map<String, dynamic> user = Map<String, dynamic>();
      AppPreferences.instance!
          .setEntityId(loginUserResponse.data!.user!.entity!.id.toString());

      user.putIfAbsent(CTPropertyName.IDENTITY,
          () => loginUserResponse.data!.user!.entity!.id);
      user.putIfAbsent(
          CTPropertyName.EMAIL, () => loginUserResponse.data!.user!.emailId);
      user.putIfAbsent(
          CTPropertyName.USER_ID, () => loginUserResponse.data!.user!.id);
      user.putIfAbsent(CTPropertyName.NAME,
          () => loginUserResponse.data!.user!.entity!.fullName);
      user.putIfAbsent(CTPropertyName.USER_TYPE,
          () => loginUserResponse.data!.user!.userType);
      // user.putIfAbsent(CTPropertyName.USER_FCM_TOKEN, () => fcmToken);
      await CleverTapService.onUserLogin(user);
    }
    try {
      UserStatus userStatus = await Future.delayed(Duration(seconds: 1));
      AppLog.log('userStatus : ${userStatus}');
      AppAnalyticsService.instance
          .loginVia(loginVia, '${userStatus.toString().split('.')[1]}');
      return userStatus;
    } catch (e) {
      AppLog.log('Error in Checking  user status', error: e);
      return null;
    }
  }

  Future<void> performLogout({String? reason}) async {
    await KFAS.instance.signOut();
    KPref.instance!.setAuthToken('');
    KPref.instance!.setPhpPageCookie(false);
    KPref.instance!.setRawLoginUserJson('');
    if (reason != null) {
      AppAnalyticsService.instance.appLogout(reason: reason);
    }
    await DefaultCacheManager().emptyCache();
    CookieManager.instance().deleteAllCookies();
    // KApi.instance.logOut();
  }

  // Basically initialize some of the objects while app is ready to use
  performWhileLoginOrLanding(LoginUserResponse? loginUserResponse) async {
    // Set shared properties so we can use when we needed.
    CommonProperties properties = CommonProperties.getInstance();
    if (loginUserResponse != null) {
      properties.userId = loginUserResponse.data!.user!.entity!.id.toString();
      properties.name = loginUserResponse.data!.user!.entity!.fullName;
      properties.email = loginUserResponse.data!.user!.emailId;
      properties.phone = '';
    }

    // System properties
    DeviceInfoPlugin dPlugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await dPlugin.androidInfo;
      properties.appVersion = androidInfo.version.release;
      properties.deviceName = androidInfo.brand;
      properties.osVersion = 'android';
      properties.sdkVersion = androidInfo.version.sdkInt != null
          ? androidInfo.version.sdkInt.toString()
          : '0';
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await dPlugin.iosInfo;
      properties.appVersion = iosDeviceInfo.utsname.release;
      properties.deviceName = iosDeviceInfo.utsname.machine;
      properties.osVersion = 'iOS';
      properties.sdkVersion = iosDeviceInfo.systemVersion;
    }
  }

  Future<void> askRequiredPermissions() async {
    try {
      // You can request multiple permissions at once.
      await [
        Permission.locationWhenInUse,
        Permission.storage,
        Permission.manageExternalStorage,
        Permission.camera,
      ].request();

      // if (statuses[Permission.storage]!.index != PermissionStatus.granted.index) {
      //   Permission.storage.request();
      // }
      //
      // if (statuses[Permission.manageExternalStorage]!.index !=
      //     PermissionStatus.granted.index) {
      //   Permission.manageExternalStorage.request();
      // }

      // if (statuses[Permission.locationWhenInUse]!.index !=
      //     PermissionStatus.granted.index) {
      //   Permission.locationWhenInUse.request();
      // }

      if (Platform.isIOS) {
        FirebaseMessaging.instance.requestPermission().then((value) {
          CleverTapService.registerForPush().then((value) async {
            if (Platform.isIOS) {
              // If the system can show an authorization request dialog
              if (await AppTrackingTransparency.trackingAuthorizationStatus ==
                  TrackingStatus.notDetermined) {
                // Show a custom explainer dialog before the system dialog
                // if (await showCustomTrackingDialog(context)) {
                // Wait for dialog popping animation
                // await Future.delayed(const Duration(milliseconds: 200));
                // Request system's tracking authorization dialog
                await AppTrackingTransparency.requestTrackingAuthorization();
                // }
              }
            }
          });
        });
      }
    } on PlatformException catch (e, s) {
      // Unexpected exception was thrown
      AppLog.log('PlatformException while askPermission',
          error: e, stackTrace: s);
    } catch (e, s) {
      AppLog.log('Error while askPermission', error: e, stackTrace: s);
    }
  }
}
