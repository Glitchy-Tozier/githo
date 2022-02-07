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

import 'package:timezone/timezone.dart' as tz;
import 'package:githo/helpers/type_extentions.dart';

/// A model for how and when notifications should be displayed.

class NotificationData {
  NotificationData({
    required this.isActive,
    required this.nextActivationDate,
    required this.hoursBetweenNotifications,
  });

  /// Converts a Map into [NotificationData].
  NotificationData.fromMap(final Map<String, dynamic> map)
      : isActive = (map['isActive'] as int).toBool(),
        nextActivationDate =
            tz.TZDateTime.parse(tz.local, map['nextActivationDate'] as String),
        hoursBetweenNotifications = map['hoursBetweenNotifications'] as int;

  /// Supplies the default instance of [NotificationData].
  NotificationData.initialValues()
      : isActive = false,
        nextActivationDate = tz.TZDateTime.now(tz.local),
        hoursBetweenNotifications = 9999;

  bool isActive;
  tz.TZDateTime nextActivationDate;
  int hoursBetweenNotifications;

  /// Converts the [NotificationData] into a Map.
  Map<String, dynamic> toMap() {
    final Map<String, dynamic> map = <String, dynamic>{
      'isActive': isActive.toInt(),
      'nextActivationDate': nextActivationDate.toString(),
      'hoursBetweenNotifications': hoursBetweenNotifications,
    };
    return map;
  }
}
