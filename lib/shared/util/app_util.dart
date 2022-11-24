import 'dart:convert';
import 'dart:io';

import 'package:basic_utils/basic_utils.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/common_analytics_service/common_properties.dart';
import '../../services/local_pref/app_pref.dart';
import '../app_logging/app_log_helper.dart';
import '../common_importer.dart';
import '../flavor/app_flutter_config.dart';

class AppUtils {
  static Future<bool?> storeJsonRawInPref(Map<String, dynamic> json) async {
    return AppPreferences.instance!.setRawLoginUserJson(jsonEncode(json));
  }

  static Map<String, dynamic> readJsonFromPref() {
    return jsonDecode(AppPreferences.instance!.rawLoginUserJson)
        as Map<String, dynamic>;
  }

  static Future<bool?> storeJsonRawInPrefUserData(
      Map<String, dynamic> json) async {
    return AppPreferences.instance!.setRawLoginUserDataJson(jsonEncode(json));
  }

  static Map<String, dynamic> readJsonFromPrefUserData() {
    return jsonDecode(AppPreferences.instance!.rawLoginUserDataJson)
        as Map<String, dynamic>;
  }

  static void storeJsonRawInPrefFirebase(Map<String, dynamic> json) {
    AppPreferences.instance!.setRawFirebaseJson(jsonEncode(json));
  }

  static Map<String, dynamic> readJsonFromPrefFirebase() {
    return jsonDecode(AppPreferences.instance!.rawFirebaseJson)
        as Map<String, dynamic>;
  }

  static Future<void> launchOrShare(String url) async {
    if (await canLaunch(url)) {
      launch(url);
    } else {
      Share.share(url);
    }
  }

  static bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static void newFocus(BuildContext context) {
    FocusScope.of(context).requestFocus(FocusNode());
  }

  static List<String> internalAppURLs = StringUtils.isNotNullOrEmpty(
          FirebaseRemoteConfig.instance.getString('my_internal_scheme'))
      ? FirebaseRemoteConfig.instance.getString('my_internal_scheme').split(';')
      : <String>[
          'creativecdn.com',
          'bluekai.com',
          'hotjar.com',
          'doubleclick.net'
        ];

  static List<String> outSideAppURLs = StringUtils.isNotNullOrEmpty(
          FirebaseRemoteConfig.instance.getString('my_outside_urls'))
      ? FirebaseRemoteConfig.instance.getString('my_outside_urls').split(';')
      : <String>[];

  // static List<String> loginPages = StringUtils.isNotNullOrEmpty(
  //         FirebaseRemoteConfig.instance.getString('my_login_pages'))
  //     ? FirebaseRemoteConfig.instance.getString('my_login_pages').split(';')
  //     : <String>[];

  static List<String> loginPages = <String>[
    'new/signin',
    'login/login.php',
    'new/login'
  ];

  static List<String> appReviewPages = StringUtils.isNotNullOrEmpty(
          FirebaseRemoteConfig.instance.getString('in_app_review_pages'))
      ? FirebaseRemoteConfig.instance
          .getString('in_app_review_pages')
          .split(';')
      : <String>[];

  static List<String> outSideAppURLsForPlatform = StringUtils.isNotNullOrEmpty(
          FirebaseRemoteConfig.instance.getString('my_outside_urls_platform'))
      ? FirebaseRemoteConfig.instance
          .getString('my_outside_urls_platform')
          .split(';')
      : <String>[];

  static bool isExternalBrowserLink(Uri uri) {
    bool flag = false;

    /// These links are common in android and iOS
    for (var urlPath in AppUtils.outSideAppURLs) {
      if (uri.path.contains(urlPath)) {
        return true;
      }
    }

    /// These links are for platform specific
    for (var urlPath in AppUtils.outSideAppURLsForPlatform) {
      if (uri.path.contains(urlPath)) {
        return true;
      }
    }

    return flag;
  }

  static bool isLoginPages(Uri uri) {
    bool flag = false;

    /// These links are common in android and iOS
    for (var urlPath in AppUtils.loginPages) {
      if (uri.path.contains(urlPath)) {
        flag = true;
      }
    }

    if (flag == true &&
        uri.path.toString().contains('new/login') &&
        uri.queryParameters.containsKey('em') &&
        uri.queryParameters.containsKey('to')) {
      flag = false;
    }

    return flag;
  }

  static bool isAppReviewPages(Uri uri) {
    bool flag = false;

    /// These links are common in android and iOS
    for (var urlPath in AppUtils.appReviewPages) {
      if (uri.toString().contains(urlPath)) {
        return true;
      }
    }

    return flag;
  }

