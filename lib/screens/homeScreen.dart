import 'package:flutter/material.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';
import 'package:githo/extracted_widgets/stepToDo.dart';

import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/models/used_classes/step.dart';

import 'package:githo/screens/habitList.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProgressData> _progressData;

  final GlobalKey globalKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    _reloadScreen();
  }

  void _reloadScreen() {
    setState(() {
      _progressData = DatabaseHelper.instance.getProgressData();
      if (DataShortcut.testing) {
        TimeHelper.instance.setTime(DateTime.now());
      }
      _scrollToActiveTraining(delay: 1);
    });
  }

  /* Widget _getToDoScreen(HabitPlan habitPlan) {
    return FutureBuilder(
      future: this._progressData,
      builder: (context, AsyncSnapshot<ProgressData> snapshot) {
        if (snapshot.hasData) {
          final ProgressData progressData = snapshot.data!;

          final int stepIndex = getCurrentStepIndex(habitPlan, progressData);
          final String currentStep = habitPlan.steps[stepIndex];

          return Ink(
            width: double.infinity,
            color: (progressData.completedReps < habitPlan.requiredReps)
                ? Colors.white
                : Colors.green,
            child: InkWell(
              splashColor: (progressData.completedReps < habitPlan.requiredReps)
                  ? Colors.green
                  : Colors.lightGreenAccent,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      InkWell(
                        splashColor: Colors.orangeAccent,
                        child: Container(
                          padding: StyleData.screenPadding,
                          child: ScreenTitle(
                            title: habitPlan.goal,
                            subTitle: getStatusString(habitPlan, progressData),
                            addBottomPadding: false,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleHabitDisplay(
                                updateFunction: _reloadScreen,
                                habitPlan: habitPlan,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: StyleData.screenPadding,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (habitPlan.requiredReps == 1)
                            ? SizedBox()
                            : Text(
                                "${progressData.completedReps}/${habitPlan.requiredReps}",
                                style: StyleData.textStyle,
                              ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Icon(
                            Icons.done,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          currentStep,
                          style: StyleData.textStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              onTap: () {
                setState(() {
                  catchUpProgressData(_habitPlan, _progressData);
                  incrementProgressData(habitPlan, progressData);
                });
              },
            ),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  } */

  void updateDbAndScreen() async {
    DatabaseHelper.instance.updateProgressData(await this._progressData);
    setState(() {});
  }

  void _scrollToActiveTraining({final int delay = 0}) {
    // Scroll to the active Training, if there is one.
    Future.delayed(
      Duration(seconds: delay),
      () {
        if (globalKey.currentContext != null) {
          Scrollable.ensureVisible(
            globalKey.currentContext!,
            duration: const Duration(seconds: 1),
            alignment: 0.5,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: _progressData,
        builder: (context, AsyncSnapshot<ProgressData> snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              ProgressData progressData = snapshot.data!;
              if (progressData.isActive == false) {
                // If connection is done but no habitPlan is active:
                double screenHeight = MediaQuery.of(context).size.height;
                return Container(
                  padding: EdgeInsets.only(
                    top: screenHeight * 0.25,
                    right: StyleData.screenPaddingValue,
                    left: StyleData.screenPaddingValue,
                  ),
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Heading1("No habit-plan is active."),
                      Text(
                        "Click on the settings-icon to add or activate your habit-plan",
                        style: StyleData.textStyle,
                      ),
                    ],
                  ),
                );
              } else {
                // If connection is done and there is an active habitPlan:
                final bool somethingChanged = progressData.updateTime();
                if (somethingChanged) {
                  _scrollToActiveTraining();
                }

                return SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Column(
                    children: <Widget>[
                      ScreenTitle(
                        title: progressData.goal,
                        //subTitle: getStatusString(progressData),
                      ),
                      ...List.generate(progressData.steps.length, (i) {
                        final StepClass step = progressData.steps[i];
                        return StepToDo(globalKey, step, updateDbAndScreen);
                      }),
                      ScreenEndingSpacer(),
                    ],
                  ),
                );
              }
            } else if (snapshot.hasError) {
              // If connection is done but there was an error:
              print(snapshot.error);
              return Center(
                child: Column(
                  children: [
                    Heading1("There was an error connecting to the database."),
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
              tooltip: "Go to settings",
              child: Icon(Icons.settings),
              backgroundColor: Colors.orange,
              heroTag: null, //"settingsHero",
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HabitList(
                      updateFunction: _reloadScreen,
                    ),
                  ),
                );
              },
            ),
            (DataShortcut.testing)
                ? FloatingActionButton(
                    backgroundColor: Colors.transparent,
                    splashColor: Colors.purple,
                    elevation: 0,
                    onPressed: () async {
                      final ProgressData progressData = await _progressData;
                      TimeHelper.instance.timeTravel(progressData);

                      print("Start ${progressData.currentStartingDate}");
                      print("Last  ${progressData.lastActiveDate}");
                      print("Now   ${TimeHelper.instance.getTime}");

                      setState(() {});
                    },
                  )
                : SizedBox(),
            FutureBuilder(
              future: this._progressData,
              builder: (context, AsyncSnapshot<ProgressData> snapshot) {
                if (snapshot.hasData) {
                  final ProgressData progressData = snapshot.data!;
                  if (progressData.isActive) {
                    return FloatingActionButton(
                      tooltip: "Mark step as done",
                      child: Icon(Icons.done),
                      heroTag: null,
                      onPressed: () {
                        //progressData.incrementData();
                        //setState(() {});
                        _scrollToActiveTraining();
                      },
                    );
                  }
                }
                return SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
