import 'package:flutter/material.dart';
import 'package:githo/extracted_widgets/buttonListItem.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/backgroundWidget.dart';

import 'package:githo/extracted_widgets/borderedImage.dart';
import 'package:githo/extracted_widgets/headings.dart';

class AppInfo extends StatelessWidget {
  // Contains licences and important links.

  @override
  Widget build(BuildContext context) {
    final Future<PackageInfo> futurePackageInfo = PackageInfo.fromPlatform();

    return Scaffold(
      body: BackgroundWidget(
        child: Container(
          alignment: Alignment.center,
          padding: StyleData.screenPadding,
          child: FutureBuilder(
            future: futurePackageInfo,
            builder:
                (BuildContext context, AsyncSnapshot<PackageInfo> snapShot) {
              if (snapShot.connectionState == ConnectionState.done) {
                if (snapShot.hasData) {
                  final PackageInfo packageInfo = snapShot.data!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 70),
                      const BorderedImage('assets/launcher/icon.png',
                          width: 90),
                      const Heading("Githo"),
                      Text(
                        packageInfo.version,
                        style: StyleData.textStyle,
                      ),
                      SizedBox(height: 20),
                      ButtonListItem(
                        text: "Source Code",
                        color: Theme.of(context).buttonColor,
                        onPressed: () async {
                          const String url =
                              "https://github.com/Glitchy-Tozier/githo";
                          if (await canLaunch(url)) {
                            launch(url);
                          } else {
                            throw "Could not launch URL: $url";
                          }
                        },
                      ),
                      ButtonListItem(
                        text: "Privacy Policy",
                        color: Theme.of(context).buttonColor,
                        onPressed: () async {
                          const String url =
                              "https://github.com/Glitchy-Tozier/githo/blob/main/privacyPolicy.md";
                          if (await canLaunch(url)) {
                            launch(url);
                          } else {
                            throw "Could not launch URL: $url";
                          }
                        },
                      ),
                      ButtonListItem(
                        text: "Licences",
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
