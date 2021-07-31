import 'package:intl/intl.dart';

String formatDate(final DateTime dateTime) {
  // Formats the input date and returns it as a String.
  return DateFormat("EEEE, dd.MM.yyyy").format(dateTime);
}
