import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

void setupLogging() {
  Logger.root.level = Level.ALL; // Set the root log level
  Logger.root.onRecord.listen((record) {
  var time = record.time;
  String formattedTime = DateFormat('HH:mm:ss').format(time);
  // TODO: file-based logging and logging reset algorithm
  print('${record.level.name}: $formattedTime: ${record.message}');
  });
}