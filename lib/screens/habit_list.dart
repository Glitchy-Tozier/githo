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
import 'package:githo/helpers/edit_habit_routes.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/list_button.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/models/habit_plan.dart';

import 'package:githo/screens/habit_details.dart';

class HabitList extends StatefulWidget {
  /// Lists all habit-plans
  const HabitList({required this.updateFunction});

  final Function updateFunction;

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
            if (snapshot.connectionState == ConnectionState.done) {
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
                        child: Text(
                          'Add a new habit-plan by clicking on the plus-icon.',
                          style: Theme.of(context).textTheme.bodyText2,
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
                            final Color color;
                            if (habitPlan.fullyCompleted) {
                              color = Colors.amberAccent;
                            } else if (habitPlan.isActive) {
                              color = Colors.green;
                            } else {
                              color = Theme.of(context).buttonColor;
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
                            return ScreenEndingSpacer();
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
                // If something went wrong with the database
                print(snapshot.error);

                return Padding(
                  padding: StyleData.screenPadding,
                  child: Column(
                    children: <Widget>[
                      const Heading(
                          'There was an error connecting to the database.'),
                      Text(
                        snapshot.error.toString(),
                        style: Theme.of(context).textTheme.bodyText2,
                      ),
                    ],
                  ),
                );
              }
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
        backgroundColor: Colors.green,
        onPressed: () {
          addNewHabit(context, _updateLoadedScreens);
        },
        heroTag: null,
        child: const Icon(
          Icons.add,
        ),
      ),
    );
  }
}
