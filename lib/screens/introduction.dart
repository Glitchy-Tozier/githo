import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/backgroundWidget.dart';
import 'package:githo/extracted_widgets/borderedImage.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/settingsModel.dart';
import 'package:githo/screens/homeScreen.dart';
import 'package:introduction_screen/introduction_screen.dart';

class OnBoardingScreen extends StatelessWidget {
  // The introduction-screen that explains how this app works.

  void _onIntroEnd(BuildContext context) async {
    // Make sure the introduction-screen doesn't get shown again
    final Settings settings = await DatabaseHelper.instance.getSettings();
    settings.showIntroduction = false;
    DatabaseHelper.instance.updateSettings(settings);

    // Navigate to the homescreen
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    const PageDecoration pageDecoration = const PageDecoration(
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
      children: [
        const BackgroundWidget(),
        IntroductionScreen(
          globalBackgroundColor: Colors.transparent,
          pages: [
            PageViewModel(
              title: "Githo – Get Into The Habit Of…",
              body: "Aquire an new habit, one step at a time",
              image: const BorderedImage('assets/launcher/icon.png', width: 90),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Define gradual steps",
              body: "Move closer towards your final habit",
              image: const BorderedImage(
                  "assets/introduction_screen_images/defineSteps.jpeg"),
              decoration: pageDecoration,
            ),
            PageViewModel(
              title: "Build strong habits",
              body:
                  "Consistently succeed in trainings to advance to the next step.\n\nIf a step is too difficult, repeat the one before it.",
              image: const BorderedImage(
                  "assets/introduction_screen_images/training.png"),
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
