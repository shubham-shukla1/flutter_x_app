import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_remote_config/firebase_remote_config.dart';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:move_to_background/move_to_background.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:phone_number/phone_number.dart';
import 'package:store_redirect/store_redirect.dart';

import 'package:truecaller_sdk/truecaller_sdk.dart';
import '../../shared/app_constants.dart';
import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/common_importer.dart';

import '../../shared/util/app_progressbar.dart';
import '../../shared/util/app_scaffold.dart';
import '../../own_package/country_picker/country_code_picker.dart';
import '../../own_package/internet_connectivity/navigation_Service.dart';
import '../../own_package/internet_connectivity/static_index.dart';
import '../../presentation/authentication/login_cubit.dart';
import '../../presentation/general/general_cubit.dart';
import '../../presentation/my_in_app_update/my_in_app_update.dart';
import '../../services/common_analytics_service/app_analytics_service.dart';
import '../../services/feature_configuration_service.dart';
import '../../services/network/network_service.dart';
import '../../services/truecaller_service.dart';
import '../sign_up/user_signup_page.dart';
import '../single_webview_page.dart';
import 'login_otp_page.dart';
import '../../shared/util/app_util.dart';

class LoginPageArgument {
  final String? funnelName;

  LoginPageArgument({this.funnelName});
}

class LoginPageParent extends StatelessWidget {
  static final String routeName = '/loginPage';

  // final LoginPageArgument argument;
  const LoginPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    LoginPageArgument? args;
    if (ModalRoute.of(context)!.settings.arguments != null) {
      args = ModalRoute.of(context)!.settings.arguments as LoginPageArgument;
    }

    return LoginPage(args);
  }
}

class LoginPage extends StatefulWidget {
  final LoginPageArgument? loginPageArgument;

