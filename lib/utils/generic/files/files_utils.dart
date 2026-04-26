import 'dart:io';

import 'package:flutter/services.dart';

import 'package:path/path.dart' as path;

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';


/// {@category Utils - Generic}
/// A generic utility class related to files.
class FileUtils 
{
  /// Channel used for communicating with Android.
  var platformAndroid = const MethodChannel('dev.journeyers/saf');
  /// Channel used for communicating with IOS.
  var platformIOS = const MethodChannel('dev.journeyers/iossaf');

  /// Method used to append text at the end of a file.
  Future<void> addTextAtFileEnd
  ({
    required String filePath,
    required String text,
  }) async 
  {
    try 
    {
      File file = File(filePath);
      var sink = file.openWrite(mode: FileMode.append);
      sink.write(text);
      await sink.flush();
      await sink.close();
    } 
    on FileSystemException 
    catch (e) {pu.printd("Files Utils: ${e.message}");}
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
    catch (e) {pu.printd("Files Utils: $errorMsg ${e.message}");} 
    catch (e) {pu.printd("Files Utils: $errorMsg  $e");}
  }

  /// Method used to create a file if necessary, and to add content to it.
  Future<void> createFileIfNecessaryAndOverwriteContent
  ({
    required String filePath,
    required String text,
  }) async 
  {
    String errorMsg = 'Error writing text to file:';
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
    on FileSystemException catch (e) {pu.printd("Files Utils: $errorMsg ${e.message}");} 
    catch (e) {pu.printd("Files Utils: $errorMsg $e");}
  }

  /// Method used to get all the files with a specific extension in a directory.
  /// This method assumes a fileExtension parameter with the format ".fileExtension".
  Future<List<File>> getFilesWithExtensionInDirectory
  ({
    required String directoryPath,
    required String fileExtension,
    required bool searchIsRecursive,
    bool followsLinks = false,
  }) async
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

  // ─── METHODS USED TO SAVE FILES : beginning ───────────────────────────────────────
  /// Method used to save a file on Android.
  /// The actual code assumes in a folder pre-selected by the user (handled by MainActivity.kt).
  Future<String> saveFileOnAndroid(String fileName, String fileExtension, Uint8List dataBytes) async 
  {
    String? filePath;
    
    final bool success = await platformAndroid.invokeMethod('saveFile', 
    {
      'fileName': "$fileName$fileExtension",
      'content': dataBytes,
    });
    String? folderPath = await upu.getApplicationFolderPath();
    filePath = "$folderPath/$fileName$fileExtension";

    if (sessionDataDebug) pu.printd("Session Data: saveFileOnAndroid: success: $success");
    if (sessionDataDebug) pu.printd("Session Data: filePath: $filePath");

    return filePath;
  }

  /// Method used to save a file on iOS.
  /// The actual code assumes in a folder pre-selected by the user (handled by AppDelegate.swift).
  Future<String> saveFileOniOS(String fileName, String fileExtension, Uint8List dataBytes) async 
  {
    String? filePath;
    
    final bool success = await platformIOS.invokeMethod('saveFile', 
    {
      'fileName': "$fileName$fileExtension",
      'content': dataBytes,
    });
    String? folderPath = await upu.getApplicationFolderPath();
    filePath = "$folderPath/$fileName$fileExtension";

    if (sessionDataDebug) pu.printd("Session Data: saveFileOniOS: success: $success");
    if (sessionDataDebug) pu.printd("Session Data: filePath: $filePath");

    return filePath;
  }
  // ─── METHODS USED TO SAVE FILES : end ───────────────────────────────────────

  // ─── METHODS USED TO READ FILES : beginning ───────────────────────────────────────
  /// Method used to read a text file on Android.
  Future<String> readTextContentOnAndroid({required String fileName}) async
  {
    return await platformAndroid.invokeMethod
        ('readFileContent', {'fileName': fileName}); 
  }

  /// Method used to read a text file on iOS.
  Future<String> readTextContentOnIOS({required String fileName}) async
  {
    return await platformIOS.invokeMethod
        ('readFileContent', {'fileName': fileName}); 
  }

  /// Method used to read a text file on mobile
  Future<String> readTextContentOnMobile({required String pathToData}) async
  {
    String fileName = path.basename(pathToData);
    if (Platform.isIOS)
    {
      return await readTextContentOnIOS(fileName: fileName);
    }
    else if (Platform.isAndroid)
    {
      return await readTextContentOnAndroid(fileName: fileName);
    }
    else 
    {
      throw Exception("Platform not taken into account");
    }

  }
  // ─── METHODS USED TO READ FILES : end ───────────────────────────────────────

  // ─── METHODS USED TO DELETE FILES : beginning  ───────────────────────────────────────
  /// Generic method used to delete a file 
  Future<void> deleteCsvFile(String pathToCsv) async
  {
    if (Platform.isLinux || Platform.isMacOS || Platform.isWindows)
    {
      await deleteCsvFileOnDesktop(pathToCsv);
    }
    else if (Platform.isAndroid)
    {
      await deleteCsvFileOnAndroid(pathToCsv);
    }
    else if (Platform.isIOS)
    {
      await deleteCsvFileOnIOS(pathToCsv);
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
        if (sessionDataDebug) pu.printd("Session Data: File successfully deleted: $pathToCsv");
      } else 
      {
        if (sessionDataDebug) pu.printd("Session Data: Deletion skipped: File does not exist at $pathToCsv");
        if (sessionDataDebug) pu.printd("Session Data: Current working directory: ${Directory.current.path}");
      }
    } on FileSystemException 
    // Specifically handling OS-level errors like permission issues
    catch (e) {pu.printd("Session Data: FileSystemException: Could not delete file. ${e.message}");} 
    // General error handling
    catch (e) {pu.printd("Session Data: An unexpected error occurred while deleting the file: $e");}
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
      {if (sessionDataDebug) pu.printd("Session Data: File deleted successfully from Android SAF storage.");} 
      else 
      {pu.printd("Session Data: Failed to delete file: File not found or permission denied.");}
      return success;
    } 
    on PlatformException 
    catch (e) 
    {
      pu.printd("Session Data: PlatformException during deletion: ${e.message}");
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
      {if (sessionDataDebug) pu.printd("Session Data: File deleted successfully from iOS SAF storage.");} 
      else 
      {pu.printd("Session Data: Failed to delete file: File not found or permission denied.");}
      return success;

    } 
    on PlatformException 
    catch (e) 
    {
      pu.printd("Session Data: PlatformException during deletion: ${e.message}");
      return false;
    }
  }
// ─── METHODS USED TO DELETE FILES : end ───────────────────────────────────────
}
