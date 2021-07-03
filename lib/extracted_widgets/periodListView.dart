import 'dart:async';
import 'package:flutter/material.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/alert_dialogs/textDialog.dart';

import 'package:githo/extracted_widgets/gradientTrainingCard.dart';
import 'package:githo/extracted_widgets/alert_dialogs/confirmTrainingStart.dart';
import 'package:githo/extracted_widgets/alert_dialogs/trainingDone.dart';
import 'package:githo/extracted_widgets/trainingCard.dart';

import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class PeriodListView extends StatelessWidget {
  final TrainingPeriod trainingPeriod;
  final String stepDescription;
  final Function updateFunction;
  final GlobalKey globalKey;
  const PeriodListView({
    required this.trainingPeriod,
    required this.stepDescription,
    required this.updateFunction,
    required this.globalKey,
  });

  String _getDurationDiff(final DateTime dateTime1, final DateTime dateTime2) {
    final Duration difference = dateTime2.difference(dateTime1);
    print(dateTime1);
    print(dateTime2);
    print(difference.inDays);

    if (difference.inDays > 1) {
      return "${difference.inDays} days";
    } else if (difference.inDays == 1) {
      return "${difference.inDays} day";
    } else if (difference.inHours >= 1) {
      return "${difference.inHours} h";
    } else if (difference.inMinutes >= 1) {
      return "${difference.inDays} min";
    } else {
      return "${difference.inSeconds} s";
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewChildren = [];
    double cardMarginRL = 6;

    for (int i = 0; i < trainingPeriod.trainings.length; i++) {
      final Training training = trainingPeriod.trainings[i];

      double textSize = 25;
      double cardWidth = 100;
      double cardHeight = 70;
      cardMarginRL = 6;

      final Widget child;
      Function? onTap; // Usually Null
      final Color color;

      if (trainingPeriod.status == "completed") {
        child = const Icon(Icons.check_rounded);
        if (training.status == "successful") {
          color = Colors.green;
        } else if (training.status == "unsuccessful") {
          color = Colors.red;
        } else {
          color = Colors.grey.shade400;
        }
      } else if (trainingPeriod.status == "waiting for start") {
        textSize *= 0.9;
        cardWidth *= 1.3;
        cardHeight *= 1.3;
        cardMarginRL *= 1.3;

        color = Colors.orange;
        if (i == 0) {
          final String remainingTime = _getDurationDiff(
            DateTime.now(),
            training.startingDate,
          );
          child = Text(
            "Starting in\n$remainingTime",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: textSize,
            ),
          );
          onTap = () => showDialog(
                context: context,
                builder: (BuildContext buildContext) {
                  return TextDialog(
                    title: const Text("Waiting for training to start"),
                    text:
                        "To-do: $stepDescription\n\nRemaining time: $remainingTime",
                    buttonColor: Colors.orange,
                  );
                },
              );
          Timer(
            const Duration(seconds: 1),
            () => updateFunction(),
          );
        } else {
          child = const Icon(Icons.lock_clock);
        }
      } else if (trainingPeriod.status == "active") {
        textSize *= 1.3;
        cardWidth *= 1.3;
        cardHeight *= 1.3;
        cardMarginRL *= 1.3;
        if (training.hasPassed) {
          if (training.status == "successful") {
            color = Colors.green;
            child = Text(
              "${training.doneReps}/${training.requiredReps}",
              style: TextStyle(
                fontSize: textSize * 1.3,
                color: Colors.black,
              ),
            );
          } else if (training.status == "unsuccessful") {
            color = Colors.red;
            child = Text(
              "${training.doneReps}/${training.requiredReps}",
              style: TextStyle(
                fontSize: textSize * 1.3,
                color: Colors.black,
              ),
            );
          } else {
            color = Colors.grey.shade400;
            child = Text(
              "Skipped",
              style: TextStyle(
                fontSize: textSize * 0.9,
                color: Colors.black,
              ),
            );
          }
        } else if (training.isNow) {
          cardWidth *= 1.3;
          cardHeight *= 1.3;
          if (training.status == "current") {
            child = Text(
              "Start training",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: textSize, color: Colors.white),
            );
            final Function onConfirmation = () {
              training.activate();
              updateFunction();
            };
            onTap = () => showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return ConfirmTrainingStart(
                      title: "Confirm Activation",
                      trainingDescription: this.stepDescription,
                      training: training,
                      confirmationFunc: onConfirmation,
                    );
                  },
                );
            color = Colors.orange; // Doesn't do anything.
          } else {
            child = Text(
              "${training.doneReps}/${training.requiredReps}",
              style: TextStyle(
                fontSize: textSize * 1.3,
                color: Colors.black,
              ),
            );
            onTap = () {
              training.incrementReps();
              updateFunction();
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
          child = const Icon(Icons.lock_clock);
          color = Colors.orange;
        }
      } else {
        child = const Icon(Icons.lock);
        color = Colors.grey.shade300;
      }

      if (training.isNow) {
        if (training.status == "current") {
          listViewChildren.add(
            GradinentTrainingCard(
              key: globalKey,
              horizontalMargin: cardMarginRL,
              width: cardWidth,
              height: cardHeight,
              child: child,
              onTap: onTap,
            ),
          );
        } else {
          listViewChildren.add(
            TrainingCard(
              key: globalKey,
              horizontalMargin: cardMarginRL,
              width: cardWidth,
              height: cardHeight,
              child: child,
              onTap: onTap,
              color: color,
            ),
          );
        }
      } else {
        listViewChildren.add(
          TrainingCard(
            horizontalMargin: cardMarginRL,
            width: cardWidth,
            height: cardHeight,
            child: child,
            onTap: onTap,
            color: color,
          ),
        );
      }
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(
        horizontal: StyleData.screenPaddingValue - cardMarginRL,
      ),
      child: Row(
        children: listViewChildren,
      ),
    );
  }
}
