import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final double margin;
  final double width;
  final double height;
  final Widget child;
  final Function? onTap;
  final Color color;

  const CustomCard({
    required this.margin,
    required this.width,
    required this.height,
    required this.child,
    required this.onTap,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.only(right: margin, left: margin),
        child: Ink(
          width: this.width,
          height: this.height,
          child: InkWell(
            child: Center(child: this.child),
            splashColor: Colors.black,
            onTap: (onTap == null) ? null : () => onTap!(),
            borderRadius: BorderRadius.circular(7),
          ),
          decoration: BoxDecoration(
            color: this.color,
            /* border: Border.all(
              color: Colors.black,
              width: 4,
            ), */
            borderRadius: BorderRadius.circular(7),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Colors.grey,
                blurRadius: 5,
                offset: Offset(4, 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
