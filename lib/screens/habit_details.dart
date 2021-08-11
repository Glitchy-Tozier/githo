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

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/config/style_data.dart';
import 'package:githo/helpers/edit_habit_routes.dart';

import 'package:githo/widgets/activation_fab.dart';
import 'package:githo/widgets/alert_dialogs/confirm_edit.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/bullet_point.dart';
import 'package:githo/widgets/custom_list_tile.dart';
import 'package:githo/widgets/alert_dialogs/confirm_deletion.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

import 'package:githo/models/habit_plan.dart';

class SingleHabitDisplay extends StatefulWidget {
  /// Displays the details of the [habitPlan].
  ///
  /// This includes…
  /// - final habit,
  /// - rules,
  /// - comments,
  /// - and steps.
  const SingleHabitDisplay({
    required this.updateFunction,
    required this.habitPlan,
  });

  final Function updateFunction;
  final HabitPlan habitPlan;

  @override
  _SingleHabitDisplayState createState() => _SingleHabitDisplayState();
}

class _SingleHabitDisplayState extends State<SingleHabitDisplay> {
  late HabitPlan habitPlan;

  @override
  void initState() {
    super.initState();
    habitPlan = widget.habitPlan;
  }

  /// Returns a list-item for each comment in the [habitPlan].
  List<Widget> _getCommentWidgets() {
    final List<Widget> widgetList = <Widget>[];

    // Personal Comments
    for (final String comment in habitPlan.comments) {
      widgetList.addAll(
        <Widget>[
          CustomListTile(
            leadingWidget: BulletPoint(),
            title: comment,
          ),
          const SizedBox(
            height: StyleData.listRowSpacing,
          ),
        ],
      );
    }
    return widgetList;
  }

  /// Returns a list-item for each rule in the [habitPlan].
  List<Widget> _getRuleWidgets() {
    final List<Widget> widgetList = <Widget>[];

    final int requiredReps = habitPlan.requiredReps;
    final int trainingTimeIndex = habitPlan.trainingTimeIndex.toInt();
    final String trainingTimeFrame = DataShortcut.timeFrames[trainingTimeIndex];
    final String periodTimeFrame =
        DataShortcut.timeFrames[trainingTimeIndex + 1];
    final String amountString;
    if (requiredReps == 1) {
      amountString = 'once';
    } else if (requiredReps == 2) {
      amountString = 'twice';
    } else {
      amountString = '$requiredReps times';
    }
    final String timeFrameStr;
    if (trainingTimeFrame == 'hour') {
      timeFrameStr = 'an $trainingTimeFrame';
    } else {
      timeFrameStr = 'a $trainingTimeFrame';
    }
    widgetList.addAll(
      <Widget>[
        CustomListTile(
            leadingWidget: BulletPoint(),
            title: 'Perform $amountString $timeFrameStr'),
        const SizedBox(
          height: StyleData.listRowSpacing,
        ),
      ],
    );

    const List<int> maxRequired = DataShortcut.maxTrainings;
    final int maxReps = maxRequired[trainingTimeIndex].toInt();
    final int currentReps = habitPlan.requiredTrainings.toInt();
    widgetList.addAll(
      <Widget>[
        CustomListTile(
            leadingWidget: BulletPoint(),
            title: '$currentReps out of $maxReps ${trainingTimeFrame}s '
                'must be successful in order to advance'),
        const SizedBox(
          height: StyleData.listRowSpacing,
        ),
      ],
    );

    final int requiredTrainingPeriods =
        habitPlan.requiredTrainingPeriods.toInt();
    final String periodEnder = (requiredTrainingPeriods == 1) ? ' is' : 's are';
    widgetList.addAll(
      <Widget>[
        CustomListTile(
          leadingWidget: BulletPoint(),
          title: '$requiredTrainingPeriods successful '
              '$periodTimeFrame$periodEnder required to progress '
              'to the next step',
        ),
        const SizedBox(
          height: StyleData.listRowSpacing,
        ),
      ],
    );

    return widgetList;
  }

  /// Creates a table that looks like a list of the [steps] of the [habitPlan].
  Table _getStepTable() {
    final List<TableRow> tableRowList = <TableRow>[];
    final List<String> steps = habitPlan.steps;

    for (int i = 0; i < steps.length; i++) {
      final int stepNr = i + 1;

      tableRowList.add(
        TableRow(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: StyleData.listRowSpacing,
              ),
              child: Text(
                stepNr.toString(),
                textAlign: TextAlign.center,
                style: StyleData.textStyle,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: StyleData.listRowSpacing,
              ),
              child: Text(
                steps[i],
                style: StyleData.textStyle,
              ),
            ),
          ],
        ),
      );
    }

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: tableRowList,
    );
  }

  /// Reloads/updates all loaded screens.
  void _updateLoadedScreens(final HabitPlan changedHabitPlan) {
    setState(() {
      habitPlan = changedHabitPlan;
      widget.updateFunction();
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> commentSection;
    if (habitPlan.comments[0] == '') {
      commentSection = const <Widget>[];
    } else {
      commentSection = <Widget>[
        const FatDivider(),
        Padding(
          padding: StyleData.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Heading('Comments'),
              ..._getCommentWidgets(),
            ],
          ),
        ),
      ];
    }

    return Scaffold(
      body: Background(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          children: <Widget>[
            Padding(
              padding: StyleData.screenPadding,
              child: ScreenTitle(habitPlan.habit),
            ),
            const FatDivider(),
            Padding(
              padding: StyleData.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Heading('Rules'),
                  ..._getRuleWidgets(),
                ],
              ),
            ),
            ...commentSection,
            const FatDivider(),
            Padding(
              padding: StyleData.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Heading('Steps'),
                  _getStepTable(),
                ],
              ),
            ),
            ScreenEndingSpacer(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              tooltip: 'Delete habit-plan',
              backgroundColor: Colors.red,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext buildContext) => ConfirmDeletion(
                    habitPlan: habitPlan,
                    onConfirmation: widget.updateFunction,
                  ),
                );
              },
              heroTag: null,
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            ActivationFAB(
              habitPlan: habitPlan,
              updateFunction: (final HabitPlan changedHabitPlan) {
                widget.updateFunction();
                habitPlan = changedHabitPlan;
              },
            ),
            FloatingActionButton(
              tooltip: 'Edit habit-plan',
              backgroundColor: Colors.orange,
              onPressed: () {
                if (habitPlan.isActive) {
                  showDialog(
                    context: context,
                    builder: (BuildContext buildContext) => ConfirmEdit(
                      onConfirmation: () => editHabit(
                        context,
                        _updateLoadedScreens,
                        habitPlan,
                      ),
                    ),
                  );
                } else {
                  editHabit(
                    context,
                    _updateLoadedScreens,
                    habitPlan,
                  );
                }
              },
              heroTag: null,
              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            )
          ],
        ),
      ),
    );
  }
}
