import 'package:json_annotation/json_annotation.dart';

part 'login_via_otp_firebase_request.g.dart';

@JsonSerializable()
class LoginViaOTPFirebaseRequest {
  String phone;
  String extension;
  @JsonKey(name: "firebase_response")
  Map<String, dynamic> firebaseResponse;
  // @JsonKey(name: "app_name")
  // String appName;

  LoginViaOTPFirebaseRequest(this.phone, this.extension, this.firebaseResponse);

  factory LoginViaOTPFirebaseRequest.fromJson(Map<String, dynamic> json) =>
      _$LoginViaOTPFirebaseRequestFromJson(json);

  Map<String, dynamic> toJson() => _$LoginViaOTPFirebaseRequestToJson(this);
}
