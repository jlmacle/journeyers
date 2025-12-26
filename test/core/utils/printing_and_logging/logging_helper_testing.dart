// Line for automated processing
// flutter run -t ./test/core/utils/printing_and_logging/logging_helper_testing.dart -d chrome
// flutter run -t ./test/core/utils/printing_and_logging/logging_helper_testing.dart -d linux
// flutter run -t ./test/core/utils/printing_and_logging/logging_helper_testing.dart -d macos
// flutter run -t ./test/core/utils/printing_and_logging/logging_helper_testing.dart -d windows
// Line for automated processing

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';
import 'package:logging/logging.dart';

void main(){
  LoggingUtils lu = LoggingUtils();
  lu.setupLogging();
  // The logger doesn't print without the previous lines
  final logger = Logger('MyTestingCode');
  logger.fine('Message');
  logger.finer('Message');
  logger.finest('Message');
  logger.info('Message');
  logger.severe('Message');
  logger.shout('Message');
  logger.warning('Message');

}

