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

import 'package:background_fetch/background_fetch.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';

//
// Notifications:

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Initialises notifications.
Future<void> _initNotifications() async {
  // Initialise the plugin. app_icon needs to be a added as a drawable resource
  // to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('repeat');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
  );
}

/// Contains the logic that decides whether a notification should get displayed.
/// If the answer is yes, the notification is deployed.
Future<void> _decideOnNotification() async {
  final NotificationData notificationData =
      await DatabaseHelper.instance.getNotificationData();
  print('\nstarted manageNotifications');

  // If notifications are enabled
  if (notificationData.isActive) {
    print('is allowed');
    final DateTime now = TimeHelper.instance.currentTime;
    // If the time has come to display the notification
    if (now.isAfter(notificationData.comparisonActivationDate)) {
      print('is now');
      final ProgressData progressData =
          await DatabaseHelper.instance.getProgressData();
      final ProgressDataSlice? timedDataSlice =
          progressData.getDataSliceByDate(notificationData.nextActivationDate);

      await notificationData.updateActivationDate();
      print('finished notificationData.updateActivationDate()');
      if (timedDataSlice != null) {
        print('timedDataSlice exists');
        if (!timedDataSlice.period.wasSuccessful ||
            notificationData.keepNotifyingAfterSuccess) {
          print(
            "period wasn't successful yet (${!timedDataSlice.period.wasSuccessful})"
            ' or notifications should always be displayed (${notificationData.keepNotifyingAfterSuccess})',
          );
          if (timedDataSlice.training.hasPassed) {
            print('timed dataSlice has passed => NO notification');
            await progressData.updateSelf();
          } else {
            print('correct training => showing notification');
            final String toDo = timedDataSlice.level.text;

            // Show the notification.
            const NotificationDetails platformChannelSpecifics =
                NotificationDetails(
              android: AndroidNotificationDetails(
                'your channel id',
                'your channel name',
                channelDescription: 'your channel description',
                importance: Importance.max,
                styleInformation: BigTextStyleInformation(''),
                priority: Priority.high,
                ticker: 'ticker',
              ),
            );
            await _flutterLocalNotificationsPlugin.show(
              0,
              progressData.habit,
              '${timedDataSlice.training.number}:\n$toDo',
              platformChannelSpecifics,
            );
          }
        }
      }
    }
  }
  print('ran through manageNotifications()\n');
}

/* /// Exists for testing purposes.
Future<void> messageNotification(String msg) async {
// Show the notification.
  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      channelDescription: 'your channel description',
      importance: Importance.max,
      styleInformation: BigTextStyleInformation(''),
      priority: Priority.high,
      ticker: 'ticker',
    ),
  );
  await _flutterLocalNotificationsPlugin.show(
    Random().nextInt(100000000) + 99999239,
    msg,
    '$msg\n'
    'This message was sent at ${TimeHelper.instance.currentTime.weekday}, '
    '${TimeHelper.instance.currentTime.hour}:'
    '${TimeHelper.instance.currentTime.minute}.',
    platformChannelSpecifics,
  );
} */

//
// Tasks:

/// [Android-only] This "Headless Task" is run when the Android app
/// is terminated with enableHeadless: true
Future<void> _backgroundFetchHeadlessTask(final HeadlessTask task) async {
  final String taskId = task.taskId;
  final bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    BackgroundFetch.finish(taskId);
    return;
  }
  // Do your work here...
  await _initNotifications();
  await _decideOnNotification();
  BackgroundFetch.finish(taskId);
}

//
// Public functions:

/// Stops all ([BackgroundFetch]-) tasks, which are the tasks that
/// will produce notifications.
Future<int> stopBackgroundTasks() async {
  final int result = await BackgroundFetch.stop();
  return result;
}

Future<void> annihilateNotifcations() async {
  await NotificationData.emptyData().save();
  await stopBackgroundTasks();
}

/// Initializes the headless tasks that can spawn notifications.
///
/// As a safety measure, this method will stop all headless tasks
/// if notifications are disabled.
Future<void> initHeadlessNotifications() async {
  await stopBackgroundTasks();
  final NotificationData notificationData =
      await DatabaseHelper.instance.getNotificationData();

  // If notifications are enabled and a habit-plan is active:
  if (notificationData.isActive) {
    /// Starts the headless tasks which can spawn notifications.
    // Register to receive BackgroundFetch events after app is terminated.
    // Requires {stopOnTerminate: false, enableHeadless: true}
    await BackgroundFetch.registerHeadlessTask(_backgroundFetchHeadlessTask);

    // Configure BackgroundFetch.
    await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        startOnBoot: true,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresDeviceIdle: false,
        requiresStorageNotLow: false,
        requiredNetworkType: NetworkType.NONE,
      ),
      (final String taskId) async {
        // <-- Event handler
        // This is the fetch-event callback.
        await _initNotifications();
        await _decideOnNotification();
        // IMPORTANT:  You must signal completion of your task or the OS
        // can punish your app for taking too long in the background.
        BackgroundFetch.finish(taskId);
      },
    );
  }
}
