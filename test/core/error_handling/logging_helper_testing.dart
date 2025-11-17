// flutter run -t test\core\error_handling\logging_helper_testing.dart

import 'package:journeyers/core/error_handling/logging_helper.dart';
import 'package:logging/logging.dart';

void main(){
  setupLogging();
  final logger = Logger('MyTestingCode');
  logger.fine('Message');
  logger.finer('Message');
  logger.finest('Message');
  logger.info('Message');
  logger.severe('Message');
  logger.shout('Message');
  logger.warning('Message');

}

