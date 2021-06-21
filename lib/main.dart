import 'package:flutter/material.dart';

import 'package:githo/extracted_functions/adaptDatabaseToOS.dart';
import 'package:githo/screens/homeScreen.dart';

void main() {
  adaptDatabaseToOS();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GITHO - Get Into The Habit Of…",
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
