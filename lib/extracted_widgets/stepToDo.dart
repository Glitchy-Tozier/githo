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
  //static const double periodHeadingPadding = 12;

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
        stepColor = Colors.orange;
        break;
      default:
        stepColor = Colors.grey.shade300;
    }
    periodWidgets.addAll([
      FatDivider(
        color: stepColor,
      ),
      Padding(
        padding: StyleData.screenPadding,
        child: InkWell(
          splashColor: stepColor,
          borderRadius: BorderRadius.circular(7),
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
          onTap: () {
            final Color statusColor;
            if (step.status == "active") {
              statusColor = Colors.orange;
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
                  text: "To-do: ${this.step.text}",
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
          periodWidgets.add(ThinDivider(
            color: stepColor,
          ));
        }

        final Widget periodHeading;
        // Add the heading
        /* if (trainingPeriod.status == "active") {
          periodHeading = Padding(
            padding: StyleData.screenPadding,
            child: InkWell(
              splashColor: Colors.orange,
              borderRadius: BorderRadius.circular(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: periodHeadingPadding,
                    ),
                    child: Text(
                      "${trainingPeriod.durationText.capitalize()} ${i + 1} of ${step.trainingPeriods.length}",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
                ],
              ),
              onTap: () {
                final String periodString = (step.trainingPeriods.length > 1)
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
                      title: Text("Step ${this.step.number}$periodString"),
                      text:
                          "$toDoString\n\n$progressString\n\n$remainingString",
                      buttonColor: Colors.orange,
                    );
                  },
                );
              },
            ),
          );
        } else { */
        periodHeading = Padding(
          padding: EdgeInsets.symmetric(
            //vertical: periodHeadingPadding,
            horizontal: StyleData.screenPaddingValue,
          ),
          child: Text(
            "${trainingPeriod.durationText.capitalize()} ${i + 1} of ${step.trainingPeriods.length}",
            style: const TextStyle(
              fontSize: 20,
              color: Colors.black,
            ),
          ),
        );
        //}
        periodWidgets.add(periodHeading);
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
