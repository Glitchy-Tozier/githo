import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/customCard.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class StepToDo extends StatelessWidget {
  final StepClass step;
  final Function updateFunction;
  const StepToDo(this.step, this.updateFunction);

  final double cardWidth = 100;
  final double activeCardWidth = 130;

  final double cardHeight = 70;
  final double activeCardHeight = 90;

  final double rowHeight = 80;
  final double activeRowHeight = 100;

  @override
  Widget build(BuildContext context) {
    List<Widget> periodWidgets = [];
    periodWidgets.add(Padding(
      padding: StyleData.screenPadding,
      child: Heading1(step.text),
    ));
    double cardRowHeight = rowHeight;

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
              width: cardWidth,
              height: cardHeight,
              child: Icon(Icons.check_rounded),
              onTap: () {},
              color: color,
            ),
          );
        } else if (trainingPeriod.status == "active") {
          cardRowHeight = activeRowHeight;
          if (training.status == "current" ||
              training.status == "active" ||
              training.status == "done") {
            final Color color;
            if (training.status == "done") {
              color = Colors.pink;
            } else {
              color = Colors.white;
            }
            listViewChildren.add(
              CustomCard(
                width: activeCardWidth,
                height: activeCardHeight,
                child: Text(training.startingDate.toString()),
                /* child: Text(
                    "${training.doneReps}/${training.requiredReps}\n${training.status}"), */
                onTap: () {
                  training.activate();
                  training.incrementReps();
                  updateFunction();
                },
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
                width: cardWidth,
                height: cardHeight,
                child: Text(training.startingDate.toString()),

                //child: Text(training.status),
                onTap: () {},
                color: color,
              ),
            );
          }
        } else {
          listViewChildren.add(
            CustomCard(
              width: cardWidth,
              height: cardHeight,
              child: Text(training.startingDate.toString()),

//              child: Icon(Icons.lock),
              onTap: () {},
              color: Colors.grey,
            ),
          );
        }
      }
      periodWidgets.add(
        SizedBox(
          height: cardRowHeight,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
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
