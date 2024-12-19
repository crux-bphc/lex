import 'package:intl/intl.dart';

final _dateFormat = DateFormat.yMMMd().add_jm();
final _timeFormat = DateFormat.jm();

String formatDate(DateTime dt) {
  if (DateTime.now().difference(dt).inDays < 1) {
    return "Today ${_timeFormat.format(dt)}";
  }
  return _dateFormat.format(dt);
}
