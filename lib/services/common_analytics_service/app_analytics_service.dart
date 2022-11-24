import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_x_app/shared/app_logging/app_log_helper.dart';

import '../clevertap/clevertap_service.dart';
import '../firebase/firebase_analytics_service.dart';
import '../network/network_exceptions.dart';
import '../system_event_service/system_event_service.dart';
import 'common_properties.dart';

class AppAnalyticsService {
  static AppAnalyticsService _instance = AppAnalyticsService._internal();

  AppAnalyticsService._internal();

  factory AppAnalyticsService() {
    return _instance;
  }

  static AppAnalyticsService get instance => _instance;

  Future<bool> notificationReceived() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      FirebaseAnalyticsService.instance.sendEvent(' notification received');
      CleverTapService.recordEvent(' notification received');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, ' notification received');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } on Exception catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  Future<bool> notificationClicked() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      FirebaseAnalyticsService.instance.sendEvent(' notification clicked');
      CleverTapService.recordEvent(' notification clicked');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, ' notification clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  Future<bool> giveMeTestNotification() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      FirebaseAnalyticsService.instance.sendEvent(' Give me notification');
      CleverTapService.recordEvent(' Give me notification');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, ' Give me notification');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  Future<bool> loginVia(String result, String status) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.putIfAbsent('result', () => result);
      _properties.putIfAbsent('status', () => status);
      final FirebaseAnalytics _firebaseAnalytics = FirebaseAnalytics.instance;
      _firebaseAnalytics.logLogin(loginMethod: result);
      FirebaseAnalyticsService.instance.sendEvent(
        ' App login',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        ' App login',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      _properties.putIfAbsent('info_3', () => 'status');
      _properties.putIfAbsent('info_4', () => status);
      return SystemEventService.callSystemEvent(_properties, ' App login');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: App login');
    }
  }

  Future<bool> TestEvent(String eventName) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      FirebaseAnalyticsService.instance.sendEvent(eventName);
      CleverTapService.recordEvent(eventName);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(_properties, eventName);
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  Future<bool> pageView(String pageName) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.addAll(_getPageName(pageName));
      // Firebase event
      FirebaseAnalyticsService.instance.sendEvent(
        'PageView',
        appProperties: _properties,
      );
      // Clevertap event
      CleverTapService.recordEvent(
        'PageView',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(_properties, 'PageView');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: PageView');
    }
  }

  Future<bool> loginDetailsEntered(String type, String value) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      if (type == 'email') {
        _properties.putIfAbsent('t_email', () => value);
        _properties.putIfAbsent('type', () => 'email');
      } else {
        _properties.putIfAbsent('t_phone', () => value);
        _properties.putIfAbsent('type', () => 'phone');
      }
      FirebaseAnalyticsService.instance.sendEvent(
        'Login details entered',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'Login details entered',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      if (type == 'email') {
        _properties.putIfAbsent('infor_1', () => 't_email');
        _properties.putIfAbsent('infor_2', () => value);
        _properties.putIfAbsent('infor_3', () => 'type');
        _properties.putIfAbsent('infor_4', () => 'email');
      } else {
        _properties.putIfAbsent('infor_1', () => 't_phone');
        _properties.putIfAbsent('infor_2', () => value);
        _properties.putIfAbsent('infor_3', () => 'type');
        _properties.putIfAbsent('infor_4', () => 'phone');
      }
      return SystemEventService.callSystemEvent(
          _properties, 'Login details entered');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Login details entered');
    }
  }

  Future<bool> signupOTPEntered(String value) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('otp', () => value);
      FirebaseAnalyticsService.instance.sendEvent(
        'nameApp_otp_entered',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'nameApp_otp_entered',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('infor_1', () => 'otp');
      _properties.putIfAbsent('infor_2', () => value);
      return SystemEventService.callSystemEvent(
          _properties, 'nameApp_otp_entered');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  Future<bool> otpSentResult(String otpSentResult) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => otpSentResult);
      FirebaseAnalyticsService.instance.sendEvent(
        ' OTP Result',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        ' OTP Result',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => otpSentResult);

      return SystemEventService.callSystemEvent(_properties, ' OTP Result');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called:  OTP Result');
    }
  }

  Future<bool> getOTPClicked(String result) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      FirebaseAnalyticsService.instance.sendEvent(
        'Get OTP clicked',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'Get OTP clicked',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      return SystemEventService.callSystemEvent(_properties, 'Get OTP clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Get OTP clicked');
    }
  }

  Future<void>? clickOnResendOTP() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      FirebaseAnalyticsService.instance.sendEvent(
        // 'NonnameSignup clicked',
        'nameApp_otp_resend_clicked',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        // 'NonnameSignup clicked',
        'nameApp_otp_resend_clicked',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'nameApp_otp_resend_clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<bool> loginClicked(String result) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      FirebaseAnalyticsService.instance.sendEvent(
        'Login clicked',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'Login clicked',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      return SystemEventService.callSystemEvent(_properties, 'Login clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Login clicked');
    }
  }

  Future<bool> errorMessage(String errMsg) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('error_message', () => errMsg);
      FirebaseAnalyticsService.instance.sendEvent(
        'Error message',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'Error message',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(_properties, 'Error message');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  /// Result posibilities  = GSuccess/GFail/APIException
  Future<bool> googleSignInResult(String result) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      FirebaseAnalyticsService.instance.sendEvent(
        'Google Sign In in result',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'Google Sign In in result',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      return SystemEventService.callSystemEvent(
          _properties, 'Google Sign In in result');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Google Sign In in result');
    }
  }

  Future<bool> googleSignInClicked(String result) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      FirebaseAnalyticsService.instance.sendEvent(
        'Google Sign in clicked',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'Google Sign in clicked',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      return SystemEventService.callSystemEvent(
          _properties, 'Google Sign in clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Google Sign in clicked');
    }
  }

  Future<bool> tcSubmitClicked(
    String result, {
    String? token,
  }) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      if (token != null) _properties.putIfAbsent('failed_token', () => token);
      FirebaseAnalyticsService.instance.sendEvent(
        'TrueCaller clicked',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'TrueCaller clicked',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      if (token != null) {
        _properties.putIfAbsent('info_3', () => 'failed_token');
        _properties.putIfAbsent('info_4', () => token);
      }

      return SystemEventService.callSystemEvent(
          _properties, 'TrueCaller clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: TrueCaller clicked');
    }
  }

  Future<bool> appLogout({String? reason}) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      if (reason != null) {
        _properties.putIfAbsent('reason', () => reason);
      }
      FirebaseAnalyticsService.instance.sendEvent(
        ' App Logout',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        ' App Logout',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(_properties, ' App Logout');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called:  App Logout');
    }
  }

  Future<bool> clickedOnBottomTab(int index) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('info_1', () => 'result');
      if (index == 0) {
        _properties.putIfAbsent('info_2', () => 'home');
      } else if (index == 1) {
        _properties.putIfAbsent('info_2', () => 'myname');
      } else if (index == 2) {
        _properties.putIfAbsent('info_2', () => 'updates');
      } else {
        _properties.putIfAbsent('info_2', () => 'activity');
      }
      FirebaseAnalyticsService.instance.sendEvent(
        'Click on icons',
        appProperties: _properties,
      );

      CleverTapService.recordEvent(
        'Click on icons',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      if (index == 0) {
        _properties.putIfAbsent('icon', () => 'home');
      } else if (index == 1) {
        _properties.putIfAbsent('icon', () => 'myname');
      } else if (index == 2) {
        _properties.putIfAbsent('icon', () => 'updates');
      } else {
        _properties.putIfAbsent('icon', () => 'activity');
      }
      return SystemEventService.callSystemEvent(_properties, 'Click on icons');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Click on icons');
    }
  }

  Future<bool> loginPageDropOff() {
    try {
      FirebaseAnalyticsService.instance.sendEvent(
        'Login page drop off',
      );

      CleverTapService.recordEvent(
        'Login page drop off',
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          Map<String, dynamic>(), 'Login page drop off');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: Login page drop off');
    }
  }

  Future<bool> appLaunched() {
    try {
      Map<String, dynamic> _properties = Map<String, dynamic>();
      _properties.putIfAbsent('app_name', () => 'name');
      FirebaseAnalyticsService.instance.sendEvent(
        'App app launched',
        appProperties: _properties,
      );

      CleverTapService.recordEvent(
        'App app launched',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      Map<String, dynamic> _properties = Map<String, dynamic>();
      _properties.putIfAbsent('info_1', () => 'app_name');
      _properties.putIfAbsent('info_2', () => 'name');
      return SystemEventService.callSystemEvent(
          _properties, 'App app launched');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    } finally {
      AppLog.log('Event called: App app launched');
    }
  }

  // Future<void>? clickedOnHomePageIcons(String icon) {
  //   // icons can be Home/Activity/Updates/Myname
  //   try {
  //     Map<String, dynamic> _properties = Map<String, dynamic>();
  //     _properties.addAll(_getUserProperties());
  //     _properties.putIfAbsent('icon', () => icon);

  //     FirebaseAnalyticsService.instance.sendEvent(
  //       'Click on icons',
  //       appProperties: _properties,
  //     );

  //     return CleverTapService.recordEvent(
  //       'Click on icons',
  //       properties: _properties,
  //     );
  //   } catch (e) {
  //     AppLog.log('Error ${e.toString()}');
  //   }

  //   try {
  //     SystemEventService.callSystemEvent(
  //         Map<String, dynamic>(), 'Click on icons');
  //   } on SystemEventException catch (e) {
  //     AppLog.log('SystemEventException ${e.toString()}');
  //   } catch (e) {
  //     AppLog.log('Error ${e.toString()}');
  //   }
  // }

  Future<void>? clickOnSignupButton() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      FirebaseAnalyticsService.instance.sendEvent(
        // 'NonnameSignup clicked',
        'Click on Sign up button',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        // 'NonnameSignup clicked',
        'Click on Sign up button',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'Click on Sign up button');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<bool> signUpResult(String result, {String? errorMessage}) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      if (result == 'failure') {
        _properties.putIfAbsent('error_message', () => errorMessage);
      }
      FirebaseAnalyticsService.instance.sendEvent(
        'nameApp_signup',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        'nameApp_signup',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'result');
      _properties.putIfAbsent('info_2', () => result);
      if (result == 'failure') {
        _properties.putIfAbsent('info_3', () => 'error message');
        _properties.putIfAbsent('info_4', () => errorMessage);
      }
      return SystemEventService.callSystemEvent(_properties, 'nameApp_signup');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
      return Future.value(false);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
      return Future.value(false);
    }
  }

  Future<void>? clickedOnMenuIcon() {
    Map<String, dynamic> _properties = Map<String, dynamic>();

    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      FirebaseAnalyticsService.instance.sendEvent(
        'Click on menu icon',
      );

      CleverTapService.recordEvent(
        'Click on menu icon',
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'Click on menu icon');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? clickedOnNotificationIcon() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      FirebaseAnalyticsService.instance.sendEvent(
        'Notification icon click',
      );

      CleverTapService.recordEvent(
        'Notification icon click',
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'Notification icon click');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? clickonLoginWithAnotherAccount() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      FirebaseAnalyticsService.instance.sendEvent(
        // 'Retry login clicked',
        'Click on Login with Another account',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        // 'Retry login clicked',
        'Click on Login with Another account',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'Click on Login with Another account');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? clickedOnMenuItems(String item) {
    // item can be Refer /Support / Logout
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('item', () => item);

      FirebaseAnalyticsService.instance.sendEvent(
        'Click on menu item',
        appProperties: _properties,
      );

      CleverTapService.recordEvent(
        'Click on menu item',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      _properties.putIfAbsent('info_1', () => 'item');
      _properties.putIfAbsent('info_2', () => item);
      return SystemEventService.callSystemEvent(
          _properties, 'Click on menu item');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? profileIconClicked() {
    // item can be Refer /Support / Logout
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());

      FirebaseAnalyticsService.instance.sendEvent(
        'Hamburget_profile_clicked',
        appProperties: _properties,
      );

      CleverTapService.recordEvent(
        'Hamburget_profile_clicked',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'Hamburget_profile_clicked');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? nonnamePageView() {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      FirebaseAnalyticsService.instance.sendEvent(
        // 'NonnameSignup page view',
        'name sign up page',
        appProperties: _properties,
      );
      CleverTapService.recordEvent(
        // 'NonnameSignup page view',
        'name sign up page',
        properties: _properties,
      );
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, 'name sign up page');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? forceUpdateCalled(String result, {String? errorMessage}) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      if (errorMessage != null) {
        _properties.putIfAbsent('errorMessage', () => errorMessage);
      }
      FirebaseAnalyticsService.instance
          .sendEvent(' force update called', appProperties: _properties);
      CleverTapService.recordEvent(' force update called',
          properties: _properties);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(
          _properties, ' force update called');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Future<void>? updateCalled(String result, {String? errorMessage}) {
    Map<String, dynamic> _properties = Map<String, dynamic>();
    try {
      _properties.addAll(_getSystemProperties());
      _properties.addAll(_getUserProperties());
      _properties.putIfAbsent('result', () => result);
      if (errorMessage != null) {
        _properties.putIfAbsent('errorMessage', () => errorMessage);
      }
      FirebaseAnalyticsService.instance
          .sendEvent(' update called', appProperties: _properties);
      CleverTapService.recordEvent(' update called', properties: _properties);
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }

    try {
      return SystemEventService.callSystemEvent(_properties, ' update called');
    } on SystemEventException catch (e) {
      AppLog.log('SystemEventException ${e.toString()}');
    } catch (e) {
      AppLog.log('Error ${e.toString()}');
    }
  }

  Map<String, dynamic> _getSystemProperties() {
    Map<String, dynamic> params = Map<String, dynamic>();
    params.putIfAbsent(
        'app_version', () => CommonProperties.getInstance().appVersion);
    params.putIfAbsent(
        'device_name', () => CommonProperties.getInstance().deviceName);
    params.putIfAbsent(
        'os_version', () => CommonProperties.getInstance().osVersion);
    params.putIfAbsent(
        'sdk_version', () => CommonProperties.getInstance().sdkVersion);
    return params;
  }

  Map<String, dynamic> _getUserProperties() {
    Map<String, dynamic> params = Map<String, dynamic>();
    params.putIfAbsent('user_id', () => CommonProperties.getInstance().userId);
    params.putIfAbsent(
        'entity_id', () => CommonProperties.getInstance().userId);
    params.putIfAbsent('name', () => CommonProperties.getInstance().name);
    params.putIfAbsent('phone', () => CommonProperties.getInstance().phone);
    params.putIfAbsent('email', () => CommonProperties.getInstance().email);
    return params;
  }

  Map<String, dynamic> _getPageName(String pageName) {
    Map<String, dynamic> params = Map<String, dynamic>();
    params.putIfAbsent('page_name', () => pageName);
    return params;
  }
}
