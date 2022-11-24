import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:version/version.dart';

class MyInAppUpdate {
  Future<bool> ifForceUpdateRequired() async {
    final info = await PackageInfo.fromPlatform();

    Version currentVersion = Version.parse(info.version);
    Version minimumVersion = Version.parse(
        FirebaseRemoteConfig.instance.getString('minimum_app_version'));
    return currentVersion < minimumVersion;
  }

  Future<bool> isGentalUpdateAvailable() async {
    final info = await PackageInfo.fromPlatform();
    Version currentVersion = Version.parse(info.version);
    Version latestVersion = Version.parse(
        FirebaseRemoteConfig.instance.getString('latest_app_version'));
    return latestVersion > currentVersion;
  }
}
