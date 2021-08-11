/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
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
import 'package:githo/widgets/background.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/models/settings_data.dart';
import 'package:githo/screens/home_screen.dart';
import 'package:githo/screens/introduction.dart';

/// Return the apropriate first screen.
///
/// If the app is started for the first time: [OnBoardingScreen];
/// Else: [HomeScreen];

class FirstScreen extends StatelessWidget {
  Future<Widget> getFirstScreen() async {
    final SettingsData settings = await DatabaseHelper.instance.getSettings();

    if (settings.showIntroduction) {
      return OnBoardingScreen();
    } else {
      return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Widget>(
      future: getFirstScreen(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final Widget firstScreen = snapshot.data!;
            return firstScreen;
          }
        }
        // While loading, return this:
        return const Background();
      },
    );
  }
}
