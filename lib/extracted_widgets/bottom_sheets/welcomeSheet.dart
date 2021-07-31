import 'package:flutter/material.dart';
import 'package:githo/extracted_data/styleData.dart';
import 'package:githo/extracted_widgets/bottom_sheets/textSheet.dart';
import 'package:githo/models/progressDataModel.dart';
import 'package:githo/models/used_classes/step.dart';
import 'package:githo/models/used_classes/trainingPeriod.dart';

class WelcomeSheet extends StatelessWidget {
  // Returns a bottom sheet that welcomes the user and supplies the most relevant information.

  final ProgressData progressData;
  const WelcomeSheet({required this.progressData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> dataMap;
    final StepData step;
    final TrainingPeriod trainingPeriod;
    final TextSpan text;

    if (progressData.activeData != null) {
      dataMap = progressData.activeData!;
      step = dataMap["step"];
      trainingPeriod = dataMap["trainingPeriod"];
      text = TextSpan(
        children: [
          const TextSpan(
            text: "In ",
            style: StyleData.textStyle,
          ),
          TextSpan(
            text: "Step ${step.number}\n\nTo-do",
            style: StyleData.boldTextStyle,
          ),
          TextSpan(
            text: ": ${step.text}\n\n",
            style: StyleData.textStyle,
          ),
          TextSpan(
            text: "This ${trainingPeriod.durationText}'s progress:",
            style: StyleData.boldTextStyle,
          ),
          TextSpan(
            text:
                " ${trainingPeriod.successfulTrainings} out of ${trainingPeriod.requiredTrainings} trainings completed",
            style: StyleData.textStyle,
          ),
        ],
      );
    } else if (progressData.waitingData != null) {
      dataMap = progressData.waitingData!;
      step = dataMap["step"];
      text = TextSpan(
        children: [
          TextSpan(
            text: "Waiting for step ${step.number} to start.\n\n",
            style: StyleData.textStyle,
          ),
          const TextSpan(
            text: "To-do",
            style: StyleData.boldTextStyle,
          ),
          TextSpan(
            text: ": ${step.text}",
            style: StyleData.textStyle,
          ),
        ],
      );
    } else {
      throw "TimedInfoSheet: All dataMaps are inactive";
    }

    return TextSheet(
      title: "Welcome back",
      text: text,
    );
  }
}
