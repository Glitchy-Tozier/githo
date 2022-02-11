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

import 'package:githo/helpers/notification_helper.dart';
import 'package:githo/widgets/dividers/thin_divider.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:githo/config/data_shortcut.dart';
import 'package:githo/config/style_data.dart';
import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/helpers/type_extentions.dart';
import 'package:githo/models/habit_plan.dart';
import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/widgets/background.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';

/// A view that allows users to customize their notification-timing

class NotificationSettings extends StatefulWidget {
  const NotificationSettings(this._progressData, {Key? key}) : super(key: key);
  final ProgressData _progressData;

  @override
  _NotificationSettingsState createState() => _NotificationSettingsState();
}

class _NotificationSettingsState extends State<NotificationSettings> {
  final TextEditingController dateController = TextEditingController();

  final Future<NotificationData> notificationDataFuture =
      DatabaseHelper.instance.getNotificationData();
  final Future<List<HabitPlan>> habitPlanFuture =
      DatabaseHelper.instance.getActiveHabitPlan();

  late bool enabled = false;
  late bool keepNotifyingAfterSuccess = false;
  late DateTime notificationTime = DateTime(0);

  @override
  void initState() {
    super.initState();

    // Update the settings to show their actual values.
    notificationDataFuture.then(
      (final NotificationData notificationData) {
        setState(() {
          enabled = notificationData.isActive;
          keepNotifyingAfterSuccess =
              notificationData.keepNotifyingAfterSuccess;
          if (notificationData.isActive) {
            notificationTime = notificationData.nextActivationDate;
          } else {
            notificationTime = widget._progressData.currentStartingDate;
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          children: <Widget>[
            const ScreenTitle('Notifications'),
            const FatDivider(),
            SwitchListTile(
              contentPadding: StyleData.screenPadding,
              title: const Text('Use notifications'),
              value: enabled,
              onChanged: (final bool enableNotifications) async {
                final NotificationData notificationData =
                    await notificationDataFuture;
                notificationData.isActive = enableNotifications;
                await notificationData.save();
                setState(() {
                  enabled = enableNotifications;
                  if (enableNotifications == true) {
                    initHeadlessNotifications();
                  } else {
                    stopBackgroundTasks();
                  }
                });
              },
            ),
            const ThinDivider(),
            Visibility(
              // Only show the remaining settings if notifications are enabled.
              visible: enabled,
              child: FutureBuilder<List<HabitPlan>>(
                future: habitPlanFuture,
                builder: (
                  BuildContext context,
                  AsyncSnapshot<List<HabitPlan>> snapshot,
                ) {
                  if (snapshot.hasData) {
                    final HabitPlan habitPlan = snapshot.data!.first;
                    final int trainingTimeIndex = habitPlan.trainingTimeIndex;
                    final String trainingDuration =
                        DataShortcut.timeFrames[trainingTimeIndex];
                    final DateTime now = TimeHelper.instance.currentTime;

                    final String notificationTimePrefix;
                    String notificationTimeStr;
                    final Future<DateTime?> Function() selectTime;
                    switch (trainingTimeIndex) {
                      case 0:
                        notificationTimePrefix = 'at';
                        if (notificationTime.minute.toString().length == 1) {
                          notificationTimeStr =
                              'xx:0${notificationTime.minute}';
                        } else {
                          notificationTimeStr = 'xx:${notificationTime.minute}';
                        }
                        selectTime = () async {
                          final TimeOfDay? timeOfDay = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: notificationTime.hour,
                              minute: notificationTime.minute,
                            ),
                          );
                          if (timeOfDay != null) {
                            return now.copyWith(
                              hour: timeOfDay.hour,
                              minute: timeOfDay.minute,
                            );
                          }
                          return null;
                        };
                        break;
                      case 1:
                        notificationTimePrefix = 'at';
                        notificationTimeStr = DateFormat('Hm').format(
                          notificationTime,
                        );
                        selectTime = () async {
                          // Get desired starting-timeOfDay
                          final TimeOfDay? timeOfDay = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: notificationTime.hour,
                              minute: notificationTime.minute,
                            ),
                          );
                          if (timeOfDay != null) {
                            // Turn the TimeOfDay into a DateTime
                            return now.copyWith(
                              hour: timeOfDay.hour,
                              minute: timeOfDay.minute,
                            );
                          }
                          return null;
                        };
                        break;
                      default:
                        notificationTimePrefix = 'on';
                        notificationTimeStr = DateFormat('EEEE, Hm').format(
                          notificationTime,
                        );
                        selectTime = () async {
                          // Get the desired starting-date
                          final DateTime? dateTime = await showDatePicker(
                            context: context,
                            initialDate: notificationTime,
                            firstDate: widget._progressData.currentStartingDate,
                            lastDate: widget._progressData.currentStartingDate
                                .add(const Duration(days: 7)),
                          );
                          if (dateTime != null) {
                            // Get desired starting-timeOfDay
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay(
                                hour: notificationTime.hour,
                                minute: notificationTime.minute,
                              ),
                            );
                            if (timeOfDay != null) {
                              // Turn the TimeOfDay into a DateTime
                              return dateTime.copyWith(
                                hour: timeOfDay.hour,
                                minute: timeOfDay.minute,
                              );
                            }
                          }
                          return null;
                        };
                    }
                    dateController.text = notificationTimeStr;

                    return Column(
                      children: <Widget>[
                        SwitchListTile(
                          contentPadding: StyleData.screenPadding,
                          title: Text(
                            'Keep reminding me every $trainingDuration, '
                            'even after completing the required number '
                            'of trainings',
                          ),
                          value: keepNotifyingAfterSuccess,
                          onChanged: (final bool value) async {
                            final NotificationData notificationData =
                                await notificationDataFuture;
                            notificationData.keepNotifyingAfterSuccess = value;
                            await notificationData.save();
                            setState(() {
                              keepNotifyingAfterSuccess = value;
                              initHeadlessNotifications();
                            });
                          },
                        ),
                        const FatDivider(),
                        Padding(
                          padding: StyleData.screenPadding,
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Every $trainingDuration, you will '
                                      'be notified $notificationTimePrefix ',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                                TextSpan(
                                  text: notificationTimeStr,
                                  style: Theme.of(context).textTheme.headline3,
                                ),
                                TextSpan(
                                  text: ' (± 8 Minutes)',
                                  style: Theme.of(context).textTheme.headline4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: StyleData.screenPadding,
                          child: TextFormField(
                            controller: dateController,
                            decoration: const InputDecoration(
                              labelText: 'Notification Time',
                            ),
                            readOnly: true,
                            onTap: () async {
                              final DateTime? selectedDateTime =
                                  await selectTime();

                              if (selectedDateTime != null) {
                                final NotificationData notificationData =
                                    await notificationDataFuture;
                                notificationData.nextActivationDate =
                                    selectedDateTime;
                                await notificationData.save();
                                setState(() {
                                  notificationTime = selectedDateTime;
                                  initHeadlessNotifications();
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ),
            ScreenEndingSpacer(),
          ],
        ),
      ),
    );
  }
}
