part of 'user_signup_cubit.dart';

abstract class UserSignupState extends Equatable {
  const UserSignupState();
}

class UserSignupInitial extends UserSignupState {
  @override
  List<Object> get props => [];
}

class UserUiHandlerState extends UserSignupState {
  late final bool isLoading;

// 0 = NONE, 1= SENDING 2=SENT 3=ENTERED WRONG
  late final int otpStatus;
  late final bool hasError;
  late final String errorMessage;

  UserUiHandlerState(
      {this.isLoading = false,
      this.otpStatus = 0,
      this.hasError = false,
      this.errorMessage = ''});

  @override
  List<Object> get props =>
      [this.isLoading, this.otpStatus, this.hasError, this.errorMessage];
}

class LoginSuccessViaGoogle extends UserSignupState {
  late final UserStatus? userStatus;
  // late final FUserWithAccessToken user;

  LoginSuccessViaGoogle(this.userStatus);
  // LoginSuccessViaGoogle();

  @override
  List<Object> get props => [userStatus ?? Object()];
}

class USLoginSuccessViaMobile extends UserSignupState {
  //late final FUserWithAccessToken user;
  //final UserStatus? userStatus;

  //NRFLoginSuccessViaMobile(this.user, this.userStatus);
  USLoginSuccessViaMobile();
  //@override
  // List<Object> get props => [user, userStatus ?? Object()];
  @override
  List<Object> get props => [];
}

class USLoginSuccessViaEmail extends UserSignupState {
  // late final FUserWithAccessToken user;
  final UserStatus? userStatus;
  USLoginSuccessViaEmail(this.userStatus);

  @override
  List<Object> get props => [userStatus ?? Object()];
}

class USMobileOTPSentSuccess extends UserSignupState {
  late final String verificationId;
  late final String mobile;
  late final String extension;
  late final int? forceResendingToken;

  USMobileOTPSentSuccess(
    this.verificationId,
    this.mobile,
    this.extension,
    this.forceResendingToken,
  );

  @override
  List<Object> get props =>
      [verificationId, mobile, extension, forceResendingToken as Object];
}
