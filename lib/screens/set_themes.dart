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

import 'package:githo/config/app_theme.dart';
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/style_data.dart';

import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/list_button.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

/// A view that allows for changing the app's theme.

class SetThemes extends StatefulWidget {
  @override
  State<SetThemes> createState() => _SetThemesState();
}

class _SetThemesState extends State<SetThemes> with WidgetsBindingObserver {
  Brightness brightness = SchedulerBinding.instance!.window.platformBrightness;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  // Reload this screen if platform-brightness (light/dark mode) changes.
  @override
  void didChangePlatformBrightness() {
    setState(() {
      brightness = SchedulerBinding.instance!.window.platformBrightness;
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Shortcuts to simplify some of the following commands.
    final AppThemeData themeClass = AppThemeData.instance;
    final ThemeEnum currentLightThemeEnum = themeClass.currentLightThemeEnum;
    final ThemeEnum currentDarkThemeEnum = themeClass.currentDarkThemeEnum;
    final TextStyle lightBodyStyle2 =
        themeClass.currentLightTheme.textTheme.bodyText2!;
    final TextStyle darkBodyStyle2 =
        themeClass.currentDarkTheme.textTheme.bodyText2!;

    return Scaffold(
      body: Background(
        child: ListView(
          children: <Widget>[
            const ScreenTitle('Themes'),
            const FatDivider(),
            Padding(
              padding: StyleData.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 20),
                  const Text(
                    'Click on a button to change the theme used in light / dark mode.',
                  ),
                  const SizedBox(height: 60),
                  IntrinsicHeight(
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              const Icon(Icons.light_mode),
                              const SizedBox(height: 20),
                              Text(
                                brightness == Brightness.light
                                    ? '(active)'
                                    : '',
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  themeClass.setNewLightEnum(
                                    currentLightThemeEnum.nextEnum,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: ListButton.minSize,
                                  padding: ListButton.padding,
                                  primary: ThemedColors.greyFrom(
                                    currentLightThemeEnum,
                                  ),
                                  onPrimary: lightBodyStyle2.color,
                                  textStyle: lightBodyStyle2,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(4),
                                      bottomLeft: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  currentLightThemeEnum.name,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const VerticalDivider(
                          thickness: 3,
                          width: 3,
                        ),
                        Expanded(
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              const Icon(Icons.dark_mode),
                              const SizedBox(height: 20),
                              Text(
                                brightness == Brightness.dark ? '(active)' : '',
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  themeClass.setNewDarkEnum(
                                    currentDarkThemeEnum.nextEnum,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  minimumSize: ListButton.minSize,
                                  padding: ListButton.padding,
                                  primary: ThemedColors.greyFrom(
                                    currentDarkThemeEnum,
                                  ),
                                  onPrimary: darkBodyStyle2.color,
                                  textStyle: darkBodyStyle2,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(4),
                                      bottomRight: Radius.circular(4),
                                    ),
                                  ),
                                ),
                                child: Text(
                                  currentDarkThemeEnum.name,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 55),
                  const Text(
                    'To always use the same theme, '
                    'just set both modes to that theme.',
                  ),
                  ScreenEndingSpacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
