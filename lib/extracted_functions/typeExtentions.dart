extension StringExtension on String {
  // Capitalizes the first letter of a st ring.
  String capitalize() {
    return "${this[0].toUpperCase()}${this.substring(1)}";
  }
}

extension BoolExtension on bool {
  int boolToInt() {
    if (this == true) {
      return 1;
    } else {
      return 0;
    }
  }
}

extension IntExtension on int {
  // Return false if input == 1. Otherwise return true.
  bool intToBool() {
    if (this == 0) {
      return false;
    } else if (this == 1) {
      return true;
    } else {
      print("intToBool-extension: ERROR: Int was not 1 or 0.");
      return true;
    }
  }
}
