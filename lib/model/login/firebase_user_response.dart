import 'package:json_annotation/json_annotation.dart';

part 'firebase_user_response.g.dart';

@JsonSerializable()
class FirebaseUserResponse {
  final String? uid;
  @JsonKey(name: 'phoneNumber')
  final String? phoneNumber;
  final String? apiKey;
  final String? appName;
  final String? authDomain;
  @JsonKey(name: 'stsTokenManager')
  final StsTokenManager? stsTokenManager;

  FirebaseUserResponse({
    required this.uid,
    required this.phoneNumber,
    required this.apiKey,
    required this.appName,
    required this.authDomain,
    required this.stsTokenManager,
  });

  factory FirebaseUserResponse.fromJson(Map<String, dynamic> json) =>
      _$FirebaseUserResponseFromJson(json);

  Map<String, dynamic> toJson() => _$FirebaseUserResponseToJson(this);
}

@JsonSerializable()
class StsTokenManager {
  final String? apiKey;
  final String? refreshToken;
  @JsonKey(name: 'accessToken')
  final String? accessToken;

  StsTokenManager({
    required this.apiKey,
    required this.refreshToken,
    required this.accessToken,
  });

  factory StsTokenManager.fromJson(Map<String, dynamic> json) =>
      _$StsTokenManagerFromJson(json);

  Map<String, dynamic> toJson() => _$StsTokenManagerToJson(this);
}
