/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
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
import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/helpers/notification_helper.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/widgets/alert_dialogs/training_done.dart';

class ActiveTrainingCard extends StatefulWidget {
  /// Returns the default training-card.
  const ActiveTrainingCard({
    Key? key,
    required this.training,
    required this.horizontalMargin,
    required this.cardWidth,
    required this.cardHeight,
    required this.textSize,
    required this.setHomeState,
  }) : super(key: key);

  final Training training;
  final double horizontalMargin;
  final double cardWidth;
  final double cardHeight;
  final double textSize;
  final void Function() setHomeState;

  @override
  _ActiveTrainingCardState createState() => _ActiveTrainingCardState();
}

class _ActiveTrainingCardState extends State<ActiveTrainingCard> {
  double get height {
    final double height = widget.cardHeight +
        TrainingCardThemes.topMargin +
        TrainingCardThemes.bottomMargin;
    return height;
  }

  @override
  Widget build(BuildContext context) {
    final Color color;
    if (widget.training.status == 'done') {
      color = CardColors.activeDone;
    } else {
      color = CardColors.activeNotDone;
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.only(
          top: TrainingCardThemes.topMargin,
          right: widget.horizontalMargin,
          bottom: TrainingCardThemes.bottomMargin,
          left: widget.horizontalMargin,
        ),
        child: SizedBox(
          width: widget.cardWidth,
          height: widget.cardHeight,
          child: TrainingCardThemes.getThemedCard(
            cardHeight: widget.cardHeight,
            color: color,
            elevation: 7,
            onTap: () async {
              await widget.training.incrementReps();
              widget.setHomeState();
              if (widget.training.doneReps == widget.training.requiredReps) {
                await cancelNotifications();
                await scheduleNotifications();
                Timer(
                  const Duration(milliseconds: 700),
                  () => showDialog(
                    context: context,
                    builder: (BuildContext buildContext) {
                      return const TrainingDoneAlert();
                    },
                  ),
                );
              }
            },
            onLongPress: () async {
              await widget.training.decrementReps();
              if (widget.training.doneReps ==
                  widget.training.requiredReps - 1) {
                await cancelNotifications();
                await scheduleNotifications();
              }
              widget.setHomeState();
            },
            child: Text(
              '${widget.training.doneReps}/${widget.training.requiredReps}',
              style: TextStyle(
                fontSize: widget.textSize * 1.3 * 1.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
