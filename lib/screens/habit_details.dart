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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

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
import 'package:share_plus/share_plus.dart';

class SingleHabitDisplay extends StatefulWidget {
  /// Displays the details of the [habitPlan].
  ///
  /// This includes…
  /// - final habit,
  /// - rules,
  /// - comments,
  /// - and levels.
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
  final ValueNotifier<bool> isDialOpen = ValueNotifier<bool>(false);

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
                'must be successful in order to advance to the next '
                '$periodTimeFrame'),
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
              '$periodTimeFrame$periodEnder required to level up',
        ),
        const SizedBox(
          height: StyleData.listRowSpacing,
        ),
      ],
    );

    return widgetList;
  }

  /// Creates a table that looks like a list of the [levels] of the [habitPlan].
  Table _getLevelTable() {
    final List<TableRow> tableRowList = <TableRow>[];
    final List<String> levels = habitPlan.levels;

    for (int i = 0; i < levels.length; i++) {
      final int levelNr = i + 1;

      tableRowList.add(
        TableRow(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                top: StyleData.listRowSpacing,
              ),
              child: Text(
                levelNr.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyText2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 10,
                top: StyleData.listRowSpacing,
              ),
              child: Text(
                levels[i],
                style: Theme.of(context).textTheme.bodyText2,
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
                  const Heading('Levels'),
                  _getLevelTable(),
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
            WillPopScope(
              onWillPop: () async {
                if (isDialOpen.value) {
                  isDialOpen.value = false;
                  return false;
                } else {
                  return true;
                }
              },
              child: SpeedDial(
                backgroundColor: Colors.orange,
                icon: Icons.settings,
                activeIcon: Icons.close,
                spacing: 4,
                spaceBetweenChildren: 4,

                // Necessary to make the dial close when pressing the
                // back-button. Prevents a crash.
                openCloseDial: isDialOpen,

                overlayColor: Colors.black,
                overlayOpacity: 0.5,

                tooltip: 'Show options',

                animationSpeed: 200,
                switchLabelPosition: true,

                children: <SpeedDialChild>[
                  SpeedDialChild(
                    label: 'Delete',
                    backgroundColor: Colors.red.shade900,
                    labelBackgroundColor: Theme.of(context).backgroundColor,
                    labelStyle: Theme.of(context).textTheme.bodyText2,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext buildContext) => ConfirmDeletion(
                          habitPlan: habitPlan,
                          onConfirmation: widget.updateFunction,
                        ),
                      );
                    },
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                    ),
                  ),
                  SpeedDialChild(
                    label: 'Share',
                    backgroundColor: Colors.lightBlue,
                    labelBackgroundColor: Theme.of(context).backgroundColor,
                    labelStyle: Theme.of(context).textTheme.bodyText2,
                    onTap: () => Share.share(
                      habitPlan.toShareJson(),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                    ),
                  ),
                  SpeedDialChild(
                    label: 'Edit',
                    backgroundColor: Colors.orangeAccent.shade700,
                    labelBackgroundColor: Theme.of(context).backgroundColor,
                    labelStyle: Theme.of(context).textTheme.bodyText2,
                    onTap: () {
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
                    child: const Icon(
                      Icons.edit,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ActivationFAB(
              habitPlan: habitPlan,
              updateFunction: (final HabitPlan changedHabitPlan) {
                widget.updateFunction();
                habitPlan = changedHabitPlan;
              },
            ),
          ],
        ),
      ),
    );
  }
}
