import 'package:flutter/material.dart';

class AppColors {
  /// Solid Colors
  static const Color primaryColor = Color(0XFF0EAE9D);
  static const Color secondaryColor = Color(0XFF013F85);
  static const Color primary2Color = Color(0XFFE7F7F5);

  static const Color green1 = Color(0XFF53AAA7);
  static const Color green2 = Color(0xFFDEF4F4);
  static const Color green5 = Color(0XFFEBFAFA);
  static const Color darkBlue = Color(0XFF204B6B);

  static const Color red = Color(0XFFDA231E);
  static const Color secondaryRed = Color(0XFFED6F69);

  ///OnBoard Colors
  static const Color onBoardGreen = Color(0xFF039695);
  static const Color onBoardBlue = Color(0xFF204B6B);
  static const Color progressDots = Color(0xFF6FD2D0);

  ///Splash Colors
  static const Color splashBG = Color(0xFFDAE9E0);
  static const Color splashDarkGreen = Color(0xFF63a87a);
  static const Color splashLightGreen = Color(0xFF84ce9d);
  ///Login Colors
  static const Color greyishBlue = Color(0xFF859ACA);
  static const Color titleColor = Color(0xFF566485);

  /// Grey Colors
  static const Color textFiledBorderColor = Color(0XFF999999);
  static const Color grey1 = Color(0XFFCCCCCC);
  static const Color grey2 = Color(0XFF979797);
  static const Color grey3 = Color(0XFFF5F8FC);
  static const Color grey4 = Color(0xFFF5F8F6);
  static const Color neutralGrey = Color(0xFF626262);
  static const Color greyLight = Color(0XFFD7E3F4);
  static const Color greyWhite = Color(0XFFFFFFFF);
  static const Color black = Color(0XFF000000);
  static const Color arrowGrey = Color(0XFF9F9F9F);
  static const Color grey5 = Color(0XFFF0F0F0);

  static const Color grey66 = Color(0XFF666666);
  static const Color limeGreen = Color(0XFF01BFBD);

  ///
  static const Color error = Color(0XFFFB2424);

  /// Trasparent
  static Color black75 = Color(0XFF000000).withOpacity(0.75);
  static Color black50 = Color(0XFF000000).withOpacity(0.50);
  static Color black25 = Color(0XFF000000).withOpacity(0.25);
  static Color black20 = Color(0XFF000000).withOpacity(0.20);
  static Color black10 = Color(0XFF000000).withOpacity(0.10);
  static Color white20 = Color(0XFFFFFFFF).withOpacity(0.20);
  static Color white10 = Color(0XFFFFFFFF).withOpacity(0.10);

  /// Dark
  static const Color dark1 = Color(0XFF181719);
  static const Color dark2 = Color(0XFF2C2B2D);

  /// Avtar skin
  static const Color skin1 = Color(0XFFFFDBB4);
  static const Color skin2 = Color(0XFFEDB98A);
  static const Color skin3 = Color(0XFFEDB98A);
  static const Color skin4 = Color(0XFFD08B5B);
  static const Color skin5 = Color(0XFFA56F4C);

  /// Whatsapp
  static const Color whatsapp = Color(0XFF25D366);

  /// Gradients
  static const gradient1 = [Color(0xFF0A67BE), Color(0xFF0EB798)];
  static const gradient2 = [Color(0xFFF95A5A), Color(0xFFF6AD57)];
  static const gradient3 = [Color(0xFFFFEA29), Color(0xFFF9AB14)];
  static const gradient4 = [Color(0xFF5B5B5B), Color(0xFF353535)];
  static const gradient4_1 = [Color(0xFF9A34FF), Color(0xFF415DBF)];
  static const gradient5 = [Color(0xFF9A0053), Color(0xFF8500A7)];
  static const gradient6 = [Color(0xFF0A67BE), Color(0xFF0EB798)];
  static const gradient7 = [Color(0xFF913af9), Color(0xFF913af9)];

  // static const gradient7 = [Color(0xFF9A0053),Color(0xFF8500A7)];

  /// Dark Theme colors
  static const scaffoldDark = AppColors.black;
  static const appBarDark = dark1;
  static const bottomSheetBGColorDark = dark2;
  static const dividerColorDark = Color(0xFF2C2B2D);
  static const Color bsChipColor = Color(0XFFD7E3F4);

  /// Light Theme Colors
  static const scaffoldLight = grey3;
  static const appBarLight = greyWhite;
  static const bottomSheetBGColorLight = Color(0xFFD1D8E0);
  static const dividerColorLight = Color(0xFFE7F7F5);

  /// Shimmer colors
  static const darkBaseShimmer = Color(0xFF2C2B2D);
  static const darkShimmerColor = Color(0xFF5A575C);

  static const lightBaseShimmer = Color(0xFFE6EEF8);
  static const lightShimmerColor = Color(0xFFFFFFFF);
  static const closeIconColor = Color(0xFF545B63);

// static const darkShimmerColor = Color(0xFF);

  /// Expert and Doctor badge color
  static const expertBadgeColor = gradient4_1;
  static const doctorBadgeColor = gradient1;

  static const tertiary = Color(0xFFE7F7F5);

  // TextField Border Color
  static const textFieldBorderColorLight = Color(0xFFE7F7F5);
  static const textFieldBorderColorDark = Color(0xFF013F85);

  //gradient
  final Shader linearGradient1 = LinearGradient(
    colors: <Color>[Color(0xff0A67BE), Color(0xff0EB798)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));
}
