import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

import 'package:flutter/material.dart';

import 'screens/todo.dart';
//import 'screens/habitList.dart';
//import 'screens/editHabit.dart';
import 'screens/appSettings.dart';
import 'screens/appInfo.dart';

void main() {
  final bool _needsSpecialSQfliteTreatment;
  if (Platform.isWindows) {
    print(
        "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\nDetected Windows\n~~~~~~~~~~~~~~~~~~~~~~~~~~");
    _needsSpecialSQfliteTreatment = true;
  } else if (Platform.isLinux) {
    print(
        "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~\nDetected Linux\n~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    _needsSpecialSQfliteTreatment = true;
  } else {
    print(
        "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\nThere's definitely nothing wrong. Ignore this message please!!\n~~~~~~~~~~~~~~~~~~~~~~~~~~");
    _needsSpecialSQfliteTreatment = false;
  }
  if (_needsSpecialSQfliteTreatment) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
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
          //
          // Try running your application with "flutter run". You'll see the
          // application has a blue toolbar. Then, without quitting the app, try
          // changing the primarySwatch below to Colors.green and then invoke
          // "hot reload" (press "r" in the console where you ran "flutter run",
          // or simply save your changes to "hot reload" in a Flutter IDE).
          // Notice that the counter didn't reset back to zero; the application
          // is not restarted.
          primarySwatch: Colors.green,
        ),
        //home: ToDoScreen(), //MyHomePage(title: 'Flutter Demo Home Page'),
        routes: {
          "/": (context) => ToDoScreen(),
          //"/habitList": (context) => HabitList(),
          //"/editHabit": (context) => EditHabit(),
          "/appSettings": (context) => AppSettings(),
          "/appInfo": (context) => AppInfo(),
        });
  }
}
