import 'package:flutter/material.dart';

import 'package:githo/extracted_data/styleData.dart';

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

  @override
  Widget build(BuildContext context) {
    final List<Widget> listViewChildren = [];
    double cardMarginRL = 6;

    for (final Training training in trainingPeriod.trainings) {
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
          if (training.status == "current") {
            cardWidth *= 1.3;
            cardHeight *= 1.3;
            child = Text(
              "Start training",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: textSize),
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
            color = Colors.amberAccent;
          } else {
            cardWidth *= 1.3;
            cardHeight *= 1.3;
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
                showDialog(
                  context: context,
                  builder: (BuildContext buildContext) {
                    return TrainingDoneAlert();
                  },
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
          color = Colors.amberAccent;
        }
      } else {
        child = const Icon(Icons.lock);
        color = Colors.grey.shade300;
      }

      if (training.isNow) {
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
