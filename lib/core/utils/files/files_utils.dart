import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';

/// {@category Utils}
/// A utility class related to files.
class FileUtils 
{
  FileUtils()
  {
    LoggingUtils lu = LoggingUtils();
    lu.setupLogging();
  }
 
  final _logger = Logger("file_utils.dart");

  /// Method used to append text at the end of a file.
  Future<void> appendText({required String filePath, required String text}) async
  {
    String errorMsg = 'Error appending text to file:';
    try
    {
      File file = File(filePath);
      var sink = file.openWrite(mode: FileMode.append);
      sink.write(text);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {_logger.shout('$errorMsg ${e.message}'); }
    catch(e) {_logger.shout('$errorMsg $e');}
  }

  /// Method used to add text at the beginning of a file.
  Future<void> addTextAtFileStart({required String filePath, required String text}) async
  {
    String errorMsg = 'Error appending text in front of file:';
    try
    {
      File file = File(filePath);
      String fileContent = file.readAsStringSync();
      String newContent = text + fileContent;
      var sink = file.openWrite(mode: FileMode.write);
      sink.write(newContent);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {_logger.shout('$errorMsg ${e.message}'); }
    catch(e) {_logger.shout('$errorMsg  $e');}
  }
  
  /// Method used to create a file if necessary, and to add content to it.
  Future<void> createFileIfNecessaryAndAddContent({required String filePath, required String text}) async
  {
    String errorMsg = 'Error writitng text to file:';
    try
    {
      File file = File(filePath);
      // FileMode.write: "The file is overwritten if it already exists. 
      // The file is created if it does not already exist."
      var sink = file.openWrite(mode: FileMode.write);
      sink.write(text);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {_logger.shout('$errorMsg ${e.message}'); }
    catch(e) {_logger.shout('$errorMsg $e');}
  }

  /// Method used to get all the files with a specific extension in a directory.
  /// This method assumes a fileExtension parameter with the format ".fileExtension".
  List<File> getFilesWithExtensionInDirectory({required String directoryPath, required String fileExtension, required bool searchIsRecursive, bool followsLinks = false})
  {
    List<File> fileList = [];
    Directory fileDir = Directory(directoryPath);
    List<FileSystemEntity> entityList  = fileDir.listSync(recursive: searchIsRecursive, followLinks: followsLinks);
    for (var entity in entityList)
    {
      if (entity is File)
      {
        String fileName = path.basename(entity.path);
        if (fileName.endsWith(fileExtension)) fileList.add(entity);
      }
    }
    return fileList;
  }

}

