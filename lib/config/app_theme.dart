/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
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

/// A class that is used to represent what [ThemeData] should be used.
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
}

/// Contains the app's [ThemeData]s and the information for which
/// [ThemeData] should be used in light mode and dark mode.
class AppThemeData with ChangeNotifier {
  AppThemeData._privateConstructor();

  /// The singleton-instance of DatabaseHelper.
  static AppThemeData instance = AppThemeData._privateConstructor();

  /// The bool value that decides whether the app should use light and dark mode
  /// or always light mode.
  bool _adaptToSystem = true;

  bool get adaptToSystem => _adaptToSystem;
  Future<void> setAdaptToSystem({required final bool value}) async {
    if (value != _adaptToSystem) {
      _adaptToSystem = value;
      // Save the new value to the database.
      final SettingsData settingsData =
          await DatabaseHelper.instance.getSettings();
      settingsData.adaptThemeToSystem = value;
      await DatabaseHelper.instance.updateSettings(settingsData);
      // Make sure the app updates its design.
      notifyListeners();
    }
  }

  /// Returns the [ThemeMode] that corresponds to [_adaptToSystem].
  ThemeMode get themeMode {
    if (_adaptToSystem) {
      return ThemeMode.system;
    } else {
      return ThemeMode.light;
    }
  }

  /// The field that tells the rest of the app what [ThemeEnum] should be used
  /// during daytime.
  /// Only change this field by using the method [setNewLightEnum]!
  ThemeEnum _currentLightThemeEnum = ThemeEnum.light;

  /// The field that tells the rest of the app what [ThemeEnum] should be used
  /// during nighttime.
  /// Only change this field by using the method [setNewDarkEnum]!
  ThemeEnum _currentDarkThemeEnum = ThemeEnum.dark;

  /// Returns the [ThemeEnum] used during daytime (light mode).
  ThemeEnum get currentLightThemeEnum {
    return _currentLightThemeEnum;
  }

  /// Returns the [ThemeEnum] used during nighttime (dark mode).
  ThemeEnum get currentDarkThemeEnum {
    return _currentDarkThemeEnum;
  }

  /// Change [_currentLightThemeEnum] to some other [ThemeEnum]-value
  /// and use this new information.
  Future<void> setNewLightEnum(final ThemeEnum newThemeEnum) async {
    if (newThemeEnum != _currentLightThemeEnum) {
      // Set the relevant field to the new [ThemeEnum].
      _currentLightThemeEnum = newThemeEnum;
      // Save the new theme to the database.
      final SettingsData settingsData =
          await DatabaseHelper.instance.getSettings();
      settingsData.lightThemeEnum = newThemeEnum;
      await DatabaseHelper.instance.updateSettings(settingsData);
      // Make sure the app updates its design.
      notifyListeners();
    }
  }

  /// Change [_currentDarkThemeEnum] to some other [ThemeEnum]-value
  /// and use this new information.
  Future<void> setNewDarkEnum(final ThemeEnum newThemeEnum) async {
    if (newThemeEnum != _currentDarkThemeEnum) {
      // Set the relevant field to the new [ThemeEnum].
      _currentDarkThemeEnum = newThemeEnum;
      // Save the new theme to the database.
      final SettingsData settingsData =
          await DatabaseHelper.instance.getSettings();
      settingsData.darkThemeEnum = newThemeEnum;
      await DatabaseHelper.instance.updateSettings(settingsData);
      // Make sure the app updates its design.
      notifyListeners();
    }
  }

  /// Returns the [ThemeData] that is to be displayed in light-mode.
  ThemeData get currentLightTheme {
    return themefromEnum(_currentLightThemeEnum);
  }

  /// Returns the [ThemeData] that is to be displayed in dark-mode.
  ThemeData get currentDarkTheme {
    return themefromEnum(_currentDarkThemeEnum);
  }

  /// Returns the [ThemeEnum] that corresponds to the currently used
  /// [ThemeData].
  ThemeEnum get currentThemeEnum {
    final Brightness brightness =
        SchedulerBinding.instance!.window.platformBrightness;

    if (_adaptToSystem == false || brightness == Brightness.light) {
      return _currentLightThemeEnum;
    } else {
      return _currentDarkThemeEnum;
    }
  }

  /// Returns the [ThemeData] that corresponds to a certain [ThemeEnum].
  ThemeData themefromEnum(final ThemeEnum themeEnum) {
    switch (themeEnum) {
      case ThemeEnum.light:
        return lightTheme;
      case ThemeEnum.dark:
        return darkTheme;
      default:
        return blackTheme;
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
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade400,
    ),
    backgroundColor: Colors.white,
    dividerColor: Colors.black54,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: _inputDecBorderRadius,
      ),
    ),
    primarySwatch: Colors.pink,
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
  );

  final ThemeData darkTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade800,
    ),
    backgroundColor: Colors.black,
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
    primarySwatch: Colors.pink,
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
  );

  final ThemeData blackTheme = ThemeData(
    appBarTheme: AppBarTheme(
      color: Colors.pink.shade900,
    ),
    backgroundColor: Colors.black,
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
    primarySwatch: Colors.pink,
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
  );
}
