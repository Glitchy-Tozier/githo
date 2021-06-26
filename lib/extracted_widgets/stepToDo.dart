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
    double cardWidth = 100;
    double activeCardWidth = 130;

    double cardHeight = 70;
    double activeCardHeight = 90;

    double cardMarginRL = 6;

    if (step.isActive) {
      cardWidth *= 1.3;
      activeCardWidth *= 1.3;

      cardHeight *= 1.3;
      activeCardHeight *= 1.3;

      cardMarginRL *= 1.3;
    }

    List<Widget> periodWidgets = [];
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
            ),
          ),
        );
      }

      List<Widget> listViewChildren = [];

      for (final Training training in trainingPeriod.trainings) {
        if (trainingPeriod.status == "completed") {
          final Color color;
          if (training.status == "successful") {
            color = Colors.green;
          } else if (training.status == "unsuccessful") {
            color = Colors.red;
          } else {
            color = Colors.grey;
          }

          listViewChildren.add(
            CustomCard(
              margin: cardMarginRL,
              width: cardWidth,
              height: cardHeight,
              child: Icon(Icons.check_rounded),
              onTap: null,
              color: color,
            ),
          );
        } else if (trainingPeriod.status == "active") {
          final Widget child;
          final Function onTap;
          if (training.status == "current") {
            child = Heading1(
              "Click to\nactivate",
            );
            final Function onConfirmation = () {
              training.activate();
              updateFunction();
            };

            listViewChildren.add(
              CustomCard(
                key: globalKey,
                margin: cardMarginRL,
                width: activeCardWidth,
                height: activeCardHeight,
                child: child,
                onTap: () => showDialog(
                  context: context,
                  builder: (BuildContext buildContext) => ConfirmTrainingStart(
                    title: "Confirm Activation",
                    trainingDescription: step.text,
                    confirmationFunc: onConfirmation,
                  ),
                ),
                color: Colors.white,
              ),
            );
          } else if (training.status == "active" || training.status == "done") {
            child = Heading1("${training.doneReps}/${training.requiredReps}");
            onTap = () {
              training.incrementReps();
              updateFunction();
            };
            final Color color;
            if (training.status == "done") {
              color = Colors.pink;
            } else {
              color = Colors.white;
            }
            listViewChildren.add(
              CustomCard(
                key: globalKey,
                margin: cardMarginRL,
                width: activeCardWidth,
                height: activeCardHeight,
                child: child,
                onTap: onTap,
                color: color,
              ),
            );
          } else {
            final Color color;
            if (training.status == "successful") {
              color = Colors.green;
            } else if (training.status == "unsuccessful") {
              color = Colors.red;
            } else {
              color = Colors.grey;
            }

            listViewChildren.add(
              CustomCard(
                margin: cardMarginRL,
                width: cardWidth,
                height: cardHeight,
                child: Text(training.status),
                onTap: null,
                color: color,
              ),
            );
          }
        } else {
          listViewChildren.add(
            CustomCard(
              margin: cardMarginRL,
              width: cardWidth,
              height: cardHeight,
              child: Icon(Icons.lock),
              onTap: null,
              color: Colors.grey,
            ),
          );
        }
      }

      periodWidgets.add(
        SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(
            left: StyleData.screenPaddingValue / 2,
            right: StyleData.screenPaddingValue / 2,
          ),
          child: Row(
            children: listViewChildren,
          ),
        ),
      );
      /* periodWidgets.add(
        SizedBox(
          height: cardRowHeight,
          child: ListView(
            physics: BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            children: listViewChildren,
          ),
        ),
      ); */
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: periodWidgets,
    );
  }
}
