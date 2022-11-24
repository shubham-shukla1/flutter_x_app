class UserModel {
  String? email;
  String? password;
  String? mobileExtension;
  String? phoneNumber;
  String? fullName;
  String? firebaseToken;
  String? registrationSource;
  String? userType;
  int? isSubscribed;

  UserModel({this.email,
    this.password,
    this.phoneNumber,
    this.mobileExtension,
    this.fullName,
    this.firebaseToken,
    this.isSubscribed,
    this.registrationSource,
    this.userType,
  });

  Map<String, dynamic> toJson(){
    return {
      'email_id': email,
      'password': password,
      'extension': mobileExtension,
      'phone_1': phoneNumber,
      'full_name': fullName,
      'user_type': userType,
      'registration_source': registrationSource,
      'is_subscribed' : isSubscribed,
      'accessToken': firebaseToken,
    };
  }
}