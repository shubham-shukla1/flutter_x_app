import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_path_provider/android_path_provider.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/services.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_x_app/shared/app_logging/app_log_helper.dart';
import 'package:flutter_x_app/shared/app_theme/app_colors/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';

import '../../../presentation/general/general_cubit.dart';
import '../../../services/common_analytics_service/app_analytics_service.dart';
import '../../../services/local_pref/app_pref.dart';
import '../../../services/network/network_exceptions.dart';
import '../../../view/login/login_page.dart';
import '../../common_importer.dart';
import '../../flavor/app_flutter_config.dart';
import '../../util/app_util.dart';

class AppWebviewWithProgressWidget extends StatefulWidget {
  final Function(InAppWebViewController controller, Uri? url) paramOnLoadStart;
  final Function(InAppWebViewController controller, Uri? url) paramOnLoadStop;
  final Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
      paramOnUpdateVisitedHistory;
  final Function(InAppWebViewController controller) paramOnWebViewCreated;
  final Function(InAppWebViewController controller, Uri? url, int code,
      String message)? paramOnLoadError;
  final Function(InAppWebViewController controller, int progress)?
      paramOnProgress;
  final String? url;
  final BuildContext? context;

  final Function() onRefresh;

  const AppWebviewWithProgressWidget(
      {required this.paramOnLoadStart,
      required this.paramOnLoadStop,
      required this.paramOnWebViewCreated,
      required this.onRefresh,
      this.paramOnLoadError,
      this.paramOnProgress,
      this.url,
      this.context,
      this.paramOnUpdateVisitedHistory,
      Key? key})
      : super(key: key);

  @override
  State<AppWebviewWithProgressWidget> createState() =>
      _AppWebviewWithProgressWidgetState();
}

class _AppWebviewWithProgressWidgetState
    extends State<AppWebviewWithProgressWidget> {
  late PullToRefreshController _pulltoRefreshController;

  double progressBar = 0;

  @override
  void initState() {
    super.initState();
    _pulltoRefreshController = PullToRefreshController(
      options: PullToRefreshOptions(
        color: AppColors.darkBlue,
      ),
      onRefresh: widget.onRefresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AppWebViewWidget(
          paramOnLoadStart: widget.paramOnLoadStart,
          paramOnLoadStop: widget.paramOnLoadStop,
          paramOnWebViewCreated: widget.paramOnWebViewCreated,
          context: widget.context,
          paramOnLoadError: widget.paramOnLoadError,
          paramOnProgress: (_, progress) {
            if (progress == 100) {
              _pulltoRefreshController.endRefreshing();
            }
            setState(() {
              progressBar = progress / 100;
              widget.paramOnProgress?.call(_, progress);
            });
          },
          paramOnUpdateVisitedHistory: widget.paramOnUpdateVisitedHistory,
          url: widget.url,
          pulltoRefreshController: _pulltoRefreshController,
        ),
        progressBar < 1.0
            ? LinearProgressIndicator(
                value: progressBar,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.darkBlue),
                backgroundColor: Colors.white,
              )
            : SizedBox.shrink(),
      ],
    );
  }
}

