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
import 'package:githo/config/app_theme.dart';

/// A [LicensePage] that always is styled as if the current
/// theme was [ThemeEnum.light], because getting other
/// stylings to work feels close to impossible.

class CustomLicensePage extends StatelessWidget {
  const CustomLicensePage({
    Key? key,
    this.applicationIcon,
    this.applicationLegalese,
    this.applicationName,
    this.applicationVersion,
  }) : super(key: key);

  final Widget? applicationIcon;
  final String? applicationLegalese;
  final String? applicationName;
  final String? applicationVersion;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppThemeData.instance.themefromEnum(ThemeEnum.light).copyWith(
            appBarTheme: Theme.of(context).appBarTheme,
          ),
      child: LicensePage(
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
        applicationName: applicationName,
        applicationVersion: applicationVersion,
      ),
    );
  }
}
