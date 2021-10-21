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

import 'package:githo/config/app_theme.dart';
import 'package:githo/helpers/type_extentions.dart';

/// A model for how the user's settings are stored.

class SettingsData {
  SettingsData({
    required this.showIntroduction,
    required this.lightThemeEnum,
    required this.darkThemeEnum,
  });

  /// Converts a Map into [SettingsData].
  SettingsData.fromMap(final Map<String, dynamic> map)
      : showIntroduction = (map['showIntroduction'] as int).toBool(),
        lightThemeEnum = ThemeEnumMethods.fromName(map['lightTheme'] as String),
        darkThemeEnum = ThemeEnumMethods.fromName(map['darkTheme'] as String);

  /// Supplies an instance of [SettingsData] that contains its default values.
  SettingsData.initialValues()
      : showIntroduction = true,
        lightThemeEnum = AppThemeData.instance.currentLightThemeEnum,
        darkThemeEnum = AppThemeData.instance.currentDarkThemeEnum;

  bool showIntroduction;
  ThemeEnum lightThemeEnum;
  ThemeEnum darkThemeEnum;

  /// Converts the [SettingsData] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'showIntroduction': showIntroduction.toInt(),
      'lightTheme': lightThemeEnum.name,
      'darkTheme': darkThemeEnum.name,
    };
    return map;
  }
}
