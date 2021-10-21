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
import 'package:flutter/scheduler.dart';

import 'package:githo/database/database_helper.dart';
import 'package:githo/models/settings_data.dart';

enum ThemeEnum { light, dark, black }

/// A few handy methods for the [ThemeEnum]-enum.
extension ThemeEnumMethods on ThemeEnum {
  /// The private storage for what the theme-names should be.
  static const Map<ThemeEnum, String> _shortNames = <ThemeEnum, String>{
    ThemeEnum.light: 'Light',
    ThemeEnum.dark: 'Dark',
    ThemeEnum.black: 'Black',
  };

  /// Uses a name-[String] generated by the [ThemeEnum.abcd.name]-getter.
  /// Returns the corresponding [ThemeEnum].
  static ThemeEnum fromName(final String name) {
    for (final ThemeEnum themeEnum in _shortNames.keys) {
      if (name == _shortNames[themeEnum]) {
        return themeEnum;
      }
    }
    throw 'Nonexistent name was used in [ThemeEnumMethods] -> [fromName()].';
  }

  /// Returns a short, comprehendable name for the [ThemeEnum].
  String get name {
    return _shortNames[this]!;
  }

  /// Returns the [ThemeEnum] that is next in line after the current one.
  ThemeEnum get nextEnum {
    final int index = this.index;
    final int nextIndex = (index + 1) % 3;

    final ThemeEnum nextEnum = ThemeEnum.values[nextIndex];
    return nextEnum;
  }
}

/// Defines how the app looks.
class AppThemeData with ChangeNotifier {
  AppThemeData._privateConstructor();

  /// The singleton-instance of DatabaseHelper.
  static AppThemeData instance = AppThemeData._privateConstructor();

  /// The field that tells the rest of the app what [ThemeEnum] should be used
  /// during daytime.
  /// Only change this field by using the method [setNewLightMode]!
  ThemeEnum currentLightThemeEnum = ThemeEnum.light;

  /// The field that tells the rest of the app what [ThemeEnum] should be used
  /// during nighttime.
  /// Only change this field by using the method [setNewDarkMode]!
  ThemeEnum currentDarkThemeEnum = ThemeEnum.dark;

  /// Change [currentLightThemeEnum] to some other [ThemeEnum]-value
  /// and use this new information.
  Future<void> setNewLightMode(final ThemeEnum newThemeEnum) async {
    if (newThemeEnum != currentLightThemeEnum) {
      // Set the relevant field to the new [ThemeEnum].
      currentLightThemeEnum = newThemeEnum;
      // Save the new theme to the database.
      final SettingsData settingsData =
          await DatabaseHelper.instance.getSettings();
      settingsData.lightThemeEnum = newThemeEnum;
      await DatabaseHelper.instance.updateSettings(settingsData);
      // Make sure the app updates its design.
      notifyListeners();
    }
  }

  /// Change [currentDarkThemeEnum] to some other [ThemeEnum]-value
  /// and use this new information.
  Future<void> setNewDarkMode(final ThemeEnum newThemeEnum) async {
    if (newThemeEnum != currentDarkThemeEnum) {
      // Set the relevant field to the new [ThemeEnum].
      currentDarkThemeEnum = newThemeEnum;
      // Save the new theme to the database.
      final SettingsData settingsData =
          await DatabaseHelper.instance.getSettings();
      settingsData.darkThemeEnum = newThemeEnum;
      await DatabaseHelper.instance.updateSettings(settingsData);
      // Make sure the app updates its design.
      notifyListeners();
    }
  }

  /// Returns the [ThemeEnum] that corresponds to the currently used
  /// [ThemeData].
  ThemeEnum get currentThemeMode {
    final Brightness brightness =
        SchedulerBinding.instance!.window.platformBrightness;

    if (brightness == Brightness.light) {
      return currentLightThemeEnum;
    } else {
      return currentDarkThemeEnum;
    }
  }

  /// Returns the [ThemeData] that is to be displayed in light-mode.
  ThemeData get currentLightTheme {
    switch (currentLightThemeEnum) {
      case ThemeEnum.light:
        return lightTheme;
      case ThemeEnum.dark:
        return _darkTheme;
      default:
        return _blackTheme;
    }
  }

  /// Returns the [ThemeData] that is to be displayed in dark-mode.
  ThemeData get currentDarkTheme {
    switch (currentDarkThemeEnum) {
      case ThemeEnum.light:
        return lightTheme;
      case ThemeEnum.dark:
        return _darkTheme;
      default:
        return _blackTheme;
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
  static final BorderRadius _inputDecBorderRadius = BorderRadius.circular(10);

  final ThemeData lightTheme = ThemeData(
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
        borderRadius: _inputDecBorderRadius,
      ),
    ),
  );

  final ThemeData _darkTheme = ThemeData(
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
        borderRadius: _inputDecBorderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _inputDecBorderRadius,
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
        borderRadius: _inputDecBorderRadius,
        borderSide: BorderSide(
          color: Colors.red.shade300,
        ),
      ),
      errorStyle: TextStyle(
        color: Colors.red.shade50,
      ),
    ),
  );

  final ThemeData _blackTheme = ThemeData(
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
        borderRadius: _inputDecBorderRadius,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _inputDecBorderRadius,
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
        borderRadius: _inputDecBorderRadius,
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
