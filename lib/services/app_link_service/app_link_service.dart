import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../shared/app_logging/app_log_helper.dart';

class AppLinkService {
  static AppLinkService? _instance;
  static AppLinks? _appLinks;
  static String latestOpenedURl = '';
  static String outsideURL = '';
  static StreamController<Uri> _onLinkChangedStreamCntrl =
      StreamController<Uri>.broadcast();
  // static late Stream<Uri> onLinkChangedStream;

  static AppLinkService get instance {
    if (_instance == null) {
      _instance = AppLinkService();
    }

    return _instance!;
  }

  static void initAppLinks() {
    if (_instance == null) {
      _instance = AppLinkService();
    }
    _appLinks = AppLinks();
    /*   _appLinks = AppLinks(
      // Called when a new uri has been redirected to the app
      onAppLink: (Uri uri, String stringUri) {
        // Do something (navigation, ...)
        AppLog.log('onAppLink ${stringUri}');
        _onLinkChangedStreamCntrl.add(uri);
      },
    ); */
  }

  void closeMyStream() {
    _onLinkChangedStreamCntrl.close();
  }

  Stream<Uri?> getMyLinkStream() {
    return _onLinkChangedStreamCntrl.stream.asBroadcastStream();
  }

  Future<String?> getInitialLink() async {
    return await _appLinks?.getInitialAppLinkString();
  }

  Future<String?> getLatestLink() async {
    return await _appLinks?.getLatestAppLinkString();
  }

  String getLatestOpenedURL() {
    return latestOpenedURl;
  }

  void setLatestOpenedURL(String paramUrl) {
    latestOpenedURl = paramUrl;
  }

  String getOutsideURL() {
    return outsideURL;
  }

  void setOutsideURL(String paramUrl) {
    outsideURL = paramUrl;
  }
}
