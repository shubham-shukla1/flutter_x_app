import 'package:firebase_remote_config/firebase_remote_config.dart';

class AppConstants {
  static final String emailPattern =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  static final int resendOTPSecs =
      FirebaseRemoteConfig.instance.getInt('resend_sec');
  static final String playStoreURL = 'playStoreURL';
  static final String appStoreURL = 'appStoreURL';

  static final String meWithParam =
      'avtar;subscribed;activateReward;lastUpdateCount;rewardActivation;occupation;walletBalance;verifiedPhoneNumber;subscriptions;latestOrder;multiCauseSubscription;panNumber';
}
