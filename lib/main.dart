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
import 'package:flutter/services.dart';

import 'package:githo/config/app_theme.dart';
import 'package:githo/config/data_shortcut.dart';
import 'package:githo/database/adapt_database_to_os.dart';
import 'package:githo/widgets/splash_screen.dart';

void main() {
  adaptDatabaseToOS();
  runApp(MyApp());
}

/// This widget is the root of the application.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Necessary to make the app reload when manually changing the theme.
    AppThemeData.instance.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    // Disables screen-rotation to prevent some layots getting too large.
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: 'Githo - Get Into The Habit Of…',
      theme: AppThemeData.instance.currentLightTheme,
      darkTheme: AppThemeData.instance.currentDarkTheme,
      home: SplashScreen(),
      debugShowCheckedModeBanner: DataShortcut.testing,
    );
  }
}
