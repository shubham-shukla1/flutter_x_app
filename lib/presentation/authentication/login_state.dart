part of 'login_cubit.dart';

abstract class LoginState extends Equatable {
  const LoginState();
}

class LoginInitial extends LoginState {
  @override
  List<Object> get props => [];
}

class LoginUiHandlerState extends LoginState {
  late final bool isLoading;

  // 0 = NONE, 1= SENDING 2=SENT 3=ENTERED WRONG
  late final int isWaitingForOTPSendCallBack;
  late final bool hasError;
  late final String errorMessage;

  LoginUiHandlerState(
      {this.isLoading = false,
      this.isWaitingForOTPSendCallBack = 0,
      this.hasError = false,
      this.errorMessage = ''});

  @override
  List<Object> get props => [
        this.isLoading,
        this.isWaitingForOTPSendCallBack,
        this.hasError,
        this.errorMessage
      ];
}

class LoginSuccessViaGoogle extends LoginState {
  late final UserStatus? userStatus;
  // late final FUserWithAccessToken user;

  LoginSuccessViaGoogle(this.userStatus);
  // LoginSuccessViaGoogle();

  @override
  List<Object> get props => [userStatus ?? Object()];
}

// class NonUser extends LoginState {
//   // late final FUserWithAccessToken user;

//   // LoginUserLoginSuccessViaGoogle(this.user);
//   // LoginSuccessViaGoogle();

//   @override
//   List<Object> get props => [];
// }

class LoginSuccessViaMobile extends LoginState {
  late final FUserWithAccessToken user;
  final UserStatus? userStatus;

  LoginSuccessViaMobile(this.user, this.userStatus);

  @override
  List<Object> get props => [user, userStatus ?? Object()];
}

class LoginSuccessViaEmail extends LoginState {
  // late final FUserWithAccessToken user;
  final UserStatus? userStatus;
  LoginSuccessViaEmail(this.userStatus);

  @override
  List<Object> get props => [userStatus ?? Object()];
}

class MobileOTPSentSuccess extends LoginState {
  late final String verificationId;
  late final String mobile;
  late final String extension;
  late final int? forceResendingToken;

  MobileOTPSentSuccess(
    this.verificationId,
    this.mobile,
    this.extension,
    this.forceResendingToken,
  );

  @override
  List<Object> get props =>
      [verificationId, mobile, extension, forceResendingToken as Object];
}

class EmailOTPSentSuccess extends LoginState {
  late final String email;

  EmailOTPSentSuccess(this.email);

  @override
  List<Object> get props => [email];
}

class NoRecordFoundState extends LoginState {
  late final String? email;
  late final String? mobile;
  late final String? extension;
  late final String? firebaseToken;

  NoRecordFoundState({
    this.email,
    this.mobile,
    this.extension,
    this.firebaseToken,
  });

  @override
  List<Object?> get props => [];
}

class TruecallerInvalidCustomTokenState extends LoginState {
  final String mobile;
  final String extension;

  TruecallerInvalidCustomTokenState(
    this.mobile,
    this.extension,
  );

  @override
  List<Object> get props => [mobile, extension];
}
//  @override
// List<Object> get props =>
//      [email, mobile, extension, firebaseToken];
