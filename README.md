# flutter_x_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

## Handy commands

[ Flutter and Dart version]
Flutter 3.3.8 • channel stable • <https://github.com/flutter/flutter.git>

[ Code generator ]
flutter packages pub run build_runner build --delete-conflicting-outputs

[ Change mac HOME path's]
Open -e $HOME/.zshrc

[ Run application with different flavor using following commands ]

flutter run --flavor prod
flutter run --flavor dev

APK
   i. flutter build apk --flavor dev -t lib/main_dev.dart
   ii. flutter build apk --flavor prod -t lib/main_prod.dart
App Bundle
   i. flutter build appbundle --flavor dev -t lib/main_dev.dart
   ii. flutter build appbundle --flavor prod -t lib/main_prod.dart
iOS
   1)
      flutter build ios --flavor dev -t lib/main_dev.dart
      flutter build ios --flavor prod -t lib/main_prod.dart
   2)
      Select "any iOS device"
   3)
      Product -> Archive


URL
<https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports?platform=ios&authuser=0>

Command
.../flutter_x_app/ios/Pods/FirebaseCrashlytics/upload-symbols -gsp .../flutter_x_app/ios/GoogleService-Info.plist -p ios /Users/admin/Library/Developer/Xcode/Archives/2022-02-16/prod 16-02-22, 12.26 PM.xcarchive/dSYMs

If amazon repo fail fatal:repository 'URL' not found
git config --global credential.UseHttpPath true
