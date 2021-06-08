import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleShortcut.dart';
import 'package:githo/extracted_functions/editHabitRoutes.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/screens/singlelHabitDisplay.dart';

import 'package:githo/extracted_widgets/screenTitle.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlan_model.dart';

class HabitList extends StatefulWidget {
  final Function updateFunction;
  HabitList({required this.updateFunction});
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

  String _getActiveHabitPlanName(List<HabitPlan> habitPlanList) {
    String returnText = "";

    for (int i = 0; i < habitPlanList.length; i++) {
      final HabitPlan habitPlan = habitPlanList[i];
      if (habitPlan.isActive) {
        if (returnText == "") {
          returnText = "Goal: ${habitPlan.goal}";
        } else {
          // If somehow multiple habitPlans are active at the same time
          return "There has been an error. Multiple goals are active at the same time.";
        }
      }
    }
    if (returnText == "") {
      // If there is no active habitPlan
      returnText =
          "No challenges are active. Click on a challenge to activate it.";
    }
    return returnText;
  }

  Widget _createHabitListItem(List<HabitPlan> habitPlanList, int index) {
    HabitPlan habitPlan = habitPlanList[index];
    return Column(
      children: <Widget>[
        TextButton(
            child: ListTile(
              title: Text(habitPlan.goal), //"Titel der Challenge"),
              subtitle: Text("Subtitle ka okay!!??!"),
              trailing: Icon(Icons.visibility),
              tileColor: habitPlan.isActive ? Colors.lightGreen : null,
            ),
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
            }),
        Divider(color: Colors.black),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: StyleData.screenPadding,
        children: <Widget>[
          ScreenTitle("List of habits"),
          FutureBuilder(
            future: _habitPlanListFuture,
            builder: (context, AsyncSnapshot<List<HabitPlan>> snapshot) {
              List<Widget> returnWidgets = [];
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  List<HabitPlan> habitPlanList = snapshot.data!;

                  if (habitPlanList.length == 0) {
                    // If there are no habit plans
                    returnWidgets.add(
                      Heading1("Please add a habit plan."),
                    );
                  } else {
                    // If there are habit plans
                    String activePlanHeading1 =
                        _getActiveHabitPlanName(habitPlanList);
                    returnWidgets.add(
                      Text(activePlanHeading1),
                    );

                    for (int i = 0; i < habitPlanList.length; i++) {
                      Widget listItem = _createHabitListItem(habitPlanList, i);
                      returnWidgets.add(listItem);
                    }
                  }
                } else if (snapshot.hasError) {
                  // If something went wrong with the database
                  returnWidgets.add(
                    Heading1("There was an error connecting to the database."),
                  );
                  returnWidgets.add(
                    Text(snapshot.error.toString()),
                  );
                  print(snapshot.error);
                }
              } else {
                // While loading, do this:
                returnWidgets.add(
                  Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return Column(
                children: returnWidgets,
              );
            },
          ),
          ScreenEndingSpacer(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          addNewHabit(context, _updateLoadedScreens);
        },
        heroTag: null,
      ),
    );
  }
}
