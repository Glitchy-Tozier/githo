String getDurationDiff(final DateTime dateTime1, final DateTime dateTime2) {
  final Duration difference = dateTime2.difference(dateTime1);
  print("getDurationDiff says:");
  print(dateTime1);
  print(dateTime2);
  print(difference.inDays);

  if (difference.inDays > 1) {
    return "${difference.inDays} days";
  } else if (difference.inDays == 1) {
    return "${difference.inDays} day";
  } else if (difference.inHours >= 1) {
    return "${difference.inHours} h";
  } else if (difference.inMinutes >= 1) {
    return "${difference.inDays} min";
  } else {
    return "${difference.inSeconds} s";
  }
}
