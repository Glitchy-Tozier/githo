import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleShortcut.dart';

class Heading1 extends StatelessWidget {
  final String _text;
  Heading1(this._text);

  @override
  Widget build(BuildContext context) {
    final double _sizedBoxHeight = 10;
    return Column(
      children: <Widget>[
        SizedBox(height: _sizedBoxHeight),
        Text(
          _text,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _sizedBoxHeight),
      ],
    );
  }
}

class Heading2 extends StatelessWidget {
  final String _text;
  Heading2(this._text);

  @override
  Widget build(BuildContext context) {
    final double _sizedBoxHeight = 10;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(height: _sizedBoxHeight),
        Text(
          _text,
          style: TextStyle(
            fontSize: 20,
            //fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: _sizedBoxHeight),
      ],
    );
  }
}

class HeadingButton extends StatelessWidget {
  final String text;
  final Function onPressedFunc;
  const HeadingButton({required this.text, required this.onPressedFunc});

  @override
  Widget build(BuildContext context) {
    const double borderWidth = 5;
    const double usualScreenPadding = StyleData.screenPaddingValue;
    const double buttonPadding = usualScreenPadding - borderWidth;

    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        primary: Colors.black,
        side: BorderSide(
          color: Colors.black,
          width: borderWidth,
        ),
        minimumSize: Size(double.infinity, 90),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: buttonPadding, vertical: buttonPadding / 2),
        child: Text(
          text,
          style: TextStyle(fontSize: 25),
        ),
      ),
      onPressed: () {
        onPressedFunc();
      },
    );
  }
}
