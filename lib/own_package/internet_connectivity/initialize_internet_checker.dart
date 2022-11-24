import 'package:flutter/material.dart';
//import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'navigation_Service.dart';
import 'static_index.dart';

class InternetChecker {
  InternetChecker({Widget? page, GlobalKey<NavigatorState>? navigationKey}) {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult value){
      if (value.index != ConnectivityResult.mobile.index &&
      value.index != ConnectivityResult.wifi.index) {
        print('Data connection is not available.');
        IndexClass.index = 1;
        NavigationService.navigateTo(
            page: page, navigationKey: navigationKey);
      }
      else {
        print('Data connection is available.');
        if (IndexClass.index == 1) {
          IndexClass.index = 0;
          NavigationService.popScreen(navigationKey: navigationKey);
        }
      }
    });
  }
}
