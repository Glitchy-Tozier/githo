/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2022 Florian Thaler
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';

import 'package:githo/config/custom_widget_themes.dart';
import 'package:githo/config/data_shortcut.dart';
import 'package:githo/helpers/notification_helper.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/screens/notification_settings.dart';
import 'package:githo/widgets/alert_dialogs/base_dialog.dart';

class NotificationDialogue extends StatefulWidget {
  /// Returns a dialog that asks 'Do you really want to edit the habit-plan?'
  const NotificationDialogue({
    Key? key,
    required this.habitPlan,
    required this.progressData,
    required this.onConfirmation,
  }) : super(key: key);

  final HabitPlan habitPlan;
  final ProgressData progressData;
  final void Function() onConfirmation;

  @override
  State<NotificationDialogue> createState() => _NotificationDialogueState();
}

class _NotificationDialogueState extends State<NotificationDialogue> {
  final TextEditingController dateController = TextEditingController();
  NotificationData notificationData = NotificationData.emptyData();

  @override
  void initState() {
    super.initState();
    setState(() {
      notificationData = NotificationData.fromHabitPlan(widget.habitPlan);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int trainingTimeIndex = widget.habitPlan.trainingTimeIndex;
    final String trainingDuration = DataShortcut.timeFrames[trainingTimeIndex];
    final DateTime notificationTime = notificationData.nextActivationDate;
    final TimeStrings timeStrings =
        TimeStrings(trainingTimeIndex, notificationTime);

    final String notificationTimePrefix = timeStrings.prefix;
    final String notificationTimeStr = timeStrings.text;
    dateController.text = notificationTimeStr;

    final Future<DateTime?> Function() selectTime = getSelectTime(
      context,
      trainingTimeIndex,
      notificationTime,
      widget.progressData,
    );

    return BaseDialog(
      title: const Text(
        'Notifications',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use notifications'),
              value: notificationData.isEnabled,
              onChanged: (final bool value) async {
                setState(() {
                  notificationData.isEnabled = value;
                });
              },
            ),
            Visibility(
              visible: notificationData.isEnabled,
              child: Column(
                children: <Widget>[
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: <TextSpan>[
                        TextSpan(
                          text: 'Every $trainingDuration, you will '
                              'be notified $notificationTimePrefix ',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                        TextSpan(
                          text: notificationTimeStr,
                          style: Theme.of(context).textTheme.bodyText1,
                        ),
                        TextSpan(
                          text: '.',
                          style: Theme.of(context).textTheme.bodyText2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: dateController,
                    decoration: const InputDecoration(
                      labelText: 'Notification Time',
                    ),
                    readOnly: true,
                    onTap: () async {
                      final DateTime? selectedDateTime = await selectTime();

                      if (selectedDateTime != null) {
                        notificationData.nextActivationDate = selectedDateTime;
                        setState(() {});
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <ElevatedButton>[
            ElevatedButton.icon(
              icon: const Icon(
                Icons.cancel,
              ),
              label: Text(
                'Cancel',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.orange),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton.icon(
              icon: const Icon(
                Icons.edit,
              ),
              label: Text(
                'Start',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      color: Colors.white,
                    ),
              ),
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(ThemedColors.green),
              ),
              onPressed: () async {
                Navigator.pop(context); // Pop dialog

                await widget.progressData.save(); // Save ProgressData
                await notificationData.save(); // Save NotificationData

                // Set up notifications
                await notificationData.updateActivationDate();
                await scheduleNotifications();

                widget.onConfirmation();
              },
            ),
          ],
        ),
      ],
    );
  }
}
