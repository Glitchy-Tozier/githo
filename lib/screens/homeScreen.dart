import 'package:flutter/material.dart';
import 'package:githo/extracted_functions/getDurationDiff.dart';
import 'package:githo/extracted_widgets/alert_dialogs/confirmTrainingStart.dart';
import 'package:githo/extracted_widgets/alert_dialogs/trainingDone.dart';
import 'package:githo/extracted_widgets/backgroundWidget.dart';
import 'package:githo/extracted_widgets/bottom_sheets/textSheet.dart';
import 'package:githo/extracted_widgets/bottom_sheets/welcomeSheet.dart';
import 'package:githo/extracted_widgets/screenEndingSpacer.dart';
import 'package:githo/extracted_widgets/stepToDo.dart';

import 'package:githo/helpers/timeHelper.dart';
import 'package:githo/extracted_data/dataShortcut.dart';
import 'package:githo/extracted_data/fullDatabaseImport.dart';
import 'package:githo/extracted_data/styleData.dart';

import 'package:githo/extracted_widgets/headings.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/training.dart';

import 'package:githo/screens/habitList.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<ProgressData> _progressData;
  bool initialLoad = true;

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

  void _updateDbAndScreen() async {
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
        } else {
          print("\nGlobalKey is null\n");
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: FutureBuilder(
          future: _progressData,
          builder: (context, AsyncSnapshot<ProgressData> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                ProgressData progressData = snapshot.data!;
                if (progressData.isActive == false) {
                  initialLoad = false;
                  // If connection is done but no habitPlan is active:
                  final double screenHeight =
                      MediaQuery.of(context).size.height;
                  return Padding(
                    padding: EdgeInsets.only(
                      top: screenHeight * 0.25,
                      right: StyleData.screenPaddingValue,
                      left: StyleData.screenPaddingValue,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const <Widget>[
                        Heading("No habit-plan is active."),
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

                    if (initialLoad == true) {
                      WidgetsBinding.instance?.addPostFrameCallback(
                        (_) => showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) =>
                              WelcomeSheet(progressData: progressData),
                        ),
                      );
                    }
                  }
                  initialLoad = false;

                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    children: <Widget>[
                      Padding(
                        padding: StyleData.screenPadding,
                        child: ScreenTitle(
                          title: progressData.goal,
                        ),
                      ),
                      Column(
                        // This column exists to make sure all trainings are being cached. (= to disable lazyloading)
                        children: [
                          ...List.generate(progressData.steps.length, (i) {
                            final StepClass step = progressData.steps[i];
                            return StepToDo(
                              globalKey,
                              step,
                              _updateDbAndScreen,
                            );
                          }),
                        ],
                      ),
                      ScreenEndingSpacer(),
                    ],
                  );
                }
              } else if (snapshot.hasError) {
                initialLoad = false;

                // If connection is done but there was an error:
                print(snapshot.error);
                return Padding(
                  padding: StyleData.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
            return Center(
              child: const CircularProgressIndicator(),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: StyleData.floatingActionButtonPadding,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            FloatingActionButton(
              tooltip: "Go to settings",
              child: const Icon(
                Icons.settings,
                color: Colors.white,
              ),
              backgroundColor: Colors.orange,
              heroTag: null,
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
            FutureBuilder(
              future: this._progressData,
              builder: (context, AsyncSnapshot<ProgressData> snapshot) {
                if (snapshot.hasData) {
                  final ProgressData progressData = snapshot.data!;
                  if (progressData.isActive && DataShortcut.testing) {
                    return SizedBox(
                      height: 55,
                      width: 150,
                      child: InkWell(
                        splashColor: Colors.purple,
                        onTap: () {
                          TimeHelper.instance.timeTravel(progressData);

                          print("Start ${progressData.currentStartingDate}");
                          print("Now   ${TimeHelper.instance.getTime}\n");

                          setState(() {});
                        },
                        onLongPress: () {
                          TimeHelper.instance.superTimeTravel(progressData);

                          print("Start ${progressData.currentStartingDate}");
                          print("Now   ${TimeHelper.instance.getTime}\n");
                        },
                      ),
                    );
                  }
                }
                return const SizedBox();
              },
            ),
            FutureBuilder(
              future: this._progressData,
              builder: (context, AsyncSnapshot<ProgressData> snapshot) {
                if (snapshot.hasData) {
                  final ProgressData progressData = snapshot.data!;
                  if (progressData.isActive) {
                    final Map<String, dynamic>? activeMap =
                        progressData.activeData;

                    final IconData icon;
                    final Function onClickFunc;

                    if (activeMap == null) {
                      icon = Icons.timelapse;

                      onClickFunc = () {
                        final Map<String, dynamic> waitingMap =
                            progressData.waitingData!;

                        final Training training = waitingMap["training"];
                        final StepClass step = waitingMap["step"];
                        final String stepDescription = step.text;

                        final String remainingTime = getDurationDiff(
                          DateTime.now(),
                          training.startingDate,
                        );
                        showModalBottomSheet(
                          context: context,
                          backgroundColor: Colors.transparent,
                          builder: (context) => TextSheet(
                            headingString: "Waiting for training to start",
                            textSpan: TextSpan(
                              children: [
                                const TextSpan(
                                  text: "Starting in ",
                                  style: StyleData.textStyle,
                                ),
                                TextSpan(
                                  text: "$remainingTime.\n\nTo-do: ",
                                  style: StyleData.boldTextStyle,
                                ),
                                TextSpan(
                                  text: stepDescription,
                                  style: StyleData.textStyle,
                                ),
                              ],
                            ),
                          ),
                        );
                      };
                    } else {
                      icon = Icons.done;

                      onClickFunc = () {
                        final Training activeTraining = activeMap["training"];
                        final StepClass activeStep = activeMap["step"];
                        if (activeTraining.status == "current") {
                          showDialog(
                            context: context,
                            builder: (BuildContext buildContext) {
                              return ConfirmTrainingStart(
                                title: "Confirm Activation",
                                trainingDescription: activeStep.text,
                                training: activeTraining,
                                confirmationFunc: () {
                                  activeTraining.activate();
                                  _updateDbAndScreen();
                                },
                              );
                            },
                          );
                        } else {
                          activeTraining.incrementReps();
                          if (activeTraining.doneReps ==
                              activeTraining.requiredReps) {
                            showDialog(
                              context: context,
                              builder: (BuildContext buildContext) {
                                return TrainingDoneAlert();
                              },
                            );
                          }
                        }
                        _updateDbAndScreen();
                      };
                    }
                    return FloatingActionButton(
                      tooltip: "Mark step as done",
                      backgroundColor: Colors.green,
                      child: Icon(
                        icon,
                        color: Colors.white,
                      ),
                      heroTag: null,
                      onPressed: () {
                        onClickFunc();
                        _scrollToActiveTraining();
                      },
                    );
                  }
                }
                return const SizedBox();
              },
            ),
          ],
        ),
      ),
    );
  }
}
