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

/// Exstensions for the type [String].
extension StringExtension on String {
  /// Capitalizes the first letter of a string.
  String capitalize() {
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

/// Exstensions for the type [bool].
extension BoolExtension on bool {
  /// Returns 1 if true; Returns 0 if false.
  int toInt() {
    if (this == true) {
      return 1;
    } else {
      return 0;
    }
  }
}

/// Exstensions for the type [int].
extension IntExtension on int {
  /// Returns false if the int is 0.
  /// Otherwise returns true.
  bool toBool() {
    if (this == 0) {
      return false;
    } else if (this == 1) {
      return true;
    } else {
      print(
        'intToBool-extension: WARNING: Int was not 1 or 0.\n'
        '[bool: true] was returned.',
      );
      return true;
    }
  }
}

/// An extension on [DateTime].
extension MyDateUtils on DateTime {
  /// Copies the [DateTime], while overriding the selected attributes.
  DateTime copyWith({
    final int? year,
    final int? month,
    final int? day,
    final int? hour,
    final int? minute,
    final int? second,
    final int? millisecond,
    final int? microsecond,
  }) {
    return DateTime(
      year ?? this.year,
      month ?? this.month,
      day ?? this.day,
      hour ?? this.hour,
      minute ?? this.minute,
      second ?? this.second,
      millisecond ?? this.millisecond,
      microsecond ?? this.microsecond,
    );
  }

  /// Sets [second], [millisecond], and [microsecond] to of the [DateTime] to 0.
  DateTime clean() {
    return DateTime(
      year,
      month,
      day,
      hour,
      minute,
    );
  }
}
