import 'dart:io';

import 'package:flutter/services.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';

import 'package:logging/logging.dart';
import 'package:path/path.dart' as path;

import 'package:journeyers/core/utils/printing_and_logging/logging_utils.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';

// Utility class
final PrintUtils _pu = PrintUtils();
final UserPreferencesUtils _upu = UserPreferencesUtils();

/// {@category Utils}
/// A utility class related to files.
class FileUtils 
{
  FileUtils() 
  {
    LoggingUtils lu = LoggingUtils();
    lu.setupLogging();
  }

  /// Channel used for communicating with Android
  var platformAndroid = MethodChannel('dev.journeyers/saf');
  /// Channel used for communicating with IOS
  var platformIOS = MethodChannel('dev.journeyers/iossaf');

  // A logger
  final _logger = Logger("file_utils.dart");

  /// Method used to append text at the end of a file.
  Future<void> addTextAtFileEnd
  ({
    required String filePath,
    required String text,
  }) async 
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
    on FileSystemException 
    catch (e) {_logger.shout('$errorMsg ${e.message}');} 
    catch (e) {_logger.shout('$errorMsg $e');}
  }

  /// Method used to add text at the beginning of a file.
  Future<void> addTextAtFileStart
  ({
    required String filePath,
    required String text,
  }) async 
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
    on FileSystemException 
    catch (e) {_logger.shout('$errorMsg ${e.message}');} 
    catch (e) {_logger.shout('$errorMsg  $e');}
  }

  /// Method used to create a file if necessary, and to add content to it.
  Future<void> createFileIfNecessaryAndOverwriteContent
  ({
    required String filePath,
    required String text,
  }) async 
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
    on FileSystemException catch (e) {_logger.shout('$errorMsg ${e.message}');} 
    catch (e) {_logger.shout('$errorMsg $e');}
  }

  /// Method used to get all the files with a specific extension in a directory.
  /// This method assumes a fileExtension parameter with the format ".fileExtension".
  List<File> getFilesWithExtensionInDirectory
  ({
    required String directoryPath,
    required String fileExtension,
    required bool searchIsRecursive,
    bool followsLinks = false,
  }) 
  {
    List<File> fileList = [];
    Directory fileDir = Directory(directoryPath);
    List<FileSystemEntity> entityList = fileDir.listSync
    (
      recursive: searchIsRecursive,
      followLinks: followsLinks,
    );
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

  //*****************  Methods used to save files: beginning  ***********************//

  /// Method used to save a file on Android.
  /// The actual code assumes in a folder pre-selected by the user (handled by MainActivity.kt).
  Future<String> saveFileOnAndroid(String fileName, Uint8List dataBytes) async 
  {
    String? filePath;
    
    final bool success = await platformAndroid.invokeMethod('saveFile', 
    {
      'fileName': "$fileName.csv",
      'content': dataBytes,
    });
    String? folderPath = await _upu.getApplicationFolderPath();
    filePath = "$folderPath/$fileName.csv";

    _pu.printd("_saveFileOnAndroid: success: $success");
    _pu.printd("filePath: $filePath");

    return filePath;
  }

  /// Method used to save a file on iOS.
  /// The actual code assumes in a folder pre-selected by the user (handled by AppDelegate.swift).
  Future<String> saveFileOniOS(String fileName, Uint8List dataBytes) async 
  {
    String? filePath;
    
    final bool success = await platformIOS.invokeMethod('saveFile', 
    {
      'fileName': "$fileName.csv",
      'content': dataBytes,
    });
    String? folderPath = await _upu.getApplicationFolderPath();
    filePath = "$folderPath/$fileName.csv";

    _pu.printd("_saveFileOnAndroid: success: $success");
    _pu.printd("filePath: $filePath");

    return filePath;
  }

  //*****************  Methods used to save files: end  ***********************//

  //*****************  Methods used to read files: beginning  ***********************//

  /// Method used to read a text file on Android.
  Future<String> readTextContentOnAndroid(String fileName) async
  {
    return await platformAndroid.invokeMethod
        ('readFileContent', {'fileName': fileName}); 
  }

  /// Method used to read a text file on iOS.
  Future<String> readTextContentOnIOS(String fileName) async
  {
    return await platformIOS.invokeMethod
        ('readFileContent', {'fileName': fileName}); 
  }


  //*****************  Methods used to read files: end  ***********************//
  //*****************  Methods used to delete files: beginning  ***********************//
  /// Generic method used to delete a file 
  Future<void> deleteCsvFile(String pathToCsv) async
  {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
    {
      deleteCsvFileOnDesktop(pathToCsv);
    }
    else if (Platform.isAndroid)
    {
      deleteCsvFileOnAndroid(pathToCsv);
    }
    else if (Platform.isIOS)
    {
      deleteCsvFileOnIOS(pathToCsv);
    }
    else 
    {
      throw Exception("Platform not taken into account");
    }
  }

  // Method used to delete a file on desktop
  Future<void> deleteCsvFileOnDesktop(String pathToCsv) async
  {
    try 
    {
      final file = File(pathToCsv);

      // Checking if the file exists before attempting to delete
      if (await file.exists()) 
      {
        await file.delete();
        _pu.printd("File successfully deleted: $pathToCsv");
      } else 
      {
        _pu.printd("Deletion skipped: File does not exist at $pathToCsv");
        _pu.printd("Current working directory: ${Directory.current.path}");
      }
    } on FileSystemException 
    // Specifically handling OS-level errors like permission issues
    catch (e) {_pu.printd("FileSystemException: Could not delete file. ${e.message}");} 
    // General error handling
    catch (e) {_pu.printd("An unexpected error occurred while deleting the file: $e");}
  }

// Method used to delete a file on Android
Future<bool> deleteCsvFileOnAndroid(String pathToCsv) async 
{
  try 
  {
    // Extracting only the filename from the path if necessary, 
    // as findFile() in Kotlin expects the name within the tree
    final fileName = pathToCsv.split('/').last;

    final bool success = await platformAndroid.invokeMethod('deleteFile', {'fileName': fileName});

    if (success) 
    {_pu.printd("File deleted successfully from Android SAF storage.");} 
    else 
    {_pu.printd("Failed to delete file: File not found or permission denied.");}
    return success;
  } 
  on PlatformException 
  catch (e) 
  {
    _pu.printd("PlatformException during deletion: ${e.message}");
    return false;
  }
}

// Method used to delete a file on iOS
Future<bool> deleteCsvFileOnIOS(String pathToCsv) async 
{
  try 
  {
    // Extracting only the filename from the path if necessary, 
    // as findFile() in Kotlin expects the name within the tree
    final fileName = pathToCsv.split('/').last;

    final bool success = await platformIOS.invokeMethod('deleteFile', {'fileName': fileName});

    if (success) 
    {_pu.printd("File deleted successfully from iOS SAF storage.");} 
    else 
    {_pu.printd("Failed to delete file: File not found or permission denied.");}
    return success;

  } 
  on PlatformException 
  catch (e) 
  {
    _pu.printd("PlatformException during deletion: ${e.message}");
    return false;
  }
}

//*****************  Methods used to delete files: end  ***********************//

}
