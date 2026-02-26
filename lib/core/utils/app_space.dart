import 'package:expensive/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class AppSpacing extends StatelessWidget {
  final double? height;
  final double? width;

  // 🔹 Default constructor
  const AppSpacing({super.key, this.height, this.width});

  // 🔹 Named constructors (THIS FIXES YOUR ERROR)
  const AppSpacing.h(double height, {super.key})
    : height = height,
      width = null;

  const AppSpacing.w(double width, {super.key}) : width = width, height = null;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          height: height != null
              ? ResponsiveHelper.getResponsiveHeight(constraints, height!)
              : null,
          width: width != null
              ? ResponsiveHelper.getResponsiveWidth(constraints, width!)
              : null,
        );
      },
    );
  }
}
