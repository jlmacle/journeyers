// dart test\core\error_handling\logging_helper_testing.dart

import 'package:journeyers/core/error_handling/logging_helper.dart';
import 'package:logging/logging.dart';

void main(){
  setupLogging();
  final logger = Logger('MyTestingCode');
  logger.info('Logging test');
}

