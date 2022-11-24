import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../../presentation/app_webview/app_webview_cubit.dart';
import '../../flavor/app_flutter_config.dart';
import '../../util/app_progressbar.dart';

class WebViewCookiePage extends StatefulWidget {
  final InAppWebViewController controller;

  const WebViewCookiePage({required this.controller, Key? key})
      : super(key: key);

  @override
  _WebViewCookiePageState createState() => _WebViewCookiePageState();
}

class _WebViewCookiePageState extends State<WebViewCookiePage> {
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
        title: Text('Cookie data'),
      ),
      body: ListView(
        children: [
          _buildCookieStorage(),
        ],
      ),
    );
  }

  Widget _buildCookieStorage() {
    // _webStorageManager.android.getOrigins().
    return FutureBuilder<List<Cookie>>(
      // future: _appWebViewCntrl!.controller!.webStorage.localStorage.getItems(),
      future: CookieManager.instance().getCookies(
          url: Uri.parse(AppFlavorConfig.instance!.baseURL!)),
      builder: (_, snapShot) {
        if (snapShot.connectionState == ConnectionState.waiting) {
          return AppCircularProgressbar();
        } else if (ConnectionState.done == snapShot.connectionState) {
          if (snapShot.data == null || snapShot.data!.length == 0)
            return const Text('Data is\'n available');
          else
            return Column(
              children: snapShot.data!.map((e) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 6,
                      ),
                      child: Text(
                        '[${e.name}] : \n${e.value}',
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
        } else
          return Text('else');
      },
    );
  }
}
