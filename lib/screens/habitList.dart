import 'package:flutter/material.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/editHabitRoutes.dart';
import 'package:githo/extracted_widgets/backgroundWidget.dart';
import 'package:githo/extracted_widgets/buttonListItem.dart';
import 'package:githo/extracted_widgets/dividers/fatDivider.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlanModel.dart';

import 'package:githo/screens/habitDetails.dart';

class HabitList extends StatefulWidget {
  // List all habit-plans
  final Function updateFunction;
  const HabitList({required this.updateFunction});

  @override
  _HabitListState createState() =>
      _HabitListState(updatePrevScreens: updateFunction);
}

class _HabitListState extends State<HabitList> {
  final Function updatePrevScreens;
  late Future<List<HabitPlan>> _habitPlanListFuture;

  _HabitListState({
    required this.updatePrevScreens,
  });

  @override
  void initState() {
    super.initState();
    _habitPlanListFuture = DatabaseHelper.instance.getHabitPlanList();
  }

  void _updateLoadedScreens() {
    setState(() {
      _habitPlanListFuture = DatabaseHelper.instance.getHabitPlanList();
      updatePrevScreens();
    });
  }

  List<HabitPlan> _orderHabitPlans(final List<HabitPlan> habitPlanList) {
    // Order the habitPlans in a way that displays the most cecently edited ones at the top
    habitPlanList.sort((a, b) {
      final String dateStringA = a.lastChanged.toString();
      final String dateStringB = b.lastChanged.toString();
      return dateStringB.compareTo(dateStringA);
    });
    return habitPlanList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: FutureBuilder(
          future: _habitPlanListFuture,
          builder: (context, AsyncSnapshot<List<HabitPlan>> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final List<HabitPlan> habitPlanList = snapshot.data!;
                final List<Widget> columnItems = [];

                columnItems.addAll(
                  const <Widget>[
                    Padding(
                      padding: StyleData.screenPadding,
                      child: ScreenTitle("Habits"),
                    ),
                    FatDivider(),
                  ],
                );

                if (habitPlanList.length == 0) {
                  // If there are no habit plans
                  columnItems.add(
                    Expanded(
                      child: Container(
                        padding: StyleData.screenPadding,
                        alignment: Alignment.center,
                        child: const Text(
                          "Add a new habit-plan by clicking on the plus-icon.",
                          style: StyleData.textStyle,
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
                            return ButtonListItem(
                              text: habitPlan.habit,
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SingleHabitDisplay(
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
                  mainAxisAlignment: MainAxisAlignment.start,
                );
              } else if (snapshot.hasError) {
                // If something went wrong with the database
                print(snapshot.error);

                return Padding(
                  padding: StyleData.screenPadding,
                  child: Column(
                    children: [
                      const Heading(
                          "There was an error connecting to the database."),
                      Text(
                        snapshot.error.toString(),
                        style: StyleData.textStyle,
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
        tooltip: "Add new habit-plan",
        backgroundColor: Colors.green,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
        onPressed: () {
          addNewHabit(context, _updateLoadedScreens);
        },
        heroTag: null,
      ),
    );
  }
}
