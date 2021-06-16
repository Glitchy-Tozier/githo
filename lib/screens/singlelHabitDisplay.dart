import 'package:flutter/material.dart';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_functions/editHabitRoutes.dart';
import 'package:githo/extracted_functions/getCurrentStepIndex.dart';
import 'package:githo/extracted_functions/getStatusString.dart';

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
  Future<ProgressData> _progressData =
      DatabaseHelper.instance.getProgressData();

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
      widgetList.add(
        SizedBox(
          height: StyleData.listRowSpacing,
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
    widgetList.addAll([
      CustomListTile(
          leadingWidget: BulletPoint(),
          title: "Perform $timeString a $timeFrame"),
      SizedBox(
        height: StyleData.listRowSpacing,
      ),
    ]);

    const List<int> maxRequired = DataShortcut.maxTrainings;
    final int maxReps = maxRequired[trainingTimeIndex].toInt();
    final int currentReps = this.habitPlan.requiredTrainings.toInt();
    widgetList.addAll([
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$currentReps out of $maxReps ${timeFrame}s must be successful in order to level up"),
      SizedBox(
        height: StyleData.listRowSpacing,
      ),
    ]);

    final int requiredTrainingPeriods =
        this.habitPlan.requiredTrainingPeriods.toInt();
    final String lvlUpEnder = (requiredTrainingPeriods == 1) ? " is" : "s are";
    widgetList.addAll([
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$requiredTrainingPeriods level-up$lvlUpEnder required to progress to the next step"),
      SizedBox(
        height: StyleData.listRowSpacing,
      ),
    ]);

    return widgetList;
  }

  Table _getStepTable(ProgressData progressData) {
    List<TableRow> tableRowList = [];
    final steps = this.habitPlan.steps;
    final int currentStepIndex = getCurrentStepIndex(habitPlan, progressData);

    for (int i = 0; i < steps.length; i++) {
      final int stepNr = i + 1;

      final TextStyle textStyle;
      if ((i == currentStepIndex) && (habitPlan.isActive)) {
        textStyle = StyleData.boldTextStyle;
      } else {
        textStyle = StyleData.textStyle;
      }

      tableRowList.add(
        TableRow(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: StyleData.listRowSpacing),
              child: Text(
                stepNr.toString(),
                textAlign: TextAlign.center,
                style: textStyle,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10, top: StyleData.listRowSpacing),
              child: Text(
                "${steps[i]}",
                style: textStyle,
              ),
            ),
          ],
        ),
      );
    }

    return Table(columnWidths: const <int, TableColumnWidth>{
      0: IntrinsicColumnWidth(),
      1: FlexColumnWidth(),
    }, children: tableRowList);
  }

  FloatingActionButton _variableFloatActButton() {
    void onClickFunc() async {
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
    List<Widget> commentSection;
    if (habitPlan.comments[0] == "") {
      commentSection = [];
    } else {
      commentSection = <Widget>[
        Heading1("Comments"),
        ..._getCommentWidgets(),
      ];
    }

    return Scaffold(
      body: FutureBuilder(
        future: _progressData,
        builder: (context, AsyncSnapshot<ProgressData> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ProgressData progressData = snapshot.data!;
              return ListView(
                padding: StyleData.screenPadding,
                children: [
                  ScreenTitle(
                    title: habitPlan.goal,
                    subTitle: getStatusString(this.habitPlan, progressData),
                  ),
                  Heading1("Rules"),
                  ..._getRuleWidgets(),
                  ...commentSection,
                  Heading1("Steps"),
                  _getStepTable(progressData),
                  ScreenEndingSpacer()
                ],
              );
            } else if (snapshot.hasError) {
              // If something went wrong with the database
              return Column(children: [
                Heading1("There was an error connecting to the database."),
                Text(
                  snapshot.error.toString(),
                  style: StyleData.textStyle,
                ),
              ]);
            }
          }
          // Default return (while loading, for example)
          return Center(
            child: CircularProgressIndicator(),
          );
        },
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
