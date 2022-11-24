import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

import '../shared/app_theme/app_colors/app_colors.dart';
import '../shared/common_importer.dart';
import '../own_package/internet_connectivity/initialize_internet_checker.dart';
import '../own_package/internet_connectivity/navigation_Service.dart';
import '../presentation/general/general_cubit.dart';
import '../presentation/landing/landing_bloc.dart';
import '../presentation/locale/locale_provider.dart';
import '../services/common_analytics_service/app_analytics_service.dart';
import 'error_page.dart';
import 'login/login_otp_page.dart';
import 'login/login_page.dart';
import 'sign_up/otp_page.dart';
import 'sign_up/user_signup_page.dart';
import 'splash_page.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  late LandingBloc _landingBloc;
  late GeneralCubit _generalCubit;
  // final _appRouter = AppRouter();
  FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void initState() {
    InternetChecker();
    super.initState();
    AppAnalyticsService.instance.appLaunched();
    AppAnalyticsService.instance.pageView(' Landing Page');
    _landingBloc = BlocProvider.of<LandingBloc>(context);
    _generalCubit = BlocProvider.of<GeneralCubit>(context);

    _landingBloc.add(
      RunLandingLogicEvent(_generalCubit, context),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LocaleProvider(),
      builder: (builderContext, __) {
        /// Step:1 We can set whatever locale which we want to choose.
        /// Currently
        /// it will detect from the phone local language.
        // final localeProvider = BlocProvider.of<LocaleProvider>(builderContext);
        //
        // localeProvider.setLocale(
        //   Locale('en'),
        // );
        return MaterialApp(
            navigatorKey: NavigationService.navigationKey,
            // supportedLocales: L10n.all,
            // localizationsDelegates: [
            //   AppLocalizations.delegate,
            //   GlobalMaterialLocalizations.delegate,
            //   GlobalCupertinoLocalizations.delegate,
            //   GlobalWidgetsLocalizations.delegate,
            // ],

            /// Step 2: define provider locale
            // locale: localeProvider.locale,
            // routerDelegate: AutoRouterDelegate(
            //   _appRouter,
            //   navigatorObservers: () => [
            //     AutoRouteObserver(),
            //     FirebaseAnalyticsObserver(analytics: _analytics),
            //   ],
            // ),
            // routeInformationParser: _appRouter.defaultRouteParser(),
            theme: ThemeData(
              primaryColor: AppColors.limeGreen,
              secondaryHeaderColor: AppColors.limeGreen,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              appBarTheme: AppBarTheme(
                color: AppColors.limeGreen,
              ),
              fontFamily: 'Montserrat',
            ).copyWith(
              pageTransitionsTheme: const PageTransitionsTheme(
                builders: <TargetPlatform, PageTransitionsBuilder>{
                  TargetPlatform.android: ZoomPageTransitionsBuilder(),
                },
              ),
            ),
            builder: (BuildContext context, Widget? widget) {
              ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
                return MasterErrorPage(errorDetails);
              };
              return widget!;
            },
            debugShowCheckedModeBanner: false,
            routes: {
              SplashPage.routeName: (_) => SplashPage(),
              LoginPageParent.routeName: (_) => LoginPageParent(),
              LoginOtpPageParent.routeName: (_) => LoginOtpPageParent(),
            });
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
