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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:githo/config/app_theme.dart';
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/style_data.dart';

import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bordered_image.dart';
import 'package:githo/widgets/custom_licence_page.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/list_button.dart';

/// Contains licenses and important links.

class About extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final Future<PackageInfo> futurePackageInfo = PackageInfo.fromPlatform();

    return Scaffold(
      body: Background(
        child: Container(
          alignment: Alignment.center,
          padding: StyleData.screenPadding,
          child: FutureBuilder<PackageInfo>(
            future: futurePackageInfo,
            builder:
                (BuildContext context, AsyncSnapshot<PackageInfo> snapShot) {
              if (snapShot.connectionState == ConnectionState.done) {
                if (snapShot.hasData) {
                  final PackageInfo packageInfo = snapShot.data!;
                  final String version = packageInfo.version;

                  return Column(
                    children: <Widget>[
                      const SizedBox(height: 70),
                      const BorderedImage(
                        'assets/zoomed_icon.png',
                        width: 90,
                      ),
                      const Heading('Githo'),
                      Text(version),
                      const SizedBox(height: 20),
                      ListButton(
                        text: 'Source Code',
                        onPressed: () async {
                          const String url =
                              'https://github.com/Glitchy-Tozier/githo';
                          if (await canLaunch(url)) {
                            launch(url);
                          } else {
                            throw 'Could not launch URL: $url';
                          }
                        },
                      ),
                      ListButton(
                        text: 'Privacy Policy',
                        onPressed: () async {
                          const String url =
                              'https://github.com/Glitchy-Tozier/githo/blob/main/privacyPolicy.md';
                          if (await canLaunch(url)) {
                            launch(url);
                          } else {
                            throw 'Could not launch URL: $url';
                          }
                        },
                      ),
                      ListButton(
                        text: 'Licenses',
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const CustomLicensePage(
                              applicationName: 'Githo\nGet Into The Habit Of…',
                            ),
                          ));
                        },
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Expanded(
                            child: Theme(
                              data: AppThemeData.instance.currentLightTheme,
                              child: ListButton(
                                text: 'Change LightTheme',
                                color: ThemedColors.greyFrom(
                                  AppThemeData.instance.currentLightThemeMode,
                                ),
                                onPressed: () {
                                  AppThemeData.instance.setNewLightMode(
                                    AppThemeData.instance.nextThemeEnum(
                                      AppThemeData
                                          .instance.currentLightThemeMode,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Theme(
                              data: AppThemeData.instance.currentDarkTheme,
                              child: ListButton(
                                text: 'Change DarkTheme',
                                color: ThemedColors.greyFrom(
                                  AppThemeData.instance.currentDarkThemeMode,
                                ),
                                onPressed: () {
                                  AppThemeData.instance.setNewDarkMode(
                                      AppThemeData.instance.nextThemeEnum(
                                    AppThemeData.instance.currentDarkThemeMode,
                                  ));
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      ListButton(
                        text: 'Go back',
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  );
                }
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
          ),
        ),
      ),
    );
  }
}
