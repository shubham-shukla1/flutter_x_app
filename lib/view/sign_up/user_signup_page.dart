import 'dart:async';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_x_app/services/common_analytics_service/app_analytics_service.dart';

import '../../shared/app_constants.dart';
import '../../shared/app_logging/app_log_helper.dart';
import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/util/app_progressbar.dart';
import '../../shared/util/app_scaffold.dart';
import '../../shared/util/app_util.dart';
import '../../model/user_data/user_model.dart';
import '../../own_package/country_picker/country_code_picker.dart';
import '../../presentation/authentication/signup/user_signup_cubit.dart';
import '../../presentation/general/general_cubit.dart';
import '../../services/network/network_service.dart';
import '../single_webview_page.dart';
import 'otp_page.dart';

class UserSignupPageArgument {
  final String? funnelName;
  final String? mobileNumber;
  final String? extensionNumber;
  final String? email;

  UserSignupPageArgument(
      {this.funnelName, this.mobileNumber, this.email, this.extensionNumber});
}

class UserSignupPageParent extends StatelessWidget {
  static final String routeName = '/userSignupPage';

  // final LoginPageArgument argument;
  const UserSignupPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    UserSignupPageArgument? args;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args =
          ModalRoute.of(context)!.settings.arguments as UserSignupPageArgument;
    }

    return UserSignup(args);
  }
}

class UserSignup extends StatefulWidget {
  final UserSignupPageArgument? userSignupPageArgument;

