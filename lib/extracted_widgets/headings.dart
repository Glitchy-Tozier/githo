import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subTitle;
  ScreenTitle({required this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {
    List<Widget> columnContents = [
      Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];
    if (subTitle != null) {
      columnContents.addAll([
        SizedBox(height: 5),
        Text(
          subTitle!,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ]);
    }
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 30),
      child: Column(
        children: columnContents,
      ),
    );
  }
}

class Heading1 extends StatelessWidget {
  final String _text;
  Heading1(this._text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _text,
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class Heading2 extends StatelessWidget {
  final String _text;
  Heading2(this._text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _text,
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          //fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
