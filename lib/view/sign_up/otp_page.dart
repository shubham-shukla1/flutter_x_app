import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';

import '../../shared/app_constants.dart';
import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/common_importer.dart';
import '../../shared/util/app_util.dart';
import '../../presentation/authentication/signup/user_signup_cubit.dart';
import '../../presentation/general/general_cubit.dart';
import '../../services/common_analytics_service/app_analytics_service.dart';
import '../../services/firebase/firebase_auth_service.dart';

class OtpPageArgument {
  final String mobileNumber;
  final String extensionNumber;
  final String email;
  final String fullName;
  final int? forcedResendingToken;
  final String verificationId;

  OtpPageArgument(
      {required this.mobileNumber,
      required this.verificationId,
      required this.email,
      required this.extensionNumber,
      required this.forcedResendingToken,
      required this.fullName});
}

class OtpPageParent extends StatelessWidget {
  static final String routeName = '/otpPage';

  // final LoginPageArgument argument;
  const OtpPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    OtpPageArgument? args;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as OtpPageArgument;
    }
    AppLog.log('${args?.email.toString()}');
    AppLog.log('${args?.mobileNumber.toString()}');
    AppLog.log('${args?.extensionNumber.toString()}');
    return OtpPage(args);
  }
}

class OtpPage extends StatefulWidget {
  final OtpPageArgument? otpPageArgument;

  const OtpPage(this.otpPageArgument, {Key? key}) : super(key: key);

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  TextEditingController otpController = TextEditingController();
  late UserSignupCubit _userSignupCubit;
  late GeneralCubit _generalCubit;
  late Timer _timer;
  int _start = AppConstants.resendOTPSecs;
  bool hasError = false;
  late String _verificationId = widget.otpPageArgument!.verificationId;
  late String _mobileNumberWithoutExtension =
      widget.otpPageArgument!.mobileNumber;
  late int? _forceResendingToken = widget.otpPageArgument?.forcedResendingToken;
  late String? _countryCode = widget.otpPageArgument?.extensionNumber;

  @override
  void initState() {
    // TODO: implement initState
    _userSignupCubit = BlocProvider.of<UserSignupCubit>(context);
    _generalCubit = BlocProvider.of<GeneralCubit>(context);
    startTimer();
    super.initState();
    AppAnalyticsService.instance.pageView('App_verify_mobile_number');
  }

  @override
  void dispose() {
    // TODO: implement dispose

    if (_timer.isActive) {
      _timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Pin themes
    final defaultPinTheme = PinTheme(
      width: 40,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    final focusedPinTheme = PinTheme(
      width: 40,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.grey)),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    final submittedPinTheme = PinTheme(
      width: 40,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: AppColors.limeGreen)),
        borderRadius: BorderRadius.circular(4),
      ),
    );
    final errorPinTheme = PinTheme(
      width: 40,
      height: 56,
      textStyle: TextStyle(
          fontSize: 20,
          color: Color.fromRGBO(30, 60, 87, 1),
          fontWeight: FontWeight.w600),
      decoration: BoxDecoration(
        border: Border.fromBorderSide(BorderSide(color: Colors.redAccent)),
        borderRadius: BorderRadius.circular(4),
      ),
    );

    return Container(
      color: AppColors.greyWhite,
      child: SafeArea(
        child: Scaffold(
          body: BlocConsumer<UserSignupCubit, UserSignupState>(
            bloc: _userSignupCubit,
            listener: (context, state) {
              if (state is USLoginSuccessViaMobile) {
                AppLog.log('Login success');
                _userSignupCubit.emit(UserSignupInitial());

                Future.delayed(Duration(milliseconds: 300));
                //navigate here
              } else if ((state is UserUiHandlerState) &&
                  (state.otpStatus == 3)) {
                setState(() {
                  hasError = true;
                });
              } else if (state is USMobileOTPSentSuccess) {
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
                    Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: Icon(
                            Icons.close,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                    AspectRatio(
                      aspectRatio: 1.5,
                      child: Image.asset(
                        'assets/images/otp_pic.png',
                        height: 500,
                        width: 500,
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'We have sent an OTP on ',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                        Text(
                          '${widget.otpPageArgument?.extensionNumber} ${widget.otpPageArgument?.mobileNumber.substring(0, 5)} ${widget.otpPageArgument?.mobileNumber.substring(5, widget.otpPageArgument?.mobileNumber.length)} ',
                          style: TextStyle(
                            color: AppColors.darkBlue,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Pinput(
                      length: 6,
                      controller: otpController,
                      errorPinTheme: errorPinTheme,
                      defaultPinTheme: defaultPinTheme,
                      focusedPinTheme: focusedPinTheme,
                      submittedPinTheme:
                          (state is UserUiHandlerState && state.otpStatus == 3)
                              ? errorPinTheme
                              : submittedPinTheme,
                      onChanged: (pin) {
                        _userSignupCubit.emit(
                            UserUiHandlerState(hasError: false, otpStatus: 2));
                      },
                      autofocus: true,
                      closeKeyboardWhenCompleted: true,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                      hapticFeedbackType:
                          (state is UserUiHandlerState && state.otpStatus == 3)
                              ? HapticFeedbackType.mediumImpact
                              : HapticFeedbackType.selectionClick,
                      showCursor: true,
                      onCompleted: (pin) {
                        if ((state is UserUiHandlerState) &&
                            state.otpStatus == 2) {
                          _userSignupCubit.verifyMobileOTP(
                            _generalCubit,
                            widget.otpPageArgument!.email,
                            widget.otpPageArgument!.mobileNumber,
                            widget.otpPageArgument!.extensionNumber,
                            pin,
                            widget.otpPageArgument!.fullName,
                            _verificationId,
                          );
                        }
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ((state is UserUiHandlerState) && (state.otpStatus == 3))
                        ? Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Text(
                              'Incorrect Pin',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          )
                        : SizedBox.shrink(),
                    ((state is UserUiHandlerState) &&
                            (state.otpStatus == 2 || state.otpStatus == 3))
                        ? SizedBox(
                            height: 110,
                            child: _start < 1
                                ? GestureDetector(
                                    onTap: () {
                                      AppLog.log('Resend OTP tapped');
                                      AppAnalyticsService.instance
                                          .clickOnResendOTP();

                                      /// Reset timer and logout from firebase
                                      _start = AppConstants.resendOTPSecs;
                                      startTimer();

                                      FirebaseAuthService.instance.signOut();
                                      AppLog.log('Get OTP : Mobile');
                                      AppUtils.newFocus(context);
                                      try {
                                        _userSignupCubit.sendOTPToMobile(
                                            _generalCubit,
                                            widget
                                                .otpPageArgument!.mobileNumber,
                                            widget.otpPageArgument!
                                                .extensionNumber,
                                            widget.otpPageArgument!.email,
                                            widget.otpPageArgument!.fullName,
                                            widget.otpPageArgument!
                                                .forcedResendingToken);
                                        otpController.text = '';
                                      } catch (e, s) {
                                        AppLog.log('Error while Resend OTP',
                                            error: e, stackTrace: s);
                                      }
                                    },
                                    child: Text('Resend Code',
                                        style: TextStyle(
                                          color: AppColors.limeGreen,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        )),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Enter Code in... ',
                                        style: TextStyle(
                                          color: AppColors.grey2,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        '($_start Sec)',
                                        style: TextStyle(
                                          color: AppColors.grey2,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ))
                        : SizedBox.shrink(),
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
}
