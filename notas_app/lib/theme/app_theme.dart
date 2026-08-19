import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextStyle display(BuildContext context) => GoogleFonts.lora();
  static TextStyle mono(BuildContext context) => GoogleFonts.jetBrainsMono();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.paper,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.pine,
        brightness: Brightness.light,
        primary: AppColors.pineDark,
        secondary: AppColors.steel,
        surface: AppColors.paperCard,
        error: AppColors.red,
      ),
      fontFamily: GoogleFonts.inter().fontFamily,
    );

    return base.copyWith(
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.lora(fontWeight: FontWeight.w600, color: AppColors.pineDark),
        displayMedium: GoogleFonts.lora(fontWeight: FontWeight.w600, color: AppColors.pineDark),
        displaySmall: GoogleFonts.lora(fontWeight: FontWeight.w600, color: AppColors.pineDark),
        titleLarge: GoogleFonts.lora(fontWeight: FontWeight.w600, color: AppColors.pineDark),
        titleMedium: GoogleFonts.lora(fontWeight: FontWeight.w600, color: AppColors.pineDark),
        labelSmall: GoogleFonts.jetBrainsMono(fontSize: 10, letterSpacing: 0.4, color: AppColors.inkSoft),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.paper,
        foregroundColor: AppColors.pineDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: AppColors.paperCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.paperCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.pine, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.pineDark,
          foregroundColor: AppColors.paperCard,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          textStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: AppColors.paperCard,
        side: const BorderSide(color: AppColors.line),
        labelStyle: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.inkSoft),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
    );
  }
}
