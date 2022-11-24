import 'package:flutter/material.dart';
import '../../view/no_internet/new_no_internet_page.dart';



class NavigationService {
  static GlobalKey<NavigatorState> _navigationKey = GlobalKey<NavigatorState>();

  static GlobalKey<NavigatorState> get navigationKey => _navigationKey;

  static void pop() {
    return _navigationKey.currentState!.pop();
  }

  static Future<dynamic> navigateTo(
      {Widget? page, GlobalKey<NavigatorState>? navigationKey}) {
    if (navigationKey == null) {
      return _navigationKey.currentState!.push(MaterialPageRoute(
          builder: (context) => page ?? NewNoInternetPage()));
    } else
      return navigationKey.currentState!.push(MaterialPageRoute(
          builder: (context) => page ?? NewNoInternetPage()));
  }

  static void popScreen({GlobalKey<NavigatorState>? navigationKey}) {
    if (navigationKey == null) {
      _navigationKey.currentState!.pop();
    } else
      navigationKey.currentState!.pop();
  }
}
