import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class StaticShimmerFunctions {
  static Widget buildRadiusContainer(
    BuildContext context,
    double radius,
  ) {
    return Shimmer.fromColors(
      highlightColor: Color(0xFFFFFFFF),
      baseColor: Color(0xFFE6EEF8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFE7F7F5),
          borderRadius: BorderRadius.circular(
            radius,
          ),
        ),
      ),
    );
  }

  static Widget buildImageCircle(
    double width,
    double height,
    Color color,
    Color baseColor,
    Color shimmerColor,
  ) {
    return Shimmer.fromColors(
      highlightColor: baseColor,
      baseColor: shimmerColor,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          width: width,
          height: height,
          child: SizedBox(
            width: width,
            height: height,
          ),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  static Widget buildTextLine(
    double width,
    double height,
    double radius,
    Color color,
    Color baseColor,
    Color shimmerColor,
  ) {
    return Shimmer.fromColors(
      highlightColor: shimmerColor,
      baseColor: baseColor,
      child: Opacity(
        opacity: 0.6,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(
              radius,
            ),
          ),
          child: SizedBox(
            width: width,
            height: height,
          ),
        ),
      ),
    );
  }
}
