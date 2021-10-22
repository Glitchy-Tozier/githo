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

/// A collection of variables that shouldn't be affected by `setState()`s or
/// other runtiime-reloads.
class RuntimeVariables {
  RuntimeVariables._privateConstructor();

  /// The singleton-instance of DatabaseHelper.
  static RuntimeVariables instance = RuntimeVariables._privateConstructor();

  /// If true, a [WelcomeSheet]-widget will be shown upon the loading of
  /// [HomeScreen].
  bool showWelcomeSheet = true;
}
