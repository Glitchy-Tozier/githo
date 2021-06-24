import 'package:flutter/material.dart';

import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';

import 'package:githo/extracted_functions/editHabitRoutes.dart';

import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

import 'package:githo/screens/habitDetails.dart';

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

  List<HabitPlan> _orderHabitPlans(List<HabitPlan> habitPlanList) {
    // Order the habitPlans in a way that displays the most cecently edited ones at the top
    habitPlanList.sort((a, b) {
      String dateStringA = a.lastChanged.toString();
      String dateStringB = b.lastChanged.toString();
      return dateStringB.compareTo(dateStringA);
    });
    return habitPlanList;
  }

  Widget _createHabitListItem(HabitPlan habitPlan) {
    return Column(
      children: <Widget>[
        TextButton(
            child: ListTile(
              title: Text(
                habitPlan.goal,
                style: StyleData.textStyle,
              ),
              // subtitle: Text("Subtitle ka okay!!??!"),
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
        children: [
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
                      ScreenTitle(
                        title: "List of habits",
                        subTitle: "Please add a habit plan.",
                      ),
                    );
                  } else {
                    // If there are habit plans
                    returnWidgets.add(
                      ScreenTitle(
                          title: "List of habits",
                          subTitle: "Click on a habit-plan to look at it."),
                    );

                    List<HabitPlan> orderedList =
                        _orderHabitPlans(habitPlanList);

                    for (int i = 0; i < orderedList.length; i++) {
                      Widget listItem = _createHabitListItem(orderedList[i]);
                      returnWidgets.add(listItem);
                    }
                  }
                } else if (snapshot.hasError) {
                  // If something went wrong with the database
                  returnWidgets.add(
                    Heading1("There was an error connecting to the database."),
                  );
                  returnWidgets.add(
                    Text(
                      snapshot.error.toString(),
                      style: StyleData.textStyle,
                    ),
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
