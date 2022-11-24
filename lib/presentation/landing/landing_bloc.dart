import 'dart:async';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_x_app/shared/app_logging/app_log_helper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:flutter/foundation.dart' show kDebugMode;

import '../../shared/common_importer.dart';
import '../../shared/flavor/app_flutter_config.dart';
import '../../shared/util/app_util.dart';
import '../../main_prod.dart';
import '../../model/login/login_user_response.dart';
import '../../services/app_link_service/app_link_service.dart';
import '../../services/firebase/firebase_deeplink_service.dart';
import '../../services/firebase/firebase_message_service.dart';
import '../../services/firebase/firebase_remote_config_service.dart';
import '../../services/local_pref/app_pref.dart';
import '../../services/network/network_exceptions.dart';
import '../../services/network/network_service.dart';
import '../../view/login/login_page.dart';
import '../general/general_cubit.dart';

part 'landing_event.dart';

part 'landing_state.dart';

class LandingBloc extends Bloc<LandingEvent, LandingState> {
  LandingBloc() : super(LandingInitial());

  @override
  Stream<LandingState> mapEventToState(
    LandingEvent event,
  ) async* {
    if (event is RunLandingLogicEvent) {
      try {
        runAsyncCode();

        await Firebase.initializeApp();
        await FirebaseRemoteConfigService.setupFirebaseRemoteConfig();
        FirebaseAppCheck.instance.activate();

        FirebaseMessageService.setMessageWhileForeground();
        FirebaseMessageService.setMessageWhileBackOrTerminated();

        await FlutterDownloader.initialize(
          debug: AppFlavorConfig.instance!
              .isDevelopment!, // optional: set false to disable printing logs to console
        );

        // set app preferences
        await AppPreferences.instance?.initPrefBox();
        AppPreferences.instance!.setVeryFirstTime(true);

        if (Platform.isAndroid) {
          await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(
              true);
        }
        AppLinkService.initAppLinks();
        String? appAssociatedURL1 =
            await AppLinkService.instance.getInitialLink();
        if (appAssociatedURL1 != null) {
          if (appAssociatedURL1
              .toString()
              .contains(AppFlavorConfig.instance!.baseURL2!)) {
            AppLinkService.instance.setOutsideURL(appAssociatedURL1);
            //Fluttertoast.showToast(msg: 'I am url : $appAssociatedURL1 ');
          } else if (appAssociatedURL1.toString().contains('.page.link')) {
            //Fluttertoast.showToast(msg: 'I am url who has .page.link : $appAssociatedURL1 ');
            PendingDynamicLinkData? urlData =
                await FirebaseDynamicLinks.instance.getDynamicLink(
              Uri.parse(appAssociatedURL1),
            );
            String deepLinkUrl = '';
            if (urlData != null) {
              //Fluttertoast.showToast(msg: ' I am url that has url data as well $appAssociatedURL1 , $urlData ');
              deepLinkUrl = urlData.link.toString();
              deepLinkUrl = AppUtils.addHttpsAndRemoveWww(deepLinkUrl);
              AppLinkService.instance.setOutsideURL(deepLinkUrl);
            }
          } else {
            //Fluttertoast.showToast(msg: 'I am outside url : $appAssociatedURL1 ');
            AppLinkService.instance.setOutsideURL(appAssociatedURL1);
          }
        } else if (Platform.isIOS) {
          PendingDynamicLinkData? urlData =
              await FirebaseDynamicLinks.instance.getInitialLink();
          String deepLinkUrl = '';
          if (urlData != null) {
            deepLinkUrl = urlData.link.toString();
            deepLinkUrl = AppUtils.addHttpsAndRemoveWww(deepLinkUrl);
            AppLinkService.instance.setOutsideURL(deepLinkUrl);
            // Fluttertoast.showToast(msg: '$deepLinkUrl');
            deepLinkUrl = '';
          } else {
            //Fluttertoast.showToast(msg: 'no deep-link');
          }
        } else {
          //Fluttertoast.showToast(msg: 'nothing');
        }

        if (StringUtils.isNotNullOrEmpty(AppPreferences.instance!.authToken)) {
          // yield NavigateToState(HomeRoute.name);
          CookieManager cManager = CookieManager.instance();
          await cManager.setCookie(
            // url: Uri.parse(AppFlavorConfig.instance!.HomePageURL!),
            url: Uri.parse('https://..org'), name: 'u_auth',
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
          event.generalCubit.performWhileLoginOrLanding(
              LoginUserResponse.fromJson(AppUtils.readJsonFromPrefFirebase()));
          await DefaultCacheManager().emptyCache();
          AppLinkService.initAppLinks();
          String? appAssociatedURL =
              await AppLinkService.instance.getInitialLink();
          if (appAssociatedURL != null) {
            if (appAssociatedURL
                .toString()
                .contains(AppFlavorConfig.instance!.baseURL2!)) {
              Fluttertoast.showToast(
                  msg: 'userStatus domain: $appAssociatedURL');
              AppLinkService.instance.setOutsideURL(appAssociatedURL);
            } else if (appAssociatedURL.toString().contains('.page.link')) {
              PendingDynamicLinkData? urlData =
                  await FirebaseDynamicLinks.instance.getDynamicLink(
                Uri.parse(appAssociatedURL),
              );
              String deepLinkUrl = '';
              if (urlData != null) {
                deepLinkUrl = urlData.link.toString();
                deepLinkUrl = AppUtils.addHttpsAndRemoveWww(deepLinkUrl);
                AppLinkService.instance.setOutsideURL(deepLinkUrl);
                Fluttertoast.showToast(msg: 'ASS $deepLinkUrl');
                deepLinkUrl = '';
              } else {
                Fluttertoast.showToast(msg: 'ASS no deep link');
              }
            } else {
              AppLinkService.instance.setOutsideURL(appAssociatedURL);
            }
          } else if (Platform.isIOS) {
            PendingDynamicLinkData? urlData =
                await FirebaseDynamicLinks.instance.getInitialLink();
            String deepLinkUrl = '';
            if (urlData != null) {
              deepLinkUrl = urlData.link.toString();
              deepLinkUrl = AppUtils.addHttpsAndRemoveWww(deepLinkUrl);
              AppLinkService.instance.setOutsideURL(deepLinkUrl);
              Fluttertoast.showToast(msg: '$deepLinkUrl');
              deepLinkUrl = '';
            } else {
              Fluttertoast.showToast(msg: 'no deep-link');
            }
          } else {
            // Fluttertoast.showToast(msg: 'nothing');
          }
          try {
            List<InternetAddress> result =
                await InternetAddress.lookup('google.com');

            if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
              /// Let's allow to handle no-internet catch on home page

            }
          } on SocketException catch (e, _) {
            /// Let's allow to handle no-internet catch on home page

          }
        } else {
          event.generalCubit.performWhileLoginOrLanding(null);
          yield NavigateToState(LoginPageParent.routeName);
        }

        /// Once landing logic is done we have to initFirebaseDeeplink
        FirebaseDeeplinkService.initFirebaseDeeplink(event.buildContext);
        // yield NavigateToState(MyInAppWebviewRoute.name);
      } catch (e, s) {
        FirebaseCrashlytics.instance.log('Something wrong with landing logic.');
        if (e is AppNetworkException) {
          FirebaseCrashlytics.instance.recordError(e, s, reason: e.message);
        } else {
          FirebaseCrashlytics.instance.recordError(e, s);
        }

        event.generalCubit.performLogout(reason: 'landing_bloc');
        yield NavigateToState(LoginPageParent.routeName);
      }
    }
  }

  Future<void> runAsyncCode() async {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
            onDidReceiveLocalNotification: onDidReceiveLocalNotification);
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse,
    );

    // Firebase.initializeApp();
    // set the publishable key for Stripe - this is mandatory
    // Stripe.publishableKey = 'stripePublishableKey';

    if (kDebugMode) {
      // Force disable Crashlytics collection while doing every day development.
      // Temporarily toggle this to true if you want to test crash reporting in your app.
      // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(false);
    } else {
      // Handle Crashlytics enabled status when not in Debug,
      // e.g. allow your users to opt-in to crash reporting.
    }
  }

  void onDidReceiveLocalNotification(
      int id, String? title, String? body, String? payload) {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
  }
}
