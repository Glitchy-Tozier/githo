import 'package:flutter/material.dart';

import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_functions/editHabitRoutes.dart';
import 'package:githo/extracted_widgets/activationFAB.dart';

import 'package:githo/extracted_widgets/bulletPoint.dart';
import 'package:githo/extracted_widgets/customListTile.dart';
import 'package:githo/extracted_widgets/confirmDeletion.dart';
import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

class SingleHabitDisplay extends StatefulWidget {
  final Function updateFunction;
  final HabitPlan habitPlan;

  const SingleHabitDisplay({
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
    final List<Widget> widgetList = [];

    // Personal Comments
    this.habitPlan.comments.forEach((comment) {
      widgetList.add(
        CustomListTile(
          leadingWidget: BulletPoint(),
          title: comment.toString(),
        ),
      );
      widgetList.add(
        const SizedBox(
          height: StyleData.listRowSpacing,
        ),
      );
    });
    return widgetList;
  }

  List<Widget> _getRuleWidgets() {
    final List<Widget> widgetList = [];

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
      const SizedBox(
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
              "$currentReps out of $maxReps ${timeFrame}s must be successful in order to advance"),
      SizedBox(
        height: StyleData.listRowSpacing,
      ),
    ]);

    final int requiredTrainingPeriods =
        this.habitPlan.requiredTrainingPeriods.toInt();
    final String weekEnder = (requiredTrainingPeriods == 1) ? " is" : "s are";
    widgetList.addAll([
      CustomListTile(
          leadingWidget: BulletPoint(),
          title:
              "$requiredTrainingPeriods successful week$weekEnder required to progress to the next step"),
      const SizedBox(
        height: StyleData.listRowSpacing,
      ),
    ]);

    return widgetList;
  }

  Table _getStepTable(ProgressData progressData) {
    final List<TableRow> tableRowList = [];
    final steps = this.habitPlan.steps;
    //final int currentStepIndex = getCurrentStepIndex(habitPlan, progressData);

    for (int i = 0; i < steps.length; i++) {
      final int stepNr = i + 1;

      final TextStyle textStyle;
      /* if ((i == currentStepIndex) && (habitPlan.isActive)) {
        textStyle = StyleData.boldTextStyle;
      } else { */
      textStyle = StyleData.textStyle;
      //}

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

    return Table(
      columnWidths: const <int, TableColumnWidth>{
        0: IntrinsicColumnWidth(),
        1: FlexColumnWidth(),
      },
      children: tableRowList,
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
    final List<Widget> commentSection;
    if (habitPlan.comments[0] == "") {
      commentSection = const <Widget>[];
    } else {
      commentSection = <Widget>[
        const Heading1("Comments"),
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
                    //subTitle: getStatusString(progressData),
                  ),
                  const Heading1("Rules"),
                  ..._getRuleWidgets(),
                  ...commentSection,
                  const Heading1("Steps"),
                  _getStepTable(progressData),
                  ScreenEndingSpacer()
                ],
              );
            } else if (snapshot.hasError) {
              // If something went wrong with the database
              return Column(children: [
                const Heading1(
                    "There was an error connecting to the database."),
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
              child: const Icon(
                Icons.delete,
              ),
              backgroundColor: Colors.red,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext buildContext) => ConfirmDeletion(
                    habitPlan,
                    updatePrevScreens,
                  ),
                );
              },
              heroTag: null,
            ),
            ActivationFAB(
              habitPlan: habitPlan,
              updateFunction: () => setState(() => updatePrevScreens()),
            ),
            FloatingActionButton(
              child: const Icon(
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
