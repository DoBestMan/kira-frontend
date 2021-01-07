import 'package:flutter/material.dart';
import 'package:kira_auth/utils/colors.dart';
import 'package:kira_auth/utils/responsive.dart';

class AppStyles {
  // Text style for numbers of mnemonic
  static TextStyle textStyleNumbersOfMnemonic(BuildContext context) {
    return TextStyle(
      fontSize: AppFontSizes.smallText(context),
      color: KiraColors.white,
      fontFamily: 'OverpassMono',
      fontWeight: FontWeight.w300,
    );
  }

  // Text style for mnemonic
  static TextStyle textStyleMnemonic(BuildContext context) {
    return TextStyle(
      fontSize: AppFontSizes.smallText(context),
      color: KiraColors.white.withOpacity(0.7),
      fontFamily: 'OverpassMono',
      fontWeight: FontWeight.w300,
    );
  }

  // Text style for mnemonic success
  static TextStyle textStyleMnemonicSuccess(BuildContext context) {
    return TextStyle(
      fontSize: AppFontSizes.smallText(context),
      color: KiraColors.kYellowColor.withOpacity(0.8),
      fontFamily: 'OverpassMono',
      fontWeight: FontWeight.w300,
    );
  }
}

class AppFontSizes {
  static const smallest = 13.0;
  static const small = 14.0;
  static const medium = 18.0;
  static const _large = 22.0;
  static const larger = 26.0;
  static const _largest = 30.0;
  static const largestc = 30.0;
  static const _sslarge = 20.0;
  static const _sslargest = 24.0;

  static double largest(context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      return _sslargest;
    }
    return _largest;
  }

  static double large(context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      return _sslarge;
    }
    return _large;
  }

  static double smallText(context) {
    if (ResponsiveWidget.isSmallScreen(context)) {
      return smallest;
    }
    return small;
  }
}
