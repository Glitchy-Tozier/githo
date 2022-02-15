/* 
 * Githo – An app that helps you gradually form long-lasting habits.
 * Copyright (C) 2021 Florian Thaler
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

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/used_classes/training_period.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:githo/database/database_helper.dart';
import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';
import 'package:githo/models/used_classes/training.dart';

//
// Notifications:

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const NotificationDetails _trainingNotificationDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'training_notifications',
    'Training Notifications',
    channelDescription: 'Reminders, shown for every training.',
    importance: Importance.max,
    styleInformation: BigTextStyleInformation(''),
    priority: Priority.high,
    ticker: 'ticker',
  ),
);

/// Takes a list of trainings and schedules a message for each of them.
Future<void> _scheduleTrainingNotifications(
  final List<Training> trainings,
  final NotificationData notificationData,
  final String toDo,
) async {
  for (final Training training in trainings) {
    final DateTime? notificationTime = notificationData.getNotifyTimeBetween(
      training.startingDate,
      training.endingDate,
    );
    if (notificationTime != null) {
      if (notificationTime.isAfter(TimeHelper.instance.currentTime)) {
        print('TrainingNotification scheduled for $notificationTime');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          training.number,
          'Ready for the next training?',
          toDo,
          tz.TZDateTime.from(notificationTime, tz.local),
          _trainingNotificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
      }
    }
  }
}

//
// Public functions:

/// Contains the logic that decides when and if a notification should get
/// displayed.
Future<void> scheduleNotifications() async {
  final NotificationData notificationData =
      await DatabaseHelper.instance.getNotificationData();

  if (notificationData.isEnabled) {
    final ProgressData progressData =
        await DatabaseHelper.instance.getProgressData();

    // Schedule notifications for the active trainings.
    ProgressDataSlice? dataSlice = progressData.activeDataSlice;
    if (dataSlice != null) {
      final TrainingPeriod activePeriod = dataSlice.period;
      if ((!activePeriod.currentlyIsSuccessful ||
              notificationData.keepNotifyingAfterSuccess) &&
          !activePeriod.hasFailed) {
        final int nrTrainings = activePeriod.trainings.length;

        int startingNotifyIdx =
            dataSlice.training.number - activePeriod.trainings.first.number;
        final int scheduledNotificationCount =
            1 + activePeriod.remainingAllowedUnsuccessfulTrainings;
        int endingNotifyIdx = startingNotifyIdx + scheduledNotificationCount;

        // If the current training already was successfully completed or its
        // notification-time already has passed, don't set up a notification for
        // it.
        if (TimeHelper.instance.currentTime.isAfter(
              notificationData.getNotifyTimeBetween(
                dataSlice.training.startingDate,
                dataSlice.training.endingDate,
              )!,
            ) ||
            dataSlice.training.status == 'done') {
          startingNotifyIdx++;
          endingNotifyIdx++;
        } else if (TimeHelper.instance.currentTime.isBefore(
              notificationData.getNotifyTimeBetween(
                dataSlice.training.startingDate,
                dataSlice.training.endingDate,
              )!,
            ) &&
            dataSlice.training.status != 'done') {
          // Add one more training to keep the number of "future trainings"
          // correct
          endingNotifyIdx++;
        }

        if (endingNotifyIdx > nrTrainings) endingNotifyIdx = nrTrainings;

        final List<Training> notifiedTrainings =
            dataSlice.period.trainings.sublist(
          startingNotifyIdx,
          endingNotifyIdx,
        );
        await _scheduleTrainingNotifications(
          notifiedTrainings,
          notificationData,
          dataSlice.level.text,
        );
      }
      // Schedule the notification for the beginnig of the next TrainingPeriod.
      final DateTime? notifyDateTimeNextPeriod = notificationData
          .getNotifyTimeBetween(
            dataSlice.period.trainings.last.startingDate,
            dataSlice.period.trainings.last.endingDate,
          )
          ?.add(Duration(hours: notificationData.hoursBetweenNotifications));
      if (notifyDateTimeNextPeriod != null) {
        final String msg;
        if (activePeriod.currentlyIsSuccessful) {
          msg = 'Tackle the next Level!';
        } else {
          msg = 'A new ${activePeriod.durationText}!';
        }
        print('NextWeekNotification scheduled for $notifyDateTimeNextPeriod');
        await _flutterLocalNotificationsPlugin.zonedSchedule(
          0,
          msg,
          null,
          tz.TZDateTime.from(notifyDateTimeNextPeriod, tz.local),
          _trainingNotificationDetails,
          androidAllowWhileIdle: true,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.wallClockTime,
        );
      }
    } else {
      // Schedule notifications for waiting, future trainings.
      dataSlice = progressData.waitingDataSlice;
      if (dataSlice != null) {
        final int scheduledNotificationCount = 1 +
            dataSlice.period.trainings.length -
            dataSlice.period.requiredTrainings;
        print('length: ${dataSlice.period.trainings.length}');
        print('required: ${dataSlice.period.requiredTrainings}');
        print('scheduledNotificationCount = $scheduledNotificationCount');

        final List<Training> notifiedTrainings =
            dataSlice.period.trainings.sublist(
          0,
          scheduledNotificationCount,
        );
        await _scheduleTrainingNotifications(
          notifiedTrainings,
          notificationData,
          dataSlice.level.text,
        );
      }
    }
  }
}

/* /// Exists for testing purposes.
Future<void> messageNotification(String msg) async {
// Show the notification.
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'debug_notifications',
      'Debug Notifications',
      channelDescription: 'Exists for testing purposes.',
      importance: Importance.max,
      styleInformation: BigTextStyleInformation(''),
      priority: Priority.high,
      ticker: 'ticker',
    ),
  );
  await _flutterLocalNotificationsPlugin.show(
    999999,
    msg,
    null,
    /* '$msg\n'
  'This message was sent at weekday ${TimeHelper.instance.currentTime.weekday},'
  '${TimeHelper.instance.currentTime.hour}:'
  '${TimeHelper.instance.currentTime.minute}.', */
    platformChannelSpecifics,
  );
} */

/// Cancels all scheduled notifications and resets [NotificationData].
Future<void> annihilateNotifcations() async {
  await cancelNotifications();
  await NotificationData.emptyData().save();
}

/// Cancels a scheduled notification with a specific ID.
///
/// - ID 0 = Next [TrainingPeriod]'s notification.
/// - ID [training.number] = The notification that corresponds to a specific
/// training.
Future<void> cancelNotification(final int id) async {
  await _flutterLocalNotificationsPlugin.cancel(id);
}

/// Cancels all scheduled notifications.
Future<void> cancelNotifications() async {
  print('canceled Notifications');
  await _flutterLocalNotificationsPlugin.cancelAll();
}

/// Initialises everything needed to later call [scheduleNotifications].
Future<void> initNotifications() async {
  // Initialise the plugin. app_icon needs to be a added as a drawable resource
  // to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('repeat');
  const LinuxInitializationSettings initializationSettingsLinux =
      LinuxInitializationSettings(defaultActionName: 'repeat');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    linux: initializationSettingsLinux,
  );
  tz.initializeTimeZones();
  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}
