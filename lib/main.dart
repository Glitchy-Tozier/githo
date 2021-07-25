import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:githo/extracted_data/dataShortcut.dart';

import 'package:githo/extracted_widgets/firstScreen.dart';
import 'package:githo/extracted_functions/adaptDatabaseToOS.dart';

void main() {
  adaptDatabaseToOS();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of the application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp(
      title: "Githo - Get Into The Habit Of…",
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: FirstScreen(),
      debugShowCheckedModeBanner: DataShortcut.testing,
    );
  }
}
