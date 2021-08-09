/* 
 * Githo – An app that helps you form long-lasting habits, one step at a time.
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

extension StringExtension on String {
  /// Capitalizes the first letter of a string.
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension BoolExtension on bool {
  /// Returns 1 if true; Returns 0 if false.
  int boolToInt() {
    if (this == true) {
      return 1;
    } else {
      return 0;
    }
  }
}

extension IntExtension on int {
  /// Returns false if the int is 0.
  /// Otherwise returns true.
  bool intToBool() {
    if (this == 0) {
      return false;
    } else if (this == 1) {
      return true;
    } else {
      print(
          "intToBool-extension: WARNING: Int was not 1 or 0.\n'''true''' was returned.");
      return true;
    }
  }
}
