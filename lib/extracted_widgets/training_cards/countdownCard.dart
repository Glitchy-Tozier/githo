import 'dart:async';
import 'package:flutter/material.dart';

import 'package:githo/extracted_functions/getDurationDiff.dart';
import 'package:githo/helpers/timeHelper.dart';

class CountdownCard extends StatefulWidget {
  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final DateTime startingDate;
  final double textSize;
  final Function updatePrevScreens;
  final Function? onTap;
  final Color color;

  const CountdownCard({
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.startingDate,
    required this.textSize,
    required this.updatePrevScreens,
    required this.onTap,
    required this.color,
    Key? key,
  }) : super(key: key);

  @override
  _CountdownCardState createState() => _CountdownCardState(
        horizontalMargin,
        cardWidth,
        cardHeight,
        startingDate,
        textSize,
        updatePrevScreens,
        onTap,
        color,
      );
}

class _CountdownCardState extends State<CountdownCard> {
  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final DateTime startingDate;
  final double textSize;
  final Function updatePrevScreens;
  final Function? onTap;
  final Color color;

  _CountdownCardState(
    this.horizontalMargin,
    this.cardWidth,
    this.cardHeight,
    this.startingDate,
    this.textSize,
    this.updatePrevScreens,
    this.onTap,
    this.color,
  );

  final double topMargin = 5;
  final double bottomMargin = 15;
  final double borderRadius = 7;

  late final Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        final DateTime now = TimeHelper.instance.currentTime;
        final Duration remainingTime = this.startingDate.difference(now);

        if (remainingTime.isNegative) {
          // Update whole homeScreen when the next training is ready
          this.updatePrevScreens();
        } else {
          // While waiting, refresh card every second
          setState(() {});
        }
      },
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  double get height {
    final double height = this.cardHeight + this.topMargin + this.bottomMargin;
    return height;
  }

  void _startTimer() {
    // Refresh the necessary parts of the screen every second
  }

  @override
  Widget build(BuildContext context) {
    _startTimer();

    final DateTime now = TimeHelper.instance.currentTime;
    final String remainingTimeStr = getDurationDiff(
      now,
      startingDate,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: topMargin,
          right: horizontalMargin,
          bottom: bottomMargin,
          left: horizontalMargin,
        ),
        child: Container(
          width: cardWidth,
          height: cardHeight,
          child: Material(
            color: color,
            child: InkWell(
              child: Center(
                child: Text(
                  "$remainingTimeStr remaining",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textSize,
                  ),
                ),
              ),
              splashColor: Colors.black,
              onTap: (onTap == null) ? null : () => onTap!(remainingTimeStr),
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
