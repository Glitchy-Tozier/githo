import 'package:flutter/material.dart';
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
    periodWidgets.add(Heading1(step.text));
    double cardRowHeight;

    for (int i = 0; i < step.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = step.trainingPeriods[i];
      if (step.trainingPeriods.length > 1) {
        periodWidgets.add(
          Heading2(
            "${trainingPeriod.durationText} ${i + 1}/${step.trainingPeriods.length} – ${trainingPeriod.status}",
          ),
        );
      }

      List<Widget> listViewChildren = [];

      if (trainingPeriod.status == "completed") {
        cardRowHeight = rowHeight;
        for (final Training training in trainingPeriod.trainings) {
          final Color color;
          if (training.status == "successful") {
            color = Colors.green;
          } else if (training.status == "unsuccessful") {
            color = Colors.red;
          } else {
            color = Colors.grey;
          }
          listViewChildren.add(
            Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Card(
                  color: color,
                  child: Ink(
                    child: InkWell(
                      child: Icon(Icons.check_rounded),
                      splashColor: Colors.red,
                      onTap: () {},
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      } else if (trainingPeriod.status == "active") {
        cardRowHeight = activeRowHeight;
        for (final Training training in trainingPeriod.trainings) {
          if (training.status == "current" ||
              training.status == "active" ||
              training.status == "done") {
            listViewChildren.add(
              Center(
                child: SizedBox(
                  width: cardWidth + 40,
                  height: cardHeight + 40,
                  child: Card(
                    color: (training.status == "done")
                        ? Colors.pink
                        : Colors.white,
                    child: Ink(
                      child: InkWell(
                        child: Text(
                            "${training.doneReps}/${training.requiredReps}\n${training.status}"),
                        splashColor: Colors.purple,
                        onTap: () {
                          training.activate();
                          training.incrementReps();
                          updateFunction();
                        },
                      ),
                    ),
                  ),
                ),
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
              Center(
                child: SizedBox(
                  width: cardWidth,
                  height: cardHeight,
                  child: Card(
                    color: color,
                    child: Ink(
                      child: InkWell(
                        child: Text(training.status),
                        splashColor: Colors.red,
                        onTap: () {},
                      ),
                    ),
                  ),
                ),
              ),
            );
          }
        }
      } else {
        cardRowHeight = rowHeight;
        for (final Training training in trainingPeriod.trainings) {
          listViewChildren.add(
            Center(
              child: SizedBox(
                width: cardWidth,
                height: cardHeight,
                child: Card(
                  color: Colors.grey,
                  child: Ink(
                    child: InkWell(
                      child: Center(child: Icon(Icons.lock)),
                      splashColor: Colors.red,
                      onTap: () {},
                    ),
                  ),
                ),
              ),
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
      children: periodWidgets,
    );
  }
}
