/* 
 * Githo – An app that helps you gradually form long-lasting habits.
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
import 'package:githo/config/custom_widget_themes.dart';

import 'package:githo/config/style_data.dart';
import 'package:githo/helpers/type_extentions.dart';
import 'package:githo/models/used_classes/level.dart';
import 'package:githo/models/used_classes/training_period.dart';
import 'package:githo/widgets/bottom_sheets/text_sheet.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/dividers/thin_divider.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/period_list_view.dart';

class LevelToDo extends StatelessWidget {
  /// Create the to-do-section for a whole [Level].
  /// Used in the [HomeScreen].
  const LevelToDo(this.activeCardKey, this.level);

  final Level level;
  final GlobalKey activeCardKey;

  @override
  Widget build(BuildContext context) {
    // What will be the returned contents
    final List<Widget> colChildren = <Widget>[];

    final Color levelColor;
    switch (level.status) {
      case 'completed':
        levelColor = LevelColors.completed;
        break;
      case 'active':
        levelColor = LevelColors.active;
        break;
      default: // 'locked':
        levelColor = LevelColors.locked;
    }
    colChildren.addAll(<Widget>[
      FatDivider(
        color: levelColor,
      ),
      // The following monstrosity is the title.
      Padding(
        padding: StyleData.screenPadding * 0.75,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            splashColor: levelColor,
            borderRadius: BorderRadius.circular(7),
            onTap: () {
              final Color statusColor;
              if (level.status == 'completed') {
                statusColor = LevelContrastColors.completed;
              } else if (level.status == 'active') {
                statusColor = LevelContrastColors.active;
              } else {
                // status == 'locked'
                statusColor = LevelContrastColors.locked;
              }
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (BuildContext context) => TextSheet(
                  title: 'Level ${level.number}',
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'Status: ',
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                      TextSpan(
                        text: '${level.status}\n\n',
                        style: Theme.of(context).textTheme.bodyText1!.copyWith(
                              color: statusColor,
                            ),
                      ),
                      TextSpan(
                          text: 'To-do: ',
                          style: Theme.of(context).textTheme.bodyText1),
                      TextSpan(
                        text: level.text,
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
                  Heading('Level ${level.number}'),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(7),
                      ),
                    ),
                    child: const Text(
                      'Info',
                      style: TextStyle(
                        fontSize: 30,
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

    for (int i = 0; i < level.trainingPeriods.length; i++) {
      final TrainingPeriod trainingPeriod = level.trainingPeriods[i];

      if (level.trainingPeriods.length > 1) {
        // Add a divider
        if (i > 0) {
          colChildren.add(
            ThinDivider(color: levelColor),
          );
        }

        colChildren.add(
          Padding(
            padding: StyleData.screenPadding,
            child: Text(
              '${trainingPeriod.durationText.capitalize()} ${i + 1} '
              'of ${level.trainingPeriods.length}',
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        );
      }

      colChildren.add(
        PeriodListView(
          trainingPeriod: trainingPeriod,
          levelDescription: level.text,
          activeCardKey: activeCardKey,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: colChildren,
    );
  }
}
