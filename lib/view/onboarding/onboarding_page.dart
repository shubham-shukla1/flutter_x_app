import 'package:flutter/material.dart';

import '../../shared/app_theme/app_colors/app_colors.dart';
import '../../shared/common_importer.dart';
import '../login/login_page.dart';

class OnboardingPageArgument {
  final String? funnelName;

  const OnboardingPageArgument(this.funnelName);
}

class OnboardingPageParent extends StatelessWidget {
  static final String routeName = '/onboarding';
  const OnboardingPageParent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final OnboardingPageArgument args =
        ModalRoute.of(context)!.settings.arguments as OnboardingPageArgument;
    return OnboardingPage(args);
  }
}

class OnboardingPage extends StatefulWidget {
  final OnboardingPageArgument onboardingPageArgument;
  const OnboardingPage(this.onboardingPageArgument, {Key? key})
      : super(key: key);

  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int currentIndex = 0;
  late PageController _controller;

  Widget get loginButton {
    return TextButton(
      child: Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
      onPressed: () {
        Navigator.of(context).pushReplacementNamed(
          LoginPageParent.routeName,
          arguments: LoginPageArgument(
            funnelName: '${widget.onboardingPageArgument.funnelName}',
          ),
        );
        // AutoRouter.of(context).replace(
        //     LoginRoute(funnelName: widget.onboardingPageArgument.funnelName));
      },
      style: TextButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        padding: EdgeInsets.only(bottom: 2),
      ),
    );
  }

  Widget get nextButton {
    return TextButton(
      onPressed: () {
        _controller.nextPage(
          duration: const Duration(milliseconds: 100),
          curve: Curves.bounceOut,
        );
      },
      child: Text(
        'Next',
        style: TextStyle(
          color: AppColors.onBoardGreen,
          fontWeight: FontWeight.w700,
          // fontFamily: 'Montserrat',
        ),
      ),
      style: TextButton.styleFrom(
        side: BorderSide(color: AppColors.onBoardGreen, width: 2),
        backgroundColor: Colors.white30,
      ),
    );
  }

  @override
  void initState() {
    _controller = PageController(initialPage: 0);
    try {
      KPref.instance?.setOnceOnboardVisited(true);
    } catch (e) {
      AppLog.log('Error while setting isOnceOnboardVisited');
    }
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // return Scaffold(
    //   body: Column(
    //     children: [getBackButton, nextButton, loginButton],
    //   ),
    // );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: contents.length,
            onPageChanged: (int index) {
              setState(() {
                currentIndex = index;
              });
            },
            itemBuilder: (_, i) {
              return Padding(
                padding: const EdgeInsets.all(40),
                child: Text(
                  contents[i].title,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    // fontFamily: 'Montserrat',
                    color: AppColors.onBoardBlue,
                  ),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    contents.length,
                    (index) => buildDot(index, context),
                  ),
                ),
                SizedBox(
                  height: 48,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 21, bottom: 16),
                      child: getBackButton,
                    ),
                    currentIndex == contents.length - 1
                        ? Container(
                            margin: EdgeInsets.only(right: 21, bottom: 16),
                            height: 30,
                            width: 130,
                            child: loginButton,
                          )
                        : Container(
                            margin: EdgeInsets.only(right: 21, bottom: 16),
                            height: 30,
                            width: 121,
                            child: nextButton,
                          )
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget get getBackButton {
    return TextButton(
      onPressed: () {
        if (currentIndex != 0) {
          _controller.previousPage(
            duration: const Duration(milliseconds: 100),
            curve: Curves.bounceOut,
          );
        }
      },
      child: Text(
        currentIndex == 0 ? '' : 'Back',
        style: TextStyle(
            color: AppColors.onBoardGreen,
            // fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            fontFamily: 'Montserrat'),
      ),
      style: currentIndex != 0
          ? TextButton.styleFrom(
              side: BorderSide(
                color: Colors.transparent,
                width: 2,
              ),
              backgroundColor: Colors.white30,
            )
          : null,
    );
  }

  List<OnbordingContent> contents = [
    OnbordingContent(
      title: 'Title 1',
    ),
    OnbordingContent(
      title: 'Title 2',
    ),
    OnbordingContent(
      title: 'Title 3',
    ),
  ];

  Widget buildDot(int index, BuildContext context) {
    return Container(
      height: 7,
      width: currentIndex == index ? 25 : 7,
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: currentIndex == index ? AppColors.red : Colors.grey,
      ),
    );
  }
}

class OnbordingContent {
  String? image;
  String title;
  String? description;

  OnbordingContent({this.image, required this.title, this.description});
}
