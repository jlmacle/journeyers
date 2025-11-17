import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'package:journeyers/core/utils/print_utils.dart';

void setupLogging() {
  Logger.root.level = Level.ALL; // Set the root log level
  Logger.root.onRecord.listen((record) {
  var time = record.time;
  String formattedTime = DateFormat('HH:mm:ss').format(time);
  printd('${record.level.name}: $formattedTime: ${record.message}');
  });
}