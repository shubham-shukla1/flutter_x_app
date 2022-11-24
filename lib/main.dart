import 'dart:async';
import 'dart:convert';
import 'package:clevertap_plugin/clevertap_plugin.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_x_app/shared/app_logging/app_log_helper.dart';
import 'package:flutter_x_app/presentation/app_webview/app_webview_cubit.dart';
import 'shared/app_logging/app_bloc_observer.dart';
import 'shared/flavor/app_flutter_config.dart';
import 'package:flutter_x_app/presentation/general/general_cubit.dart';
import 'package:flutter_x_app/presentation/landing/landing_bloc.dart';
import 'package:flutter_x_app/view/landing_page.dart';


Future<void> main() async {
  Bloc.observer = AppBlocObserver();
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };
  AppFlavorConfig.setFlavor(
    flavor: AppFlavor.prod,
  );

  runZonedGuarded(
    () async {
      ///Note : you must call WidgetsFlutterBinding.ensureInitialized() inside
      ///runZonedGuarded. Error handling wouldn’t work if WidgetsFlutterBinding.
      ///ensureInitialized() was called from the outside.
      WidgetsFlutterBinding.ensureInitialized();

      return runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider<LandingBloc>(
              create: (_) => LandingBloc(),
            ),
            BlocProvider<GeneralCubit>(
              create: (_) => GeneralCubit(),
            ),
            BlocProvider<AppWebviewCubit>(
              create: (_) => AppWebviewCubit(),
            ),
          ],
          child: LandingPage(),
        ),
      );
    },
    (error, stackTrace) {
      FirebaseCrashlytics.instance.recordError(error, stackTrace);
      AppLog.log('message', error: error, stackTrace: stackTrace);
    },
  );
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLog.log('onBackgroundMessage : ${message}');
  var data = jsonEncode(message.data);
  CleverTapPlugin.createNotification(data);
}

Future<void> selectLocalNotification(String? payload) async {
  if (payload != null) {
    debugPrint('notification payload: $payload');
  }
}
