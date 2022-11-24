import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../shared/app_logging/app_log_helper.dart';
import '../shared/app_theme/app_colors/app_colors.dart';
import '../shared/app_webview/in_app/app_webview_widget.dart';
import '../shared/flavor/app_flutter_config.dart';
import '../shared/util/app_util.dart';

class SingleWebViewPageArgument {
  final String url;
  final String title;
  final bool? isItFromMyDonationCTA;
  final bool? isItFromNonHomePage;

  SingleWebViewPageArgument(this.url, this.title,
      {this.isItFromMyDonationCTA, this.isItFromNonHomePage});
}

class SingleWebViewPageParent extends StatelessWidget {
  static const String routeName = '/single-webview-page';

  const SingleWebViewPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SingleWebViewPageArgument args =
        ModalRoute.of(context)!.settings.arguments as SingleWebViewPageArgument;
    return SingleWebViewPage(args);
  }
}

class SingleWebViewPage extends StatefulWidget {
  final SingleWebViewPageArgument pageArgument;

  const SingleWebViewPage(this.pageArgument, {Key? key}) : super(key: key);

  @override
  _SingleWebViewPageState createState() => _SingleWebViewPageState();
}

class _SingleWebViewPageState extends State<SingleWebViewPage> {
  late InAppWebViewController _controller;

  @override
  void initState() {
    super.initState();
    AppLog.log('SingleWebview Page: ${widget.pageArgument.url}');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyWhite,
      child: SafeArea(
        top: Platform.isAndroid ? true : true,
        bottom: false,
        child: Scaffold(
          appBar: widget.pageArgument.isItFromMyDonationCTA != null &&
                  widget.pageArgument.isItFromMyDonationCTA!
              ? null
              : AppBar(
                  centerTitle: true,
                  leading: IconButton(
                    icon: Icon(
                      Platform.isAndroid
                          ? Icons.arrow_back
                          : CupertinoIcons.back,
                      color: AppColors.black75,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  elevation: 0,
                  backgroundColor: AppColors.greyWhite,
                  title: Text('test'),
                ),
          // body: Text('ONE'),
          body: AppWebviewWithProgressWidget(
            onRefresh: () async {
              if (Platform.isAndroid) {
                _controller.reload();
              } else if (Platform.isIOS) {
                _controller.loadUrl(
                    urlRequest: URLRequest(url: await _controller.getUrl()));
              }
            },
            context: context,
            url: widget.pageArgument.url,
            paramOnWebViewCreated: (InAppWebViewController controller) {
              _controller = controller;
            },
            paramOnLoadStart:
                (InAppWebViewController controller, Uri? url) async {},
            paramOnLoadStop: (InAppWebViewController controller, Uri? url) {
              if (url!.path.contains('privacy-policy.php') ||
                  url.path.contains('terms-of-use.php')) {
                controller.evaluateJavascript(
                    source:
                        "document.getElementsByClassName('container')[0].style.display = 'none';");
              }
            },
            paramOnUpdateVisitedHistory: (controller, url, androidIsReload) {
              AppLog.log('paramOnLoadStart: $url');
              if (widget.pageArgument.isItFromMyDonationCTA != null &&
                  widget.pageArgument.isItFromNonHomePage == null &&
                  widget.pageArgument.isItFromMyDonationCTA!) {
                if (url.toString().contains('paused=true')) {
                  Fluttertoast.showToast(
                    msg:
                        'Hi ${AppUtils.getUserName()}, Yoil ${url?.queryParameters['till']}',
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.grey,
                    textColor: Colors.white,
                    fontSize: 16.0,
                  );
                  Navigator.of(context).pop();
                }
              } else if (widget.pageArgument.isItFromNonHomePage != null &&
                  widget.pageArgument.isItFromNonHomePage!) {
                if (url!.path.contains('nonuser')) {
                  Navigator.of(context).pop();
                }
              }
            },
            //nonOnUpdateVisitedHistory: (controller, url, androidIsReload) {},
          ),
        ),
      ),
    );
  }
}
