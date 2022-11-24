import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/util/app_scaffold.dart';
import '../login/login_page.dart';

class NoInternetPageArgument {
  final String funnelName;

  NoInternetPageArgument(this.funnelName);
}

class NoInternetPageParent extends StatelessWidget {
  static final String routeName = '/no_internet_page';

  const NoInternetPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NoInternetPageArgument args =
        ModalRoute.of(context)!.settings.arguments as NoInternetPageArgument;
    return NoInternetPage(args);
  }
}

class NoInternetPage extends StatefulWidget {
  final NoInternetPageArgument pageArgument;

  NoInternetPage(this.pageArgument, {Key? key}) : super(key: key);

  @override
  _NoInternetPageState createState() => _NoInternetPageState();
}

class _NoInternetPageState extends State<NoInternetPage> {
  late StreamSubscription<ConnectivityResult> subscription;
  DateTime? currentBackPressTime;

  @override
  void initState() {
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      // Got a new connectivity status!

      if (result.index == ConnectivityResult.wifi.index ||
          result.index == ConnectivityResult.mobile.index) {
        if (widget.pageArgument.funnelName == 'supposeToLandHomePage') {
          //navigate

        } else if (widget.pageArgument.funnelName ==
            'supposedToLandLoginPage') {
          Navigator.of(context).pushReplacementNamed(
            LoginPageParent.routeName,
            arguments: LoginPageArgument(funnelName: 'noInternetPage'),
          );
        } else {
          Navigator.of(context).pop();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: WillPopScope(
        onWillPop: _checkPopScope,
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.scaffoldLight,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Platform.isAndroid ? Icons.arrow_back : CupertinoIcons.back,
                color: AppColors.black75,
              ),
              onPressed: () {
                subscription = Connectivity()
                    .onConnectivityChanged
                    .listen((ConnectivityResult result) {
                  // Got a new connectivity status!
                  if (result.index == ConnectivityResult.wifi.index ||
                      result.index == ConnectivityResult.mobile.index) {
                    if (widget.pageArgument.funnelName ==
                        'supposedToLandLoginPage') {
                      Navigator.of(context).pushReplacementNamed(
                        LoginPageParent.routeName,
                        arguments:
                            LoginPageArgument(funnelName: 'noInternetPage'),
                      );
                    } else {
                      Navigator.of(context).pop();
                    }
                  }
                });
                // AutoRouter.of(context).pop();
              },
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: Container()),
              Icon(
                Icons.sync_problem_rounded,
                size: 62,
                color: AppColors.darkBlue,
              ),
              SizedBox(
                height: 12,
              ),
              Text(
                'Use Wi-Fi or Mobile Data',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // fontFamily: 'Montserrat',
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkBlue,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Text(
                'Please connect with working internet connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  // fontFamily: 'Montserrat',
                  color: AppColors.darkBlue,
                  fontSize: 12,
                ),
              ),
              Expanded(child: Container()),
              TextButton(
                onPressed: () {
                  AppSettings.openDeviceSettings(asAnotherTask: true);
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 41),
                  height: 40,
                  child: Center(
                    child: Text(
                      'Open Settings',
                      style: TextStyle(
                        color: AppColors.darkBlue,
                        fontSize: 18,
                        // fontFamily: 'Montserrat',
                        decoration: TextDecoration.underline,
                        // fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  dispose() {
    super.dispose();

    subscription.cancel();
  }

  Future<bool> _checkPopScope() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null) {
      currentBackPressTime = now;
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.mobile &&
          connectivityResult != ConnectivityResult.wifi) {
        Fluttertoast.showToast(
          msg: 'Please use working internet connection.',
        );
        return false;
      } else {
        if (widget.pageArgument.funnelName == 'supposedToLandLoginPage') {
          Navigator.of(context).pushReplacementNamed(
            LoginPageParent.routeName,
            arguments: LoginPageArgument(funnelName: 'noInternetPage'),
          );
        } else {
          Navigator.of(context).pop();
        }

        return true;
      }
    } else if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      var connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.mobile &&
          connectivityResult != ConnectivityResult.wifi) {
        Fluttertoast.showToast(
          msg: 'Please use working internet connection.',
        );
        return false;
      } else {
        Navigator.of(context).pop();

        return true;
      }
    }

    return Future.value(true);
  }
}
