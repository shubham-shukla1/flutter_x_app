import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../shared/app_constants.dart';
import '../../shared/app_logging/app_log_helper.dart';
import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/common_importer.dart';
import '../../shared/util/app_progressbar.dart';
import '../../shared/util/app_util.dart';
import '../../presentation/authentication/login_cubit.dart';
import '../../presentation/general/general_cubit.dart';
import '../../services/common_analytics_service/app_analytics_service.dart';
import '../../services/firebase/firebase_auth_service.dart';
import '../../services/network/network_service.dart';
import '../single_webview_page.dart';

class LoginOtpPageArgument {
  final String? mobileNumber;
  final String? extensionNumber;
  final String? email;
  final int? forcedResendingToken;
  final String? verificationId;

  LoginOtpPageArgument({
    this.mobileNumber,
    this.verificationId,
    this.email,
    this.extensionNumber,
    this.forcedResendingToken,
  });
}

class LoginOtpPageParent extends StatelessWidget {
  static final String routeName = '/loginOtpPage';

  // final LoginPageArgument argument;
  const LoginOtpPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoginOtpPageArgument? args;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as LoginOtpPageArgument;
    }

    return LoginOtpPage(args);
  }
}

class LoginOtpPage extends StatefulWidget {
  final LoginOtpPageArgument? loginOtpPageArgument;
  const LoginOtpPage(this.loginOtpPageArgument, {Key? key}) : super(key: key);

