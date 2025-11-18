// flutter run -t test\core\utils\printing_and_logging\logging_helper_testing.dart

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';
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

