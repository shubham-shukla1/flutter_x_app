import 'package:flutter/material.dart';

import '../shared/app_theme/app_colors/app_colors.dart';
import '../shared/common_importer.dart';
import '../shared/util/resources/resources.dart';
import '../presentation/landing/landing_bloc.dart';
import '../services/common_analytics_service/app_analytics_service.dart';
import 'login/login_page.dart';

class SplashPage extends StatefulWidget {
  static final String routeName = '/';
  const SplashPage({Key? key}) : super(key: key);

  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _animation;
  final Future<String> _calculation = Future<String>.delayed(
    const Duration(seconds: 1, milliseconds: 500),
    () => 'Data Loaded',
  );

  @override
  void initState() {
    AppAnalyticsService.instance.pageView('Tech - Splash Page');
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 1,
      ),
    );
    _animation = _animationController.drive(ColorTween(
      begin: AppColors.splashDarkGreen,
      end: AppColors.splashLightGreen,
    ));
    _animationController.repeat();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LandingBloc, LandingState>(
      listener: (context, state) {
        /// This code will wait for 2 seconds once landing logic is done
        Future.delayed(
            Duration(
              seconds: 3,
            ), () {
          if (state is NavigateToState) {
           
              Navigator.of(context).pushReplacementNamed(
                LoginPageParent.routeName,
                arguments: LoginPageArgument(funnelName: 'splashFunnel'),
              );
          
          }
        });
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.splashBG,
          body: Stack(
            children: [
              Align(
                  alignment: Alignment.bottomRight,
                  child: Image.asset(
                    AppImages.user1,
                  )),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 120,
                  ),
                  Align(
                    alignment: Alignment.center,
                    child: FutureBuilder(
                      future: _calculation,
                      builder: (BuildContext context,
                          AsyncSnapshot<dynamic> snapshot) {
                        if (snapshot.hasData) {
                          return SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                valueColor: _animation,
                              ));
                        } else {
                          return SizedBox(
                            height: 20,
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}
