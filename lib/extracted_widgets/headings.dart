import 'package:flutter/material.dart';

class ScreenTitle extends StatelessWidget {
  // Defines what screen-titles look like.

  final String _text;
  const ScreenTitle(this._text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 70, bottom: 30),
      child: Text(
        _text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 35,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }
}

class Heading extends StatelessWidget {
  // Defines what headings look like.

  final String _text;
  const Heading(this._text);

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
