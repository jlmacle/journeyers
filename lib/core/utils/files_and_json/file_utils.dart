import 'dart:io';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';


class FileUtils 
{
  FileUtils()
  {
    setupLogging();
  }
 
  final logger = Logger("file_utils.dart");

  Future<void> appendText({required String filePath, required String text}) async
  {
    String errorMsg = 'Error appending text to file:';
    try{
      File file = File(filePath);
      var sink = file.openWrite(mode: FileMode.append);
      sink.write(text);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {logger.shout('$errorMsg ${e.message}'); }
    catch(e) {logger.shout('$errorMsg $e');}
  }


  Future<void> appendTextInFront({required String filePath, required String text}) async
  {
    String errorMsg = 'Error appending text in front of file:';
    try{
      File file = File(filePath);
      String fileContent = file.readAsStringSync();
      String newContent = text + fileContent;
      var sink = file.openWrite(mode: FileMode.write);
      sink.write(newContent);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {logger.shout('$errorMsg ${e.message}'); }
    catch(e) {logger.shout('$errorMsg  $e');}
  }
  
  Future<void> createFileIfNecessaryAndAddContent({required String filePath, required String text}) async
  {
    String errorMsg = 'Error writitng text to file:';
    try{
      File file = File(filePath);
      var sink = file.openWrite(mode: FileMode.write);
      sink.write(text);
      await sink.flush();
      await sink.close();
    }
    on FileSystemException catch (e) {logger.shout('$errorMsg ${e.message}'); }
    catch(e) {logger.shout('$errorMsg $e');}
  }

  /// This method assumes a file extension with the format .file_extension
  List<File> getFilesInDirectory({required String directoryPath, required String fileExtension, required bool searchIsRecursive, bool followsLinks = false})
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

