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

import 'package:githo/config/app_theme.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/models/settings_data.dart';
import 'package:githo/screens/home_screen.dart';
import 'package:githo/screens/introduction.dart';

/// A splash screen that decides which view/screen should follow.
///
/// If the app is started for the first time:
/// [OnBoardingScreen];
/// Else:
/// [HomeScreen].

class SplashScreen extends StatelessWidget {
  final Future<SettingsData> _settings = DatabaseHelper.instance.getSettings();

  /// Update the app's themes according to what is stored in the database.
  Future<void> setThemes(final SettingsData settingsData) async {
    await AppThemeData.instance.setNewLightEnum(settingsData.lightThemeEnum);
    await AppThemeData.instance.setNewDarkEnum(settingsData.darkThemeEnum);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsData>(
      future: _settings,
      builder: (BuildContext context, AsyncSnapshot<SettingsData> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final SettingsData settings = snapshot.data!;

            if (settings.showIntroduction) {
              // If this is the first start of the app reading the theme-
              // config isn't needed.
              return OnBoardingScreen();
            } else {
              return FutureBuilder<void>(
                future: setThemes(settings),
                builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return HomeScreen();
                  }
                  return Splash();
                },
              );
            }
          }
        }
        return Splash();
      },
    );
  }
}

/// The [Widget] displayed on the [SplashScreen].
class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/pixabayColorGradient.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Image(
          image: const AssetImage('assets/launcher/foreground.png'),
          width: screenWidth * 0.7,
        ),
      ),
    );
  }
}
