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

import 'package:flutter/material.dart';

import 'package:githo/config/styleData.dart';
import 'package:githo/helpers/typeExtentions.dart';
import 'package:githo/widgets/bottom_sheets/textSheet.dart';
import 'package:githo/widgets/dividers/fatDivider.dart';
import 'package:githo/widgets/dividers/thinDivider.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/periodListView.dart';

import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class StepToDo extends StatelessWidget {
  final StepData step;
  final Function updateFunction;
  final GlobalKey globalKey;

  /// Create the to-do-section for a whole step.
  /// Used in the [HomeScreen].
  const StepToDo(this.globalKey, this.step, this.updateFunction);

  @override
  Widget build(BuildContext context) {
    final List<Widget> colChildren = []; // What will be the returned contents

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
    colChildren.addAll([
      FatDivider(
        color: stepColor,
      ),
      // The following monstrosity is the title.
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
                      style: TextStyle(
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
                  title: "Step ${step.number}",
                  text: TextSpan(
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
          colChildren.add(
            ThinDivider(color: stepColor),
          );
        }

        colChildren.add(
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

      colChildren.add(
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
      children: colChildren,
    );
  }
}
