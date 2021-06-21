import 'package:flutter/material.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_functions/catchUpProgressData.dart';
import 'package:githo/extracted_functions/getCurrentStepIndex.dart';
import 'package:githo/extracted_functions/getStatusString.dart';
import 'package:githo/extracted_functions/incrementProgressData.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';

import 'headings.dart';

class ToDoScreen extends StatefulWidget {
  final HabitPlan habitPlan;
  final Future<ProgressData> futureProgressData;

  const ToDoScreen({
    required this.habitPlan,
    required this.futureProgressData,
  });

  @override
  _ToDoScreenState createState() => _ToDoScreenState(
        habitPlan: habitPlan,
        futureProgressData: futureProgressData,
      );
}

class _ToDoScreenState extends State<ToDoScreen> {
  final HabitPlan habitPlan;
  final Future<ProgressData> futureProgressData;

  _ToDoScreenState({
    required this.habitPlan,
    required this.futureProgressData,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: this.futureProgressData,
      builder: (context, AsyncSnapshot<ProgressData> snapshot) {
        if (snapshot.hasData) {
          final ProgressData progressData = snapshot.data!;
          catchUpProgressData(habitPlan, progressData);

          final int stepIndex = getCurrentStepIndex(habitPlan, progressData);
          final String currentStep = habitPlan.steps[stepIndex];
          print(stepIndex);

          final int maxTrainings =
              DataShortcut.maxTrainings[habitPlan.trainingTimeIndex];
          final int requiredTrainingPeriods = habitPlan.requiredTrainingPeriods;
          final int maxTrainingIndexPerStep =
              maxTrainings * requiredTrainingPeriods;

          final int currentTrainingIndex = stepIndex * maxTrainingIndexPerStep +
              progressData.completedTrainings;

          List<Widget> verticalChildren = [];

          // Add the Title
          verticalChildren.add(
            ScreenTitle(
              title: habitPlan.goal,
              subTitle: getStatusString(habitPlan, progressData),
              addBottomPadding: false,
            ),
          );

          int nrOfSteps = habitPlan.steps.length;
          // Go trough every step
          for (int stepIndex = 0; stepIndex < nrOfSteps; stepIndex++) {
            verticalChildren.addAll([
              Heading1("Step ${stepIndex + 1}/$nrOfSteps"),
              Text(
                habitPlan.steps[stepIndex],
                style: StyleData.textStyle,
              ),
            ]);

            // Go trough every training period (for daily habits, that would be a week)
            for (int trainingPeriodIndex = 0;
                trainingPeriodIndex < requiredTrainingPeriods;
                trainingPeriodIndex++) {
              if (requiredTrainingPeriods > 1) {
                verticalChildren.add(
                  Heading2(
                      "Week ${trainingPeriodIndex + 1}/$requiredTrainingPeriods"),
                );
              }

              List<Widget> horizontalChildren = [];
              for (int i = 0; i < maxTrainings; i++) {
                int trainingIndex = stepIndex * maxTrainingIndexPerStep +
                    trainingPeriodIndex * maxTrainings +
                    i;

                final String trainingState =
                    progressData.trainingData[trainingIndex];
                final Color cardColor;
                if (trainingState == "successful") {
                  cardColor = Colors.green;
                } else if (trainingState == "unsuccessful") {
                  cardColor = Colors.red;
                } else {
                  cardColor = Colors.grey;
                }
                final Widget cardChild;
                if (trainingIndex < currentTrainingIndex) {
                  cardChild = SizedBox();
                } else if (trainingIndex == currentTrainingIndex) {
                  cardChild = Ink(
                    color: Colors.white,
                    child: InkWell(
                      splashColor: Colors.blueGrey,
                      child: Text(
                          "${progressData.completedReps}/${habitPlan.requiredReps}"),
                      onTap: () {
                        incrementProgressData(habitPlan, progressData);
                        setState(() {});
                      },
                    ),
                  );
                } else {
                  cardChild = Icon(Icons.lock);
                }
                horizontalChildren.add(
                  Center(
                    child: Card(
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: cardChild,
                      ),
                      color: cardColor,
                      //elevation: 5,
                    ),
                  ),
                );
              }
              verticalChildren.add(
                SizedBox(
                  height: 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: horizontalChildren,
                  ),
                ),
              );
            }
          }
          verticalChildren.add(ScreenEndingSpacer());
          return ListView(
            padding: StyleData.screenPadding,
            children: verticalChildren,
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }
}