  const UserSignup(this.userSignupPageArgument, {Key? key}) : super(key: key);

  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {
  late UserModel userModel;
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  late GeneralCubit _generalCubit;
  late UserSignupCubit _userSignupCubit;
  final _formKey = GlobalKey<FormState>();
  int? _forceResendingToken;
  late String? _countryCode = widget.userSignupPageArgument?.extensionNumber;
  late String _verificationId;
  late String _mobileNumberWithoutExtension;

  @override
  void initState() {
    _userSignupCubit = BlocProvider.of<UserSignupCubit>(context);
    _generalCubit = BlocProvider.of<GeneralCubit>(context);
    super.initState();
    AppAnalyticsService.instance.pageView('App_signup');
  }

  @override
  void didChangeDependencies() {
    // _loginCubit = LoginCubit();
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _formKey.currentState?.dispose();
    //_userSignupCubit.close();
    //_timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocConsumer<UserSignupCubit, UserSignupState>(
          bloc: _userSignupCubit,
          listener: (context, state) {
            if (state is UserUiHandlerState) {
              if (state.isLoading) {
                AppLog.log('Show loading');
                AppProgressBar.instance.showProgressbarWithContext(context);
              } else if (!state.isLoading && !state.hasError) {
                AppLog.log('Hide loading');
                AppProgressBar.instance.hideProgressBar();
              } else if (state.hasError && !state.isLoading) {
                AppLog.log('Hide loading');
                AppProgressBar.instance.hideProgressBar();
                AppLog.log('Show error message ${state.errorMessage}');
                SnackBar snackBar =
                    SnackBar(content: Text('${state.errorMessage}'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              } else if (state.hasError) {
                AppLog.log('Show error message ${state.errorMessage}');
                SnackBar snackBar =
                    SnackBar(content: Text('${state.errorMessage}'));
                ScaffoldMessenger.of(context).showSnackBar(snackBar);
              }
            } else if (state is USMobileOTPSentSuccess) {
              setState(() {
                _verificationId = state.verificationId;
                _mobileNumberWithoutExtension = state.mobile;
                _countryCode = state.extension;
                _forceResendingToken = state.forceResendingToken;
              });
              if ((widget.userSignupPageArgument?.mobileNumber != null &&
                  widget.userSignupPageArgument?.extensionNumber != null)) {
                Navigator.of(context).pushNamed(OtpPageParent.routeName,
                    arguments: OtpPageArgument(
                      mobileNumber:
                          '${phoneNumberController.text.substring(_countryCode!.length, phoneNumberController.text.length)}',
                      extensionNumber:
                          '${phoneNumberController.text.substring(0, _countryCode!.length)}',
                      email: emailController.text,
                      forcedResendingToken: _forceResendingToken,
                      fullName: fullNameController.text,
                      verificationId: _verificationId,
                    ));
                //_userSignupCubit.emit(UserSignupInitial());
              } else if (widget.userSignupPageArgument?.email != null) {
                Navigator.of(context).pushNamed(OtpPageParent.routeName,
                    arguments: OtpPageArgument(
                      mobileNumber: phoneNumberController.text,
                      extensionNumber: _countryCode ?? '+91',
                      email: emailController.text,
                      forcedResendingToken: _forceResendingToken,
                      fullName: fullNameController.text,
                      verificationId: _verificationId,
                    ));
                // _userSignupCubit.emit(UserSignupInitial());
              }
            } else if (state is USLoginSuccessViaMobile) {
              AppLog.log('Login success');
              _userSignupCubit.emit(UserSignupInitial());
            } else if (state is LoginSuccessViaGoogle) {
              _userSignupCubit.emit(UserSignupInitial());
              UserStatus? _userStatus;
              _userStatus = state.userStatus;
              //Navigate to non or home page based on status

            }
          },
          builder: (_, state) {
            if (widget.userSignupPageArgument?.mobileNumber != null &&
                widget.userSignupPageArgument?.extensionNumber != null) {
              phoneNumberController.text =
                  '${widget.userSignupPageArgument?.extensionNumber}${widget.userSignupPageArgument?.mobileNumber}';
            } else if (widget.userSignupPageArgument?.email != null) {
              emailController.text = '${widget.userSignupPageArgument?.email}';
            }
            return Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 21,
                      ),
                      Container(
                          padding: const EdgeInsets.only(
                              top: 10, left: 24, bottom: 12),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Image.asset(
                              'assets/images/_logo.png',
                            ),
                          )),
                      Container(
                        padding: const EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 24, bottom: 12),
                                  child: Text(
                                    'Hi, Welcome to !',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: AppColors.darkBlue,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 24, bottom: 15),
                              child: Text(
                                'Sign up',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  color: AppColors.darkBlue,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w200,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2, left: 24),
                        child: Text(
                          'Name',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.black75,
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Container(
                          //height: 40,
                          width: 335,
                          child: TextFormField(
                            autofocus: Platform.isIOS ? true : false,
                            cursorColor: Colors.black,
                            keyboardType: TextInputType.name,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            controller: fullNameController,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.only(top: 10, left: 8),
                              hintText: 'Enter name',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter full name';
                              } else if (AppUtils.isNumeric(value)) {
                                return 'Name should not consist of numbers';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2, left: 24),
                        child: Text(
                          'Email Address',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.black75,
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Container(
                          // height: 40,
                          width: 335,
                          child: TextFormField(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            readOnly:
                                (widget.userSignupPageArgument?.email != null)
                                    ? true
                                    : false,
                            cursorColor: Colors.black,
                            validator: (text) {
                              Pattern pattern = AppConstants.emailPattern;
                              RegExp regex = RegExp(pattern.toString());
                              if (!regex.hasMatch(text!)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.emailAddress,
                            controller: emailController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              hintText: 'Enter email address',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 12,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: 2, left: 24),
                        child: Text(
                          'Mobile Number',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            color: AppColors.black75,
                            fontSize: 12,
                            fontWeight: FontWeight.w200,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24, right: 24),
                        child: Container(
                          width: 335,
                          child: TextFormField(
                            cursorColor: Colors.black,
                            readOnly:
                                (widget.userSignupPageArgument?.mobileNumber !=
                                        null)
                                    ? true
                                    : false,
                            keyboardType: TextInputType.phone,
                            controller: phoneNumberController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 5.0, horizontal: 10.0),
                              prefixIcon: widget.userSignupPageArgument
                                          ?.extensionNumber ==
                                      null
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          bottom: 3,
                                          top: 0,
                                          left: 10,
                                          right: 4),
                                      child: SizedBox(
                                        height: 20,
                                        width: 40,
                                        child: CountryCodePicker(
                                          initialSelection: 'IN',
                                          hideMainText: true,
                                          showDropDownButton: false,
                                          builder: (countryCode) {
                                            return Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    '${countryCode!.dialCode!.toLowerCase()}'),
                                                Icon(
                                                  Icons.keyboard_arrow_down,
                                                  color: AppColors.grey2,
                                                  size: 16,
                                                )
                                                // Text(countryCode.dialCode!),
                                              ],
                                            );
                                          },
                                          onInit: (value) {
                                            _countryCode = value!.dialCode!;
                                          },
                                          onChanged: (value) {
                                            setState(() {
                                              if (value.dialCode != null) {
                                                _countryCode = value.dialCode!;
                                              }
                                            });
                                          },
                                        ),
                                      ),
                                    )
                                  : null,
                              hintText: 'Enter mobile number',
                              hintStyle: TextStyle(fontStyle: FontStyle.italic),
                              border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.redAccent),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(4)),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a valid mobile number';
                              } else if (!AppUtils.isNumeric(value)) {
                                return 'Numbers should not consist of alphabets';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 17,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 24, right: 24),
                        child: Container(
                          height: 45,
                          width: 330,
                          decoration: BoxDecoration(
                            color: AppColors.limeGreen,
                            borderRadius: BorderRadius.circular(
                              4,
                            ),
                          ),
                          child: TextButton(
                              onPressed: () {
                                validateAndSubmit(state);
                              },
                              style: TextButton.styleFrom(
                                primary: Colors.transparent,
                              ),
                              child: ((state is UserUiHandlerState) &&
                                      state.otpStatus == 1)
                                  ? AppCircularProgressbar()
                                  : Text(
                                      'Sign up',
                                      style: TextStyle(
                                        color: AppColors.greyWhite,
                                        fontSize: 18,
                                        // fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w700,
                                      ),
                                    )),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Text(
                          'By continuing you agree to our',
                          style: TextStyle(
                            // height: 18,
                            fontSize: 11,
                            color: AppColors.black75,
                            // fontFamily: 'Montserrat',
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                                color: AppColors.green1,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          Text(
                            'and ',
                            style: TextStyle(
                              color: AppColors.black75,
                              fontSize: 11,
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
                                color: AppColors.green1,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 33,
                      ),
                      Column(
                        children: [
                          FirebaseRemoteConfig.instance
                                  .getBool('social_button_signup')
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 140,
                                      child: Divider(
                                        thickness: 1,
                                        color: AppColors.green2,
                                      ),
                                    ),
                                    Text(
                                      '    OR    ',
                                      style: TextStyle(
                                        color: AppColors.darkBlue,
                                        fontSize: 14,
                                        // fontFamily: 'Montserrat',
                                      ),
                                    ),
                                    Container(
                                      width: 140,
                                      child: Divider(
                                        thickness: 1,
                                        color: AppColors.green2,
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink(),
                          FirebaseRemoteConfig.instance
                                  .getBool('social_button_signup')
                              ? SizedBox(
                                  height: 30,
                                )
                              : SizedBox.shrink(),
                          FirebaseRemoteConfig.instance
                                  .getBool('social_button_signup')
                              ? Center(
                                  child: Padding(
                                    padding:
                                        EdgeInsets.only(left: 10, right: 10),
                                    child: Container(
                                      width: 350,
                                      height: 45,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(0.5),
                                            spreadRadius: 1,
                                            blurRadius: 5,
                                            offset: Offset(0,
                                                3), // changes position of shadow
                                          ),
                                        ],
                                      ),
                                      child: TextButton(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5),
                                          child: Row(
                                            //mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 50.0),
                                                child: Image.asset(
                                                    'assets/images/google.png'),
                                              ),
                                              Text(
                                                'Sign in with Google',
                                                style: TextStyle(
                                                  fontSize: 17,
                                                  color: AppColors.grey66,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                        onPressed: () {
                                          _userSignupCubit
                                              .signInWithGoogle(_generalCubit);
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                      FirebaseRemoteConfig.instance
                              .getBool('social_button_signup')
                          ? SizedBox(
                              height: 20,
                            )
                          : SizedBox.shrink(),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account? ',
                              style: TextStyle(
                                color: AppColors.black75,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                // checkAndUpdate();
                                Navigator.of(context).pop();
                              },
                              child: Text(
                                'Login',
                                style: TextStyle(
                                  color: AppColors.green1,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> validateAndSubmit(UserSignupState state) async {
    try {
      if (validateAndSave()) {
        AppLog.log('Phone number: ${phoneNumberController.text}');
        AppLog.log('Extension: ${emailController.text}');
        AppLog.log('Full name: ${fullNameController.text}');
        AppLog.log(
            'Extension number: ${phoneNumberController.text.substring(0, _countryCode!.length)}');

        if (widget.userSignupPageArgument?.mobileNumber != null &&
            widget.userSignupPageArgument?.extensionNumber != null) {
          _userSignupCubit.checkIfValidEmailAndMobile(
              _generalCubit,
              '${phoneNumberController.text.substring(_countryCode!.length, phoneNumberController.text.length)}',
              '${phoneNumberController.text.substring(0, _countryCode!.length)}',
              _forceResendingToken,
              fullNameController.text,
              emailController.text);
        } else if (widget.userSignupPageArgument?.email != null) {
          _userSignupCubit.sendOTPToMobile(
            _generalCubit,
            phoneNumberController.text,
            _countryCode ?? '+91',
            emailController.text,
            fullNameController.text,
            _forceResendingToken,
          );
        }
      }
    } catch (e, s) {
      AppLog.log('Error while sending OTP: ', error: e, stackTrace: s);
    }
  }

  bool validateAndSave() {
    if (_formKey.currentState!.validate()) {
      return true;
    }
    return false;
  }
}
