import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/confirmTrainingStart.dart';
import 'package:githo/extracted_widgets/customCard.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class StepToDo extends StatelessWidget {
  final StepClass step;
  final Function updateFunction;
  final GlobalKey globalKey;

  const StepToDo(this.globalKey, this.step, this.updateFunction);

  @override
  Widget build(BuildContext context) {
    double textSize = 25;

    double cardWidth = 100;
    double cardHeight = 70;
    double cardMarginRL = 6;

    if (step.isActive) {
      textSize *= 1.3;

      cardWidth *= 1.3;
      cardHeight *= 1.3;
      cardMarginRL *= 1.3;
    }
    //double activeTrainingNr = double.infinity;

    final List<Widget> periodWidgets = [];
    periodWidgets.add(
      Padding(
        padding: StyleData.screenPadding,
        child: Heading1(step.text),
      ),
    );

    for (int i = 0; i < step.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = step.trainingPeriods[i];

      if (step.trainingPeriods.length > 1) {
        periodWidgets.add(
          Padding(
            padding: StyleData.screenPadding,
            child: Heading2(
              "${trainingPeriod.durationText} ${i + 1}/${step.trainingPeriods.length}",
              //style: TextStyle(fontSize: textSize),
            ),
          ),
        );
      }

      final List<Widget> listViewChildren = [];

      for (final Training training in trainingPeriod.trainings) {
        Key key = ObjectKey(training.number);
        double width = cardWidth;
        double height = cardHeight;
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
            key = globalKey;
            // = training.number.toDouble();

            if (training.status == "current") {
              width *= 1.3;
              height *= 1.3;
              child = Text(
                "Click to\nactivate",
                style: TextStyle(fontSize: textSize),
              );
              final Function onConfirmation = () {
                training.activate();
                updateFunction();
              };
              onTap = () => showDialog(
                    context: context,
                    builder: (BuildContext buildContext) =>
                        ConfirmTrainingStart(
                      title: "Confirm Activation",
                      trainingDescription: step.text,
                      confirmationFunc: onConfirmation,
                    ),
                  );
              color = Colors.amberAccent;
            } else {
              key = globalKey;
              width *= 1.3;
              height *= 1.3;
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

        listViewChildren.add(
          CustomCard(
            key: key,
            margin: cardMarginRL,
            width: width,
            height: height,
            child: child,
            onTap: onTap,
            color: color,
          ),
        );
      }

      periodWidgets.add(
        SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(
            left: StyleData.screenPaddingValue / 2,
            right: StyleData.screenPaddingValue / 2,
          ),
          child: Row(
            children: listViewChildren,
          ),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: periodWidgets,
    );
  }
}