class AppWebViewWidget extends InAppWebView {
  final Function(InAppWebViewController controller, Uri? url) paramOnLoadStart;
  final Function(InAppWebViewController controller, Uri? url) paramOnLoadStop;
  final Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)?
      paramOnUpdateVisitedHistory;
  final Function(InAppWebViewController controller) paramOnWebViewCreated;
  final Function(InAppWebViewController controller, Uri? url, int code,
      String message)? paramOnLoadError;
  final Function(InAppWebViewController controller, int progress)?
      paramOnProgress;
  final String? url;
  final PullToRefreshController pulltoRefreshController;
  late String _localPath;
  bool isStorageSet = false;
  BuildContext? context;

  AppWebViewWidget({
    required this.paramOnLoadStart,
    required this.paramOnLoadStop,
    required this.paramOnWebViewCreated,
    required this.pulltoRefreshController,
    this.paramOnLoadError,
    this.paramOnProgress,
    this.url,
    this.context,
    this.paramOnUpdateVisitedHistory,
  });

  @override
  URLRequest? get initialUrlRequest {
    return url == null
        ? URLRequest(
            url: Uri.parse(AppFlavorConfig.instance!.baseURL!),
          )
        : URLRequest(
            url: Uri.parse(url!),
          );
  }

  @override
  InAppWebViewGroupOptions? get initialOptions =>
      MyInAppWebViewUtils.webViewGroupOptions;

  @override
  void Function(InAppWebViewController controller) get onWebViewCreated =>
      (cntrl) {
        paramOnWebViewCreated.call(cntrl);
      };

  @override
  PullToRefreshController? get pullToRefreshController =>
      pulltoRefreshController;

  @override
  Future<JsBeforeUnloadResponse?> Function(InAppWebViewController controller,
          JsBeforeUnloadRequest jsBeforeUnloadRequest)
      get androidOnJsBeforeUnload => (cntrl, jsBeforeJsRequest) async {
            AppLog.log('androidOnJsBeforeUnload');
            return JsBeforeUnloadResponse();
          };

  @override
  void Function(InAppWebViewController controller, Uri? url) get onLoadStart =>
      (cntrl, uri) async {
        AppLog.log('onLoadStart: ${uri.toString()}');

        if (AppUtils.isLoginPages(uri!)) {
          AppLog.log('User doesn\'t have rights to access  pages.');
          if (context != null) {
            try {
              BlocProvider.of<GeneralCubit>(context!)
                  .performLogout(reason: 'session_expired')
                  .then((value) {
                Fluttertoast.showToast(msg: 'Session expired!');
                Navigator.of(context!)
                    .pushReplacementNamed(LoginPageParent.routeName);
                // AutoRouter.of(context!).replace(
                //   LoginRoute(),
                // );
              });
            } catch (e, s) {
              AppLog.log('Error while session expired!',
                  stackTrace: s, error: e);
            }
          }
        }

        if (AppUtils.isAppReviewPages(uri)) {
          /* AppAnalyticsService.instance
              .techTestEvent('Tech - InAppReview detected'); */
          final InAppReview inAppReview = InAppReview.instance;
          if (await inAppReview.isAvailable()) {
            /*  AppAnalyticsService.instance
                .techTestEvent('Tech - InAppReview requestReview'); */
            AppLog.log('InAppReview requestReview');
            inAppReview.requestReview().then((value) {
              /* AppAnalyticsService.instance
                  .techTestEvent('Tech - InAppReview requestReview success'); */
              AppLog.log('InAppReview requestReview success');
            }).catchError((error) {
              /*   AppAnalyticsService.instance
                  .techTestEvent('Tech - InAppReview requestReview error'); */
              AppLog.log('InAppReview requestReview error: $error');
            });
          } else {
            /* AppAnalyticsService.instance
                .techTestEvent('Tech - InAppReview notAvailable'); */
            AppLog.log('InAppReview notAvailable');
          }
        }

        // This condition means non  webpage
        if (!uri.toString().contains(AppFlavorConfig.instance!.baseURL!)) {
          isStorageSet = true;
          AppLog.log('onLoadStart: Non  Page ${uri.toString()}');

          var _userLoggedInData;

          try {
            var rJFP = AppUtils.readJsonFromPref();
            if (rJFP['data'] != null)
              _userLoggedInData = rJFP['data'] as Map<String, dynamic>;

            // _userLoggedInData = null;
            // put user is logged in user
            (_userLoggedInData['user'] as Map<String, dynamic>)
                .putIfAbsent('isLoggedIn', () => true);
            (_userLoggedInData['user'] as Map<String, dynamic>)
                .putIfAbsent('isApp', () => true);

            String user = jsonEncode(
              _userLoggedInData,
            );
            // set variable null for memory
            _userLoggedInData = Map<String, dynamic>();

            Future<void> settingUserFuture = cntrl.webStorage.localStorage
                .setItem(key: 'user', value: '${user}');

            settingUserFuture
              ..onError((error, stackTrace) {
                AppLog.log('Error while setItem(user ',
                    error: error, stackTrace: stackTrace);
              }).whenComplete(() {
                // AppLog.log('setItem(user completed URL : ${uri.host}');
                // AppLog.log('User object: ${user}');
              });

            String? userData;

            userData = jsonEncode(
              AppUtils.readJsonFromPrefUserData()['data'],
            );

            Future<void> settingUserDataFuture = cntrl.webStorage.localStorage
                .setItem(key: 'userdata', value: '${userData}');

            settingUserDataFuture.onError((error, stackTrace) {
              AppLog.log('Error while setItem(userdata ',
                  error: error, stackTrace: stackTrace);
            }).whenComplete(() {
              // AppLog.log('setItem(userdata completed URL : ${uri.host}');
              // AppLog.log('Userdata object: ${userData}');
            });

            var futures = <Future>[settingUserDataFuture, settingUserFuture];

            Future.wait(futures).then((value) async {
              try {
                if (StringUtils.isNotNullOrEmpty(
                    AppPreferences.instance!.authToken)) {
                  Cookie? SessionId = await CookieManager.instance().getCookie(
                    url: Uri.parse(AppFlavorConfig.instance!.baseURL!),
                    name: AppFlavorConfig.instance!.isDevelopment!
                        ? 'PHPSESSID'
                        : 'SESSID',
                  );

                  if (SessionId != null) {
                    try {
                      KApi.instance.loginPage(
                        AppPreferences.instance!.authToken,
                        SessionId.value as String,
                      );
                      AppPreferences.instance!.setPhpPageCookie(true);
                    } on AppNetworkException catch (e) {
                      FirebaseCrashlytics.instance
                          .recordError(e.error, e.stack);
                    }
                  }
                }
              } catch (e, s) {
                AppLog.log('Error while setPhpCookie code',
                    error: e, stackTrace: s);
              }
            });

            cntrl.webStorage.localStorage
                .setItem(
              key: 'tech-host',
              value: 'non-webpage',
            )
                .onError((error, stackTrace) {
              AppLog.log('Error while setItem(user ',
                  error: error, stackTrace: stackTrace);
            }).whenComplete(() {
              AppLog.log('setItem(user completed URL : ${uri.host}');
            });
          } on FormatException catch (e, s) {
            // FirebaseCrashlytics.instance.recordError(e, s);
            AppLog.log('FormatException', error: e, stackTrace: s);
          } catch (e, s) {
            AppLog.log('Catch', error: e, stackTrace: s);
          }
        } else {
          AppLog.log('onLoadStart:  Page ${uri.toString()}');
          cntrl.webStorage.localStorage
              .setItem(
            key: 'tech-host',
            value: 'webpage',
          )
              .onError((error, stackTrace) {
            AppLog.log('Error while setItem(user ',
                error: error, stackTrace: stackTrace);
          }).whenComplete(() {
            AppLog.log('setItem(user completed URL : ${uri.host}');
          });
        }

        paramOnLoadStart.call(cntrl, uri);
      };

  @override
  void Function(
          InAppWebViewController controller, Uri? url, bool? androidIsReload)
      get onUpdateVisitedHistory => (cntrl, url, androidIsReload) async {
            AppLog.log('onUpdateVisitedHistory ${url.toString()}');

            if (paramOnUpdateVisitedHistory != null) {
              paramOnUpdateVisitedHistory!.call(cntrl, url, androidIsReload);
            }
          };

  @override
  void Function(InAppWebViewController controller, Uri? url) get onLoadStop =>
      (cntrl, uri) async {
        try {
          cntrl.evaluateJavascript(
              source:
                  " var style = document.createElement('style');style.innerHTML = `body {-webkit-touch-callout: none;-webkit-user-select: none;-khtml-user-select: none;-moz-user-select: none;-ms-user-select: none;user-select: none;}`;document.body.appendChild(style);");
          AppLog.log('onLoadStop: ${uri.toString()}');
        } catch (e) {
          AppLog.log('onLoadStop Evaluate Javascript error ${e.toString()}');
        }

        paramOnLoadStop.call(cntrl, uri);
      };

  @override
  void Function(InAppWebViewController controller,
      ConsoleMessage consoleMessage) get onConsoleMessage => (cntrl,
          consoleMsg) async {
        /// works for android only
        if (Platform.isAndroid) {
          if (consoleMsg.message.toString().contains('info_1=referral_page')) {
            var html = cntrl.evaluateJavascript(
                source: "document.getElementsByClassName('text')[2].innerText");
            html.then((value) {
              if (value.toString() != 'null')
                Clipboard.setData(ClipboardData(text: value.toString()));
            });
          } else if (consoleMsg.message
              .toString()
              .contains('info_1=tc_claim_page')) {
            var html = cntrl.evaluateJavascript(
                source: "document.getElementsByClassName('text')[0].innerText");
            html.then((value) {
              if (value.toString() != 'null')
                Clipboard.setData(ClipboardData(text: value.toString()));
            });
          }
        }

        /// shared for all the platform
        if (consoleMsg.message
            .toString()
            .toLowerCase()
            .contains('tech share')) {
          /*  AppAnalyticsService.instance
              .techTestEvent('Tech - Share detected'); */
          String param = consoleMsg.message.toString();
          var arr = param.split('~');
          try {
            String title = arr[1];
            String text = arr[2];
            String url = arr[3];
            Share.share(
              '$text\n$url',
              subject: title,
            );
          } catch (e) {
            AppLog.log('Share error: ${e.toString()}');
          }
        } else if (consoleMsg.message
            .toString()
            .contains('Tech in-app-review')) {
          /* AppAnalyticsService.instance
              .techTestEvent('Tech - InAppReview detected'); */
          final InAppReview inAppReview = InAppReview.instance;
          if (await inAppReview.isAvailable()) {
            /*  AppAnalyticsService.instance
                .techTestEvent('Tech - InAppReview requestReview'); */
            AppLog.log('InAppReview requestReview');
            inAppReview.requestReview().then((value) {
              /*  AppAnalyticsService.instance
                  .techTestEvent('Tech - InAppReview requestReview success'); */
              AppLog.log('InAppReview requestReview success');
            }).catchError((error) {
              /*   AppAnalyticsService.instance
                  .techTestEvent('Tech - InAppReview requestReview error'); */
              AppLog.log('InAppReview requestReview error: $error');
            });
          } else {
            /*  AppAnalyticsService.instance
                .techTestEvent('Tech - InAppReview notAvailable'); */
            AppLog.log('InAppReview notAvailable');
          }
        } else if (consoleMsg.message.toString().contains('tech-app-copy')) {
          try {
            String param = consoleMsg.message.toString();
            Clipboard.setData(
              ClipboardData(
                text: param.toString().substring(14, param.length),
              ),
            );
          } catch (e) {}
        }
        cntrl.getUrl().then((value) {
          AppLog.log('console[${value}] : ${consoleMsg.message}');
        });
      };

  @override
  void Function(
          InAppWebViewController controller, Uri? url, int code, String message)
      get onLoadError => (cntrl, uri, i, message) {
            AppLog.log('onLoadError:${uri.toString()}');
            AppLog.log(
                'Failed URL : ${uri?.data.toString()} \n Description: $message');
            if (paramOnLoadError != null)
              paramOnLoadError!.call(cntrl, uri, i, message);
          };

  @override
  void Function(InAppWebViewController controller, int progress)
      get onProgressChanged => (cntrl, progress) {
            if (paramOnProgress != null) paramOnProgress!.call(cntrl, progress);
          };

  @override
  Future<NavigationActionPolicy?> Function(
          InAppWebViewController controller, NavigationAction navigationAction)
      get shouldOverrideUrlLoading => (cntrl, navigationAction) async {
            Uri uri = navigationAction.request.url!;
            AppLog.log('shouldOverrideUrlLoading ${uri.toString()}');
            bool newLoginPageCondition =
                uri.path.toString().contains('new/login') &&
                    uri.queryParameters.containsKey('em') &&
                    uri.queryParameters.containsKey('to');
            if (![
              'http',
              'https',
              'file',
              'chrome',
              'data',
              'javascript',
              'about'
            ].contains(uri.scheme)) {
              if (await canLaunch(uri.data.toString())) {
                // Launch the App
                await launch(
                  uri.data.toString(),
                );

                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              } else if (uri.toString().contains('mailto:') ||
                  uri.toString().contains('tel:')) {
                // Launch the App
                try {
                  await launch(
                    uri.toString(),
                  );
                } catch (e, s) {
                  AppLog.log(
                      'Error while launching mailto or tel ${uri.toString()}',
                      error: e,
                      stackTrace: s);
                }

                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              } else if (uri.toString().contains('upi:')) {
                // Launch the App
                try {
                  await launch(
                    uri.toString(),
                  );
                } catch (e, s) {
                  AppLog.log(
                      'Error while launching mailto or tel ${uri.toString()}',
                      error: e,
                      stackTrace: s);
                }

                // and cancel the request
                return NavigationActionPolicy.CANCEL;
              }
            } else if (AppUtils.isExternalBrowserLink(uri)) {
              await AppUtils.canLaunchAndCancelNavigationPolicy(uri.toString());

              return NavigationActionPolicy.CANCEL;
            } else if (newLoginPageCondition) {
              AppUtils.canLaunchAndCancelNavigationPolicy(uri.toString());

              return NavigationActionPolicy.CANCEL;
            }
            // If this is not a 's URL, continue with the default behavior
            else if (!uri.origin.contains('.org')) {
              // Get the URL from the navigation action
              String url = '${uri.origin}${uri.path}';
              // check if this URI contains a query string
              if (uri.query.isNotEmpty) url += '?${uri.query}';

              if (url.contains('facebook.com/sharer/sharer.php')) {
                AppLog.log('Facebook sharing...');
                AppUtils.canLaunchAndCancelNavigationPolicy(url);
                return NavigationActionPolicy.CANCEL;
              }
              // Launch the URL
              else if (url.contains('web.whatsapp.com') ||
                  url.contains('api.whatsapp.com')) {
                if (await canLaunch(url)) {
                  await launch(
                      url.replaceFirst(
                          RegExp('web.whatsapp.com'), 'api.whatsapp.com'),
                      forceSafariVC: false);
                  // and cancel the request
                  return NavigationActionPolicy.CANCEL;
                } else {
                  AppLog.log('Could not launch $url');
                }
              } else {
                if (AppUtils.allowToLoadInternalLinks(uri))
                  return AppUtils.canLaunchAndCancelNavigationPolicy(url);
              }
            }
          };

  @override
  void Function(InAppWebViewController controller, Uri url)
      get onDownloadStart =>
          (InAppWebViewController controller, Uri uri) async {
            AppLog.log('onDownloadStart: ${uri.toString()}');
            bool perm = await _checkPermission();
            if (perm) {
              await _prepareSaveDir();

              // Get the URL from the navigation action
              FlutterDownloader.enqueue(
                url: uri.toString(),
                savedDir: _localPath,
                showNotification: true,
                // show download progress in status bar (for Android)
                openFileFromNotification: true,
                saveInPublicStorage: true,
                fileName: uri.toString().contains('certificate')
                    ? 'Certificate${DateTime.now().millisecondsSinceEpoch}.png'
                    : '${DateTime.now().millisecondsSinceEpoch}',
              );

              FlutterDownloader.registerCallback(downloadCallback);
              Fluttertoast.showToast(
                msg: FirebaseRemoteConfig.instance
                    .getString('files_download_in_progress'),
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0,
              );
            } else {
              Fluttertoast.showToast(
                msg: 'You dont\'t have storage permission! Retry again later',
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.grey,
                textColor: Colors.white,
                fontSize: 16.0,
              );
              AppLog.log('Permission denied');
            }
            // FlutterDownloader.enqueue(
            //   url: url.path,
            //   savedDir: (await getExternalStorageDirectory())!.path,
            //   showNotification:
            //       true, // show download progress in status bar (for Android)
            //   openFileFromNotification: true,
            // );

            // FlutterDownloader.registerCallback(downloadCallback);
          };

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('MyAppProgress' + id)!;
    send.send([id, status, progress]);
  }

  Future<Directory?> _findLocalPath() async {
    String externalStorageDirPath = '';
    if (Platform.isAndroid) {
      try {
        externalStorageDirPath = await AndroidPathProvider.downloadsPath;
      } catch (e) {
        final directory = await getExternalStorageDirectory();
        externalStorageDirPath = directory!.path;
      }
    } else if (Platform.isIOS) {
      externalStorageDirPath =
          (await getApplicationDocumentsDirectory()).absolute.path;
    }
    return Directory(externalStorageDirPath);
  }

  Future<bool> _checkPermission() async {
    if (Platform.isIOS) {
      return true;
    }
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    if (androidInfo.version.sdkInt <= 28 && Platform.isAndroid) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> _prepareSaveDir() async {
    _localPath = (await _findLocalPath())!.path;
    final savedDir = Directory(_localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }
}
