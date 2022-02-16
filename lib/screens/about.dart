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
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:githo/config/style_data.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bordered_image.dart';
import 'package:githo/widgets/custom_licence_page.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/list_button.dart';

/// Contains licenses and important links.

class About extends StatelessWidget {
  /// Opens an URL-[String]. If something goes wrong, the user gets alerted.
  void openUrl(final BuildContext context, final String url) {
    try {
      launch(url);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not launch URL: $url\n\nError: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Future<PackageInfo> futurePackageInfo = PackageInfo.fromPlatform();

    return Scaffold(
      body: Background(
        child: Padding(
          padding: StyleData.screenPadding,
          child: FutureBuilder<PackageInfo>(
            future: futurePackageInfo,
            builder:
                (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
              if (snapshot.hasData) {
                final PackageInfo packageInfo = snapshot.data!;
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
                      onPressed: () {
                        const String url =
                            'https://github.com/Glitchy-Tozier/githo';
                        openUrl(context, url);
                      },
                    ),
                    ListButton(
                      text: 'Privacy Policy',
                      onPressed: () {
                        const String url =
                            'https://github.com/Glitchy-Tozier/githo/blob/main/privacyPolicy.md';
                        openUrl(context, url);
                      },
                    ),
                    ListButton(
                      text: 'Licenses',
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (BuildContext context) =>
                                const CustomLicensePage(
                              applicationName: 'Githo\nGet Into The Habit Of…',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
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
              // While loading, do this:
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
