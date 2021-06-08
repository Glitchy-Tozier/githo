import 'package:flutter/material.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/styleShortcut.dart';
import 'package:githo/extracted_functions/editHabitRoutes.dart';
import 'package:githo/extracted_widgets/bulletPoint.dart';
import 'package:githo/extracted_widgets/customListTile.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

import 'package:githo/extracted_widgets/screenTitle.dart';
import 'package:githo/helpers/databaseHelper.dart';
import 'package:githo/models/habitPlan_model.dart';

class SingleHabitDisplay extends StatefulWidget {
  final Function updateFunction;
  final HabitPlan habitPlan;

  SingleHabitDisplay({
    required this.updateFunction,
    required this.habitPlan,
  });

  @override
  _SingleHabitDisplayState createState() => _SingleHabitDisplayState(
        updatePrevScreens: this.updateFunction,
        habitPlan: this.habitPlan,
      );
}

class _SingleHabitDisplayState extends State<SingleHabitDisplay> {
  final Function updatePrevScreens;
  HabitPlan habitPlan;

  _SingleHabitDisplayState({
    required this.updatePrevScreens,
    required this.habitPlan,
  });

  List<Widget> _prepareRuleWidgets() {
    List<Widget> widgetList = [];
    final int timeIndex = this.habitPlan.timeIndex.toInt();

    // Personal Rules
    this.habitPlan.rules.forEach((rule) {
      widgetList.add(
        CustomListTile(
          leadingWidget: BulletPoint(),
          title: rule.toString(),
        ),
      );
    });

    // Checked rules
    final reps = this.habitPlan.reps;
    const List<String> timeFrames = DataShortcut.timeFrames;
    final String timeFrame = timeFrames[timeIndex];
    final String timeString;
    if (reps == 1) {
      timeString = "Once";
    } else if (reps == 2) {
      timeString = "Twice";
    } else {
      timeString = "$reps times";
    }
    widgetList.add(
      CustomListTile(
          leadingWidget: BulletPoint(), title: "$timeString a $timeFrame"),
    );

    const List<double> maxRequired = DataShortcut.maxActivity;
    final int maxReps = maxRequired[timeIndex].toInt();
    final int currentReps = this.habitPlan.activity.toInt();
    widgetList.add(
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$currentReps out of $maxReps ${timeFrame}s must be successful in order to level up"),
    );

    final int requiredRepeats = this.habitPlan.requiredRepeats.toInt();
    final String lvlUpEnder = (requiredRepeats == 1) ? " is" : "s are";
    widgetList.add(
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$requiredRepeats level-up$lvlUpEnder required to progress to the next challenge"),
    );

    return widgetList;
  }

  List<Widget> _prepareChallengeWidgets() {
    List<Widget> widgetList = [];
    final challenges = this.habitPlan.challenges;

    for (int i = 0; i < challenges.length; i++) {
      widgetList.add(
        CustomListTile(
          leadingString: "${i + 1}. ",
          title: challenges[i].toString(),
        ),
      );
    }

    return widgetList;
  }

  void _updateLoadedScreens(HabitPlan changedHabitPlan) {
    setState(() {
      this.habitPlan = changedHabitPlan;
      updatePrevScreens();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: StyleData.screenPadding,
        children: [
          ScreenTitle(habitPlan.goal),
          Heading1("Rules"),
          ..._prepareRuleWidgets(),
          Heading1("Challenges"),
          ..._prepareChallengeWidgets(),
          ScreenEndingSpacer()
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              child: Icon(
                Icons.delete,
              ),
              backgroundColor: Colors.red,
              onPressed: () {
                DatabaseHelper.instance.deleteHabitPlan(habitPlan.id as int);
                updatePrevScreens();
                Navigator.pop(context);
              },
              heroTag: null,
            ),
            Visibility(
              visible: (habitPlan.isActive == true) ? false : true,
              child: FloatingActionButton(
                child: Icon(
                  Icons.grade,
                ),
                backgroundColor: Colors.green,
                onPressed: () {
                  // Update the database
                  Future<List<HabitPlan>> activeHabitPlanFuture =
                      DatabaseHelper.instance.getActiveHabitPlan();

                  activeHabitPlanFuture.then((activeHabitPlan) {
                    if (activeHabitPlan.length > 0) {
                      // Mark the old plan as inactive
                      HabitPlan oldHabitPlan = activeHabitPlan[0];
                      oldHabitPlan.isActive = false;
                      DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
                    }
                    // Update the plan you're looking at to be active
                    habitPlan.isActive = true;
                    DatabaseHelper.instance.updateHabitPlan(habitPlan);

                    // Refresh List Screen AND singleHabitDisplay-screen.
                    //_updateThisScreen(habitPlan);
                    updatePrevScreens();
                    Navigator.pop(context);
                  });
                },
                heroTag: null,
              ),
            ),
            FloatingActionButton(
              child: Icon(
                Icons.edit,
              ),
              backgroundColor: Colors.orange,
              onPressed: () {
                editHabit(
                  context,
                  _updateLoadedScreens,
                  habitPlan,
                );
              },
              heroTag: null,
            )
          ],
        ),
      ),
    );
  }
}
