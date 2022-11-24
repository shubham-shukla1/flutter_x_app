import 'dart:async';
import 'dart:io';

import 'package:app_settings/app_settings.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../own_package/internet_connectivity/static_index.dart';
import '../../shared/app_logging/app_log_helper.dart';
import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/util/app_scaffold.dart';

class NewNoInternetPageParent extends StatelessWidget {
  static final String routeName = '/no_internet_page';

  const NewNoInternetPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NewNoInternetPage();
  }
}

class NewNoInternetPage extends StatefulWidget {
  NewNoInternetPage({Key? key}) : super(key: key);

  @override
  _NewNoInternetPageState createState() => _NewNoInternetPageState();
}

class _NewNoInternetPageState extends State<NewNoInternetPage> {
  DateTime? currentBackPressTime;

  @override
  void initState() {
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
              onPressed: () async {
                try {
                  List<InternetAddress> result =
                      await InternetAddress.lookup('google.com');
                  if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
                    IndexClass.index = 0;
                    Navigator.of(context).pop();
                  } else {
                    Fluttertoast.showToast(
                      msg: 'Please use working internet connection.',
                    );
                  }
                } on SocketException catch (e, _) {
                  Fluttertoast.showToast(
                    msg: 'Please use working internet connection.',
                  );
                } catch (e, _) {
                  AppLog.log('Catch', error: e);
                }
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
  }

  Future<bool> _checkPopScope() async {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null) {
      currentBackPressTime = now;
      try {
        List<InternetAddress> result =
            await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          IndexClass.index = 0;
          Navigator.of(context).pop();
          return true;
        } else {
          Fluttertoast.showToast(
            msg: 'Please use working internet connection.',
          );
          return false;
        }
      } on SocketException catch (e, _) {
        Fluttertoast.showToast(
          msg: 'Please use working internet connection.',
        );
        return false;
      } catch (e, _) {}
    } else if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      try {
        List<InternetAddress> result =
            await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          IndexClass.index = 0;
          Navigator.of(context).pop();
          return true;
        } else {
          Fluttertoast.showToast(
            msg: 'Please use working internet connection.',
          );
          return false;
        }
      } on SocketException catch (e, _) {
        Fluttertoast.showToast(
          msg: 'Please use working internet connection.',
        );
        return false;
      } catch (e, _) {}
    }
    return Future.value(true);
  }
}
