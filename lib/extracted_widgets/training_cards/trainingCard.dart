import 'package:flutter/material.dart';

class TrainingCard extends StatelessWidget {
  // Returns the default training-card.

  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final Widget child;
  final Function? onTap;
  final Color color;

  final double topMargin = 5;
  final double bottomMargin = 15;
  final double borderRadius = 7;

  const TrainingCard({
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.child,
    required this.onTap,
    required this.color,
    Key? key,
  }) : super(key: key);

  double get height {
    final double height = this.cardHeight + this.topMargin + this.bottomMargin;
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
          width: this.cardWidth,
          height: this.cardHeight,
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
