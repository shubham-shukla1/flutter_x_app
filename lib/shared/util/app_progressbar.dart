import 'package:flutter/material.dart';
import 'package:flutter_x_app/shared/util/resources/resources.dart';
import 'package:lottie/lottie.dart';

class AppProgressBar {
  static AppProgressBar _instance = AppProgressBar._internal();

  AppProgressBar._internal();

  factory AppProgressBar() {
    return _instance;
  }

  static AppProgressBar get instance => _instance;

  BuildContext? _context;

  bool? _isShowing;

  void showProgressbarWithContext(BuildContext context) {
    this._context = context;
    _isShowing = true;
    // showDialog(context: context, builder: builder);
    showDialog<Widget>(
      context: _context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: Center(
            child: Container(
              height: 82,
              width: 82,
              child: AppCircularProgressbar(),
            ),
          ),
        );
      },
    );
  }

  void hideProgressBar() {
    if (_isShowing != null && _context != null && _isShowing!) {
      _isShowing = false;
      Navigator.pop(_context!);
    } //pop dialog
  }
}

class AppCircularProgressbar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Lottie.asset(SLottieAsset.spinner);
  }
}
