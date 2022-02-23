/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
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
import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/edit_habit_routes.dart';
import 'package:githo/models/habit_plan.dart';

import 'package:githo/screens/habit_details.dart';

import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/list_button.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

class HabitList extends StatefulWidget {
  /// Lists all habit-plans
  const HabitList({
    required this.updateFunction,
    Key? key,
  }) : super(key: key);

  final void Function() updateFunction;

  @override
  _HabitListState createState() => _HabitListState();
}

class _HabitListState extends State<HabitList> {
  late Future<List<HabitPlan>> _habitPlanListFuture;

  @override
  void initState() {
    super.initState();
    _habitPlanListFuture = DatabaseHelper.instance.getHabitPlanList();
  }

  /// Reloads/updates all loaded screens.
  void _updateLoadedScreens() {
    setState(() {
      _habitPlanListFuture = DatabaseHelper.instance.getHabitPlanList();
      widget.updateFunction();
    });
  }

  /// Order the [habitPlanList] in a way that displays the most recently
  /// edited ones at the top.
  List<HabitPlan> _orderHabitPlans(final List<HabitPlan> habitPlanList) {
    habitPlanList.sort((HabitPlan a, HabitPlan b) {
      final String dateStringA = a.lastChanged.toString();
      final String dateStringB = b.lastChanged.toString();
      return dateStringB.compareTo(dateStringA);
    });
    return habitPlanList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: FutureBuilder<List<HabitPlan>>(
          future: _habitPlanListFuture,
          builder:
              (BuildContext context, AsyncSnapshot<List<HabitPlan>> snapshot) {
            if (snapshot.hasData) {
              final List<HabitPlan> habitPlanList = snapshot.data!;
              final List<Widget> columnItems = <Widget>[];

              columnItems.addAll(
                const <Widget>[
                  Padding(
                    padding: StyleData.screenPadding,
                    child: ScreenTitle('Habits'),
                  ),
                  FatDivider(),
                ],
              );

              if (habitPlanList.isEmpty) {
                // If there are no habit plans
                columnItems.add(
                  Expanded(
                    child: Container(
                      padding: StyleData.screenPadding,
                      alignment: Alignment.center,
                      child: const Text(
                        'Add a new habit-plan by clicking on the plus-icon.',
                      ),
                    ),
                  ),
                );
              } else {
                // If habit plans were found in the database
                final List<HabitPlan> orderedHabitPlans =
                    _orderHabitPlans(habitPlanList);

                columnItems.add(
                  Expanded(
                    child: ListView.builder(
                      padding: StyleData.screenPadding,
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: orderedHabitPlans.length + 1,
                      itemBuilder: (BuildContext buildContex, int i) {
                        if (i < orderedHabitPlans.length) {
                          final HabitPlan habitPlan = orderedHabitPlans[i];
                          Color? color;
                          if (habitPlan.fullyCompleted) {
                            color = ThemedColors.gold;
                          } else if (habitPlan.isActive) {
                            color = ThemedColors.green;
                          }
                          return ListButton(
                            text: habitPlan.habit,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute<SingleHabitDisplay>(
                                  builder: (BuildContext context) =>
                                      SingleHabitDisplay(
                                    updateFunction: _updateLoadedScreens,
                                    habitPlan: habitPlan,
                                  ),
                                ),
                              );
                            },
                            color: color,
                          );
                        } else {
                          return const ScreenEndingSpacer();
                        }
                      },
                    ),
                  ),
                );
              }
              return Column(
                children: columnItems,
              );
            } else if (snapshot.hasError) {
              // If connection is done but there was an error:
              print(snapshot.error);
              return Padding(
                padding: StyleData.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Heading(
                      'There was an error connecting to the database.',
                    ),
                    Text(
                      snapshot.error.toString(),
                    ),
                  ],
                ),
              );
            }
            // While loading, do this:
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add new habit-plan',
        backgroundColor: ThemedColors.green,
        heroTag: null,
        onPressed: () {
          addNewHabit(context, _updateLoadedScreens);
        },
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
