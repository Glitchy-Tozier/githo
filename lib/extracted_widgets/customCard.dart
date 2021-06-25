import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final Function onTap;
  final Color color;

  CustomCard({
    required this.width,
    required this.height,
    required this.child,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: 2, left: 2),
        child: Ink(
          width: this.width,
          height: this.height,
          child: InkWell(
            child: this.child,
            splashColor: Colors.black,
            onTap: () => onTap(),
          ),
          decoration: BoxDecoration(
            color: this.color,
            border: Border.all(
              color: Colors.black,
              width: 3,
            ),
            borderRadius: BorderRadius.circular(7),
          ),
        ),
      ),
    );
  }
}
