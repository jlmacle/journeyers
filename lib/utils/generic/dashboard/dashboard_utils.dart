import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';


/// {@category Utils - Generic}
/// A generic utility class used for the context analyses dashboard, and for the group problem-solvings dashboard (more to do on genericity).
class DashboardUtils {

  /// String used to communicate the context of the context analyses.
  static const String caContext = "Context for the context analyses";

  /// String used to communicate the context of the group problem-solvings.
  static const String gpsContext = "Context for the group problem-solvings";

  /// The key for the session title.
  static const String keyTitle = 'title';

  /// The key for the session keywords
  static const String keyKeywords = 'keywords';

  /// The key for the session date.
  static const String keyDate = 'date';

  /// The key for the session file path.
  static const String keyFilePath = 'filePath';

  /// The current list of stored file names (for the mobile applications).
  List<String> currentListOfStoredFileNames = [];  

  // ─── SMARTPHONES CHANNELS ───────────────────────────────────────
  // Android: storage access framework (reading/saving files)
  static const _platformAndroid = MethodChannel('dev.journeyers/saf');
  // Android: storage access framework (reading/saving files)
  static const _platformIOS = MethodChannel('dev.journeyers/iossaf');

  /// Method used to retrieve the file with all the dashboard session metadata, 
  /// either for the context analyses, or for the group problem-solvings.
  Future<File> getSessionMetadataFile({required String typeOfDashboardContext}) async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    String fileName = "";
    if (typeOfDashboardContext == caContext) {
      fileName = 'dashboard_session_data_context_analyses.json';
    } else if (typeOfDashboardContext == gpsContext) {
      fileName = 'dashboard_session_data_group_problem_solvings.json';
    } else {
      if (sessionDataDebug) pu.printd("Session Data: Error: Unexpected type of dashboard context: $typeOfDashboardContext");
    }

