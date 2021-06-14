import 'package:flutter/material.dart';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleShortcut.dart';

import 'package:githo/extracted_functions/editHabitRoutes.dart';

import 'package:githo/extracted_widgets/bulletPoint.dart';
import 'package:githo/extracted_widgets/customListTile.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

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

  List<Widget> _getCommentWidgets() {
    List<Widget> widgetList = [];

    // Personal Comments
    this.habitPlan.comments.forEach((comment) {
      widgetList.add(
        CustomListTile(
          leadingWidget: BulletPoint(),
          title: comment.toString(),
        ),
      );
    });
    return widgetList;
  }

  List<Widget> _getRuleWidgets() {
    List<Widget> widgetList = [];

    final requiredReps = this.habitPlan.requiredReps;
    final int trainingTimeIndex = this.habitPlan.trainingTimeIndex.toInt();
    final String timeFrame = DataShortcut.timeFrames[trainingTimeIndex];
    final String timeString;
    if (requiredReps == 1) {
      timeString = "once";
    } else if (requiredReps == 2) {
      timeString = "twice";
    } else {
      timeString = "$requiredReps times";
    }
    widgetList.add(
      CustomListTile(
          leadingWidget: BulletPoint(),
          title: "Perform $timeString a $timeFrame"),
    );

    const List<int> maxRequired = DataShortcut.maxTrainings;
    final int maxReps = maxRequired[trainingTimeIndex].toInt();
    final int currentReps = this.habitPlan.requiredTrainings.toInt();
    widgetList.add(
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$currentReps out of $maxReps ${timeFrame}s must be successful in order to level up"),
    );

    final int requiredTrainingPeriods =
        this.habitPlan.requiredTrainingPeriods.toInt();
    final String lvlUpEnder = (requiredTrainingPeriods == 1) ? " is" : "s are";
    widgetList.add(
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$requiredTrainingPeriods level-up$lvlUpEnder required to progress to the next step"),
    );

    return widgetList;
  }

  Future<List<Widget>> _getStepWidgets() async {
    List<Widget> widgetList = [];
    final challenges = this.habitPlan.challenges;
    final ProgressData progressData =
        await DatabaseHelper.instance.getProgressData();

    final int currentStepIndex =
        (progressData.level / habitPlan.requiredTrainingPeriods).ceil();
    print(currentStepIndex);
    for (int i = 0; i < challenges.length; i++) {
      if (i == currentStepIndex) {
        widgetList.add(
          CustomListTile(
            leadingString: "${i + 1}. ",
            title: challenges[i].toString(),
            titleStyle: "bold",
          ),
        );
      } else {
        widgetList.add(
          CustomListTile(
            leadingString: "${i + 1}. ",
            title: challenges[i].toString(),
          ),
        );
      }
    }
    return widgetList;
  }

  FloatingActionButton _variableFloatActButton() {
    void onClickFunc() async {
      print("Was active ${habitPlan.isActive}");
      if (habitPlan.isActive == true) {
        // If the viewed habetPlan was active to begin with, disable it.
        habitPlan.isActive = false;
        await DatabaseHelper.instance.updateHabitPlan(habitPlan);
      } else {
        // If the viewed habitPlan wasn't active, activate it.

        // Mark the old plan as inactive
        List<HabitPlan> activeHabitPlan =
            await DatabaseHelper.instance.getActiveHabitPlan();
        if (activeHabitPlan.length > 0) {
          HabitPlan oldHabitPlan = activeHabitPlan[0];
          oldHabitPlan.isActive = false;
          await DatabaseHelper.instance.updateHabitPlan(oldHabitPlan);
        }

        // Update (and reset) older progressData
        ProgressData progressData =
            await DatabaseHelper.instance.getProgressData();
        DateTime now = DateTime.now();

        progressData.lastActiveDate = now;
        progressData.challengeStartingDate = DateTime(
          now.year,
          now.month,
          now.day + 8 - now.weekday,
        );
        progressData.completedReps = 0;
        progressData.completedTrainings = 0;
        progressData.level = 0;
        await DatabaseHelper.instance.updateProgressData(progressData);

        // Update the plan you're looking at to be active
        habitPlan.isActive = true;
        habitPlan.lastChanged = DateTime.now();
        await DatabaseHelper.instance.updateHabitPlan(habitPlan);
      }
      // Refresh List Screen AND singleHabitDisplay-screen.
      //_updateThisScreen(habitPlan);
      updatePrevScreens();
      Navigator.pop(context);
    }

    Color buttonColor() {
      if (habitPlan.isActive == true) {
        return Colors.black;
      } else {
        return Colors.green;
      }
    }

    return FloatingActionButton(
      child: Icon(
        Icons.grade,
      ),
      backgroundColor: buttonColor(),
      onPressed: () => onClickFunc(),
      heroTag: null,
    );
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
          ..._getRuleWidgets(),
          Heading1("Comments"),
          ..._getCommentWidgets(),
          Heading1("Steps"),
          FutureBuilder(
            future: _getStepWidgets(),
            builder: (context, AsyncSnapshot<List<Widget>> snapshot) {
              List<Widget> returnWidgets = [];
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  List<Widget> widgetList = snapshot.data!;
                  returnWidgets.addAll(widgetList);
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
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return Column(
                children: returnWidgets,
              );
            },
          ),
          //..._getStepWidgets(),
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
              onPressed: () async {
                await DatabaseHelper.instance
                    .deleteHabitPlan(habitPlan.id as int);
                updatePrevScreens();
                Navigator.pop(context);
              },
              heroTag: null,
            ),
            _variableFloatActButton(),
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
