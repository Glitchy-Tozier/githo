import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/headings.dart';

class TextSheet extends StatelessWidget {
  final String headingString;
  final TextSpan textSpan;

  const TextSheet({
    required this.headingString,
    required this.textSpan,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: const Radius.circular(40),
          topRight: const Radius.circular(40),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.deepOrange.shade300,
            Colors.pinkAccent.shade400,
            Colors.purple.shade900,
          ],
        ),
      ),
      child: Container(
        //height: 400,
        padding: const EdgeInsets.only(
          right: StyleData.screenPaddingValue,
          bottom: 30,
          left: StyleData.screenPaddingValue,
        ),
        decoration: const BoxDecoration(
          borderRadius: const BorderRadius.only(
            topLeft: const Radius.circular(40),
            topRight: const Radius.circular(40),
          ),
          color: Colors.white70,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 9),
              child: Container(
                width: 100,
                height: 2,
                color: Colors.pink,
              ),
            ),
            Heading(headingString),
            RichText(
              overflow: TextOverflow.ellipsis,
              maxLines: 8,
              text: textSpan,
            ),
          ],
        ),
      ),
    );
  }
}
