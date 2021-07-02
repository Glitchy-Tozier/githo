import 'package:flutter/material.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';
import 'package:githo/extracted_widgets/alert_dialogs/textDialog.dart';
import 'package:githo/extracted_widgets/dividers/fatDivider.dart';
import 'package:githo/extracted_widgets/dividers/thinDivider.dart';
import 'package:githo/extracted_widgets/periodListView.dart';
import 'package:githo/extracted_widgets/headings.dart';

import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class StepToDo extends StatelessWidget {
  final StepClass step;
  final Function updateFunction;
  final GlobalKey globalKey;

  const StepToDo(this.globalKey, this.step, this.updateFunction);

  @override
  Widget build(BuildContext context) {
    final List<Widget> periodWidgets = []; // What will be the returned contents

    final Color stepColor;
    switch (step.status) {
      case "completed":
        stepColor = Colors.green;
        break;
      case "active":
        stepColor = Colors.amberAccent;
        break;
      default:
        stepColor = Colors.grey.shade300;
    }
    periodWidgets.addAll([
      FatDivider(),
      Padding(
        padding: StyleData.screenPadding,
        child: TextButton(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Heading("Step ${step.number}"),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                child: const Text(
                  "Info",
                  style: const TextStyle(
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                decoration: BoxDecoration(
                  color: stepColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(7),
                  ),
                ),
              )
            ],
          ),
          onPressed: () {
            final Color statusColor;
            if (step.status == "active") {
              statusColor = Colors.amber.shade600;
            } else if (step.status == "locked") {
              statusColor = Colors.grey.shade700;
            } else {
              statusColor = stepColor;
            }

            showDialog(
              context: context,
              builder: (BuildContext buildContext) {
                return TextDialog(
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Step ${step.number}"),
                      Text(
                        step.status,
                        style: TextStyle(color: statusColor),
                      )
                    ],
                  ),
                  text: "ToDo: ${this.step.text}",
                  buttonColor: stepColor,
                );
              },
            );
          },
        ),
      ),
    ]);

    for (int i = 0; i < step.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = step.trainingPeriods[i];

      if (step.trainingPeriods.length > 1) {
        // Add a divider
        if (i > 0) {
          periodWidgets.add(ThinDivider());
        }

        // Add the heading
        periodWidgets.add(
          Padding(
            padding: StyleData.screenPadding,
            child: TextButton(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${trainingPeriod.durationText.capitalize()} ${i + 1} of ${step.trainingPeriods.length}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                    (trainingPeriod.status == "active")
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 5),
                            child: const Text(
                              "Info",
                              style: const TextStyle(
                                fontSize: 20,
                                color: Colors.black,
                              ),
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(7),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
              onPressed: (trainingPeriod.status == "active")
                  ? () {
                      final String periodString = (step.trainingPeriods.length >
                              1)
                          ? ", ${trainingPeriod.durationText.capitalize()} ${trainingPeriod.number}"
                          : "";

                      final String toDoString = "ToDo: ${this.step.text}";
                      final String progressString =
                          "Progress: ${trainingPeriod.successfulTrainings} out of ${trainingPeriod.requiredTrainings} trainings have been successful";
                      final int remainingTrainings =
                          trainingPeriod.requiredTrainings -
                              trainingPeriod.successfulTrainings;
                      final String remainingString =
                          "Remaining: $remainingTrainings more trainings progress";

                      showDialog(
                        context: context,
                        builder: (BuildContext buildContext) {
                          return TextDialog(
                            title:
                                Text("Step ${this.step.number}$periodString"),
                            text:
                                "$toDoString\n\n$progressString\n\n$remainingString",
                            buttonColor: Colors.orange,
                          );
                        },
                      );
                    }
                  : null,
            ),
          ),
        );
      }

      periodWidgets.add(
        PeriodListView(
          trainingPeriod: trainingPeriod,
          stepDescription: this.step.text,
          updateFunction: this.updateFunction,
          globalKey: this.globalKey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: periodWidgets,
    );
  }
}
