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
import 'package:githo/config/style_data.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bordered_image.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/models/settings_data.dart';
import 'package:githo/screens/home_screen.dart';
import 'package:introduction_screen/introduction_screen.dart';
// The introduction-screen that explains how this app works.

class OnBoardingScreen extends StatelessWidget {
  Future<void> _onIntroEnd(BuildContext context) async {
    // Make sure the introduction-screen doesn't get shown again
    final SettingsData settings = await DatabaseHelper.instance.getSettings();
    settings.showIntroduction = false;
    DatabaseHelper.instance.updateSettings(settings);

    // Navigate to the homescreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<HomeScreen>(
        builder: (_) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 28.0,
        fontWeight: FontWeight.w700,
      ),
      bodyTextStyle: StyleData.textStyle,
      titlePadding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: StyleData.screenPaddingValue,
      ),
      descriptionPadding: StyleData.screenPadding,
      imagePadding: EdgeInsets.only(
        top: 70,
        right: StyleData.screenPaddingValue,
        left: StyleData.screenPaddingValue,
      ),
      imageFlex: 0,
    );

    return Stack(
      children: <Widget>[
        const Background(),
        IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: <PageViewModel>[
            PageViewModel(
              title: 'Githo – Get Into The Habit Of…',
              body: 'Aquire an new habit, one step at a time',
              image: const BorderedImage('assets/launcher/icon.png', width: 90),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: 'Define gradual steps',
              body: 'Move closer towards your final habit',
              image: const BorderedImage(
                  'assets/introduction_screen_images/defineSteps.jpeg'),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: 'Build strong habits',
              body: 'Consistently succeed in trainings to advance '
                  'to the next step.\n\n'
                  'If a step is too difficult, repeat the one before it.',
              image: const BorderedImage(
                  'assets/introduction_screen_images/training.png'),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          next: const Icon(Icons.arrow_forward),
          done: Text(
            'Start',
            style: coloredBoldTextStyle(Theme.of(context).primaryColor),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: const EdgeInsets.all(16),
          dotsDecorator: const DotsDecorator(
            size: Size(10.0, 10.0),
            color: Colors.black,
            activeColor: Colors.pink,
            activeSize: Size(22.0, 10.0),
            activeShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ],
    );
  }
}
