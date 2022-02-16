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
import 'package:introduction_screen/introduction_screen.dart';

import 'package:githo/config/style_data.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/models/settings_data.dart';
import 'package:githo/screens/home_screen.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bordered_image.dart';

/// The introduction-screen that explains how this app works.

class OnBoardingScreen extends StatefulWidget {
  @override
  State<OnBoardingScreen> createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  Future<void> _onIntroEnd(BuildContext context) async {
    // Make sure the introduction-screen doesn't get shown again
    final SettingsData settings = await DatabaseHelper.instance.getSettings();
    settings.showIntroduction = false;
    await DatabaseHelper.instance.updateSettings(settings);

    // Navigate to the homescreen
    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<HomeScreen>(
        builder: (_) => HomeScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final PageDecoration pageDecoration = PageDecoration(
      titleTextStyle: Theme.of(context).textTheme.headline2!,
      bodyTextStyle: Theme.of(context).textTheme.bodyText2!,
      titlePadding: const EdgeInsets.symmetric(
        vertical: 20,
        horizontal: StyleData.screenPaddingValue,
      ),
      descriptionPadding: StyleData.screenPadding,
      imagePadding: const EdgeInsets.only(
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
              title: 'Githo',
              bodyWidget: Column(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'G',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        TextSpan(
                          text: 'et ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        TextSpan(
                          text: 'I',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        TextSpan(
                          text: 'nto ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        TextSpan(
                          text: 'T',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        TextSpan(
                          text: 'he ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        TextSpan(
                          text: 'H',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        TextSpan(
                          text: 'abit ',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        TextSpan(
                          text: 'O',
                          style: Theme.of(context).textTheme.headline3,
                        ),
                        TextSpan(
                          text: 'f…',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // Get Into The Habit Of…
              //body: 'Gradually aquire an new habit',
              image: const BorderedImage('assets/zoomed_icon.png', width: 90),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: 'Define levels of difficulty',
              body: 'Move closer towards your final habit.',
              image: const BorderedImage(
                'assets/introduction_screen_images/defineLevels.jpeg',
              ),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: 'Build strong habits',
              body: 'Consistently succeed in trainings to level up.\n\n'
                  'If a level is too difficult, repeat the previous one.',
              image: const BorderedImage(
                'assets/introduction_screen_images/training.jpeg',
              ),
              decoration: pageDecoration,
            ),
          ],
          onDone: () => _onIntroEnd(context),
          next: const Icon(Icons.arrow_forward),
          done: Text(
            'Start',
            style: Theme.of(context).textTheme.headline3!.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          curve: Curves.fastLinearToSlowEaseIn,
          controlsMargin: const EdgeInsets.all(16),
          dotsDecorator: DotsDecorator(
            size: const Size(10.0, 10.0),
            color: Theme.of(context).textTheme.bodyText2!.color!,
            activeColor: Colors.pink,
            activeSize: const Size(22.0, 10.0),
            activeShape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0)),
            ),
          ),
        ),
      ],
    );
  }
}
