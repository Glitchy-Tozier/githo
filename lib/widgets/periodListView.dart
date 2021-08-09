/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
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

import 'package:githo/config/styleData.dart';
import 'package:githo/helpers/formatDate.dart';
import 'package:githo/widgets/alert_dialogs/confirmTrainingStart.dart';
import 'package:githo/widgets/alert_dialogs/trainingDone.dart';
import 'package:githo/widgets/bottom_sheets/textSheet.dart';
import 'package:githo/widgets/training_cards/countdownCard.dart';
import 'package:githo/widgets/training_cards/gradientTrainingCard.dart';
import 'package:githo/widgets/training_cards/trainingCard.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class PeriodListView extends StatelessWidget {
  final TrainingPeriod trainingPeriod;
  final String stepDescription;
  final Function updateFunction;
  final GlobalKey globalKey;

  /// Creates one of those horizontal training-listViews made out of cards.
  const PeriodListView({
    required this.trainingPeriod,
    required this.stepDescription,
    required this.updateFunction,
    required this.globalKey,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewChildren = [];
    double cardMarginRL = 6;
    int activeTrainingIndex = 9876543210;

    for (int i = 0; i < this.trainingPeriod.trainings.length; i++) {
      final Training training = this.trainingPeriod.trainings[i];

      GlobalKey? key;
      const double textSize = 25;
      double cardWidth = 100;
      double cardHeight = 70;
      cardMarginRL = 6;

      final Widget child;
      Function? onTap; // Usually Null
      final Color color;

      if (this.trainingPeriod.status == "completed") {
        child = const Icon(Icons.check_rounded);
        if (training.status == "successful") {
          color = Colors.green;
        } else if (training.status == "unsuccessful") {
          color = Colors.red;
        } else {
          color = Colors.grey.shade400;
        }
      } else if (this.trainingPeriod.status == "waiting for start") {
        color = Colors.orange;
        if (i == 0) {
          key = this.globalKey;
          cardWidth *= 1.3;
          cardHeight *= 1.3;
          onTap = (final String remainingTime) => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => TextSheet(
                  title: "Waiting for training to start",
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Starting in ",
                        style: StyleData.textStyle,
                      ),
                      TextSpan(
                        text: "$remainingTime\n",
                        style: StyleData.boldTextStyle,
                      ),
                      TextSpan(
                        text: "(On ${formatDate(training.startingDate)})\n\n",
                        style: StyleData.textStyle,
                      ),
                      const TextSpan(
                        text: "To-do: ",
                        style: StyleData.boldTextStyle,
                      ),
                      TextSpan(
                        text: this.stepDescription,
                        style: StyleData.textStyle,
                      ),
                    ],
                  ),
                ),
              );
          listViewChildren.add(
            CountdownCard(
              key: key,
              horizontalMargin: cardMarginRL,
              cardWidth: cardWidth,
              cardHeight: cardHeight,
              startingDate: training.startingDate,
              textSize: textSize,
              updatePrevScreens: updateFunction,
              onTap: onTap,
              color: color,
            ),
          );
          continue;
        } else {
          child = const Icon(Icons.lock_clock);
        }
      } else if (this.trainingPeriod.status == "active") {
        cardWidth *= 1.3;
        cardHeight *= 1.3;
        cardMarginRL *= 1.3;
        if (training.hasPassed) {
          if (training.status == "successful") {
            color = Colors.green;
            child = Text(
              "${training.doneReps}/${training.requiredReps}",
              style: const TextStyle(
                fontSize: textSize * 1.3,
                color: Colors.black,
              ),
            );
          } else if (training.status == "unsuccessful") {
            color = Colors.red;
            child = Text(
              "${training.doneReps}/${training.requiredReps}",
              style: const TextStyle(
                fontSize: textSize * 1.3,
                color: Colors.black,
              ),
            );
          } else {
            color = Colors.grey.shade400;
            child = const Text(
              "Skipped",
              style: TextStyle(
                fontSize: textSize,
                color: Colors.black,
              ),
            );
          }
        } else if (training.isNow) {
          activeTrainingIndex = i;

          key = this.globalKey;
          cardWidth *= 1.3;
          cardHeight *= 1.3;
          if (training.status == "ready") {
            child = const Text(
              "Start training",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: textSize * 1.3,
                color: Colors.white,
              ),
            );
            final Function onConfirmation = () {
              training.activate();
              this.updateFunction();
            };
            onTap = () => showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return ConfirmTrainingStart(
                      title: "Confirm Activation",
                      toDo: this.stepDescription,
                      training: training,
                      onConfirmation: onConfirmation,
                    );
                  },
                );
            listViewChildren.add(
              GradinentTrainingCard(
                key: key,
                horizontalMargin: cardMarginRL,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                child: child,
                onTap: onTap,
              ),
            );
            continue;
          } else {
            child = Text(
              "${training.doneReps}/${training.requiredReps}",
              style: const TextStyle(
                fontSize: textSize * 1.3 * 1.3,
                color: Colors.black,
              ),
            );
            onTap = () {
              training.incrementReps();
              this.updateFunction();
              if (training.doneReps == training.requiredReps) {
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
            };
            if (training.status == "done") {
              color = Colors.lightGreenAccent;
            } else {
              color = Colors.red.shade100;
            }
          }
        } else {
          color = Colors.orange;
          if (i == activeTrainingIndex + 1) {
            listViewChildren.add(
              CountdownCard(
                key: key,
                horizontalMargin: cardMarginRL,
                cardWidth: cardWidth,
                cardHeight: cardHeight,
                startingDate: training.startingDate,
                textSize: textSize,
                updatePrevScreens: updateFunction,
                onTap: onTap,
                color: color,
              ),
            );
            continue;
          } else {
            child = const Icon(Icons.lock_clock);
          }
        }
      } else {
        child = const Icon(Icons.lock);
        color = Colors.grey.shade300;
      }

      listViewChildren.add(
        TrainingCard(
          key: key,
          horizontalMargin: cardMarginRL,
          cardWidth: cardWidth,
          cardHeight: cardHeight,
          child: child,
          onTap: onTap,
          color: color,
        ),
      );
    }

    final ScrollPhysics physics = const BouncingScrollPhysics();
    final Axis scrollDirection = Axis.horizontal;
    final EdgeInsetsGeometry padding = EdgeInsets.symmetric(
      horizontal: StyleData.screenPaddingValue - cardMarginRL,
    );

    final bool activeOrWaiting = this.trainingPeriod.status == "active" ||
        this.trainingPeriod.status == "waiting for start";

    if (activeOrWaiting) {
      // If the trainingPeriod is active or will shortly be active, prevent lazyloading (to enable automatic scrolling).
      return SingleChildScrollView(
        physics: physics,
        scrollDirection: scrollDirection,
        padding: padding,
        child: Row(
          children: listViewChildren,
        ),
      );
    } else {
      // If the trainingPeriod is not active, lazyloading should be used (for performance reasons).
      final TrainingCard firstCard = listViewChildren.first as TrainingCard;
      return SizedBox(
        height: firstCard.height,
        child: ListView(
          physics: physics,
          scrollDirection: scrollDirection,
          padding: padding,
          children: listViewChildren,
        ),
      );
    }
  }
}
