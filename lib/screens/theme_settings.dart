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
import 'package:githo/widgets/dividers/thin_divider.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/list_button.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

/// A view that allows for changing the app's theme.

class ThemeSettings extends StatefulWidget {
  @override
  State<ThemeSettings> createState() => _ThemeSettingsState();
}

class _ThemeSettingsState extends State<ThemeSettings>
    with WidgetsBindingObserver {
  Brightness brightness = SchedulerBinding.instance!.window.platformBrightness;

  @override
  void initState() {
    super.initState();
    // Necessary for `didChangePlatformBrightness()` to work.
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
    return Scaffold(
      body: Background(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            const ScreenTitle('Themes'),
            const FatDivider(),
            const Padding(
              padding: StyleData.screenPadding,
              child: Heading('Theme Mode'),
            ),
            Padding(
              padding: StyleData.screenPadding,
              child: SwitchListTile(
                title: const Text('Sync with system'),
                value: AppThemeData.instance.adaptToSystem,
                onChanged: (final bool value) =>
                    AppThemeData.instance.setAdaptToSystem(value: value),
              ),
            ),
            const FatDivider(),
            Padding(
              padding: StyleData.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (AppThemeData.instance.adaptToSystem) ...<Row>{
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Row(
                          children: const <Widget>[
                            Heading('Light Mode '),
                            Icon(Icons.light_mode),
                          ],
                        ),
                        Text(
                          brightness == Brightness.light ? '(active)' : '',
                        ),
                      ],
                    ),
                  } else ...<Heading>{
                    const Heading('Choose a Theme'),
                  },
                  ThemeButton(
                    changesLightMode: true,
                    themeEnum: ThemeEnum.light,
                  ),
                  const SizedBox(width: 10),
                  ThemeButton(
                    changesLightMode: true,
                    themeEnum: ThemeEnum.dark,
                  ),
                  const SizedBox(width: 10),
                  ThemeButton(
                    changesLightMode: true,
                    themeEnum: ThemeEnum.black,
                  ),
                ],
              ),
            ),
            Visibility(
              visible: AppThemeData.instance.adaptToSystem,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 15),
                  const ThinDivider(),
                  Padding(
                    padding: StyleData.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              children: const <Widget>[
                                Heading('Dark Mode '),
                                Icon(Icons.dark_mode),
                              ],
                            ),
                            Text(
                              brightness == Brightness.dark ? '(active)' : '',
                            ),
                          ],
                        ),
                        ThemeButton(
                          changesLightMode: false,
                          themeEnum: ThemeEnum.light,
                        ),
                        const SizedBox(width: 10),
                        ThemeButton(
                          changesLightMode: false,
                          themeEnum: ThemeEnum.dark,
                        ),
                        const SizedBox(width: 10),
                        ThemeButton(
                          changesLightMode: false,
                          themeEnum: ThemeEnum.black,
                        ),
                      ],
                    ),
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

/// A [ListButton] that automatically chooses its child & styling according to
/// the [changesLightMode] and [themeEnum].
class ThemeButton extends StatelessWidget {
  // ignore: prefer_const_constructors_in_immutables
  ThemeButton({
    required this.changesLightMode,
    required this.themeEnum,
    Key? key,
  }) : super(key: key);

  final bool changesLightMode;
  final ThemeEnum themeEnum;

  @override
  Widget build(BuildContext context) {
    final AppThemeData themeClass = AppThemeData.instance;
    final ThemeData theme = themeClass.themefromEnum(themeEnum);
    final Color textColor = theme.textTheme.bodyText2!.color!;

    final ThemeEnum currentThemeEnum;
    void Function() onPressed;
    final Widget radioBox;

    if (changesLightMode) {
      currentThemeEnum = themeClass.currentLightThemeEnum;
      onPressed = () => themeClass.setNewLightEnum(themeEnum);
    } else {
      currentThemeEnum = themeClass.currentDarkThemeEnum;
      onPressed = () => themeClass.setNewDarkEnum(themeEnum);
    }

    if (currentThemeEnum == themeEnum) {
      onPressed = () {};
      radioBox = Icon(
        Icons.radio_button_checked,
        color: textColor,
      );
    } else {
      radioBox = Icon(
        Icons.radio_button_unchecked,
        color: textColor,
      );
    }

    return ListButton(
      color: ThemedColors.greyFrom(
        themeEnum,
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            themeEnum.name,
            style: theme.textTheme.bodyText2,
          ),
          radioBox,
        ],
      ),
    );
  }
}
