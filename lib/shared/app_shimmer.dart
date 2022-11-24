import 'package:flutter/material.dart';
import 'package:flutter_x_app/shared/app_theme/app_colors/app_colors.dart';
import 'package:flutter_x_app/shared/static_shimmer.dart';
import 'package:flutter_x_app/shared/util/resources/resources.dart';

class AppShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyWhite,
      ),
      child: ListView(
        children: [
          Container(
            height: 1500,
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    child: Image.asset(
                      AppImages.user1,
                      fit: BoxFit.cover,
                      // height: 40,
                      // fit: BoxFit.cover,
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    margin: EdgeInsets.only(
                      top: 100,
                    ),
                    decoration: BoxDecoration(
                        color: const Color(0xFFEBFAFA),
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40))),
                    height: 1600,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  StaticShimmerFunctions.buildTextLine(
                                      70,
                                      2,
                                      10,
                                      Color.fromRGBO(23, 168, 163, 1),
                                      Color.fromRGBO(23, 168, 163, 1),
                                      AppColors.lightShimmerColor),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  StaticShimmerFunctions.buildTextLine(
                                      70,
                                      2,
                                      10,
                                      Color.fromRGBO(23, 168, 163, 1),
                                      Color.fromRGBO(23, 168, 163, 1),
                                      AppColors.lightShimmerColor),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  StaticShimmerFunctions.buildTextLine(
                                      70,
                                      2,
                                      10,
                                      Color.fromRGBO(23, 168, 163, 1),
                                      Color.fromRGBO(23, 168, 163, 1),
                                      AppColors.lightShimmerColor),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  StaticShimmerFunctions.buildTextLine(
                                      130,
                                      2,
                                      10,
                                      Colors.black,
                                      Colors.black,
                                      AppColors.lightShimmerColor),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  StaticShimmerFunctions.buildTextLine(
                                      130,
                                      2,
                                      10,
                                      Colors.black,
                                      Colors.black,
                                      AppColors.lightShimmerColor),
                                  SizedBox(
                                    height: 3,
                                  ),
                                  StaticShimmerFunctions.buildTextLine(
                                      130,
                                      2,
                                      10,
                                      Colors.black,
                                      Colors.black,
                                      AppColors.lightShimmerColor),
                                ],
                              ),
                              StaticShimmerFunctions.buildImageCircle(
                                  30,
                                  30,
                                  Colors.black,
                                  Colors.black,
                                  AppColors.lightShimmerColor)
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 30),
                          child: SizedBox(
                            height: 40,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              StaticShimmerFunctions.buildTextLine(
                                  100,
                                  80,
                                  5,
                                  Color.fromRGBO(243, 255, 255, 1),
                                  Color.fromRGBO(243, 255, 255, 1),
                                  AppColors.lightShimmerColor),
                              StaticShimmerFunctions.buildTextLine(
                                  100,
                                  80,
                                  5,
                                  Color.fromRGBO(243, 255, 255, 1),
                                  Color.fromRGBO(243, 255, 255, 1),
                                  AppColors.lightShimmerColor),
                              StaticShimmerFunctions.buildTextLine(
                                  100,
                                  80,
                                  5,
                                  Color.fromRGBO(243, 255, 255, 1),
                                  Color.fromRGBO(243, 255, 255, 1),
                                  AppColors.lightShimmerColor),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 0),
                          child: SizedBox(
                            height: 40,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 0),
                          child: StaticShimmerFunctions.buildTextLine(
                              double.infinity,
                              60,
                              5,
                              Color.fromRGBO(243, 255, 255, 1),
                              Color.fromRGBO(243, 255, 255, 1),
                              AppColors.lightShimmerColor),
                        ),
                        SizedBox(
                          height: 30,
                        ),
                        Container(
                          color: Colors.white,
                          padding: const EdgeInsets.only(
                              left: 40, right: 40, top: 50),
                          height: 700,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StaticShimmerFunctions.buildTextLine(
                                      70,
                                      70,
                                      5,
                                      Color.fromRGBO(32, 75, 107, 0.4),
                                      Color.fromRGBO(32, 75, 107, 0.4),
                                      AppColors.lightShimmerColor),
                                  StaticShimmerFunctions.buildTextLine(
                                      70,
                                      70,
                                      5,
                                      Color.fromRGBO(32, 75, 107, 0.4),
                                      Color.fromRGBO(32, 75, 107, 0.4),
                                      AppColors.lightShimmerColor),
                                  StaticShimmerFunctions.buildTextLine(
                                      70,
                                      70,
                                      5,
                                      Color.fromRGBO(32, 75, 107, 0.4),
                                      Color.fromRGBO(32, 75, 107, 0.4),
                                      AppColors.lightShimmerColor),
                                ],
                              ),
                              SizedBox(
                                height: 40,
                              ),
                              StaticShimmerFunctions.buildTextLine(
                                  70,
                                  2,
                                  10,
                                  Colors.black,
                                  Colors.black,
                                  AppColors.lightShimmerColor),
                              SizedBox(
                                height: 3,
                              ),
                              StaticShimmerFunctions.buildTextLine(
                                  70,
                                  2,
                                  10,
                                  Colors.black,
                                  Colors.black,
                                  AppColors.lightShimmerColor),
                              SizedBox(
                                height: 3,
                              ),
                              StaticShimmerFunctions.buildTextLine(
                                  70,
                                  2,
                                  10,
                                  Colors.black,
                                  Colors.black,
                                  AppColors.lightShimmerColor),
                              SizedBox(
                                height: 40,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StaticShimmerFunctions.buildTextLine(
                                      150,
                                      150,
                                      5,
                                      Color.fromRGBO(235, 248, 247, 1),
                                      Color.fromRGBO(235, 248, 247, 1),
                                      AppColors.lightShimmerColor),
                                  StaticShimmerFunctions.buildTextLine(
                                      150,
                                      150,
                                      5,
                                      Color.fromRGBO(235, 248, 247, 1),
                                      Color.fromRGBO(235, 248, 247, 1),
                                      AppColors.lightShimmerColor),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  StaticShimmerFunctions.buildTextLine(
                                      150,
                                      150,
                                      5,
                                      Color.fromRGBO(235, 248, 247, 1),
                                      Color.fromRGBO(235, 248, 247, 1),
                                      AppColors.lightShimmerColor),
                                  StaticShimmerFunctions.buildTextLine(
                                      150,
                                      150,
                                      5,
                                      Color.fromRGBO(235, 248, 247, 1),
                                      Color.fromRGBO(235, 248, 247, 1),
                                      AppColors.lightShimmerColor),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
