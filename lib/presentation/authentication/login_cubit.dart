import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:http/http.dart' as http;
import 'package:truecaller_sdk/truecaller_sdk.dart';

import '../../shared/app_constants.dart';
import '../../shared/common_importer.dart';
import '../../shared/util/app_util.dart';
import '../../model/login/firebase_user_response.dart';
import '../../model/login/login_user_response.dart';
import '../../model/login/login_via_otp_firebase_request.dart';
import '../../services/common_analytics_service/app_analytics_service.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../services/firebase/model/fuser_with_access_token.dart';
import '../../services/network/network_exceptions.dart';
import '../../services/network/network_service.dart';
import '../general/general_cubit.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginInitial());

  // GOOGLE START
  Future<void> signInWithGoogle(GeneralCubit generalCubit) async {
    try {
      emit(LoginUiHandlerState(isLoading: true));

      /// Authenticate user with firebase google auth
      FUserWithAccessToken fUserWithAccessToken =
          await KFAS.instance.signInWithGoogle();
      AppAnalyticsService.instance.googleSignInResult('GSuccess');

      /// Once user is authenticated send access token to the server and server
      /// will give us user information with  API token
      LoginUserResponse response = await KApi.instance
          .loginViaGoogleToken(fUserWithAccessToken.accessToken);

      /// Also please set token in preference so dio-getter will set authentication
      /// barer for next API call.
      await KPref.instance!.setAuthToken(response.data!.token!);
      AppLog.log('jsonEncoded : ${jsonEncode(response.data!.toJson())}');
      AppUtils.storeJsonRawInPrefFirebase((response.toJson()));

      UserStatus? userStatus = await generalCubit.performAfterLogin(
          loginUserResponse: response, loginVia: 'Google');
      await generalCubit.performWhileLoginOrLanding(response);

      AppAnalyticsService.instance.googleSignInClicked('success');
      // AppAnalyticsService.instance.loginVia('Google');
      emit(LoginUiHandlerState(isLoading: false, hasError: false));
      emit(LoginSuccessViaGoogle(userStatus));
    } on GoogleAuthNullException catch (_) {
      generalCubit.performLogout();
      emit(LoginUiHandlerState(isLoading: false, hasError: false));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
    } on FirebaseAuthException catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.googleSignInClicked('failure');
      AppAnalyticsService.instance.googleSignInResult('GFail');
      emit(LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.message ?? '',
          isWaitingForOTPSendCallBack: 0));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.googleSignInClicked('failure');
      AppAnalyticsService.instance.googleSignInResult('APIException');
      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
        isWaitingForOTPSendCallBack: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
    } on Exception catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.googleSignInClicked('failure');
      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
        isWaitingForOTPSendCallBack: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  // GOOGLE END

  Future<void> signInWithTruecaller(
    GeneralCubit generalCubit,
    String extension,
    String phoneNumber,
    String payload,
    String signature,
  ) async {
    late LoginUserResponse response;
    try {
      emit(LoginUiHandlerState(isLoading: true));

      response = await KApi.instance.loginViaTrueCaller(
        phoneNumber,
        extension,
        payload,
        signature,
      );

      /// Also please set token in preference so dio-getter will set authentication
      /// barer for next API call.
      await KPref.instance!.setAuthToken(response.data!.token!);
      AppLog.log('jsonEncoded : ${jsonEncode(response.data!.toJson())}');
      AppUtils.storeJsonRawInPrefFirebase((response.toJson()));

      UserStatus? userStatus = await generalCubit.performAfterLogin(
        loginUserResponse: response,
        loginVia: 'Truecaller',
      );
      await generalCubit.performWhileLoginOrLanding(response);

      if (response.data!.firebaseToken != null) {
        var userCredential = await KFAS.instance
            .signInWithCustomToken(response.data!.firebaseToken!);

        AppLog.log('SignInWithCustomToken: ${userCredential}');
      }

      AppAnalyticsService.instance.tcSubmitClicked('success');
      emit(LoginUiHandlerState(isLoading: false, hasError: false));
      emit(LoginSuccessViaGoogle(userStatus));
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.tcSubmitClicked('failure');
      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
        isWaitingForOTPSendCallBack: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
    } on FirebaseAuthException catch (e) {
      generalCubit.performLogout();

      if (e.code == 'invalid-custom-token') {
        AppAnalyticsService.instance
            .tcSubmitClicked('failure', token: response.data!.firebaseToken!);
      } else {
        AppAnalyticsService.instance.tcSubmitClicked('failure');
      }

      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.code == 'invalid-custom-token'
            ? 'Please use mobile OTP login'
            : e.toString(),
        isWaitingForOTPSendCallBack: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
      await Future.delayed(Duration(milliseconds: 300));
      emit(TruecallerInvalidCustomTokenState(phoneNumber, extension));
    } on Exception catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.tcSubmitClicked('failure');
      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
        isWaitingForOTPSendCallBack: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  // MOBILE START
  Future<void> sendOTPToMobile(
      GeneralCubit generalCubit,
      String mobileWithoutCountryCode,
      String extension,
      int? forceResendingToken) async {
    try {
      emit(LoginUiHandlerState(isWaitingForOTPSendCallBack: 1));

      AppAnalyticsService.instance.loginDetailsEntered(
          'mobile', '${extension}${mobileWithoutCountryCode}');

      Map<String, String> detailsVerifyObj = <String, String>{};
      detailsVerifyObj['extension'] = extension;
      detailsVerifyObj['phone'] = mobileWithoutCountryCode;
      await KApi.instance
          .verifyMobileNumberAttempts(jsonEncode(detailsVerifyObj));
      detailsVerifyObj.clear();

      /// Verify mobile number via firebase SDK
      KFAS.instance.verifyMobileNumber(
        '${extension}${mobileWithoutCountryCode}',
        autoDetectSMSCallback: (fUserWithAccessToken) async {
          emit(LoginUiHandlerState(isWaitingForOTPSendCallBack: 2));
          FirebaseUserResponse firebaseUserResponse = FirebaseUserResponse(
            uid: fUserWithAccessToken.user.uid,
            phoneNumber: '${extension}${mobileWithoutCountryCode}',
            apiKey: FirebaseAuth.instance.app.options.apiKey,
            appName: FirebaseAuth.instance.app.options.appId,
            authDomain: FirebaseAuth.instance.app.options.authDomain,
            stsTokenManager: StsTokenManager(
              apiKey: FirebaseAuth.instance.app.options.apiKey,
              accessToken: fUserWithAccessToken.accessToken,
              refreshToken: fUserWithAccessToken.refreshToken,
            ),
          );

          LoginViaOTPFirebaseRequest firebaseRequest =
              LoginViaOTPFirebaseRequest(
            mobileWithoutCountryCode,
            extension,
            firebaseUserResponse.toJson(),
          );
          AppLog.log(jsonEncode(firebaseRequest));

          // Once user is authenticated send access token to the server and server
          // will give us user information with  API token
          LoginUserResponse response = await KApi.instance.loginViaMobileOTP(
            jsonEncode(firebaseRequest),
          );

          // Also please set token in preference so dio-getter will set authentication
          // barer for next API call.
          await KPref.instance!.setAuthToken(response.data!.token!);
          AppLog.log('jsonEncoded : ${jsonEncode(response.data!.toJson())}');
          AppUtils.storeJsonRawInPrefFirebase((response.toJson()));

          UserStatus? userStatus = await generalCubit.performAfterLogin(
              loginUserResponse: response, loginVia: 'Mobile');
          await generalCubit.performWhileLoginOrLanding(response);

          emit(LoginUiHandlerState(isLoading: false, hasError: false));
          AppAnalyticsService.instance.loginClicked('success');
        

          AppLog.log('autoDetectSMSCallback:');
          AppAnalyticsService.instance.getOTPClicked('success');
          AppAnalyticsService.instance.otpSentResult('mobile-otp-success');
          // ANDROID ONLY!
          emit(LoginSuccessViaMobile(fUserWithAccessToken, userStatus));
        },
        forceResendingToken: forceResendingToken,
        otpSentSuccessfullyCallback: (
          String verificationId,
          int? forceResendingToken,
        ) {
          AppLog.log('otpSentSuccessfullyCallback:');

          AppAnalyticsService.instance.getOTPClicked('success');
          AppAnalyticsService.instance.otpSentResult('mobile-otp-success');

          emit(
            LoginUiHandlerState(
              isLoading: false,
              hasError: false,
              errorMessage:
                  'OTP has been sent to your number ${mobileWithoutCountryCode}',
            ),
          );
          emit(MobileOTPSentSuccess(verificationId, mobileWithoutCountryCode,
              extension, forceResendingToken));
          emit(LoginUiHandlerState(isWaitingForOTPSendCallBack: 2));
        },
        authException: (authException) async {
          AppLog.log(
            'authException:',
            error: authException,
            stackTrace: authException.stackTrace,
          );
          if (authException.code == 'invalid-phone-number') {
            emit(LoginUiHandlerState(isLoading: false));
            generalCubit.performLogout();
            emit(
              LoginUiHandlerState(
                isLoading: false,
                hasError: true,
                errorMessage: 'Mobile number is incorrect',
              ),
            );
            await Future.delayed(Duration(milliseconds: 300));
            emit(LoginInitial());
          } else {
            emit(LoginUiHandlerState(isLoading: false));
            AppAnalyticsService.instance.getOTPClicked('failure');
            AppAnalyticsService.instance.otpSentResult('mobile-otp-fail');

            generalCubit.performLogout();

            emit(
              LoginUiHandlerState(
                isLoading: false,
                hasError: true,
                errorMessage: authException.message != null
                    ? authException.message!
                    : 'Auth Exception',
                isWaitingForOTPSendCallBack: 3,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (verificationId) {
          AppLog.log('codeAutoRetrievalTimeout:');
        },
        resendSeconds: AppConstants.resendOTPSecs,
      );
    } on FirebaseAuthException catch (e) {
      generalCubit.performLogout();

      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message ?? '',
        isWaitingForOTPSendCallBack: 3,
      ));
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();

      if (e.message.toLowerCase() == 'no record found') {
        emit(LoginUiHandlerState(
          isLoading: false,
          hasError: false,
          errorMessage: e.message,
          // isWaitingForOTPSendCallBack: 3,
        ));
        await Future.delayed(Duration(milliseconds: 300));
        emit(LoginInitial());
        // // emit(const LoginInitial(optionalError: 'No record found'));
        // emit(LoginUiHandlerState(
        //   isLoading: false,
        //   hasError: false,
        //   errorMessage: e.message,
        //   isWaitingForOTPSendCallBack: 4,
        // ));
        // await Future.delayed(const Duration(milliseconds: 300));
        // //emit(LoginInitial());
        navigateToNoRecordFoundRoute(
          null,
          mobileWithoutCountryCode,
          extension,
          null,
        );
      } else {
        emit(LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.message,
          isWaitingForOTPSendCallBack:
              e.message.toLowerCase() == 'no record found' ? 0 : 3,
        ));
      }
    } on Exception catch (e) {
      generalCubit.performLogout();

      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
        isWaitingForOTPSendCallBack: 3,
      ));
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  Future<void> verifyMobileOTP(
      GeneralCubit generalCubit,
      String mobileNumberWithoutExtension,
      String extension,
      String smsCode,
      String verificationId) async {
    try {
      emit(LoginUiHandlerState(isLoading: true));

      FUserWithAccessToken fUserWithAccessToken =
          await KFAS.instance.verifyOTP(smsCode, verificationId);
      // await Future<void>.delayed(Duration(seconds: 3));

      FirebaseUserResponse firebaseUserResponse = FirebaseUserResponse(
        uid: fUserWithAccessToken.user.uid,
        phoneNumber: '${extension}${mobileNumberWithoutExtension}',
        apiKey: FirebaseAuth.instance.app.options.apiKey,
        appName: FirebaseAuth.instance.app.options.appId,
        authDomain: FirebaseAuth.instance.app.options.authDomain,
        stsTokenManager: StsTokenManager(
          apiKey: FirebaseAuth.instance.app.options.apiKey,
          accessToken: fUserWithAccessToken.accessToken,
          refreshToken: fUserWithAccessToken.refreshToken,
        ),
      );

      LoginViaOTPFirebaseRequest firebaseRequest = LoginViaOTPFirebaseRequest(
        mobileNumberWithoutExtension,
        extension,
        firebaseUserResponse.toJson(),
      );
      AppLog.log(jsonEncode(firebaseRequest));

      // Once user is authenticated send access token to the server and server
      // will give us user information with  API token
      LoginUserResponse response = await KApi.instance.loginViaMobileOTP(
        jsonEncode(firebaseRequest),
      );

      // Also please set token in preference so dio-getter will set authentication
      // barer for next API call.
      await KPref.instance!.setAuthToken(response.data!.token!);
      AppLog.log('jsonEncoded : ${jsonEncode(response.data!.toJson())}');
      AppUtils.storeJsonRawInPrefFirebase((response.toJson()));

      UserStatus? userStatus = await generalCubit.performAfterLogin(
          loginUserResponse: response, loginVia: 'Mobile');
      await generalCubit.performWhileLoginOrLanding(response);

      emit(LoginUiHandlerState(isLoading: false, hasError: false));
      AppAnalyticsService.instance.loginClicked('success');
      // AppAnalyticsService.instance.loginVia('Mobile');
      // bool responseBool = await isNonUser();
      // if (responseBool) {
      //   emit(NonUser());
      // } else {
      // }
      //emit(LoginSuccessViaGoogle(userStatus));
      emit(LoginSuccessViaMobile(fUserWithAccessToken, userStatus));
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          generalCubit.performLogout();
          emit(
            LoginUiHandlerState(
              isLoading: false,
              hasError: true,
              errorMessage: 'Failed to verify OTP',
              isWaitingForOTPSendCallBack: 3,
            ),
          );
          break;
        default:
          generalCubit.performLogout();
          emit(
            LoginUiHandlerState(
              isLoading: false,
              hasError: true,
              errorMessage: e.message!,
              isWaitingForOTPSendCallBack: 3,
            ),
          );
          break;
      }
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();

      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.message,
          isWaitingForOTPSendCallBack: 3,
        ),
      );
    } on Exception catch (e) {
      generalCubit.performLogout();
      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
          isWaitingForOTPSendCallBack: 3,
        ),
      );
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  // MOBILE END

  // EMAIl START
  Future<void> sendOTPToEmail(
    GeneralCubit generalCubit,
    String email,
  ) async {
    try {
      emit(LoginUiHandlerState(isWaitingForOTPSendCallBack: 1));

      await KApi.instance.sentEmailOTP(email);

      AppAnalyticsService.instance.loginDetailsEntered('email', email);
      AppAnalyticsService.instance.otpSentResult('email-otp-success');
      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: false,
          errorMessage: 'OTP has been sent to your email ${email}',
        ),
      );
      emit(EmailOTPSentSuccess(email));
      emit(LoginUiHandlerState(isWaitingForOTPSendCallBack: 2));
    } on EMailNotFoundException catch (e) {
      generalCubit.performLogout();

      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: false,
          errorMessage: e.message,
        ),
      );
      await Future.delayed(Duration(milliseconds: 300));
      emit(LoginInitial());
      // generalCubit.performLogout();
      // //emit(NoRecordFoundState(email: email, mobile: null, extension: null, firebaseToken: null ));
      // emit(
      //   LoginUiHandlerState(
      //     isLoading: false,
      //     hasError: false,
      //     errorMessage: e.message,
      //   ),
      // );
      // await Future.delayed(Duration(milliseconds: 300));
      // emit(LoginInitial());
      navigateToNoRecordFoundRoute(
        email,
        null,
        null,
        null,
      );
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();
      AppAnalyticsService.instance.otpSentResult('email-otp-fail');

      emit(LoginUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
        isWaitingForOTPSendCallBack: 3,
      ));
    } on Exception catch (e) {
      generalCubit.performLogout();
      AppAnalyticsService.instance.otpSentResult('email-otp-fail');

      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
          isWaitingForOTPSendCallBack: 3,
        ),
      );
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  Future<void> verifyEmailOTP(
      String email, String otpCode, GeneralCubit generalCubit) async {
    try {
      emit(LoginUiHandlerState(isLoading: true));

      LoginUserResponse response = await KApi.instance.loginViaEmailOTP(
        email,
        otpCode,
      );

      /// Also please set token in preference so dio-getter will set authentication
      /// barer for next API call.
      await KPref.instance!.setAuthToken(response.data!.token!);

      AppLog.log('jsonEncoded : ${jsonEncode(response.data!.toJson())}');
      AppUtils.storeJsonRawInPrefFirebase((response.toJson()));

      UserStatus? userStatus = await generalCubit.performAfterLogin(
          loginUserResponse: response, loginVia: 'Email');
      await generalCubit.performWhileLoginOrLanding(response);

      AppAnalyticsService.instance.loginClicked('success');
      // AppAnalyticsService.instance.loginVia('Email');
      emit(LoginUiHandlerState(isLoading: false, hasError: false));
      emit(LoginSuccessViaEmail(userStatus));

      // AppAnalyticsService.instance.googleSignInClicked('success');
      // emit(LoginUiHandlerState(isLoading: false, hasError: false));
      // emit(LoginSuccessViaGoogle());
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.loginClicked('failure');

      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.message,
          isWaitingForOTPSendCallBack: 3,
        ),
      );
    } on Exception catch (e) {
      generalCubit.performLogout();

      AppAnalyticsService.instance.loginClicked('failure');

      emit(
        LoginUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
          isWaitingForOTPSendCallBack: 3,
        ),
      );
    } finally {
      AppLog.log('finally:verifyEmailOTP');
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  Future<void> navigateToNoRecordFoundRoute(
    final String? email,
    final String? mobile,
    final String? mobileExtension,
    final String? firebaseToken,
  ) async {
    emit(NoRecordFoundState(
      email: email,
      mobile: mobile,
      extension: mobileExtension,
      firebaseToken: firebaseToken,
    ));
  }

  Future<bool> promptTrueCaller() async {
    // if (Platform.isAndroid) TrueCallerService.initTC();
    try {
      /// Check TC app is installed or not!
      bool isUsable = await TruecallerSdk.isUsable as bool;

      /// Once it available as to verify his profile
      if (isUsable) {
        TruecallerSdk.getProfile;
        return true;
      } else {
        return false;
      }
    } catch (e, s) {
      AppLog.log('promptTrueCaller: $e, $s');
      return false;
    }
  }

// EMAIl END
// Future<bool> isNonUser() async {
//   //replace your restFull API here.
//   String url =
//       '${AppFlavorConfig.instance!.baseURL!}users/me?with=Subscribed';
//   // '${AppFlavorConfig.instance!.baseURL!}/users/me?with=avtar;isHospital;subscribed;aggdonationall;activateReward;allActiveCampaigns;Subscribed;lastorder';

//   final response = await http.get(Uri.parse(url), headers: {
//     "Accept": "application/json",
//     "Access-Control_Allow_Origin": "*",
//     "Authorization": "Bearer ${AppPref.instance!.authToken}"
//   });
//   var responseData = json.decode(response.body);
//   var userData = responseData['data'];

//   if ((userData['_subscribed'] == null ||
//           userData['_subscribed']['status_flag'] == null) ||
//       userData['_subscribed']['status_flag'] != 1) return true;
//   return false;
// }

}
