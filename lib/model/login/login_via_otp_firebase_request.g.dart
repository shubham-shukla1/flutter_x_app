// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_via_otp_firebase_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LoginViaOTPFirebaseRequest _$LoginViaOTPFirebaseRequestFromJson(
        Map<String, dynamic> json) =>
    LoginViaOTPFirebaseRequest(
      json['phone'] as String,
      json['extension'] as String,
      json['firebase_response'] as Map<String, dynamic>,
    );

Map<String, dynamic> _$LoginViaOTPFirebaseRequestToJson(
        LoginViaOTPFirebaseRequest instance) =>
    <String, dynamic>{
      'phone': instance.phone,
      'extension': instance.extension,
      'firebase_response': instance.firebaseResponse,
    };
