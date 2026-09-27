import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

TextStyle priceStyle({
  required double fontSize,
  FontWeight fontWeight = FontWeight.boldr,
  required Color color,
}) {
  return GoogleFonts.dmSerifDisplay(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color,
  );
}