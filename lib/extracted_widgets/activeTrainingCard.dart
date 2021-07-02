import 'package:flutter/material.dart';

class ActiveTrainingCard extends StatelessWidget {
  final double horizontalMargin;
  final double width;
  final double height;
  final Widget child;
  final Function? onTap;

  final double topMargin = 5;
  final double bottomMargin = 15;
  final double borderRadius = 7;

  const ActiveTrainingCard({
    required this.horizontalMargin,
    required this.width,
    required this.height,
    required this.child,
    required this.onTap,
    Key? key,
  }) : super(key: key);

  double getHeight() {
    final double height = this.height + this.topMargin + this.bottomMargin;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: topMargin,
          right: horizontalMargin,
          bottom: bottomMargin,
          left: horizontalMargin,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: this.width,
            height: this.height,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                child: Center(child: this.child),
                splashColor: Colors.black,
                onTap: (onTap == null) ? null : () => onTap!(),
                borderRadius: BorderRadius.circular(borderRadius),
              ),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.deepOrange.shade200,
                  Colors.pinkAccent.shade400,
                  Colors.purple.shade900,
                ],
              ),
            ),
          ),
          borderRadius: BorderRadius.circular(borderRadius),
          elevation: 5,
        ),
      ),
    );
  }
}
