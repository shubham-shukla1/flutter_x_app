// ignore_for_file: unnecessary_null_comparison

import 'dart:io';
import 'dart:convert';

import 'package:basic_utils/basic_utils.dart';
import 'package:dio/dio.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_x_app/services/network/dio_getter.dart';

import 'package:http/http.dart' as http;

import '../../shared/app_constants.dart';
import '../../shared/app_logging/app_log_helper.dart';
import '../../shared/flavor/app_flutter_config.dart';
import '../../shared/util/app_util.dart';
import '../../model/login/login_user_response.dart';
import '../local_pref/app_pref.dart';
import 'network_exceptions.dart';

// 1  USER
// 2- LAPSE
// 4 cancel, 5 request for cancel
// 3 and 6 are non- user
enum UserStatus {
  _USER,
  LAPSE_USER,
  CANCEL_USER, // 4 cancel, 5 request for cancel
  NON__USER, // 3 and 6
}

abstract class NetworkServiceAbstract {
  Future<LoginUserResponse> loginViaGoogleToken(
    String accessToken,
  );

  Future<LoginUserResponse> loginViaTrueCaller(
    String phoneNumber,
    String extension,
    String payload,
    String signature,
  );

  Future<LoginUserResponse> loginViaMobileOTP(
    String request,
  );

  Future<bool> verifyMobileNumberAttempts(String request);

  Future<LoginUserResponse> loginViaEmailOTP(
    String email,
    String otpCode,
  );

  Future<bool> sentEmailOTP(String email);

  Future<UserStatus> UserStatusCheck();

  Future<bool> loginPage(
    String token,
    String sessionId,
  );

  Future<LoginUserResponse?> registerNewUser(
    String? extension,
    String? email,
    String password,
    String? phoneNumber,
    String fullName,
    String? accessToken,
  );
}

class NetworkServiceImplementation implements NetworkServiceAbstract {
  static NetworkServiceImplementation? _instance;

  static NetworkServiceImplementation get instance {
    if (_instance == null) {
      _instance = NetworkServiceImplementation();
    }
    return _instance!;
  }

  void setAuthToken(String token) {
    DioNetworkService.instance.setToken = token;
  }