    File sessionFile = File('$path/$fileName');
    if (!sessionFile.existsSync()) {
      sessionFile.createSync();
      // Adding an empty map to the file
      List<Map<String, String>> records = [];
      String content = jsonEncode(records);
      await sessionFile.writeAsString(content);
      if (sessionDataDebug) pu.printd("Session Data: Session file for $typeOfDashboardContext created: $path/$fileName");
    }
    return sessionFile;
  }

  /// Method used to save dashboard metadata, either for a context analysis, or for a group problem-solving.
  Future<void> saveDashboardMetadata
  ({
    required String typeOfDashboardContext,
    required String? title,
    required List<String> keywords,
    required String formattedDate,
    required String pathToFile,
  }) 
  async {
    if (sessionDataDebug) pu.printd("Session Data: formattedDate: $formattedDate");
    if (sessionDataDebug) pu.printd("Session Data: analysisTitle: $title");

    Map<String, dynamic> sessionData = 
    {
      keyTitle: title ?? "Untitled",
      keyKeywords: keywords,
      keyDate: formattedDate,
      keyFilePath: pathToFile,
    };

    // Saving the session metadata (file created in getSessionFile if needed)
    File file = await getSessionMetadataFile(typeOfDashboardContext: typeOfDashboardContext);
  
    String updatedContent = "";

    // Reading and decoding the records content
    String jsonContent = file.readAsStringSync();
    List<dynamic> recordsList = jsonDecode(jsonContent);

    // Adding to the records
    recordsList.add(sessionData);

    // Encoding the metadata to String
    updatedContent = jsonEncode(recordsList);

    await file.writeAsString(updatedContent);
    if (sessionDataDebug) pu.printd('Session Data: new session metadata: $sessionData saved to: ${file.path}'); 
  }

  /// Method used to retrieved all the session metadata used for a dashboard.
  /// This metadata is used in the context analyses dashboard, or in the group problem-solvings dashboard.
  /// The metadata retrieved has the format:
  /// \[{"title":"title1","date":"March 20, 2026 4:51 PM","filePath":"filePath1"},{"title":"title2","date":"March 20, 2026 5:31 PM","filePath":"filePath2"}\]
  Future<List<dynamic>> retrieveAllDashboardMetadata({
    required String typeOfDashboardContext,
  }) async {
    List<dynamic> sessionData;
    File sessionFile = await getSessionMetadataFile(
      typeOfDashboardContext: typeOfDashboardContext,
    );
    String fileContent = sessionFile.readAsStringSync();
    // Empty list if null, at least for testing purposes
    sessionData = jsonDecode(fileContent) ?? [];
    sessionData = sessionData.reversed.toList();

    return sessionData;
  }

  /// Method used to delete a specific session from the dashboard metadata file.
  /// It identifies the session by its unique file path.
  Future<void> deleteSpecificSessionMetadata({
    required String typeOfDashboardContext,
    required String filePathRelatedToDataToDelete,
  }) async {
    try {
      // Retrieving the correct JSON file based on the context
      File file = await getSessionMetadataFile(typeOfDashboardContext: typeOfDashboardContext);
      
      // Reading and decoding the existing records
      String jsonContent = await file.readAsString();
      List<dynamic> recordsList = jsonDecode(jsonContent);

      // Removing the record where the filePath matches the target
      int originalLength = recordsList.length;
      recordsList.removeWhere((session) => session[keyFilePath] == filePathRelatedToDataToDelete);

      // If a record was removed, saving the updated list back to the file
      if (recordsList.length < originalLength) {
        String updatedContent = jsonEncode(recordsList);
        await file.writeAsString(updatedContent);
        if (sessionDataDebug) pu.printd("Session Data: Session metadata with path $filePathRelatedToDataToDelete removed from dashboard metadata.");
      } else {
        if (sessionDataDebug) pu.printd("Session Data: No session metadata found with path $filePathRelatedToDataToDelete in dashboard metadata.");
      }
    } catch (e) {
      if (sessionDataDebug) pu.printd("Session Data: Error deleting session metadata from dashboard data: $e");
    }
  }

  /// Method used to save all sessions metadata.  
  Future<void> saveAllSessionsMetadata({required String typeOfDashboardContext, required List<dynamic> allSessionsMetadata}) async
  {
    String fileName = "";
    final applicationSupportDirectory = await getApplicationSupportDirectory();
    final pathToApplicationSupportDirectory = applicationSupportDirectory.path;

    // Getting file name according to context
    if (typeOfDashboardContext == caContext) 
    {
      fileName = 'dashboard_session_data_context_analyses.json';
    } 
    else if (typeOfDashboardContext == gpsContext) 
    {
      fileName = 'dashboard_session_data_group_problem_solvings.json';
    } 
    else 
    {
      if (sessionDataDebug) pu.printd("Session Data: Error: Unexpected type of dashboard context: $typeOfDashboardContext");
    }

    File sessionFile = File('$pathToApplicationSupportDirectory/$fileName');
    // Creating session file if doesn't exist
    if (!sessionFile.existsSync()) {sessionFile.createSync();}

    // Adding the metadata to the file
    var savedContent = jsonEncode(allSessionsMetadata);
    await sessionFile.writeAsString(savedContent);
    if (sessionDataDebug) pu.printd("Session Data: Session file for $typeOfDashboardContext restored: $pathToApplicationSupportDirectory/$fileName");
  }

  /// Method used to retrieved all the file names, from the user application folder (mobile applications).
  Future<List<String>> getStoredFileNamesOnMobile() async
  {
    if (sessionDataDebug) pu.printd("Session Data: getStoredFileNamesOnMobile: \n currentListOfStoredFileNames (before retrieval): $currentListOfStoredFileNames");
    // Getting the list of stored file names
    List<Object?> result = [];
    if(Platform.isAndroid)
    {result = await _platformAndroid.invokeMethod('listFiles');}
    else if(Platform.isIOS)
    {result = await _platformIOS.invokeMethod('listFiles');}    

    List<String> retrievedFileNames = result.cast<String>();
    // Verifying that the lists are different, while not empty
    if (cu.areListsEqualSets(currentListOfStoredFileNames, retrievedFileNames) && currentListOfStoredFileNames.isNotEmpty)
    {
      pu.printd("Error: retrievedFileNames and currentListOfStoredFileNames have the same elements.");
      pu.printd("Error: retrievedFileNames: $retrievedFileNames");
    }

    // Updating currentListOfStoredFileNames
    currentListOfStoredFileNames = retrievedFileNames;

    return retrievedFileNames;
  }
}
