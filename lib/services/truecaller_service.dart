import 'dart:io';

import 'package:flutter_x_app/shared/app_theme/app_colors/app_colors.dart';
import 'package:truecaller_sdk/truecaller_sdk.dart';

class TrueCallerService {
  static void initTC() {
    if (Platform.isAndroid) {
      TruecallerSdk.initializeSDK(
        buttonColor: AppColors.limeGreen.value,
        buttonTextColor: AppColors.greyWhite.value,
        sdkOptions: TruecallerSdkScope.SDK_OPTION_WITHOUT_OTP,
        privacyPolicyUrl: 'https://privacy-policy.php',
        termsOfServiceUrl: 'https://terms-of-use.php',
      );
    }
  }

  /// https://docs.truecaller.com/truecaller-sdk/android/integrating-with-your-app/handling-error-scenarios
  static String? getTheErrorMessageByCode(TruecallerError errorCode) {
    switch (errorCode.code) {
      case 1:
        return 'Network Failure';
      case 2:
        return 'Please don\'t tap BACK while processing';
      case 14:
        return null;
    }
    return errorCode.message ?? 'Unknown error while truecaller login';
  }
}
