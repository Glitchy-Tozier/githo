import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subTitle;
  final bool addBottomPadding;

  ScreenTitle({
    required this.title,
    this.subTitle,
    this.addBottomPadding = true,
  });

  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding;
    if (addBottomPadding) {
      padding = EdgeInsets.only(top: 70, bottom: 50);
    } else {
      padding = EdgeInsets.only(top: 70, bottom: 10);
    }

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
      padding: padding,
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
