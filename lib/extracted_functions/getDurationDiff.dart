String getDurationDiff(final DateTime dateTime1, final DateTime dateTime2) {
  // Returns a String that describes the time difference between two DateTimes.

  final Duration difference = dateTime2.difference(dateTime1);
  final int amount;
  final String timeString;

  if (difference.inDays >= 1) {
    amount = difference.inDays + 1;
    timeString = "$amount days";
  } else if (difference.inHours >= 1) {
    amount = difference.inHours + 1;
    timeString = "$amount h";
  } else if (difference.inMinutes >= 1) {
    amount = difference.inMinutes + 1;
    timeString = "$amount min";
  } else {
    amount = difference.inSeconds + 1;
    timeString = "$amount s";
  }
  return timeString;
}