  LoginPage(
    this.loginPageArgument, {
    Key? key,
  }) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  late LoginCubit _loginCubit;
  late GeneralCubit _generalCubit;
  late String _verificationId;
  late String _mobileNumberWithoutExtension;
  bool switchLoginMethodToEmail = false;
  int? _forceResendingToken;
  String? _countryCode;
  String? _errorMsg;
  DateTime? currentBackPressTime;
  String? isoCode;
  late String mobileAndExtension;
  late String defaultExtension;
  final _formKey = GlobalKey<FormState>();
  final _emailKey = GlobalKey<FormFieldState>();
  final _phoneKey = GlobalKey<FormFieldState>();
  bool submitMobile = false;
  bool submitEmail = false;
  bool validMobile = false;
  PackageInfo _packageInfo = PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
    buildSignature: 'Unknown',
  );

  StreamSubscription<TruecallerSdkCallback>? streamSubscription;

  Future<PackageInfo> _initPackageInfo() async {
    final info = await PackageInfo.fromPlatform();

    _packageInfo = info;
    return info;
  }

  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  void initState() {
    if ((widget.loginPageArgument != null &&
        widget.loginPageArgument?.funnelName == 'splashFunnel')) {
      Future.delayed(Duration(milliseconds: 700), () {
        checkAndUpdate();
        //checkInternetConnection();
      });
    }
    _loginCubit = BlocProvider.of<LoginCubit>(context);
    _generalCubit = BlocProvider.of<GeneralCubit>(context);
    phoneNumberController.addListener(() {
      //mobileAndExtension = '${_countryCode}${_mobileNumberOrEmail.text}';
      //defaultExtension = '+91${_mobileNumberOrEmail.text}';
      //bool isValid = await PhoneNumberUtil().validate(_countryCode == null ? defaultExtension : mobileAndExtension , isoCode ?? 'IN');
      setState(() {
        submitMobile = phoneNumberController.text.isNotEmpty;
      });
    });
    emailController.addListener(() {
      setState(() {
        submitEmail = emailController.text.isNotEmpty;
      });
    });
    super.initState();

    /// Ask permission for required permissions
    Future<void> _futurePermisson = _generalCubit.askRequiredPermissions();

    /// Popup truecaller only if device is android and truecaller is enabled
    late FeatureConfigurationService featureFlagMap;
    try {
      featureFlagMap = FeatureConfigurationService(
          jsonDecode(FirebaseRemoteConfig.instance.getString('feature_flags'))
              as Map<String, dynamic>);
    } catch (e) {
      AppLog.log('feature_flags not found');
    } finally {
      if (featureFlagMap.isTCEnabled) {
        if (Platform.isAndroid) TrueCallerService.initTC();
        _futurePermisson.then((value1) {
          if (Platform.isAndroid) {
            _loginCubit.promptTrueCaller().then((readyForTC) {
              if (readyForTC) {
                streamTCStream();
              }
            });
          }
        });
      }
    }

    InternetAddress.lookup('google.com').then((result) {
      if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
        // Internet working
      } else {
        // No-Internet working
        IndexClass.index = 1;
        NavigationService.navigateTo(page: null, navigationKey: null);
        // Navigator.of(context).pushNamed(NewNoInternetPageParent.routeName);
      }
    }).onError((error, stackTrace) {
      if (error is SocketException) {
        // Navigator.of(context).pushNamed(NewNoInternetPageParent.routeName);
        IndexClass.index = 1;
        NavigationService.navigateTo(page: null, navigationKey: null);
      }
    });

    AppAnalyticsService.instance.pageView('Tech - Login Page');
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.detached:
        AppAnalyticsService.instance.loginPageDropOff();
        AppLog.log('App Closed on Login Page');
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        break;
    }
  }

  @override
  void didChangeDependencies() {
    // _loginCubit = LoginCubit();

    super.didChangeDependencies();
  }

  Future<bool> onWillPop() {
    // if (onBackPressed()) return Future.value(false);
    DateTime now = DateTime.now();
    if (currentBackPressTime == null) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press back again to close the app.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.value(false);
    } else if (now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(
        msg: 'Press back again to close the app.',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return Future.value(false);
    }
    AppAnalyticsService.instance.loginPageDropOff();

    MoveToBackground.moveTaskToBack();

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: onWillPop,
      child: AppScaffold(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: BlocConsumer<LoginCubit, LoginState>(
            bloc: _loginCubit,
            listener: (context, state) {
              if (state is LoginUiHandlerState) {
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
              } else if (state is TruecallerInvalidCustomTokenState) {
                phoneNumberController.text = state.mobile;
                _loginCubit.sendOTPToMobile(
                  _generalCubit,
                  state.mobile,
                  state.extension,
                  _forceResendingToken,
                );
              } else if (state is LoginSuccessViaGoogle) {
                _loginCubit.emit(LoginInitial());
                UserStatus? _userStatus;
                _userStatus = state.userStatus;

                //Navigate to non or home page based on status

                // AutoRouter.of(context).replace(
                //   HomeRoute(testName: 'loginFunnel'),
                // );
              } else if (state is MobileOTPSentSuccess) {
                setState(() {
                  _verificationId = state.verificationId;
                  _mobileNumberWithoutExtension = state.mobile;
                  _countryCode = state.extension;
                  _forceResendingToken = state.forceResendingToken;
                });
                if (phoneNumberController.text.isNotEmpty &&
                    _countryCode != null &&
                    emailController.text.isEmpty) {
                  Navigator.of(context).pushNamed(LoginOtpPageParent.routeName,
                      arguments: LoginOtpPageArgument(
                        mobileNumber: '${phoneNumberController.text}',
                        extensionNumber: '${_countryCode}',
                        email: emailController.text,
                        forcedResendingToken: _forceResendingToken,
                        verificationId: _verificationId,
                      ));
                  //_userSignupCubit.emit(UserSignupInitial());
                  // _userSignupCubit.emit(UserSignupInitial());
                }
              } else if (state is EmailOTPSentSuccess) {
                if (emailController.text.isNotEmpty &&
                    phoneNumberController.text.isEmpty &&
                    _countryCode != null) {
                  Navigator.of(context).pushNamed(LoginOtpPageParent.routeName,
                      arguments: LoginOtpPageArgument(
                        email: emailController.text,
                      ));
                }
              } else if (state is NoRecordFoundState) {
                //_loginCubit.sendOTPToEmail(_generalCubit, state.email.toString());
                Navigator.of(context).pushNamed(
                  UserSignupPageParent.routeName,
                  arguments: UserSignupPageArgument(
                    funnelName: 'loginFunnel',
                    email: state.email ?? null,
                    mobileNumber: state.mobile ?? null,
                    extensionNumber: state.extension ?? null,
                  ),
                );
                _loginCubit.emit(LoginInitial());
              }
            },
            builder: (_, state) {
              return SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 67,
                        ),

                        Padding(
                          padding: EdgeInsets.only(left: 24, bottom: 10),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Login',
                              style: TextStyle(
                                  // fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.titleColor,
                                  fontSize: 32,
                                  fontFamily: 'Larken'),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedCrossFade(
                              duration: Duration(milliseconds: 200),
                              crossFadeState: switchLoginMethodToEmail
                                  ? CrossFadeState.showSecond
                                  : CrossFadeState.showFirst,
                              firstChild: Text(
                                'Enter your phone number to proceed',
                                style: TextStyle(
                                  // fontFamily: 'Montserrat',
                                  color: AppColors.black75,
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                              secondChild: Text(
                                'Enter your email address to proceed',
                                style: TextStyle(
                                  // fontFamily: 'Montserrat',
                                  color: AppColors.black75,
                                  fontFamily: 'Poppins',
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 24, right: 24),
                          child: switchLoginMethodToEmail != true
                              ? Container(
                                  width: 335,
                                  child: TextFormField(
                                    key: _phoneKey,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    cursorColor: Colors.black,
                                    style: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 1),
                                    keyboardType: TextInputType.phone,
                                    controller: phoneNumberController,
                                    onChanged: (value) {
                                      setState(() {
                                        _errorMsg = null;
                                      });
                                    },
                                    decoration: InputDecoration(
                                      focusColor: AppColors.black75,
                                      errorText: _errorMsg,
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 5.0, horizontal: 10.0),
                                      prefixIcon: Padding(
                                        padding: EdgeInsets.only(
                                            bottom: 2, left: 10, right: 8),
                                        child: SizedBox(
                                          height: 20,
                                          width: 45,
                                          child: CountryCodePicker(
                                            initialSelection: 'IN',
                                            hideMainText: true,
                                            showDropDownButton: false,
                                            builder: (countryCode) {
                                              return Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${countryCode!.dialCode!.toLowerCase()}',
                                                    style: TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 16,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            },
                                            onInit: (value) {
                                              _countryCode = value!.dialCode!;
                                            },
                                            onChanged: (value) {
                                              setState(() {
                                                if (value.dialCode != null) {
                                                  _countryCode =
                                                      value.dialCode!;
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ),
                                      hintText: 'Enter mobile number',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            color: AppColors.black75),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.redAccent),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter a valid mobile number';
                                      } else if (!AppUtils.isNumeric(value)) {
                                        return 'This field should only contain numbers';
                                      }
                                      return null;
                                    },
                                  ),
                                )
                              : Container(
                                  // height: 40,
                                  width: 335,
                                  child: TextFormField(
                                    key: _emailKey,
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      letterSpacing: 1,
                                    ),
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    cursorColor: Colors.black,
                                    validator: (text) {
                                      Pattern pattern =
                                          AppConstants.emailPattern;
                                      RegExp regex = RegExp(pattern.toString());
                                      if (!regex.hasMatch(text!)) {
                                        return 'Please enter a valid email';
                                      }
                                      return null;
                                    },
                                    keyboardType: TextInputType.emailAddress,
                                    controller: emailController,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.fromLTRB(
                                          20, 5, 5, 5),
                                      hintText: 'yourname@example.com',
                                      hintStyle: TextStyle(
                                        fontFamily: 'Poppins',
                                        letterSpacing: 0,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                        borderSide: BorderSide(
                                            color: AppColors.black75),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.redAccent),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(4)),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 24),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              child: AnimatedCrossFade(
                                duration: Duration(milliseconds: 200),
                                crossFadeState: switchLoginMethodToEmail != true
                                    ? CrossFadeState.showFirst
                                    : CrossFadeState.showSecond,
                                firstChild: Text(
                                  'Use email address',
                                  style: TextStyle(
                                    color: AppColors.greyishBlue,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                                secondChild: Text(
                                  'Use phone number',
                                  style: TextStyle(
                                    color: AppColors.greyishBlue,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              onPressed: () {
                                emailController.clear();
                                phoneNumberController.clear();
                                AppUtils.newFocus(context);
                                if (switchLoginMethodToEmail == true) {
                                  setState(() {
                                    submitMobile = false;
                                    switchLoginMethodToEmail = false;
                                  });
                                } else if (switchLoginMethodToEmail == false) {
                                  setState(() {
                                    submitEmail = false;
                                    switchLoginMethodToEmail = true;
                                  });
                                }
                              },
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        phoneNumberController.text.isEmpty ||
                                switchLoginMethodToEmail == true
                            ? FirebaseRemoteConfig.instance
                                    .getBool('social_login')
                                ? Center(
                                    child: Padding(
                                      padding:
                                          EdgeInsets.only(left: 24, right: 24),
                                      child: Container(
                                        width: 335,
                                        height: 46.5,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.black50),
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4.0),
                                        ),
                                        child: TextButton(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(top: 0),
                                            child: Row(
                                              //mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 10),
                                                  child: Image.asset(
                                                    'assets/images/google.png',
                                                  ),
                                                ),
                                                Text(
                                                  'Continue with Google',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: AppColors.grey66,
                                                    fontFamily: 'Poppins',
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          onPressed: () {
                                            _loginCubit.signInWithGoogle(
                                                _generalCubit);
                                          },
                                        ),
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink()
                            : SizedBox.shrink(),
                        ((state is LoginUiHandlerState) &&
                                (state.isWaitingForOTPSendCallBack == 2 ||
                                    state.isWaitingForOTPSendCallBack == 3))
                            ? SizedBox(
                                height: 6,
                              )
                            : SizedBox.shrink(),
                        SizedBox(
                          height: 20,
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 24, right: 24),
                          child: Container(
                            height: 45,
                            width: 335,
                            decoration: BoxDecoration(
                              color: (submitMobile == true &&
                                          switchLoginMethodToEmail == false) ||
                                      (submitEmail == true &&
                                          switchLoginMethodToEmail == true)
                                  ? AppColors.limeGreen
                                  : AppColors.green2,
                              borderRadius: BorderRadius.circular(
                                4,
                              ),
                            ),
                            child: TextButton(
                                onPressed: () {
                                  if (submitMobile == true ||
                                      submitEmail == true) {
                                    validateAndSubmit(state);
                                  }
                                },
                                style: TextButton.styleFrom(
                                  primary: Colors.transparent,
                                ),
                                child: ((state is LoginUiHandlerState) &&
                                        state.isWaitingForOTPSendCallBack == 1)
                                    ? AppCircularProgressbar()
                                    : Text(
                                        'CONTINUE',
                                        style: TextStyle(
                                          color: AppColors.greyWhite,
                                          fontSize: 18,
                                          fontFamily: 'Poppins',
                                          fontWeight: FontWeight.w600,
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
                                        fontSize: 9),
                                  ),
                                ),
                                Text(
                                  '& ',
                                  style: TextStyle(
                                      color: AppColors.black50, fontSize: 9),
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
                                        fontSize: 9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 33,
                        ),
                        // FutureBuilder<PackageInfo>(
                        //   future: PackageInfo.fromPlatform(),
                        //   builder: (_, snapShot) {
                        //     try {
                        //       if (snapShot.hasData && !snapShot.hasError) {
                        //         return Text(
                        //             'App Version: V ${snapShot.data!.version} (${snapShot.data!.buildNumber})${AppFlavorConfig.instance!.isDevelopment! ? '-Dev' : ''}');
                        //       }
                        //       return Text(
                        //           'App Version: V ${FirebaseRemoteConfig.instance.getString(Platform.isAndroid ? 'android_version' : 'ios_version')}');
                        //     } catch (e) {
                        //       return Text(
                        //           'App Version: V ${FirebaseRemoteConfig.instance.getString(Platform.isAndroid ? 'android_version' : 'ios_version')}');
                        //     }
                        //   },
                        // ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> validateAndSubmit(LoginState state) async {
    try {
      if (validateAndSave()) {
        AppLog.log('Phone number: ${phoneNumberController.text}');
        AppLog.log('Email: ${emailController.text}');
        AppLog.log('country code: ${_countryCode}');

        if (phoneNumberController.text.isNotEmpty &&
            emailController.text.isEmpty) {
          try {
            mobileAndExtension = '${_countryCode}${phoneNumberController.text}';
            defaultExtension = '+91${phoneNumberController.text}';
            bool isValid = await PhoneNumberUtil().validate(
                _countryCode == null ? defaultExtension : mobileAndExtension,
                regionCode: isoCode ?? 'IN');
            if (isValid) {
              AppLog.log('Get OTP : Number ');
              AppUtils.newFocus(context);
              _loginCubit.sendOTPToMobile(
                  _generalCubit,
                  phoneNumberController.text,
                  _countryCode != null ? _countryCode! : '+91',
                  _forceResendingToken);
            } else {
              setState(() {
                _errorMsg = 'Please enter a valid mobile number';
              });
            }
          } catch (e, s) {
            setState(() {
              _errorMsg = 'Please enter a valid mobile number';
            });
            AppLog.log('Error while validating mobile number',
                error: e, stackTrace: s);
          }
        } else if (emailController.text.isNotEmpty &&
            phoneNumberController.text.isEmpty) {
          _loginCubit.sendOTPToEmail(
            _generalCubit,
            emailController.text,
          );
        }
      }
    } catch (e, s) {
      AppLog.log('Error while sending OTP: ', error: e, stackTrace: s);
    }
  }

  @override
  void dispose() {
    // _loginCubit.close();
    phoneNumberController.dispose();
    emailController.dispose();
    if (streamSubscription != null) streamSubscription!.cancel();
    super.dispose();
  }

  Future<void> checkAndUpdate() async {
    AppLog.log('checkAndUpdate');
    MyInAppUpdate _myInAppUpdate = MyInAppUpdate();

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (widget.loginPageArgument != null &&
          widget.loginPageArgument?.funnelName == 'splashFunnel') {
        if (Platform.isIOS && await _myInAppUpdate.ifForceUpdateRequired()) {
          calliOSForceUpdateDialog();
        } else if (Platform.isIOS &&
            await _myInAppUpdate.isGentalUpdateAvailable()) {
          calliOSGentalUpdateDialog();
        } else if (Platform.isAndroid &&
            await InAppUpdate.checkForUpdate() ==
                UpdateAvailability.updateAvailable &&
            await _myInAppUpdate.ifForceUpdateRequired()) {
          // call android native force update dialog.
          callAndroidNativeForceUpdateDialog();
        } else if (Platform.isAndroid &&
            await InAppUpdate.checkForUpdate() ==
                UpdateAvailability.updateAvailable &&
            await _myInAppUpdate.isGentalUpdateAvailable()) {
          // call android native gental update dialog.
          callAndroidNativeGentalUpdateDialog();
        } else if (await _myInAppUpdate.ifForceUpdateRequired()) {
          // call iOS force update dialog.
          calliOSForceUpdateDialog();
        } else if (await _myInAppUpdate.isGentalUpdateAvailable()) {
          // call android native gental update dialog.
          calliOSGentalUpdateDialog();
        }
      }
    }).catchError((_) async {
      AppLog.log('Error in checkAndUpdate');
      if (await _myInAppUpdate.ifForceUpdateRequired()) {
        // call iOS force update dialog.
        calliOSForceUpdateDialog();
      } else if (await _myInAppUpdate.isGentalUpdateAvailable()) {
        // call android native gental update dialog.
        calliOSGentalUpdateDialog();
      }
    });
  }

  void calliOSForceUpdateDialog() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        enableDrag: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: _onWillPop2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 0),
                    child: Text(
                      'New Update Available!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                    child: Text(
                      'A new version of app is available with better features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontFamily: 'Montserrat',
                        color: AppColors.darkBlue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              StoreRedirect.redirect(
                                androidAppId: 'androdAppId',
                                iOSAppId: 'ios:iosAppId',
                              );
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Update Now',
                                  style: TextStyle(
                                    color: AppColors.greyWhite,
                                    fontSize: 16,
                                    // fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void calliOSGentalUpdateDialog() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 55, vertical: 0),
                  child: Text(
                    'New Update Available!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Spacer(),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                  child: Text(
                    'A new version of app is available with better features',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontFamily: 'Montserrat',
                      color: AppColors.darkBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            StoreRedirect.redirect(
                                androidAppId: 'o',
                                iOSAppId:
                                    '1:184908183181:ios:3454e3b53c881f379554c4');
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Update Now',
                                style: TextStyle(
                                  color: AppColors.greyWhite,
                                  fontSize: 16,
                                  // fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 14,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Remind Later',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.neutralGrey,
                      // fontFamily: 'Montserrat',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  void callAndroidNativeForceUpdateDialog() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        enableDrag: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: _onWillPop2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 0),
                    child: Text(
                      'New Update Available!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                    child: Text(
                      'A new version of app is available with better features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontFamily: 'Montserrat',
                        color: AppColors.darkBlue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              AppAnalyticsService.instance
                                  .forceUpdateCalled('Called');
                              InAppUpdate.performImmediateUpdate()
                                  .then((value) {
                                AppAnalyticsService.instance
                                    .forceUpdateCalled('Then');
                              }).catchError((exception) {
                                AppAnalyticsService.instance.forceUpdateCalled(
                                    'catchError',
                                    errorMessage: '${exception.message}');
                                AppLog.log(
                                    'Error while doing immediate uopdate : $exception');
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Update Now',
                                  style: TextStyle(
                                    color: AppColors.greyWhite,
                                    fontSize: 16,
                                    // fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void callAndroidNativeGentalUpdateDialog() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        context: context,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 20),
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.close,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 55, vertical: 0),
                  child: Text(
                    'New Update Available!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkBlue,
                      fontSize: 18,
                    ),
                  ),
                ),
                // Spacer(),
                SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                  child: Text(
                    'A new version of app is available with better features',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      // fontFamily: 'Montserrat',
                      color: AppColors.darkBlue,
                      fontSize: 12,
                    ),
                  ),
                ),
                SizedBox(
                  height: 22,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 23),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            AppAnalyticsService.instance.updateCalled('Called');
                            InAppUpdate.startFlexibleUpdate().then((value) {
                              AppAnalyticsService.instance.updateCalled('then');
                              InAppUpdate.completeFlexibleUpdate();
                            }).catchError((exception) {
                              AppAnalyticsService.instance.updateCalled(
                                  'catchError',
                                  errorMessage: '${exception.message}');
                              AppLog.log(
                                  'Error while doing flexible uopdate : $exception');
                            });
                            Navigator.pop(context);
                          },
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.limeGreen,
                              borderRadius: BorderRadius.circular(
                                10,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Update Now',
                                style: TextStyle(
                                  color: AppColors.greyWhite,
                                  fontSize: 16,
                                  // fontFamily: 'Montserrat',
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: 14,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Remind Later',
                    style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: AppColors.neutralGrey,
                      // fontFamily: 'Montserrat',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<bool> _onWillPop2() async {
    await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: Padding(
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 0),
          child: Text(
            'Do you want to exit the App?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontWeight: FontWeight.bold,
              color: AppColors.darkBlue,
              fontSize: 16,
            ),
          ),
        ),
        // content: Padding(
        //   padding: EdgeInsets.symmetric(horizontal: 50.w, vertical: 0),
        //   child: Text(
        //     'Do you want to exit the App?',
        //     textAlign: TextAlign.center,
        //     style: TextStyle(
        //       fontFamily: 'Montserrat',
        //       color: AppColors.darkBlue,
        //       fontSize: 14,
        //     ),
        //   ),
        // ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              if (Platform.isAndroid) {
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              } else {
                minimizeApp();
              }
            },
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.limeGreen,
                borderRadius: BorderRadius.circular(
                  10,
                ),
              ),
              child: Center(
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: AppColors.greyWhite,
                    fontSize: 17,
                    // fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              return Navigator.of(context).pop(false);
            },
            child: Center(
              child: Text(
                'No',
                style: TextStyle(
                  color: AppColors.limeGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return false;
  }

  static const MethodChannel _channel = const MethodChannel('minimize_app');

  static Future<void> minimizeApp() async {
    await _channel
        .invokeMethod('minimize_app#minimize')
        .catchError((error) => print("Error: $error"));
  }

  // void checkInternetConnection() {
  //   Connectivity().onConnectivityChanged.listen((ConnectivityResult value) {
  //     if (value.index != ConnectivityResult.mobile.index &&
  //         value.index != ConnectivityResult.wifi.index) {
  //       if (mounted) {
  //         Navigator.of(context).pushNamed(
  //           NoInternetPageParent.routeName,
  //           arguments: NoInternetPageArgument('supposedToLandLoginPage'),
  //         );
  //       }
  //     }
  //   });
  // }

  void askForFoceUpdateAndroid() {
    showModalBottomSheet(
        backgroundColor: Colors.transparent,
        isScrollControlled: false,
        enableDrag: false,
        isDismissible: false,
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: _onWillPop2,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 55, vertical: 0),
                    child: Text(
                      'New Update Available!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontFamily: 'Montserrat',
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkBlue,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  // Spacer(),
                  SizedBox(
                    height: 12,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 0),
                    child: Text(
                      'A new version of app is available with better features',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        // fontFamily: 'Montserrat',
                        color: AppColors.darkBlue,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 22,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 23),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              AppAnalyticsService.instance
                                  .forceUpdateCalled('Called');
                              InAppUpdate.performImmediateUpdate()
                                  .then((value) {
                                AppAnalyticsService.instance
                                    .forceUpdateCalled('Then');
                              }).catchError((exception) {
                                AppAnalyticsService.instance.forceUpdateCalled(
                                    'catchError',
                                    errorMessage: '${exception.message}');
                                AppLog.log(
                                    'Error while doing immediate update : $exception');
                              });
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.limeGreen,
                                borderRadius: BorderRadius.circular(
                                  10,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'Update Now',
                                  style: TextStyle(
                                    color: AppColors.greyWhite,
                                    fontSize: 16,
                                    // fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(
                    height: 14,
                  ),
                ],
              ),
            ),
          );
        });
  }

  void streamTCStream() {
    try {
      streamSubscription = TruecallerSdk.streamCallbackData.listen((event) {
        switch (event.result) {
          case TruecallerSdkCallbackResult.success:
            _loginCubit.signInWithTruecaller(
              _generalCubit,
              event.profile!.phoneNumber.toString().substring(0, 3),
              event.profile!.phoneNumber.replaceFirst(
                  '${event.profile!.phoneNumber.toString().substring(0, 3)}',
                  ''),
              event.profile!.payload!,
              event.profile!.signature!,
            );
            break;
          case TruecallerSdkCallbackResult.failure:
            String? errMsg =
                TrueCallerService.getTheErrorMessageByCode(event.error!);
            if (errMsg != null) {
              _loginCubit.emit(
                LoginUiHandlerState(
                  hasError: true,
                  errorMessage: errMsg,
                  isWaitingForOTPSendCallBack: 0,
                ),
              );
              Future.delayed(Duration(milliseconds: 300)).then((value) {
                _loginCubit.emit(LoginInitial());
              });
            }
            break;
          case TruecallerSdkCallbackResult.verification:
            print('Verification Required!!');
            break;
          default:
            print('Invalid result');
        }
      });
    } catch (e, s) {
      AppLog.log('Error while TC streaming', error: e, stackTrace: s);
    }
  }

  bool validateAndSave() {
    if (phoneNumberController.text.isNotEmpty && emailController.text.isEmpty) {
      _phoneKey.currentState!.validate();
      if (_phoneKey.currentState!.validate()) {
        return true;
      } else {
        return false;
      }
    } else if (phoneNumberController.text.isEmpty &&
        emailController.text.isNotEmpty) {
      _emailKey.currentState!.validate();
      if (_emailKey.currentState!.validate()) {
        return true;
      } else {
        return false;
      }
    }
    // if (_formKey.currentState!.validate()) {
    //   return true;
    // }
    return false;
  }
}
