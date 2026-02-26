import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BoxConstraints constraints) =>
      constraints.maxWidth < 768;
  static bool isTablet(BoxConstraints constraints) =>
      constraints.maxWidth >= 768 && constraints.maxWidth < 1024;
  static bool isDesktop(BoxConstraints constraints) =>
      constraints.maxWidth >= 1024;

  static double getResponsiveFontSize(
    BoxConstraints constraints,
    double baseSize,
  ) {
    final scale = constraints.maxWidth / 375.0;
    final fontSize = baseSize * scale;
    return fontSize.clamp(12.0, 32.0);
  }

  static double getResponsiveWidth(
    BoxConstraints constraints,
    double baseWidth,
  ) {
    if (constraints.maxWidth < 768) return baseWidth;
    if (constraints.maxWidth < 1024) return baseWidth * 1.3;
    return baseWidth * 1.5;
  }

  static double getResponsiveHeight(
    BoxConstraints constraints,
    double baseHeight,
  ) {
    if (constraints.maxHeight < 800) return baseHeight * 0.8;
    if (constraints.maxHeight < 1200) return baseHeight;
    return baseHeight * 1.2;
  }

  static EdgeInsets getResponsivePaddingHV(
    BoxConstraints constraints,
    double baseHorizontal,
    double baseVertical,
  ) {
    final scale = constraints.maxWidth / 375.0;
    final horizontal = (baseHorizontal * scale).clamp(8.0, 64.0);
    final vertical = (baseVertical * scale).clamp(4.0, 48.0);

    return EdgeInsets.symmetric(horizontal: horizontal, vertical: vertical);
  }

  static double getWidthPercentage(BoxConstraints constraints, int percentage) {
    assert(
      percentage >= 0 && percentage <= 100,
      'Percentage must be between 0 and 100',
    );
    return constraints.maxWidth * (percentage / 100);
  }

  static double getHeightPercentage(
    BoxConstraints constraints,
    int percentage,
  ) {
    assert(
      percentage >= 0 && percentage <= 100,
      'Percentage must be between 0 and 100',
    );
    return constraints.maxHeight * (percentage / 100);
  }

  static double getResponsiveIconSize(
    BoxConstraints constraints,
    double baseSize,
  ) {
    final scale = constraints.maxWidth / 375.0;

    final iconSize = baseSize * scale;

    return iconSize.clamp(16.0, 120.0);
  }
}
