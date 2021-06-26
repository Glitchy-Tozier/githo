import 'package:flutter/material.dart';

class AppSettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: <Widget>[
        const Text(
          "List of Habits",
          style: TextStyle(fontSize: 25),
        ),
        Center(
          child: Column(
            children: <Widget>[
              const Text("App Settings"),
              ElevatedButton(
                  child: const Text("Go to App Info"),
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
