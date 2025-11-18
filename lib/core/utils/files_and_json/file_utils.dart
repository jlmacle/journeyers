import 'dart:io';

import 'package:logging/logging.dart';

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';

class FileUtils 
{
  FileUtils()
  {
    setupLogging();
  }
 
  final logger = Logger("file_utils.dart");

  Future<void> appendText(File file, String text) async
  {
    try{
      var sink = file.openWrite(mode: FileMode.append);
      sink.write(text);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {logger.shout('Error appending text to file: ${e.message}'); }
    catch(e) {logger.shout('Error appending text to file: $e');}
  }

}

