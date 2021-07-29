import 'package:intl/intl.dart';

String formatDate(final DateTime dateTime) {
  return DateFormat("EEEE, dd.MM.yyyy").format(dateTime);
}
