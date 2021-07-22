import 'package:flutter/material.dart';

class BorderedImage extends StatelessWidget {
  final String name;
  final double width;

  const BorderedImage(
    this.name, {
    this.width = double.infinity,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      //borderRadius: BorderRadius.circular(20),
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20)),
        color: Colors.white,
        border: Border.all(
          color: Colors.white,
          width: 7,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(15)),
        child: Image.asset(name),
      ),
    );
  }
}
