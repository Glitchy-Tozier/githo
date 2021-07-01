import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  final String title;
  final String? subTitle;

  const ScreenTitle({
    required this.title,
    this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    final padding = const EdgeInsets.only(top: 70, bottom: 30);

    List<Widget> columnContents = [
      Text(
        title,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];

    if (subTitle != null) {
      columnContents.addAll([
        const SizedBox(height: 5),
        Text(
          subTitle!,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            color: Colors.black,
          ),
        ),
      ]);
    }
    return Padding(
      padding: padding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: columnContents,
      ),
    );
  }
}

class Heading1 extends StatelessWidget {
  final String _text;
  const Heading1(this._text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        _text,
        style: const TextStyle(
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
  const Heading2(this._text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 5),
      child: Text(
        _text,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.black,
          //fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
