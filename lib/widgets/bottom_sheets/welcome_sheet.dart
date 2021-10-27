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

import 'package:githo/models/progress_data.dart';
import 'package:githo/models/used_classes/level.dart';
import 'package:githo/models/used_classes/training_period.dart';
import 'package:githo/widgets/bottom_sheets/text_sheet.dart';

class WelcomeSheet extends StatelessWidget {
  /// Returns a bottom sheet that welcomes the user and
  /// supplies the most relevant information.
  const WelcomeSheet({
    required this.progressData,
    Key? key,
  }) : super(key: key);

  final ProgressData progressData;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dataMap;
    final Level level;
    final TrainingPeriod trainingPeriod;
    final TextSpan text;

    if (progressData.activeData != null) {
      dataMap = progressData.activeData!;
      level = dataMap['levels'] as Level;
      trainingPeriod = dataMap['trainingPeriod'] as TrainingPeriod;
      text = TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'In ',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          TextSpan(
            text: 'Level ${level.number}\n\nTo-do',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          TextSpan(
            text: ': ${level.text}\n\n',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          TextSpan(
            text: "This ${trainingPeriod.durationText}'s progress:",
            style: Theme.of(context).textTheme.bodyText1,
          ),
          TextSpan(
            text: ' ${trainingPeriod.successfulTrainings} out of '
                '${trainingPeriod.requiredTrainings} trainings completed',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      );
    } else if (progressData.waitingData != null) {
      dataMap = progressData.waitingData!;
      level = dataMap['levels'] as Level;
      text = TextSpan(
        children: <TextSpan>[
          TextSpan(
            text: 'Waiting for level ${level.number} to start.\n\n',
            style: Theme.of(context).textTheme.bodyText2,
          ),
          TextSpan(
            text: 'To-do',
            style: Theme.of(context).textTheme.bodyText1,
          ),
          TextSpan(
            text: ': ${level.text}',
            style: Theme.of(context).textTheme.bodyText2,
          ),
        ],
      );
    } else {
      throw 'TimedInfoSheet: All dataMaps are inactive';
    }

    return TextSheet(
      title: 'Welcome back',
      text: text,
    );
  }
}
