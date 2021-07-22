import 'package:flutter/material.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_widgets/backgroundWidget.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/models/settingsModel.dart';
import 'package:githo/screens/homeScreen.dart';
import 'package:githo/screens/introduction.dart';

class FirstScreen extends StatefulWidget {
  const FirstScreen({Key? key}) : super(key: key);

  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  @override
  void initState() {
    super.initState();
    if (DataShortcut.testing) {
      TimeHelper.instance.setTime(DateTime.now());
    }
  }

  Future<Widget> getFirstScreen() async {
    final Settings settings = await DatabaseHelper.instance.getSettings();

    if (settings.showIntroduction) {
      return OnBoardingScreen();
    } else {
      return HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getFirstScreen(),
      builder: (context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasData) {
            final Widget firstScreen = snapshot.data!;
            return firstScreen;
          }
        }
        // While loading, do this:
        return const BackgroundWidget(
          child: Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}
