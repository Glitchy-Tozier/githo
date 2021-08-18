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
import 'package:githo/widgets/list_button.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:githo/config/style_data.dart';
import 'package:githo/widgets/background.dart';

import 'package:githo/widgets/bordered_image.dart';
import 'package:githo/widgets/headings/heading.dart';

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

                  return Column(
                    children: <Widget>[
                      const SizedBox(height: 70),
                      const BorderedImage('assets/launcher/icon.png',
                          width: 90),
                      const Heading('Githo'),
                      Text(
                        packageInfo.version,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      const SizedBox(height: 20),
                      ListButton(
                        text: 'Source Code',
                        color: Theme.of(context).buttonColor,
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
                        color: Theme.of(context).buttonColor,
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
                        color: Theme.of(context).buttonColor,
                        onPressed: () {
                          showLicensePage(
                            context: context,
                            applicationIcon: const BorderedImage(
                              'assets/launcher/icon.png',
                              width: 90,
                            ),
                          );
                        },
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
