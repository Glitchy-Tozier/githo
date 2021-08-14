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

import 'package:githo/config/style_data.dart';
import 'package:githo/helpers/type_extentions.dart';
import 'package:githo/widgets/bottom_sheets/text_sheet.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/dividers/thin_divider.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/period_list_view.dart';

import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training_period.dart';

class StepToDo extends StatelessWidget {
  /// Create the to-do-section for a whole step.
  /// Used in the [HomeScreen].
  const StepToDo(this.globalKey, this.step, this.updateFunction);

  final StepData step;
  final Function updateFunction;
  final GlobalKey globalKey;

  @override
  Widget build(BuildContext context) {
    // What will be the returned contents
    final List<Widget> colChildren = <Widget>[];

    final Color stepColor;
    switch (step.status) {
      case 'completed':
        stepColor = Colors.green;
        break;
      case 'active':
        stepColor = Colors.orange;
        break;
      default:
        stepColor = Colors.grey.shade300;
    }
    colChildren.addAll(<Widget>[
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
            onTap: () {
              final Color statusColor;
              if (step.status == 'active') {
                statusColor = Colors.orange.shade800;
              } else if (step.status == 'locked') {
                statusColor = Colors.grey.shade800;
              } else {
                statusColor = Colors.green.shade800;
              }

              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => TextSheet(
                  title: 'Step ${step.number}',
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Status: ',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      TextSpan(
                        text: '${step.status}\n\n',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: statusColor,
                            ),
                      ),
                      TextSpan(
                          text: 'To-do: ',
                          style: Theme.of(context).textTheme.bodyText1),
                      TextSpan(
                        text: step.text,
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                ),
              );
            },
            child: Padding(
              padding: StyleData.screenPadding * 0.25,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Heading('Step ${step.number}'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: stepColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Info',
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                  )
                ],
              ),
            ),
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
              '${trainingPeriod.durationText.capitalize()} ${i + 1} '
              'of ${step.trainingPeriods.length}',
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
          stepDescription: step.text,
          updateFunction: updateFunction,
          globalKey: globalKey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colChildren,
    );
  }
}
