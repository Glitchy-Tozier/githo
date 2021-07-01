import 'package:flutter/material.dart';

class TrainingCard extends StatelessWidget {
  final double horizontalMargin;
  final double width;
  final double height;
  final Widget child;
  final Function? onTap;
  final Color color;

  final double topMargin = 5;
  final double bottomMargin = 15;
  final double borderRadius = 7;

  const TrainingCard({
    required this.horizontalMargin,
    required this.width,
    required this.height,
    required this.child,
    required this.onTap,
    required this.color,
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
        child: Container(
          width: this.width,
          height: this.height,
          child: Material(
            color: this.color,
            child: InkWell(
              child: Center(child: this.child),
              splashColor: Colors.black,
              onTap: (onTap == null) ? null : () => onTap!(),
              borderRadius: BorderRadius.circular(borderRadius),
            ),
            borderRadius: BorderRadius.circular(borderRadius),
            elevation: 5,
          ),
        ),
      ),
    );
  }
}
