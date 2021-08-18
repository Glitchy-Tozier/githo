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

import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// SQFlite doesn't work on Linux and Windows out of the box.
/// To still be able to test there, this function was added.

void adaptDatabaseToOS() {
  final bool _needsSpecialSQfliteTreatment;

  if (Platform.isWindows) {
    print(
      '\n'
      '~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
      'Detected Windows\n'
      '-> Adapted Database\n'
      '~~~~~~~~~~~~~~~~~~~~~~~~~~\n',
    );
    _needsSpecialSQfliteTreatment = true;
  } else if (Platform.isLinux) {
    print(
      '\n'
      '~~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
      'Detected Linux\n'
      '-> Adapted Database\n'
      '~~~~~~~~~~~~~~~~~~~~~~~~~~~\n',
    );
    _needsSpecialSQfliteTreatment = true;
  } else {
    print(
      '\n'
      '~~~~~~~~~~~~~~~~~~~~~~~~~~\n'
      "There's definitely nothing wrong. Ignore this message please!!\n"
      '~~~~~~~~~~~~~~~~~~~~~~~~~~\n',
    );
    _needsSpecialSQfliteTreatment = false;
  }

  if (_needsSpecialSQfliteTreatment) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
}
