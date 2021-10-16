/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

enum ThemeEnum { light, dark, black }

/// Defines how the app looks.
class AppThemeData {
  static ThemeEnum _currentAppTheme = ThemeEnum.black;
  static ThemeEnum get currentThemeMode {
    return _currentAppTheme;
  }

  /// Returns the correct [ThemeData].
  static ThemeData get currentTheme {
    switch (_currentAppTheme) {
      case ThemeEnum.black:
        return _blackTheme;
      case ThemeEnum.dark:
        return _darkTheme;
      default:
        return lightTheme;
    }
  }

  // A shortcut for the heading-sizes.
  static const double _headline1size = 35;
  static const double _headline2size = 26;
  static const double _headline3size = 20;
  static const double _headline4size = 18;
  static const double _bodyText1size = 16;
  static const double _bodyText2size = 16;
  // A shortcut to important [InputDecorationTheme]-values.
  static final BorderRadius _borderRadius = BorderRadius.circular(10);

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.pink,
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade400,
    ),
    backgroundColor: Colors.white,
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontSize: _headline1size,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headline2: TextStyle(
        fontSize: _headline2size,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headline3: TextStyle(
        fontSize: _headline3size,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      headline4: TextStyle(
        fontSize: _headline4size,
        color: Colors.black,
      ),
      bodyText1: TextStyle(
        fontSize: _bodyText1size,
        color: Colors.black,
      ),
      bodyText2: TextStyle(
        fontSize: _bodyText2size,
        color: Colors.black,
      ),
    ),
    dividerColor: Colors.black54,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
      ),
    ),
  );

  static final ThemeData _darkTheme = ThemeData(
    primarySwatch: Colors.pink,
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade800,
    ),
    backgroundColor: Colors.black,
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontSize: _headline1size,
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: _headline2size,
        fontWeight: FontWeight.bold,
      ),
      headline3: TextStyle(
        fontSize: _headline3size,
        fontWeight: FontWeight.bold,
      ),
      headline4: TextStyle(
        fontSize: _headline4size,
      ),
      headline6: TextStyle(),
      bodyText1: TextStyle(
        fontSize: _bodyText1size,
      ),
      bodyText2: TextStyle(
        fontSize: _bodyText2size,
      ),
      subtitle1: TextStyle(),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: Colors.white54,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: Colors.white,
        ),
      ),
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
      helperStyle: const TextStyle(
        color: Colors.white,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade50,
      ),
    ),
  );

  static final ThemeData _blackTheme = ThemeData(
    primarySwatch: Colors.pink,
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade900,
    ),
    backgroundColor: Colors.black,
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontSize: _headline1size,
        fontWeight: FontWeight.bold,
      ),
      headline2: TextStyle(
        fontSize: _headline2size,
        fontWeight: FontWeight.bold,
      ),
      headline3: TextStyle(
        fontSize: _headline3size,
        fontWeight: FontWeight.bold,
      ),
      headline4: TextStyle(
        fontSize: _headline4size,
      ),
      headline6: TextStyle(),
      bodyText1: TextStyle(
        fontSize: _bodyText1size,
      ),
      bodyText2: TextStyle(
        fontSize: _bodyText2size,
      ),
      subtitle1: TextStyle(),
    ).apply(
      bodyColor: Colors.white,
      displayColor: Colors.white,
    ),
    dividerColor: Colors.black,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: _borderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: const BorderSide(
          color: Colors.white,
        ),
      ),
      labelStyle: const TextStyle(
        color: Colors.white,
      ),
      helperStyle: const TextStyle(
        color: Colors.white,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: _borderRadius,
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade50,
      ),
    ),
  );
}
