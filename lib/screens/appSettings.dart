import 'package:flutter/material.dart';

class AppSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        Text(
          "List of Habits",
          style: TextStyle(fontSize: 25),
        ),
        Center(
          child: Column(
            children: <Widget>[
              Text("App Settings"),
              ElevatedButton(
                  child: Text("Go to App Info"),
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/appInfo",
                    );
                  }),
            ],
          ),
        ),
      ]),
    );
  }
}
