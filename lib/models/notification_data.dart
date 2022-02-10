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

import 'package:githo/database/database_helper.dart';
import 'package:githo/helpers/time_helper.dart';
import 'package:githo/helpers/type_extentions.dart';

/// A model for how and when notifications should be displayed.

class NotificationData {
  NotificationData({
    required this.isActive,
    required this.keepNotifyingAfterSuccess,
    required this.nextActivationDate,
    required this.hoursBetweenNotifications,
  });

  /// Converts a Map into [NotificationData].
  NotificationData.fromMap(final Map<String, dynamic> map)
      : isActive = (map['isActive'] as int).toBool(),
        keepNotifyingAfterSuccess =
            (map['keepNotifyingAfterSuccess'] as int).toBool(),
        nextActivationDate =
            DateTime.parse(map['nextActivationDate'] as String),
        hoursBetweenNotifications = map['hoursBetweenNotifications'] as int;

  /// Supplies the default instance of [NotificationData].
  NotificationData.emptyData()
      : isActive = false,
        keepNotifyingAfterSuccess = false,
        nextActivationDate = DateTime.now(),
        hoursBetweenNotifications = 255;

  bool isActive;
  bool keepNotifyingAfterSuccess;
  DateTime nextActivationDate;
  int hoursBetweenNotifications;

  /// Moves [nextActivationDate] ahead in time, until the next planned
  /// notification-date lies in the future.
  Future<void> updateActivationDate() async {
    final DateTime now = TimeHelper.instance.currentTime;
    print('updateActivationDate()');
    print('starting nextActivationDate: $nextActivationDate');
    print('now: $now');
    while (nextActivationDate.isBefore(now)) {
      print('nextActivationDate: $nextActivationDate');
      nextActivationDate = nextActivationDate.add(
        Duration(hours: hoursBetweenNotifications),
      );
    }
    print('nextActivationDate is at: $nextActivationDate\n');
    await save();
  }

  /// Saves the current notificationData in the [Database].
  Future<void> save() async {
    await DatabaseHelper.instance.updateNotificationData(this);
  }

  /// Converts the [NotificationData] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'isActive': isActive.toInt(),
      'keepNotifyingAfterSuccess': keepNotifyingAfterSuccess.toInt(),
      'nextActivationDate': nextActivationDate.toString(),
      'hoursBetweenNotifications': hoursBetweenNotifications,
    };
    return map;
  }
}
