import 'package:flutter/material.dart';

import 'package:githo/extracted_functions/adaptDatabaseToOS.dart';

import 'screens/todo.dart';
//import 'screens/habitList.dart';
//import 'screens/editHabit.dart';
import 'screens/appSettings.dart';
import 'screens/appInfo.dart';

void main() {
  adaptDatabaseToOS();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "GITHO - Get Into The Habit Of...",
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.green,
      ),
      //home: ToDoScreen(), //MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        "/": (context) => ToDoScreen(),
        //"/habitList": (context) => HabitList(),
        //"/editHabit": (context) => EditHabit(),
        "/appSettings": (context) => AppSettings(),
        "/appInfo": (context) => AppInfo(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
