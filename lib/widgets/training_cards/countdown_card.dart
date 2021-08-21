/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2021 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'package:flutter/material.dart';

import 'package:githo/helpers/get_duration_diff.dart';
import 'package:githo/helpers/time_helper.dart';

class CountdownCard extends StatefulWidget {
  /// Returns a training-card that displays a countdown for
  /// how much time is left until the training starts.
  const CountdownCard({
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.startingDate,
    required this.textSize,
    required this.color,
    this.onTap,
    Key? key,
  }) : super(key: key);

  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final DateTime startingDate;
  final double textSize;
  final Function? onTap;
  final Color color;

  @override
  _CountdownCardState createState() => _CountdownCardState();
}

class _CountdownCardState extends State<CountdownCard> {
  static const double topMargin = 5;
  static const double bottomMargin = 15;
  static const double borderRadius = 7;

  late final Timer timer;

  @override
  void initState() {
    super.initState();

    // The timer is used to manage the countdown.
    // It refreshes the card every second.
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => setState(() {}),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  double get height {
    final double height = widget.cardHeight + topMargin + bottomMargin;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = TimeHelper.instance.currentTime;
    final String remainingTimeStr = getDurationDiff(
      now,
      widget.startingDate,
    );

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: topMargin,
          right: widget.horizontalMargin,
          bottom: bottomMargin,
          left: widget.horizontalMargin,
        ),
        child: SizedBox(
          width: widget.cardWidth,
          height: widget.cardHeight,
          child: Material(
            color: widget.color,
            borderRadius: BorderRadius.circular(borderRadius),
            elevation: 6,
            child: InkWell(
              splashColor: Colors.black,
              onTap: (widget.onTap == null)
                  ? null
                  : () => widget.onTap!(remainingTimeStr),
              borderRadius: BorderRadius.circular(borderRadius),
              child: Center(
                child: Text(
                  '$remainingTimeStr remaining',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: widget.textSize,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
