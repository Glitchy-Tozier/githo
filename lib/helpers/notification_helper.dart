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

import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:githo/models/notification_data.dart';
import 'package:githo/models/progress_data.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

/// Initialises notifications.
Future<void> initNotifications() async {
  // Initialize timezones.

  // Initialise the plugin. app_icon needs to be a added as a drawable resource
  // to the Android head project
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('repeat');
  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  WidgetsFlutterBinding.ensureInitialized();
  await _flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onSelectNotification: (final String? payload) =>
        print('Tapped on Notification :)'),
  );
}

Future<void> scheduleNotification(
  final NotificationData notificationData,
  final ProgressData progressData,
) async {
  if (/* notificationData.isActive */ true) {
    final String? toDo = progressData
        .getDataSliceByDate(notificationData.nextActivationDate)
        ?.level
        .text;

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
      progressData.habitPlanId,
      progressData.habit,
      toDo,
      platformChannelSpecifics,
    );
  }
}