  @override
  Future<LoginUserResponse> loginViaGoogleToken(String accessToken) async {
    // final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
    //     '${DioNetworkService.instance.getMyDio().options.baseUrl}callback/google',
    //     HttpMethod.Get);
    final Trace myTraceGoogle =
        FirebasePerformance.instance.newTrace('callback_google');

    // await metric.start();
    myTraceGoogle.start();

    Response<Map<String, dynamic>>? response;
    Map<String, dynamic> params = Map<String, dynamic>();
    params['code'] = accessToken;
    try {
      response = await DioNetworkService.instance
          .getMyDio()
          .get<Map<String, dynamic>>('callback/google',
              queryParameters: params);

      if (!(response.data!['error'] as bool)) {
        await AppUtils.storeJsonRawInPref(
            (response.data as Map<String, dynamic>));
        // var userMap = response.data as Map<String, dynamic>;
        // // userMap!.putIfAbsent('isLoggedIn', () => true);
        // AppUtils.storeJsonRawInPref((userMap));
        return LoginUserResponse.fromJson(response.data);
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: 'Unhandled',
        );
      }
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
      );
    } finally {
      // await metric.stop();
      myTraceGoogle.stop();
    }
  }

  @override
  Future<LoginUserResponse> loginViaTrueCaller(
    String phoneNumber,
    String extension,
    String payload,
    String signature,
  ) async {
    Response<Map<String, dynamic>>? response;
    Map<String, dynamic> params = Map<String, dynamic>();
    params['phone'] = phoneNumber;
    params['extension'] = extension;
    params['payload'] = payload;
    params['signature'] = signature;
    try {
      Dio dio = DioNetworkService.instance.getMyDio();
      // dio.options.baseUrl = AppFlavorConfig.instance!.baseURL2!;
      response = await dio.post<Map<String, dynamic>>(
        'auth/login/truecaller',
        data: jsonEncode(params),
      );

      if (!(response.data!['error'] as bool)) {
        await AppUtils.storeJsonRawInPref(
            (response.data as Map<String, dynamic>));
        // var userMap = response.data as Map<String, dynamic>;
        // // userMap!.putIfAbsent('isLoggedIn', () => true);
        // AppUtils.storeJsonRawInPref((userMap));
        return LoginUserResponse.fromJson(response.data);
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: response != null &&
                  response.data != null &&
                  response.data!['message'] != null
              ? '${response.data!['message']}'
              : 'Something went wrong',
        );
      }
    } on DioError catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.response != null &&
                e.response!.data != null &&
                e.response!.data!['message'] != null
            ? '${e.response!.data!['message']}'
            : 'Something went wrong',
      );
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
      );
    } finally {}
  }

  @override
  Future<LoginUserResponse> loginViaMobileOTP(String request) async {
    // final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
    //     '${AppFlavorConfig.instance!.baseURL2!}verify/otp/token',
    //     HttpMethod.Post);

    final Trace myTraceVerifyOTPToken =
        FirebasePerformance.instance.newTrace('verify_otp_token_mobile');

    // await metric.start();
    myTraceVerifyOTPToken.start();

    Response<Map<String, dynamic>>? response;
    // Map<String, dynamic> params = Map<String, dynamic>();
    // params['phone'] = mobile;
    // params['extension'] = extension;
    // params['firebase_response'] = firebaseResponse;
    // params['app_name'] = '_';

    try {
      Dio dio = DioNetworkService.instance.getMyDio();
      dio.options.baseUrl = AppFlavorConfig.instance!.baseURL2!;
      response = await dio.post('verify/otp/token', data: request);

      if (!(response.data!['error'] as bool)) {
        await AppUtils.storeJsonRawInPref(
            (response.data as Map<String, dynamic>));
        // var userMap = response.data as Map<String, dynamic>;
        // userMap!.putIfAbsent('isLoggedIn', () => true);
        // AppUtils.storeJsonRawInPref((userMap));
        return LoginUserResponse.fromJson(response.data);
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: 'Unhandled',
        );
      }
    } on DioError catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.response != null &&
                e.response!.data != null &&
                e.response!.data!['message'] != null
            ? '${e.response!.data!['message']}'
            : 'Something went wrong',
      );
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
      );
    } finally {
      // await metric.stop();
      myTraceVerifyOTPToken.stop();
    }
  }

  @override
  Future<bool> verifyMobileNumberAttempts(String request) async {
    try {
      Dio dio = DioNetworkService.instance.getMyDio();
      dio.options.baseUrl = AppFlavorConfig.instance!.baseURL2!;
      final response = await dio.post('verify/details', data: request);
      if (!(response.data!['error'] as bool)) {
        return true;
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: 'Unhandled',
        );
      }
    } on DioError catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.response != null &&
                e.response!.data != null &&
                e.response!.data!['message'] != null
            ? '${e.response!.data!['message']}'
            : 'Something went wrong',
      );
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
      );
    }
  }

  @override
  Future<bool> sentEmailOTP(String email) async {
    // final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
    //     '${AppFlavorConfig.instance!.baseURL2}verify/details', HttpMethod.Post);
    final Trace myTraceVerifyDetails =
        FirebasePerformance.instance.newTrace('verify_details');

    // await metric.start();
    myTraceVerifyDetails.start();

    Response<Map<String, dynamic>>? response;
    Map<String, dynamic> params = Map<String, dynamic>();
    params['email_id'] = email;

    try {
      Dio dio = DioNetworkService.instance.getMyDio();
      dio.options.baseUrl = AppFlavorConfig.instance!.baseURL2!;
      response = await dio.post('verify/details', data: params);

      if (!(response.data!['error'] as bool)) {
        return true;
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: 'Unhandled',
        );
      }
    } on DioError catch (e) {
      if (e.response!.statusCode == 403 &&
          e.response!.data!['message'].toString().toLowerCase() ==
              'No record found'.toLowerCase()) {
        throw EMailNotFoundException(e.response != null &&
                e.response!.data != null &&
                e.response!.data!['message'] != null
            ? '${e.response!.data!['message']}'
            : 'Something went wrong');
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: e.response != null &&
                  e.response!.data != null &&
                  e.response!.data!['message'] != null
              ? '${e.response!.data!['message']}'
              : 'Something went wrong',
        );
      }
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
      );
    } finally {
      // await metric.stop();
      myTraceVerifyDetails.stop();
    }
  }

  @override
  Future<LoginUserResponse> loginViaEmailOTP(
      String email, String otpCode) async {
    // final HttpMetric metric = FirebasePerformance.instance.newHttpMetric(
    //     '${AppFlavorConfig.instance!.baseURL2}verify/otp/token',
    //     HttpMethod.Post);

    final Trace myTraceVerifyOTPTokenEmail =
        FirebasePerformance.instance.newTrace('verify_otp_token_email');

    // await metric.start();
    myTraceVerifyOTPTokenEmail.start();

    Response<Map<String, dynamic>>? response;
    Map<String, dynamic> params = Map<String, dynamic>();
    params['email'] = email;
    params['email_id'] = email;
    params['otp'] = otpCode;
    // params['app_name'] = '_';

    try {
      Dio dio = DioNetworkService.instance.getMyDio();
      dio.options.baseUrl = AppFlavorConfig.instance!.baseURL2!;
      response = await dio.post('verify/otp/token', data: params);

      if (!(response.data!['error'] as bool)) {
        await AppUtils.storeJsonRawInPref(
            (response.data as Map<String, dynamic>));
        // var userMap = response.data as Map<String, dynamic>;
        // userMap!.putIfAbsent('isLoggedIn', () => true);
        // AppUtils.storeJsonRawInPref((userMap));
        return LoginUserResponse.fromJson(response.data);
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: 'Unhandled',
        );
      }
    } on DioError catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.response != null &&
                e.response!.data != null &&
                e.response!.data!['message'] != null
            ? '${e.response!.data!['message']}'
            : 'Something went wrong',
      );
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
      );
    } finally {
      // await metric.stop();
      myTraceVerifyOTPTokenEmail.stop();
    }
  }

  @override
  Future<UserStatus> UserStatusCheck() async {
    try {
      String meWithParam = await StringUtils.isNullOrEmpty(
              FirebaseRemoteConfig.instance.getString('meWithParam'))
          ? AppConstants.meWithParam
          : FirebaseRemoteConfig.instance.getString('meWithParam');
      try {
        if (AppFlavorConfig.instance!.isDevelopment!) {
          meWithParam = AppConstants.meWithParam;
        }
      } catch (e) {
        AppLog.log('Error while checking flavor', error: e);
      }
      AppLog.log('meWithParam: ${meWithParam}');
      //replace your restFull API here.
      String url =
          '${AppFlavorConfig.instance!.baseURL!}users/me?with=${meWithParam}';

      final response = await http.get(Uri.parse(url), headers: {
        'Accept': 'application/json',
        'Access-Control_Allow_Origin': '*',
        'Authorization': 'Bearer ${AppPreferences.instance!.authToken}'
      });
      var responseData = json.decode(response.body);
      var userData = responseData['data'];

      try {
        var ud = jsonDecode(response.body) as Map<String, dynamic>;
        AppUtils.storeJsonRawInPrefUserData(ud);
      } catch (e, _) {
        AppLog.log('Error while storing prefrence user data');
      }

      try {
        var responseData = json.decode(response.body);
        var userData = responseData['data'];

        if (userData['listsubscriptions'] is Map) {
          (userData['listsubscriptions'] as Map).remove('memorial');
        }

        if (userData['listsubscriptions'] is List<dynamic> &&
            (userData['listsubscriptions'] as List<dynamic>).length == 0) {
          return UserStatus.NON__USER;
        }
      } catch (e, _) {
        AppLog.log('Error while checking user  status from response');
      }

      return UserStatus._USER;
    } on HttpException catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.message != null ? '${e.message}' : 'Something went wrong',
      );
    } catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
        error: e,
      );
    }
  }

  @override
  Future<bool> loginPage(
    String token,
    String sessionId,
  ) async {
    try {
      String varName =
          AppFlavorConfig.instance!.isDevelopment! ? 'PHPSESSID' : 'OSESSID';
      // futureCookies.toList().toString();
      var response = await http.post(
        Uri.parse(AppFlavorConfig.instance!.baseURL!),
        body: {
          'token': token,
          'submitTokenLogin': '1',
        },
        headers: {
          'Cookie': '${varName}=${'sessionId'}',
          // 'Cookie': singleString,
        },
      );

      var setCookiesArr = response.headers['set-cookie']!.split(';');

      for (var a in setCookiesArr) {
        if (a.contains(varName)) {
          var kV = a.split('=');
          if (kV[0] == varName) {
            CookieManager.instance().setCookie(
              url: Uri.parse('https://google.com'),
              name: varName,
              value: kV[1],
            );
          }
        }
      }

      if (response.statusCode == HttpStatus.ok) {
        return true;
      } else {
        return false;
      }
    } on HttpException catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.message != null ? '${e.message}' : 'Something went wrong',
      );
    } catch (e, s) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: 'Unhandled',
        error: e,
        stack: s,
      );
    }
  }

  @override
  Future<LoginUserResponse?> registerNewUser(
    String? extension,
    String? email,
    String password,
    String? phoneNumber,
    String fullName,
    String? accessToken,
  ) async {
    try {
      Map<String, dynamic> myRequest = Map();
      myRequest['extension'] = extension;
      myRequest['phone_1'] = phoneNumber;
      myRequest['accessToken'] = null;
      myRequest['email_id'] = email;
      myRequest['full_name'] = fullName;
      myRequest['password'] = password;
      myRequest['user_type'] = 'individual';
      myRequest['registration_source'] = 'app';
      myRequest['is_subscribed'] = 0;

      http.Response response = await http.post(
        Uri.parse(AppFlavorConfig.instance!.baseURL!),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(myRequest),
      );
      AppLog.log('${response.statusCode}');

      if (response.statusCode == HttpStatus.ok) {
        return LoginUserResponse.fromJson(jsonDecode(response.body));
      } else {
        var jsonResponse = jsonDecode(response.body);
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: jsonResponse['message'] as String,
        );
      }
    } on HttpException catch (e) {
      throw AppNetworkException(
        networkExceptionType: NetworkExceptions.OTHER,
        message: e.message != null ? '${e.message}' : 'Something went wrong',
      );
    } catch (e, s) {
      if (e is AppNetworkException) {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: e.message,
          error: e,
          stack: s,
        );
      } else {
        throw AppNetworkException(
          networkExceptionType: NetworkExceptions.OTHER,
          message: 'Unhandled',
          error: e,
          stack: s,
        );
      }
    }
  }
}