  @override
  State<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage> {
  TextEditingController otpController = TextEditingController();
  late LoginCubit _loginCubit;
  late GeneralCubit _generalCubit;
  late Timer _timer;
  int _start = AppConstants.resendOTPSecs;
  bool hasError = false;
  bool submitOTP = false;
  late String? _verificationId = widget.loginOtpPageArgument?.verificationId;
  late String? _mobileNumberWithoutExtension =
      widget.loginOtpPageArgument?.mobileNumber;
  late int? _forceResendingToken =
      widget.loginOtpPageArgument?.forcedResendingToken;
  late String? _countryCode = widget.loginOtpPageArgument?.extensionNumber;
  @override
  void initState() {
    _loginCubit = BlocProvider.of<LoginCubit>(context);
    _generalCubit = BlocProvider.of<GeneralCubit>(context);
    startTimer();
    super.initState();
  }

  @override
  void dispose() {
    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          color: AppColors.greyishBlue,
          fontWeight: FontWeight.w500),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    final focusedPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          color: AppColors.greyishBlue,
          fontWeight: FontWeight.w500),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.grey, width: 2)),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    final submittedPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          color: AppColors.greyishBlue,
          fontWeight: FontWeight.w500),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.grey, width: 2)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    final errorPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 20,
          color: AppColors.greyishBlue,
          fontWeight: FontWeight.w500),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(
            BorderSide(color: Colors.redAccent, width: 2)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    return Container(
      color: AppColors.greyWhite,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          body: BlocConsumer<LoginCubit, LoginState>(
            bloc: _loginCubit,
            listener: (context, state) {
              if (state is LoginSuccessViaMobile ||
                  state is LoginSuccessViaEmail) {
                _loginCubit.emit(LoginInitial());
                UserStatus? _userStatus;
                if (state is LoginSuccessViaMobile) {
                  _userStatus = state.userStatus;
                } else if (state is LoginSuccessViaEmail) {
                  _userStatus = state.userStatus;
                } else {
                  _userStatus = UserStatus.LAPSE_USER;
                }
              }
              //Navigate to  or home page based on status
              else if ((state is LoginUiHandlerState) &&
                  (state.isWaitingForOTPSendCallBack == 3)) {
                setState(() {
                  hasError = true;
                });
              } else if (state is MobileOTPSentSuccess) {
                setState(() {
                  _verificationId = state.verificationId;
                  _mobileNumberWithoutExtension = state.mobile;
                  _countryCode = state.extension;
                  _forceResendingToken = state.forceResendingToken;
                });
              }
            },
            builder: (_, state) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30, bottom: 10),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Verify details',
                          style: TextStyle(
                            // fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            color: AppColors.titleColor,
                            fontFamily: 'Larken',
                            fontSize: 32,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 30),
                      child: Row(
                        children: [
                          Text(
                            'An OTP is sent to ',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.black75,
                              fontSize: 14,
                              fontWeight: FontWeight.w200,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Text(
                            (widget.loginOtpPageArgument?.mobileNumber != null)
                                ? '${widget.loginOtpPageArgument?.extensionNumber} ${widget.loginOtpPageArgument?.mobileNumber}'
                                : '${widget.loginOtpPageArgument?.email}',
                            style: TextStyle(
                              color: AppColors.black75,
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(
                            width: 2,
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Edit',
                              style: TextStyle(
                                color: AppColors.greyishBlue,
                                fontFamily: 'Poppins',
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24, right: 24),
                      child: Pinput(
                        length: 6,
                        controller: otpController,
                        errorPinTheme: errorPinTheme,
                        defaultPinTheme: defaultPinTheme,
                        focusedPinTheme: focusedPinTheme,
                        submittedPinTheme: (state is LoginUiHandlerState &&
                                state.isWaitingForOTPSendCallBack == 3)
                            ? errorPinTheme
                            : submittedPinTheme,
                        onChanged: (pin) {
                          _loginCubit.emit(LoginUiHandlerState(
                              hasError: false, isWaitingForOTPSendCallBack: 2));
                          submitOTP = false;
                        },
                        autofocus: true,
                        closeKeyboardWhenCompleted: true,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                        hapticFeedbackType: (state is LoginUiHandlerState &&
                                state.isWaitingForOTPSendCallBack == 3)
                            ? HapticFeedbackType.mediumImpact
                            : HapticFeedbackType.selectionClick,
                        showCursor: true,
                        onCompleted: (pin) {
                          setState(() {
                            submitOTP = true;
                          });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ((state is LoginUiHandlerState) &&
                            (state.isWaitingForOTPSendCallBack == 3))
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Incorrect Pin',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    ((state is LoginUiHandlerState) &&
                            (state.isWaitingForOTPSendCallBack == 2 ||
                                state.isWaitingForOTPSendCallBack == 3))
                        ? Padding(
                            padding: EdgeInsets.only(left: 30),
                            child: _start < 1
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Didn\'t receive the OTP?  ',
                                        style: TextStyle(
                                          color: AppColors.black75,
                                          fontSize: 14,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          AppLog.log('Resend OTP tapped');
                                          AppAnalyticsService.instance
                                              .clickOnResendOTP();

                                          /// Reset timer and logout from firebase
                                          _start = AppConstants.resendOTPSecs;
                                          startTimer();

                                          FirebaseAuthService.instance
                                              .signOut();
                                          AppLog.log('Get OTP : Mobile');
                                          AppUtils.newFocus(context);
                                          try {
                                            if (widget.loginOtpPageArgument
                                                        ?.mobileNumber !=
                                                    null &&
                                                widget.loginOtpPageArgument
                                                        ?.extensionNumber !=
                                                    null) {
                                              _loginCubit.sendOTPToMobile(
                                                  _generalCubit,
                                                  _mobileNumberWithoutExtension!,
                                                  _countryCode!,
                                                  _forceResendingToken);
                                            } else if (widget
                                                    .loginOtpPageArgument
                                                    ?.email !=
                                                null) {
                                              _loginCubit.sendOTPToEmail(
                                                  _generalCubit,
                                                  widget.loginOtpPageArgument!
                                                      .email!);
                                            }
                                            otpController.text = '';
                                          } catch (e, s) {
                                            AppLog.log('Error while Resend OTP',
                                                error: e, stackTrace: s);
                                          }
                                        },
                                        child: Text('Resend',
                                            style: TextStyle(
                                              color: AppColors.limeGreen,
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 14,
                                            )),
                                      ),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Resend OTP in ',
                                        style: TextStyle(
                                          color: AppColors.black75,
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '${_start}s',
                                        style: TextStyle(
                                          color: AppColors.black75,
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ))
                        : SizedBox.shrink(),
                    SizedBox(
                      height: 30,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 24, right: 24),
                      child: Container(
                        height: 45,
                        width: 330,
                        decoration: BoxDecoration(
                          color: submitOTP
                              ? AppColors.limeGreen
                              : AppColors.green2,
                          borderRadius: BorderRadius.circular(
                            4,
                          ),
                        ),
                        child: TextButton(
                            onPressed:
                                submitOTP ? () => verifyOTP(state) : null,
                            style: TextButton.styleFrom(
                              primary: Colors.transparent,
                            ),
                            child: ((state is LoginUiHandlerState) &&
                                    state.isWaitingForOTPSendCallBack == 1)
                                ? AppCircularProgressbar()
                                : Text(
                                    'VERIFY AND PROCEED',
                                    style: TextStyle(
                                      color: AppColors.greyWhite,
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      // fontFamily: 'Montserrat',
                                      fontWeight: FontWeight.w700,
                                    ),
                                  )),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Center(
                      child: Container(
                        width: 290,
                        height: 40,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'By continuing I accept the ',
                              style: TextStyle(
                                // height: 18,
                                fontSize: 9,
                                color: AppColors.black50,
                                fontFamily: 'Poppins',
                                // fontFamily: 'Montserrat',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  SingleWebViewPageParent.routeName,
                                  arguments: SingleWebViewPageArgument(
                                      FirebaseRemoteConfig.instance
                                          .getString('tc_link'),
                                      'Term of Service'),
                                );
                              },
                              child: Text(
                                'Term of Service ',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                            Text(
                              '& ',
                              style: TextStyle(
                                color: AppColors.black50,
                                fontSize: 9,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // checkAndUpdate();
                                Navigator.of(context).pushNamed(
                                  SingleWebViewPageParent.routeName,
                                  arguments: SingleWebViewPageArgument(
                                      FirebaseRemoteConfig.instance
                                          .getString('pp_link'),
                                      'Privacy Policy'),
                                );
                              },
                              child: Text(
                                'Privacy Policy',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 9,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void startTimer() {
    try {
      const oneSec = const Duration(seconds: 1);
      _timer = Timer.periodic(
        oneSec,
        (Timer timer) => setState(
          () {
            if (_start < 1) {
              timer.cancel();
            } else {
              _start = _start - 1;
              AppLog.log('Remaining time : ${_start} sec');
            }
          },
        ),
      );
    } catch (e, s) {
      AppLog.log('Error in startTimer', error: e, stackTrace: s);
    }
  }

  void verifyOTP(LoginState state) {
    if ((state is LoginUiHandlerState) &&
        state.isWaitingForOTPSendCallBack == 2) {
      if (widget.loginOtpPageArgument?.mobileNumber != null &&
          widget.loginOtpPageArgument?.extensionNumber != null) {
        _loginCubit.verifyMobileOTP(
          _generalCubit,
          _mobileNumberWithoutExtension!,
          _countryCode!,
          otpController.text,
          _verificationId!,
        );
      } else if (widget.loginOtpPageArgument?.email != null) {
        _loginCubit.verifyEmailOTP(
          widget.loginOtpPageArgument!.email!,
          otpController.text,
          _generalCubit,
        );
      }
    }
  }
}
