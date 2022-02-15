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
import 'package:githo/helpers/notification_helper.dart';
import 'package:githo/widgets/alert_dialogs/minute_picker.dart';
import 'package:githo/widgets/dialogs/date_picker.dart';
import 'package:githo/widgets/dialogs/time_picker.dart';
import 'package:githo/widgets/dividers/fat_divider.dart';
import 'package:githo/widgets/dividers/thin_divider.dart';
import 'package:githo/widgets/headings/heading.dart';
import 'package:githo/widgets/headings/screen_title.dart';
import 'package:githo/widgets/screen_ending_spacer.dart';

/// A class that enables us to return two string-values from a function.
class TimeStrings {
  TimeStrings(
    final int trainingTimeIdx,
    final DateTime notificationTime,
  )   : prefix = getPrefix(trainingTimeIdx, notificationTime),
        text = getText(trainingTimeIdx, notificationTime);

  static String getPrefix(
    final int trainingTimeIdx,
    final DateTime notificationTime,
  ) {
    switch (trainingTimeIdx) {
      case 0:
        return 'at';

      case 1:
        return 'at';
      default:
        return 'on';
    }
  }

  static String getText(
    final int trainingTimeIdx,
    final DateTime notificationTime,
  ) {
    switch (trainingTimeIdx) {
      case 0:
        return notificationTime.minute.toString().length == 1
            ? 'XX:0${notificationTime.minute}'
            : 'XX:${notificationTime.minute}';
      case 1:
        return DateFormat('Hm').format(notificationTime);
      default:
        return '${DateFormat('EEEE').format(notificationTime)}, '
            '${DateFormat('Hm').format(notificationTime)}';
    }
  }

  final String prefix;
  final String text;
}

Future<DateTime?> Function() getSelectTime(
  final BuildContext context,
  final int trainingTimeIdx,
  final DateTime notificationTime,
  final ProgressData progressData,
) {
  final DateTime now = TimeHelper.instance.currentTime;
  switch (trainingTimeIdx) {
    case 0:
      return () async {
        TimeOfDay timeOfDay = TimeOfDay(
          hour: 0,
          minute: notificationTime.minute,
        );
        await showDialog(
          context: context,
          builder: (BuildContext buildContext) => MinutePicker(
            initialTime: timeOfDay,
            resultCallback: (final TimeOfDay newTime) => timeOfDay = newTime,
          ),
        );
        return now.copyWith(
          hour: timeOfDay.hour,
          minute: timeOfDay.minute,
        );
      };
    case 1:
      return () async {
        // Get desired starting-timeOfDay
        final TimeOfDay? timeOfDay = await showDialog(
          context: context,
          builder: (BuildContext buildContext) => TimePicker(
            initialTime: TimeOfDay(
              hour: notificationTime.hour,
              minute: notificationTime.minute,
            ),
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
    default:
      return () async {
        // Get the desired starting-date
        final DateTime? dateTime = await showDialog(
          context: context,
          builder: (BuildContext buildContext) => DatePicker(
            initialDate: notificationTime,
            firstDate: progressData.currentStartingDate,
            lastDate: progressData.currentStartingDate.add(
              const Duration(days: 7),
            ),
          ),
        );
        if (dateTime != null) {
          // Get desired starting-timeOfDay
          final TimeOfDay? timeOfDay = await showDialog(
            context: context,
            builder: (BuildContext buildContext) => TimePicker(
              initialTime: TimeOfDay(
                hour: notificationTime.hour,
                minute: notificationTime.minute,
              ),
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
}

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: FutureBuilder<NotificationData>(
          future: notificationDataFuture,
          builder:
              (BuildContext context, AsyncSnapshot<NotificationData> snapshot) {
            if (snapshot.hasData) {
              final NotificationData notificationData = snapshot.data!;
              return Column(
                children: <Widget>[
                  const ScreenTitle('Notifications'),
                  const FatDivider(),
                  SwitchListTile(
                    contentPadding: StyleData.screenPadding,
                    title: const Text('Use notifications'),
                    value: notificationData.isEnabled,
                    onChanged: (final bool value) async {
                      notificationData.isEnabled = value;
                      await notificationData.save();
                      setState(() {
                        if (value == true) {
                          scheduleNotifications();
                        } else {
                          cancelNotifications();
                        }
                      });
                    },
                  ),
                  const ThinDivider(),
                  Visibility(
                    // Only show the remaining settings if notifications are
                    // enabled.
                    visible: notificationData.isEnabled,
                    child: FutureBuilder<List<HabitPlan>>(
                      future: habitPlanFuture,
                      builder: (
                        BuildContext context,
                        AsyncSnapshot<List<HabitPlan>> snapshot,
                      ) {
                        if (snapshot.hasData) {
                          final HabitPlan habitPlan = snapshot.data!.first;
                          final int trainingTimeIndex =
                              habitPlan.trainingTimeIndex;
                          final String trainingDuration =
                              DataShortcut.timeFrames[trainingTimeIndex];

                          final TimeStrings timeStrings = TimeStrings(
                            trainingTimeIndex,
                            notificationData.nextActivationDate,
                          );
                          final String notificationTimePrefix =
                              timeStrings.prefix;
                          final String notificationTimeStr = timeStrings.text;
                          dateController.text = notificationTimeStr;

                          final Future<DateTime?> Function() selectTime =
                              getSelectTime(
                            context,
                            trainingTimeIndex,
                            notificationData.nextActivationDate,
                            widget._progressData,
                          );

                          return Column(
                            children: <Widget>[
                              SwitchListTile(
                                contentPadding: StyleData.screenPadding,
                                title: Text(
                                  'Keep reminding me every $trainingDuration, '
                                  'even after completing the required number '
                                  'of trainings',
                                ),
                                value:
                                    notificationData.keepNotifyingAfterSuccess,
                                onChanged: (final bool value) async {
                                  notificationData.keepNotifyingAfterSuccess =
                                      value;
                                  await notificationData.save();
                                  setState(() {
                                    cancelNotifications();
                                    scheduleNotifications();
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
                                        text:
                                            'Every $trainingDuration, you will '
                                            'be notified '
                                            '$notificationTimePrefix ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
                                      ),
                                      TextSpan(
                                        text: notificationTimeStr,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline3,
                                      ),
                                      TextSpan(
                                        text: '.',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline4,
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
                                      notificationData.nextActivationDate =
                                          selectedDateTime;
                                      await notificationData.save();
                                      setState(() {
                                        cancelNotifications();
                                        scheduleNotifications();
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          // If connection is done but there was an error:
                          print(snapshot.error);
                          return Padding(
                            padding: StyleData.screenPadding,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                const Heading(
                                  'There was an error connecting '
                                  'to the database.',
                                ),
                                Text(
                                  snapshot.error.toString(),
                                ),
                              ],
                            ),
                          );
                        }
                        // While loading, do this:
                        return const SizedBox();
                      },
                    ),
                  ),
                  ScreenEndingSpacer(),
                ],
              );
            } else if (snapshot.hasError) {
              // If connection is done but there was an error:
              print(snapshot.error);
              return Padding(
                padding: StyleData.screenPadding,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Heading(
                      'There was an error connecting to the database.',
                    ),
                    Text(
                      snapshot.error.toString(),
                    ),
                  ],
                ),
              );
            }
            // While loading, do this:
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
