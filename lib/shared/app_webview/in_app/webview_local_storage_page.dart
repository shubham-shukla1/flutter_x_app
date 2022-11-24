import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../presentation/app_webview/app_webview_cubit.dart';
import '../../common_importer.dart';
import '../../util/app_progressbar.dart';

class WebViewLocalStoragePage extends StatefulWidget {
  final InAppWebViewController controller;

  const WebViewLocalStoragePage({required this.controller, Key? key})
      : super(key: key);

  @override
  _WebViewLocalStoragePageState createState() =>
      _WebViewLocalStoragePageState();
}

class _WebViewLocalStoragePageState extends State<WebViewLocalStoragePage> {
  AppWebviewCubit? _appWebViewCntrl;

  @override
  void didChangeDependencies() {
    _appWebViewCntrl = BlocProvider.of<AppWebviewCubit>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Local storage'),
      ),
      body: ListView(
        children: [
          _buildLocalStorage(),
        ],
      ),
    );
  }

  Widget _buildLocalStorage() {
    // _webStorageManager.android.getOrigins().
    return FutureBuilder<List<WebStorageItem>>(
      // future: _appWebViewCntrl!.controller!.webStorage.localStorage.getItems(),
      future: widget.controller.webStorage.localStorage.getItems(),
      builder: (_, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return AppCircularProgressbar();
        } else if (ConnectionState.done == snapShot.connectionState) {
          if (snapShot.data == null || snapShot.data!.length == 0)
            return const Text('Data is\'n available');
          else {
            return Column(
              children: snapShot.data!.map((e) {
                return Column(
                  children: [
                    FutureBuilder(
                      future: widget.controller.getUrl(),
                      builder:
                          (BuildContext context, AsyncSnapshot<Uri?> snapshot) {
                        if (snapShot.data == null && !snapshot.hasData)
                          return SizedBox.shrink();
                        AppLog.log('${e.key} : ${e.value}');
                        return Padding(
                          padding: const EdgeInsets.only(
                            bottom: 6,
                          ),
                          child: snapshot.data != null
                              ? Text(
                                  'Host: ${snapshot.data!.host}',
                                  textAlign: TextAlign.start,
                                )
                              : SizedBox.shrink(),
                        );
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 6,
                      ),
                      child: Text(
                        '[${e.key}] : \n${e.value}',
                        textAlign: TextAlign.start,
                      ),
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.black,
                    ),
                  ],
                );
              }).toList(),
            );
          }
        } else
          return Text('else');
      },
    );
  }
}
