class LoginUserResponse {
  bool? _error;
  Data? _data;

  bool? get error => _error;

  Data? get data => _data;

  LoginUserResponse({bool? error, Data? data}) {
    _error = error;
    _data = data;
  }

  LoginUserResponse.fromJson(dynamic json) {
    _error = json['error'] as bool;
    _data = json['data'] != null ? Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['error'] = _error;
    if (_data != null) {
      map['data'] = _data?.toJson();
    }
    return map;
  }
}

class Data {
  String? _type;
  User? _user;
  String? _token;
  String? _firebaseToken;

  String? get type => _type;

  User? get user => _user;

  String? get token => _token;

  String? get firebaseToken => _firebaseToken;

  Data({String? type, User? user, String? token, String? firebaseToken}) {
    _type = type;
    _user = user;
    _token = token;
    _firebaseToken = firebaseToken;
  }

  Data.fromJson(dynamic json) {
    _type = json['type'] as String;
    _user = json['user'] != null ? User.fromJson(json['user']) : null;
    _token = json['token'] as String;
    _firebaseToken =
        json['firebaseToken'] != null ? json['firebaseToken'] as String : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['type'] = _type;
    if (_user != null) {
      map['user'] = _user?.toJson();
    }
    map['token'] = _token;
    map['firebaseToken'] = _firebaseToken;
    return map;
  }
}

class User {
  int? _id;
  String? _username;
  String? _emailId;
  String? _creationDate;
  int? _emailVerifiedFlag;
  int? _phoneVerifiedFlag;
  int? _resetFlag;
  int? _statusFlag;
  int? _approvalFlag;
  dynamic? _parentUserId;
  String? _userType;
  dynamic? _registrationSource;
  int? _isAdmin;
  String? _partnerEventCode;
  Entity? _entity;

  Entity? get entity => _entity;

  int? get id => _id;

  String? get username => _username;

  String? get emailId => _emailId;

  String? get creationDate => _creationDate;

  int? get emailVerifiedFlag => _emailVerifiedFlag;

  int? get phoneVerifiedFlag => _phoneVerifiedFlag;

  int? get resetFlag => _resetFlag;

  int? get statusFlag => _statusFlag;

  int? get approvalFlag => _approvalFlag;

  dynamic? get parentUserId => _parentUserId;

  String? get userType => _userType;

  dynamic? get registrationSource => _registrationSource;

  int? get isAdmin => _isAdmin;

  String? get partnerEventCode => _partnerEventCode;

  User({
    int? id,
    String? username,
    String? emailId,
    String? creationDate,
    int? emailVerifiedFlag,
    int? phoneVerifiedFlag,
    int? resetFlag,
    int? statusFlag,
    int? approvalFlag,
    dynamic? parentUserId,
    String? userType,
    dynamic? registrationSource,
    int? isAdmin,
    String? partnerEventCode,
    Entity? entity,
  }) {
    _id = id;
    _username = username;
    _emailId = emailId;
    _creationDate = creationDate;
    _emailVerifiedFlag = emailVerifiedFlag;
    _phoneVerifiedFlag = phoneVerifiedFlag;
    _resetFlag = resetFlag;
    _statusFlag = statusFlag;
    _approvalFlag = approvalFlag;
    _parentUserId = parentUserId;
    _userType = userType;
    _registrationSource = registrationSource;
    _isAdmin = isAdmin;
    _partnerEventCode = partnerEventCode;
    _entity = entity;
  }

  User.fromJson(dynamic json) {
    _id = json['id'];
    _username = json['username'];
    _emailId = json['email_id'];
    _creationDate = json['creation_date'];
    _emailVerifiedFlag = json['email_verified_flag'];
    _phoneVerifiedFlag = json['phone_verified_flag'];
    _resetFlag = json['reset_flag'];
    _statusFlag = json['status_flag'];
    _approvalFlag = json['approval_flag'];
    _parentUserId = json['parent_user_id'];
    _userType = json['user_type'];
    _registrationSource = json['registration_source'];
    _isAdmin = json['is_admin'];
    _partnerEventCode = json['partner_event_code'];
    _entity = json['entity'] != null ? Entity.fromJson(json['entity']) : null;
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['username'] = _username;
    map['email_id'] = _emailId;
    map['creation_date'] = _creationDate;
    map['email_verified_flag'] = _emailVerifiedFlag;
    map['phone_verified_flag'] = _phoneVerifiedFlag;
    map['reset_flag'] = _resetFlag;
    map['status_flag'] = _statusFlag;
    map['approval_flag'] = _approvalFlag;
    map['parent_user_id'] = _parentUserId;
    map['user_type'] = _userType;
    map['registration_source'] = _registrationSource;
    map['is_admin'] = _isAdmin;
    map['partner_event_code'] = _partnerEventCode;
    if (_entity != null) {
      map['entity'] = _entity?.toJson();
    }
    return map;
  }
}

class Entity {
  int? _id;
  String? _fullName;

  //
  int? get id => _id;

  String? get fullName => _fullName;

  Entity({
    int? id,
    String? fullName,
  }) {
    _id = id;
    _fullName = fullName;
  }

  Entity.fromJson(dynamic json) {
    _id = json['id'];
    _fullName = json['full_name'];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map['id'] = _id;
    map['full_name'] = _fullName;
    return map;
  }
}
