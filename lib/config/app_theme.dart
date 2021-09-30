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

/// Defines how the app looks.
class AppTheme {
  static const double _headline1size = 35;
  static const double _headline2size = 26;
  static const double _headline3size = 20;
  static const double _headline4size = 18;
  static const double _bodyText1size = 16;
  static const double _bodyText2size = 16;

  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.pink,
    backgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade400,
    ),
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
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    primarySwatch: Colors.pink,
    backgroundColor: Colors.black,
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade800,
    ),
    textTheme: const TextTheme(
      headline1: TextStyle(
        fontSize: _headline1size,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headline2: TextStyle(
        fontSize: _headline2size,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headline3: TextStyle(
        fontSize: _headline3size,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      headline4: TextStyle(
        fontSize: _headline4size,
        color: Colors.white,
      ),
      bodyText1: TextStyle(
        fontSize: _bodyText1size,
        color: Colors.white,
      ),
      bodyText2: TextStyle(
        fontSize: _bodyText2size,
        color: Colors.white,
      ),
    ),
    dividerColor: Colors.white54,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}
