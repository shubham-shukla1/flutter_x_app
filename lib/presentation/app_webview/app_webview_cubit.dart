import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

part 'app_webview_state.dart';

class AppWebviewCubit extends Cubit<AppWebviewState> {
  AppWebviewCubit() : super(AppWebviewInitial());
  InAppWebViewController? _controller;

  InAppWebViewController? get controller => _controller;

  StreamController<int> _webviewProgressStreamCntrl = StreamController();

  StreamController<int> get webViewProgressStreamCntrl =>
      _webviewProgressStreamCntrl;

  void updateAppWebViewModel() {}

  Future<void> initialiseController(InAppWebViewController controller) async {
    _controller = controller;
  }

  Future<void> goBack() async {
    InAppWebViewController? a = _controller;
    if (await a!.canGoBack()) {
      a.goBack();
    }
  }

  Future<void> goForward() async {
    InAppWebViewController? a = _controller;
    if (await a!.canGoForward()) {
      a.goForward();
    }
  }

  Future<void> loadUrl(String url) async {
    InAppWebViewController? a = _controller;
    try {
      a!.loadUrl(
        urlRequest: URLRequest(
          url: Uri.parse(
            url,
          ),
        ),
      );
    } catch (e) {
      print(e);
    }
    ;
  }

  @override
  Future<void> close() {
    _webviewProgressStreamCntrl.close();
    return super.close();
  }
}
