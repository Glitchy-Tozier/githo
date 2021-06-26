import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double margin;
  final double width;
  final double height;
  final Widget child;
  final Function? onTap;
  final Color color;

  CustomCard({
    required this.margin,
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
        padding: EdgeInsets.only(right: margin, left: margin),
        child: Ink(
          width: this.width,
          height: this.height,
          child: InkWell(
            child: this.child,
            splashColor: Colors.black,
            onTap: (onTap == null) ? null : () => onTap!(),
          ),
          decoration: BoxDecoration(
            color: this.color,
            /* border: Border.all(
              color: Colors.black,
              width: 2,
            ), */
            borderRadius: BorderRadius.circular(7),
            boxShadow: <BoxShadow>[
              BoxShadow(
                //color: Colors.green,
                blurRadius: 3,
                //spreadRadius: 1,
                offset: Offset(2, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
