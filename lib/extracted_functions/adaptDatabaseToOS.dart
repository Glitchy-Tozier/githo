import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void adaptDatabaseToOS() {
  // SQFlite doesn't work on Linux and Windows out of the box.
  // To still be able to test there, this function was added.

  final bool _needsSpecialSQfliteTreatment;

  if (Platform.isWindows) {
    print(
        "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\nDetected Windows\n~~~~~~~~~~~~~~~~~~~~~~~~~~");
    _needsSpecialSQfliteTreatment = true;
  } else if (Platform.isLinux) {
    print(
        "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~\nDetected Linux\n~~~~~~~~~~~~~~~~~~~~~~~~~~~");
    _needsSpecialSQfliteTreatment = true;
  } else {
    print(
        "\n~~~~~~~~~~~~~~~~~~~~~~~~~~\nThere's definitely nothing wrong. Ignore this message please!!\n~~~~~~~~~~~~~~~~~~~~~~~~~~");
    _needsSpecialSQfliteTreatment = false;
  }

  if (_needsSpecialSQfliteTreatment) {
    // Initialize FFI
    sqfliteFfiInit();
    // Change the default factory
    databaseFactory = databaseFactoryFfi;
  }
}
