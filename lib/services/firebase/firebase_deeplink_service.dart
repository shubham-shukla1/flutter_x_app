import 'dart:async';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';

import '../../shared/app_constants.dart';
import '../../shared/app_logging/app_log_helper.dart';
import '../../view/single_webview_page.dart';
import '../clevertap/clevertap_service.dart';
import '../common_analytics_service/app_analytics_service.dart';

class FirebaseDeeplinkService {
  static FirebaseDeeplinkService? _instance;
  static String PARAM_APP_PATH = 'apppath';
  static String PARAM_TYPE = 'type';
  static String EVENT = 'event';
  static String PARAM1 = 'param1';
  static String PARAM2 = 'param2';
  static String PARAM3 = 'param3';
  static String PARAM4 = 'param4';
  static String PARAM_TITLE = 'title';
  static StreamController<Uri> _onLinkChangedStreamCntrl =
      StreamController<Uri>.broadcast();

  static FirebaseDeeplinkService get instance {
    if (_instance == null) {
      _instance = FirebaseDeeplinkService();
    }

    return _instance!;
  }

  static void initFirebaseDeeplink(BuildContext context) {
    /// When user open a app via link (App state = foreground or background)
    FirebaseDynamicLinks.instance.onLink;
    /*  FirebaseDynamicLinks.instance.onLink(
      onSuccess: (PendingDynamicLinkData? linkData) async {
        AppLog.log('F/B state deep-link ${linkData!.link.toString()}');
        final Uri? deepLink = linkData.link;

        if (deepLink != null) {
          handleLink(deepLink, context);
          if (linkData.link != null) {
            AppLog.log('F/B state found');
            _onLinkChangedStreamCntrl.add(linkData.link);
          }
        }
      },
      onError: (OnLinkErrorException error) async {
        AppLog.log(
          'OnLinkErrorException:',
          error: error,
        );
      },
    ); */

    /// When user open a app via link (app is terminated state)
    FirebaseDynamicLinks.instance.getInitialLink().then(
      (value) {
        final Uri? deepLink = value?.link;

        if (deepLink != null) {
          AppLog.log('terminated state deep-link ${deepLink.toString()}');
          handleLink(deepLink, context);
          if (value != null && value.link != null) {
            _onLinkChangedStreamCntrl.add(value.link);
          }
        }
      },
    );
  }

  void closeMyDPStream() {
    _onLinkChangedStreamCntrl.close();
  }

  Stream<Uri?> getMyDPStream() {
    return _onLinkChangedStreamCntrl.stream.asBroadcastStream();
  }

  static void handleLink(Uri pendingDynamicLinkData, BuildContext context) {
    /// Type = will be indicate type of link
    /// apppath = The path of the app navigation

    if (pendingDynamicLinkData.hasQuery &&
        pendingDynamicLinkData.queryParameters[PARAM_TYPE] != 'campaigns') {
      AppAnalyticsService.instance.notificationClicked();
    }

    if (pendingDynamicLinkData.hasQuery) {
      AppLog.log(
          'handleLink ${pendingDynamicLinkData.queryParameters[PARAM_APP_PATH]}');

      /// Navigate to that screen if app path is available.
      if (pendingDynamicLinkData.queryParameters[PARAM_APP_PATH] != null) {
        Navigator.of(context).pushNamed(
            '/${pendingDynamicLinkData.queryParameters[PARAM_APP_PATH]!}');
        // AutoRouter.of(context).pushNamed(
        //     '/${pendingDynamicLinkData.queryParameters[PARAM_APP_PATH]!}');
      }

      /// If type is URL then just open URL in another page
      if (pendingDynamicLinkData.queryParameters[PARAM_TYPE] == 'url') {
        String _url =
            pendingDynamicLinkData.origin + pendingDynamicLinkData.path;
        if (!_url.contains(AppConstants.playStoreURL) &&
            !_url.contains(AppConstants.appStoreURL)) {
          Navigator.of(context).pushNamed(
            SingleWebViewPageParent.routeName,
            arguments: SingleWebViewPageArgument(
              pendingDynamicLinkData.origin + pendingDynamicLinkData.path,
              pendingDynamicLinkData.queryParameters[PARAM_TITLE]!,
            ),
          );
        }

        // AutoRouter.of(context).push(
        //   SingleWebViewRoute(
        //     url: pendingDynamicLinkData.origin + pendingDynamicLinkData.path,
        //     title: pendingDynamicLinkData.queryParameters[PARAM_TITLE]!,
        //   ),
        // );
      }

      /// Detect campaigns
      if (pendingDynamicLinkData.queryParameters[PARAM_TYPE] == 'campaigns') {
        Map<String, dynamic> _properties = Map<String, dynamic>();
      
        CleverTapService.recordEvent(
            pendingDynamicLinkData.queryParameters[EVENT] ?? 'null');
      }
    }
  }
}
