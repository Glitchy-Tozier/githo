import 'package:flutter/material.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/typeExtentions.dart';
import 'package:githo/extracted_widgets/bottom_sheets/textSheet.dart';
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
        padding: StyleData.screenPadding * 0.75,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: stepColor,
            borderRadius: BorderRadius.circular(7),
            child: Padding(
              padding: StyleData.screenPadding * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Heading("Step ${step.number}"),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
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
            ),
            onTap: () {
              final Color statusColor;
              if (step.status == "active") {
                statusColor = Colors.orange.shade800;
              } else if (step.status == "locked") {
                statusColor = Colors.grey.shade800;
              } else {
                statusColor = Colors.green.shade800;
              }

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) => TextSheet(
                  headingString: "Step ${step.number}",
                  textSpan: TextSpan(
                    children: [
                      const TextSpan(
                        text: "Status: ",
                        style: StyleData.textStyle,
                      ),
                      TextSpan(
                        text: "${step.status}\n\n",
                        style: coloredBoldTextStyle(statusColor),
                      ),
                      const TextSpan(
                          text: "To-do: ", style: StyleData.boldTextStyle),
                      TextSpan(
                        text: this.step.text,
                        style: StyleData.textStyle,
                      ),
                    ],
                  ),
                ),
              );

              /* showDialog(
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
              ); */
            },
          ),
        ),
      ),
    ]);

    for (int i = 0; i < step.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = step.trainingPeriods[i];

      if (step.trainingPeriods.length > 1) {
        // Add a divider
        if (i > 0) {
          periodWidgets.add(
            ThinDivider(color: stepColor),
          );
        }

        periodWidgets.add(
          Padding(
            padding: StyleData.screenPadding,
            child: Text(
              "${trainingPeriod.durationText.capitalize()} ${i + 1} of ${step.trainingPeriods.length}",
              style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ),
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
