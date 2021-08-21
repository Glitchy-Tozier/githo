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
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/widgets/alert_dialogs/training_done.dart';

class ActiveTrainingCard extends StatefulWidget {
  /// Returns the default training-card.
  const ActiveTrainingCard({
    required this.training,
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.textSize,
    Key? key,
  }) : super(key: key);

  final Training training;
  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final double textSize;

  static const double topMargin = 5;
  static const double bottomMargin = 15;
  static const double borderRadius = 7;

  @override
  _ActiveTrainingCardState createState() => _ActiveTrainingCardState();
}

class _ActiveTrainingCardState extends State<ActiveTrainingCard> {
  double get height {
    final double height = widget.cardHeight +
        ActiveTrainingCard.topMargin +
        ActiveTrainingCard.bottomMargin;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (widget.training.status == 'done') {
      color = Colors.lightGreenAccent;
    } else {
      color = Colors.red.shade100;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: ActiveTrainingCard.topMargin,
          right: widget.horizontalMargin,
          bottom: ActiveTrainingCard.bottomMargin,
          left: widget.horizontalMargin,
        ),
        child: SizedBox(
          width: widget.cardWidth,
          height: widget.cardHeight,
          child: Material(
            color: color,
            borderRadius:
                BorderRadius.circular(ActiveTrainingCard.borderRadius),
            elevation: 5,
            child: InkWell(
              splashColor: Colors.black,
              onTap: () {
                widget.training.incrementReps();
                setState(() {});
                if (widget.training.doneReps == widget.training.requiredReps) {
                  Timer(
                    const Duration(milliseconds: 700),
                    () => showDialog(
                      context: context,
                      builder: (BuildContext buildContext) {
                        return TrainingDoneAlert();
                      },
                    ),
                  );
                }
              },
              onLongPress: () {
                widget.training.decrementReps();
                setState(() {});
              },
              borderRadius:
                  BorderRadius.circular(ActiveTrainingCard.borderRadius),
              child: Center(
                child: Text(
                  '${widget.training.doneReps}/${widget.training.requiredReps}',
                  style: TextStyle(
                    fontSize: widget.textSize * 1.3 * 1.3,
                    color: Colors.black,
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
