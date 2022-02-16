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

/// Returns a String that describes the time difference between two DateTimes.

String getDurationDiff(final DateTime dateTime1, final DateTime dateTime2) {
  final Duration difference = dateTime2.difference(dateTime1);
  final int amount;
  final String timeString;

  if (difference.inDays >= 1) {
    amount = difference.inDays + 1;
    timeString = '$amount days';
  } else if (difference.inHours >= 1) {
    amount = difference.inHours + 1;
    timeString = '$amount h';
  } else if (difference.inMinutes >= 1) {
    amount = difference.inMinutes + 1;
    timeString = '$amount min';
  } else {
    amount = difference.inSeconds + 1;
    timeString = '$amount s';
  }
  return timeString;
}
