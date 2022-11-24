import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/app_constants.dart';
import '../../../shared/common_importer.dart';
import '../../../shared/util/app_util.dart';
import '../../../model/login/login_user_response.dart';
import '../../../services/common_analytics_service/app_analytics_service.dart';
import '../../../services/firebase/firebase_auth_service.dart';
import '../../../services/firebase/model/fuser_with_access_token.dart';
import '../../../services/network/network_exceptions.dart';
import '../../../services/network/network_service.dart';
import '../../general/general_cubit.dart';
part 'user_signup_state.dart';

class UserSignupCubit extends Cubit<UserSignupState> {
  UserSignupCubit() : super(UserSignupInitial());
  Future<void> signInWithGoogle(GeneralCubit generalCubit) async {
    try {
      emit(UserUiHandlerState(isLoading: true));

      /// Authenticate user with firebase google auth
      FUserWithAccessToken fUserWithAccessToken =
          await KFAS.instance.signInWithGoogle();

      /// Once user is authenticated send access token to the server and server
      /// will give us user information with  API token
      LoginUserResponse response = await KApi.instance
          .loginViaGoogleToken(fUserWithAccessToken.accessToken);

      /// Also please set token in preference so dio-getter will set authentication
      /// barer for next API call.
      await KPref.instance!.setAuthToken(response.data!.token!);
      AppLog.log('jsonEncoded : ${jsonEncode(response.data!.toJson())}');
      AppUtils.storeJsonRawInPrefFirebase((response.toJson()));
      await AppUtils.storeJsonRawInPref(response.toJson());

      UserStatus? userStatus = await generalCubit.performAfterLogin(
          loginUserResponse: response, loginVia: 'Google');
      await generalCubit.performWhileLoginOrLanding(response);
      emit(UserUiHandlerState(isLoading: false, hasError: false));
      emit(LoginSuccessViaGoogle(userStatus));
    } on GoogleAuthNullException catch (_) {
      generalCubit.performLogout();
      emit(UserUiHandlerState(isLoading: false, hasError: false));
      await Future.delayed(Duration(milliseconds: 300));
      emit(UserSignupInitial());
    } on FirebaseAuthException catch (e) {
      generalCubit.performLogout();
      emit(UserUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.message ?? '',
          otpStatus: 0));
      await Future.delayed(Duration(milliseconds: 300));
      emit(UserSignupInitial());
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();
      emit(UserUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
        otpStatus: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(UserSignupInitial());
    } on Exception catch (e) {
      generalCubit.performLogout();
      emit(UserUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
        otpStatus: 0,
      ));
      await Future.delayed(Duration(milliseconds: 300));
      emit(UserSignupInitial());
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  Future<void> sendOTPToMobile(
      GeneralCubit generalCubit,
      String mobileWithoutCountryCode,
      String extension,
      String email,
      String fullName,
      int? forceResendingToken) async {
    try {
      emit(UserUiHandlerState(otpStatus: 1));
      AppAnalyticsService.instance.clickOnSignupButton();

      /// Verify mobile number via firebase SDK
      KFAS.instance.verifyMobileNumber(
        '${extension}${mobileWithoutCountryCode}',
        autoDetectSMSCallback: (fUserWithAccessToken) async {
          LoginUserResponse? userResponse = await KApi.instance.registerNewUser(
            extension,
            email,
            'abcdXYZ@123',
            mobileWithoutCountryCode,
            fullName,
            fUserWithAccessToken.accessToken,
          );
          // Also please set token in preference so dio-getter will set authentication
          // barer for next API call.
          await KPref.instance!.setAuthToken(userResponse!.data!.token!);
          AppUtils.storeJsonRawInPrefFirebase(userResponse.toJson());
          await AppUtils.storeJsonRawInPref(userResponse.toJson());

          await generalCubit.performAfterLogin(
            loginUserResponse: userResponse,
            loginVia: 'Mobile',
          );
          await generalCubit.performWhileLoginOrLanding(userResponse);
          AppAnalyticsService.instance.otpSentResult('mobile-otp-success');
          AppAnalyticsService.instance.signUpResult('success');
          emit(USLoginSuccessViaMobile());
        },
        forceResendingToken: forceResendingToken,
        otpSentSuccessfullyCallback: (
          String verificationId,
          int? forceResendingToken,
        ) {
          AppLog.log('otpSentSuccessfullyCallback:');
          AppAnalyticsService.instance.otpSentResult('mobile-otp-success');
          AppAnalyticsService.instance.signUpResult('success');
          emit(
            UserUiHandlerState(
              isLoading: false,
              hasError: true,
              errorMessage:
                  'OTP has been sent to your number ${mobileWithoutCountryCode}',
            ),
          );
          emit(USMobileOTPSentSuccess(verificationId, mobileWithoutCountryCode,
              extension, forceResendingToken));
          emit(UserUiHandlerState(otpStatus: 2));
        },
        authException: (authException) async {
          AppLog.log(
            'authException:',
            error: authException,
            stackTrace: authException.stackTrace,
          );
          if (authException.code == 'invalid-phone-number') {
            emit(UserUiHandlerState(isLoading: false));
            generalCubit.performLogout();
            emit(
              UserUiHandlerState(
                isLoading: false,
                hasError: true,
                errorMessage: 'Mobile number is incorrect',
              ),
            );
            await Future.delayed(Duration(milliseconds: 300));
            emit(UserSignupInitial());
          } else if (authException.code == 'too-many-requests') {
            emit(UserUiHandlerState(isLoading: false));
            generalCubit.performLogout();
            emit(
              UserUiHandlerState(
                isLoading: false,
                hasError: true,
                errorMessage: 'Too many requests',
              ),
            );
            await Future.delayed(Duration(milliseconds: 300));
            emit(UserSignupInitial());
          } else {
            emit(UserUiHandlerState(isLoading: false));
            AppAnalyticsService.instance.otpSentResult('mobile-otp-failure');
            AppAnalyticsService.instance.signUpResult('failure');
            generalCubit.performLogout();
            emit(
              UserUiHandlerState(
                isLoading: false,
                hasError: true,
                errorMessage: authException.message != null
                    ? authException.message!
                    : 'Auth Exception',
                otpStatus: 3,
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
      AppAnalyticsService.instance.otpSentResult('mobile-otp-failure');
      AppAnalyticsService.instance.signUpResult('failure');
      emit(UserUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message ?? '',
        otpStatus: 3,
      ));
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();
      AppAnalyticsService.instance.otpSentResult('mobile-otp-failure');
      AppAnalyticsService.instance.signUpResult('failure');
      // emit(const LoginInitial(optionalError: 'No record found'));
      emit(UserUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
        otpStatus: 3,
      ));
    } on Exception catch (e) {
      generalCubit.performLogout();
      AppAnalyticsService.instance.otpSentResult('mobile-otp-failure');
      AppAnalyticsService.instance.signUpResult('failure');
      emit(UserUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.toString(),
        otpStatus: 3,
      ));
    } finally {
      // emit(NRFUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  Future<void> verifyMobileOTP(
    GeneralCubit generalCubit,
    String email,
    String mobileNumberWithoutExtension,
    String extension,
    String smsCode,
    String fullName,
    String verificationId,
  ) async {
    try {
      AppAnalyticsService.instance.signupOTPEntered(smsCode);
      emit(UserUiHandlerState(isLoading: true));
      FUserWithAccessToken fUserWithAccessToken =
          await KFAS.instance.verifyOTP(smsCode, verificationId);
      LoginUserResponse? userResponse = await KApi.instance.registerNewUser(
        extension,
        email,
        'abcdXYZ@123',
        mobileNumberWithoutExtension,
        fullName,
        fUserWithAccessToken.accessToken,
      );
      // Also please set token in preference so dio-getter will set authentication
      // barer for next API call.
      await KPref.instance!.setAuthToken(userResponse!.data!.token!);
      AppUtils.storeJsonRawInPrefFirebase(userResponse.toJson());
      await AppUtils.storeJsonRawInPref(userResponse.toJson());

      await generalCubit.performAfterLogin(
        loginUserResponse: userResponse,
        loginVia: 'Mobile',
      );
      await generalCubit.performWhileLoginOrLanding(userResponse);
      AppAnalyticsService.instance.signUpResult('success');
      emit(USLoginSuccessViaMobile());
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-verification-code':
          generalCubit.performLogout();
          AppAnalyticsService.instance
              .signUpResult('failure', errorMessage: e.code);
          emit(
            UserUiHandlerState(
              isLoading: false,
              hasError: false,
              errorMessage: 'Failed to verify OTP',
              otpStatus: 3,
            ),
          );
          break;
        default:
          generalCubit.performLogout();
          AppAnalyticsService.instance
              .signUpResult('failure', errorMessage: e.code);
          emit(
            UserUiHandlerState(
              isLoading: false,
              hasError: true,
              errorMessage: e.message!,
              otpStatus: 3,
            ),
          );
          break;
      }
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();
      AppAnalyticsService.instance
          .signUpResult('failure', errorMessage: e.message);
      emit(
        UserUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.message,
          otpStatus: 3,
        ),
      );
    } on Exception catch (e) {
      generalCubit.performLogout();
      AppAnalyticsService.instance.signUpResult(
        'failure',
        errorMessage: AppUtils.getStringByGivenNumber(e.toString(), 20),
      );
      emit(
        UserUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
          otpStatus: 3,
        ),
      );
    } finally {
      // emit(NRFUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }

  Future<void> checkIfValidEmailAndMobile(
    GeneralCubit generalCubit,
    String mobile,
    String extension,
    int? forcedToken,
    String fullName,
    String email,
  ) async {
    try {
      emit(UserUiHandlerState(otpStatus: 1));
      AppAnalyticsService.instance.clickOnSignupButton();
      await KApi.instance.sentEmailOTP(email);
      emit(
        UserUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: 'User with email: ${email} already exists',
        ),
      );
    } on EMailNotFoundException catch (e) {
      generalCubit.performLogout();
      emit(
        UserUiHandlerState(
          isLoading: false,
          hasError: false,
          errorMessage: e.message,
        ),
      );
      await Future.delayed(Duration(milliseconds: 300));
      sendOTPToMobile(
        generalCubit,
        mobile,
        extension,
        email,
        fullName,
        forcedToken,
      );
      emit(UserSignupInitial());
    } on AppNetworkException catch (e) {
      generalCubit.performLogout();
      emit(UserUiHandlerState(
        isLoading: false,
        hasError: true,
        errorMessage: e.message,
        otpStatus: 3,
      ));
    } on Exception catch (e) {
      generalCubit.performLogout();
      emit(
        UserUiHandlerState(
          isLoading: false,
          hasError: true,
          errorMessage: e.toString(),
          otpStatus: 3,
        ),
      );
    } finally {
      // emit(LoginUiHandlerState(
      //     isLoading: false, hasError: true, errorMessage: e.message));
    }
  }
}
