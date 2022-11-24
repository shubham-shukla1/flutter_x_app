// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'firebase_user_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FirebaseUserResponse _$FirebaseUserResponseFromJson(
        Map<String, dynamic> json) =>
    FirebaseUserResponse(
      uid: json['uid'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      apiKey: json['apiKey'] as String?,
      appName: json['appName'] as String?,
      authDomain: json['authDomain'] as String?,
      stsTokenManager: json['stsTokenManager'] == null
          ? null
          : StsTokenManager.fromJson(
              json['stsTokenManager'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FirebaseUserResponseToJson(
        FirebaseUserResponse instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'phoneNumber': instance.phoneNumber,
      'apiKey': instance.apiKey,
      'appName': instance.appName,
      'authDomain': instance.authDomain,
      'stsTokenManager': instance.stsTokenManager,
    };

StsTokenManager _$StsTokenManagerFromJson(Map<String, dynamic> json) =>
    StsTokenManager(
      apiKey: json['apiKey'] as String?,
      refreshToken: json['refreshToken'] as String?,
      accessToken: json['accessToken'] as String?,
    );

Map<String, dynamic> _$StsTokenManagerToJson(StsTokenManager instance) =>
    <String, dynamic>{
      'apiKey': instance.apiKey,
      'refreshToken': instance.refreshToken,
      'accessToken': instance.accessToken,
    };