  // 0 means double equals to
  // 1 means not equals to
  static bool compareUrlPathMatching(String flavorUrl, Uri? webviewUri,
      {int conditionCompare = 0}) {
    bool flag = false;

    try {
      String webviewUrl = '${webviewUri?.origin}${webviewUri?.path}';

      // AppLog.log('Actual URL: ${webviewUrl}');
      // AppLog.log('Params URL: ${webviewUri.toString()}');

      if (conditionCompare == 0)
        flag = flavorUrl == webviewUrl;
      else
        flag = flavorUrl != webviewUrl;

      // AppLog.log('Compare Result ${conditionCompare}: ${flag}');
    } catch (e, s) {
      AppLog.log('Error while compareUrlPathMatching', error: e, stackTrace: s);
    }

    return flag;
  }

  // 0 means double equals to
  // 1 means not equals to
  static bool compareUrlPathMatching2(String flavorUrl, Uri? webviewUri,
      {int conditionCompare = 0}) {
    bool flag = false;
    String webviewUrl = '';
    try {
      if (StringUtils.isNotNullOrEmpty(webviewUri.toString())) {
        webviewUrl = '${webviewUri?.origin}${webviewUri?.path}';

        AppLog.log('Outside Actual URL: ${webviewUrl}');

        AppLog.log('Outside Params URL: ${webviewUri.toString()}');

        AppLog.log('Inside Flavor URL: ${flavorUrl}');

        if (conditionCompare == 0)
          flag = flavorUrl == webviewUrl;
        else
          flag = flavorUrl != webviewUrl;

        AppLog.log('Compare Result ${conditionCompare}: ${flag}');
      }
    } catch (e, s) {
      AppLog.log('message', error: e, stackTrace: s);
    }

    return flag;
  }

  static bool allowToLoadInternalLinks(Uri uri) {
    if (Platform.isAndroid) return true;

    /// These schemas are not allowed to open in web-view
    for (var urlPath in AppUtils.internalAppURLs) {
      if (uri.origin.contains(urlPath)) {
        return false;
      }
    }

    return true;
  }

  static Future<NavigationActionPolicy?> canLaunchAndCancelNavigationPolicy(
      String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceSafariVC: false);
      // and cancel the request
      return NavigationActionPolicy.CANCEL;
    } else {
      AppLog.log('Could not launch ${url}');
    }
  }

  static String getUserImageURL() {
    try {
      String imageURL = ' url';
      var prefData = AppUtils.readJsonFromPrefUserData();
      if (prefData['data']['avtar'] == null) {
        if (KFAS.instance.currentUser == null) {
          return imageURL;
        } else {
          if (KFAS.instance.currentUser!.photoURL != null) {
            return KFAS.instance.currentUser!.photoURL!;
          } else {
            return imageURL;
          }
        }
      } else {
        return prefData['data']['avtar']['cdn_path'].toString();
      }
    } catch (e, s) {
      AppLog.log('error getUserImageURL', error: e, stackTrace: s);
      return 'url';
    }
  }

  static String getUserName() {
    try {
      return CommonProperties.getInstance().name ??
          KFAS.instance.currentUser!.displayName ??
          '';
    } catch (e, s) {
      AppLog.log('Error while getting name', error: e, stackTrace: s);
      return '';
    }
  }

  static String replaceGetParam(String url, List<String> params) {
    if (params.length == 0) {
      return url;
    }
    for (int i = 0; i < params.length; i++) {
      url = url.replaceFirst('{}', params[i]);
    }
    return url;
  }

  static String addHttpsAndRemoveWww(String url) {
    if (!url.contains('https')) {
      url = url.replaceFirst('http', 'https');
    }

    url = url.replaceAll('www.', '');

    return url;
  }

  static String getStringByGivenNumber(String str, int number) {
    try {
      String result = '';
      result = str.length < number ? str : str.substring(0, number);
      return StringUtils.isNullOrEmpty(result) ? str : result;
    } catch (e) {
      return str;
    }
  }

  static Map<String, String> convertMapDynamicToString(
      Map<String, dynamic> params) {
    Map<String, String> stringQueryParameters = Map<String, String>();
    stringQueryParameters =
        params.map((key, value) => MapEntry(key, value?.toString() ?? ''));

    return stringQueryParameters;
  }
}

class MyInAppWebViewUtils {
  static InAppWebViewGroupOptions webViewGroupOptions =
      InAppWebViewGroupOptions(
    crossPlatform: InAppWebViewOptions(
      useShouldOverrideUrlLoading: true,
      mediaPlaybackRequiresUserGesture: false,
      javaScriptEnabled: true,
      allowUniversalAccessFromFileURLs: true,
      useOnDownloadStart: true,
      supportZoom: false,
      cacheEnabled: false,
    ),
    android: AndroidInAppWebViewOptions(
      useHybridComposition: true,
      thirdPartyCookiesEnabled: true,
      cacheMode: AndroidCacheMode.LOAD_NO_CACHE,
    ),
    ios: IOSInAppWebViewOptions(
      allowsInlineMediaPlayback: true,
    ),
  );
}
