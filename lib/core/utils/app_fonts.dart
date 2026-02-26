import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFontStyle {
  static TextStyle xl = GoogleFonts.inter(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static TextStyle large = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w500,
  );

  static TextStyle medium = GoogleFonts.inter(
    fontSize: 15,
    fontWeight: FontWeight.normal,
  );

  static TextStyle buttonText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.bold,
  );
}
