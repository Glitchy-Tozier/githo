import 'package:flutter/material.dart';

class FatDivider extends StatelessWidget {
  const FatDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 30,
      thickness: 10,
      color: Colors.orange,
    );
  }
}
