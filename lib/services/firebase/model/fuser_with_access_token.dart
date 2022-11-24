import 'package:firebase_auth/firebase_auth.dart';

class FUserWithAccessToken {
  late User _user;

  User get user => _user;

  set setUser(User user) {
    _user = user;
  }

  late String _accessToken;

  String get accessToken => _accessToken;

  set setAccessToken(String accessToken) {
    _accessToken = accessToken;
  }

  String? refreshToken;

  FUserWithAccessToken(this._user, this._accessToken, {this.refreshToken});
}