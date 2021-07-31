import 'package:flutter/material.dart';

class BorderedImage extends StatelessWidget {
  // Loads an image, wraps a pretty border around it, and returns it.

  final String location;
  final double width;

  const BorderedImage(
    this.location, {
    this.width = double.infinity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 7,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(15)),
        child: Image.asset(location),
      ),
    );
  }
}
