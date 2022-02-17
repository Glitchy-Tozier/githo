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

import 'package:githo/config/style_data.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/models/settings_data.dart';
import 'package:githo/screens/home_screen.dart';
import 'package:githo/screens/introduction.dart';
import 'package:githo/widgets/headings/heading.dart';

/// A splash screen that decides which view/screen should follow.
///
/// If the app is started for the first time:
/// [OnBoardingScreen];
/// Else:
/// [HomeScreen].

class SplashScreen extends StatefulWidget {
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final Future<SettingsData> _settings = DatabaseHelper.instance.getSettings();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SettingsData>(
      future: _settings,
      builder: (BuildContext context, AsyncSnapshot<SettingsData> snapshot) {
        if (snapshot.hasData) {
          final SettingsData settings = snapshot.data!;

          if (settings.showIntroduction) {
            // If this is the first start of the app reading the theme-
            // config isn't needed.
            return OnBoardingScreen();
          } else {
            return HomeScreen();
          }
        } else if (snapshot.hasError) {
          // If connection is done but there was an error:
          print(snapshot.error);
          return Padding(
            padding: StyleData.screenPadding,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Heading(
                  'There was an error connecting to the database.',
                ),
                Text(
                  snapshot.error.toString(),
                ),
              ],
            ),
          );
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
    final double screenHeight = MediaQuery.of(context).size.height;
    final double smallestDimension =
        screenWidth < screenHeight ? screenWidth : screenHeight;

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
          width: smallestDimension * 0.7,
        ),
      ),
    );
  }
}
