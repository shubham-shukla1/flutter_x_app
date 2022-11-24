import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_x_app/shared/app_logging/app_log_helper.dart';
import 'package:flutter_x_app/shared/app_theme/app_colors/app_colors.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

import '../shared/flavor/app_flutter_config.dart';
import '../services/common_analytics_service/app_analytics_service.dart';

class MasterErrorPage extends StatefulWidget {
  final FlutterErrorDetails errorDetails;
  MasterErrorPage(this.errorDetails, {Key? key}) : super(key: key);
  @override
  _MasterErrorPageState createState() => _MasterErrorPageState();
}

class _MasterErrorPageState extends State<MasterErrorPage> {
  @override
  void initState() {
    super.initState();
    AppAnalyticsService.instance.pageView('Master Error Page View');
    FirebaseCrashlytics.instance.recordError(
      widget.errorDetails.exception,
      widget.errorDetails.stack,
      reason: 'Grey screen',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            AspectRatio(
              aspectRatio: 1,
              child: Image.asset(
                'assets/images/image_404.png',
                height: 500,
                width: 500,
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Center(
              child: SizedBox(
                width: 300,
                child: Text(
                  'We are sorry, but something went wrong.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.darkBlue,
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Center(
                child: Container(
                  height: 50,
                  width: 250,
                  decoration: BoxDecoration(
                    color: AppColors.limeGreen,
                    borderRadius: BorderRadius.circular(
                      10,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      continueInBrowser();
                    },
                    style: TextButton.styleFrom(
                      primary: Colors.transparent,
                    ),
                    child: Text(
                      'Continue with Browser',
                      style: TextStyle(
                        color: AppColors.greyWhite,
                        fontSize: 14,
                        // fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> continueInBrowser() async {
    try {
      Uri url = Uri.parse(AppFlavorConfig.instance!.baseURL.toString());
      if (!await canLaunch(url.toString())) {
        Fluttertoast.showToast(
          msg: 'Error while launching to Browser',
          fontSize: 14,
          toastLength: Toast.LENGTH_SHORT,
        );
      } else {
        await launch(url.toString());
      }
    } catch (e, s) {
      AppLog.log('Error whole continuing in browser', error: e, stackTrace: s);
    }
  }
}
