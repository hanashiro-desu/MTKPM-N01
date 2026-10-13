import 'package:flutter/material.dart';

class MovieGoColors {
  static const primary = Color(0xFFFF3041);
  static const surface = Color(0xFFF7F7F8);
  static const border = Color(0xFFE9E9ED);
  static const red = Color(0xFFFF3041);
  static const darkRed = Color(0xFFE51F31);
  static const pink = Color(0xFFFFEEF0);
  static const soft = Color(0xFFFFF7F8);
  static const text = Color(0xFF1E1E22);
  static const muted = Color(0xFF85858C);
  static const line = Color(0xFFE9E9ED);
  static const green = Color(0xFF20B77A);
  static const yellow = Color(0xFFFFB020);
}

class MovieGoTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: MovieGoColors.red, brightness: Brightness.light),
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF7F7F8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(13)), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(13)), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(13)), borderSide: BorderSide(color: MovieGoColors.red)),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: MovieGoColors.pink,
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
    ),
  );
}
