import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

import 'package:path_provider/path_provider.dart';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_export.dart';


/// {@category Utils - Generic}
/// A generic utility class related to the context analyses dashboard, and to the group problem-solvings dashboard.
class DashboardUtils {

  /// String used to communicate the context of the context analyses.
  static const String contextAnalysesContext = "contextAnalysesData";

  /// String used to communicate the context of the group problem-solvings.
  static const String groupProblemSolvingsContext = "groupProblemSolvingData";

  /// The key for the session data title.
  static const String keyTitle = 'title';

  /// The key for the file keywords
  static const String keyKeywords = 'keywords';

  /// The key for the session data date.
  static const String keyDate = 'date';

  /// The key for the session data file path.
  static const String keyFilePath = 'filePath';

  /// The current list of stored file names (for the mobile applications).
  List<String> currentListOfStoredFileNames = [];  

  //**************** SMARTPHONES CHANNELS ****************//
  // Android: storage access framework (reading/saving files)
  static const _platformAndroid = MethodChannel('dev.journeyers/saf');
  // Android: storage access framework (reading/saving files)
  static const _platformIOS = MethodChannel('dev.journeyers/iossaf');

  /// Method used to retrieve the file with all the dashboard session data, 
  /// either for the context analyses, or for the group problem-solvings.
  Future<File> getSessionMetadataFile({required String typeOfContextData}) async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    String fileName = "";
    if (typeOfContextData == contextAnalysesContext) {
      fileName = 'dashboard_session_data_context_analyses.json';
    } else if (typeOfContextData == groupProblemSolvingsContext) {
      fileName = 'dashboard_session_data_group_problem_solvings.json';
    } else {
      if (sessionDataDebug) pu.printd("Session Data: Error: Unexpected type of context data: $typeOfContextData");
    }

    File sessionFile = File('$path/$fileName');
    if (!sessionFile.existsSync()) {
      sessionFile.createSync();
      // Adding an empty map to the file
      List<Map<String, String>> records = [];
      String content = jsonEncode(records);
      await sessionFile.writeAsString(content);
      if (sessionDataDebug) pu.printd("Session Data: Session file for $typeOfContextData created: $path/$fileName");
    }
    return sessionFile;
  }

  /// Method used to save partial session data.
  /// In the case of the context analyses, the partial data saved has the format:
  /// {"title":"analysis1","keywords":["keyword1","keyword2"], "date":"12/19/25","filePath":"filePath1"}
  Future<void> _saveSessionMetadataHelper
  ({
    required String typeOfContextData,
    required Map<String, dynamic> sessionData,
  }) async 
  {
    File file = await getSessionMetadataFile(typeOfContextData: typeOfContextData);
    // file created in getSessionFile if needed

    String updatedContent = "";
    // Reading and decoding the records content
    String jsonContent = file.readAsStringSync();
    List<dynamic> recordsList = jsonDecode(jsonContent);
    // Adding to the records
    recordsList.add(sessionData);
    // Encoding the data to String
    updatedContent = jsonEncode(recordsList);

    await file.writeAsString(updatedContent);
    if (sessionDataDebug) pu.printd('Session Data: new session metadata: $sessionData saved to: ${file.path}');
  }

  /// Method used to save dashboard data, either for a context analysis, or for a group problem-solving.
  Future<void> saveDashboardMetadata
  ({
    required String typeOfContextData,
    required String? title,
    required List<String> keywords,
    required String formattedDate,
    required String pathToFile,
  }) 
  async {
    if (sessionDataDebug) pu.printd("Session Data: formattedDate: $formattedDate");
    if (sessionDataDebug) pu.printd("Session Data: analysisTitle: $title");

    // Session data storage sample:
    // [{"title":"Title session 1","keywords":["keyword1","keyword2"], "date":"01/18/26","filePath":"filePath1"},
    // {"title":"Title session 2","keywords":["keyword1","keyword3"], "date":"01/18/26","filePath":"filePath2"},
    // {"title":"Title session 3","keywords":["keyword1","keyword4"], "date":"01/18/26","filePath":"filePath3"}]

    // Building the session data
    // In the context analysis form page, filePath is tested for not null
    // if (filePath != null) dashboardDataSaving(contextAnalysesData, analysisTitle, filePath);
    Map<String, dynamic> sessionData = 
    {
      keyTitle: title ?? "Untitled",
      keyKeywords: keywords,
      keyDate: formattedDate,
      keyFilePath: pathToFile,
    };
    // Saving the session data
    await _saveSessionMetadataHelper
    (
      typeOfContextData: typeOfContextData,
      sessionData: sessionData,
    );
  }

  /// Method used to retrieved all the session data used for a dashboard.
  /// This data is used in the context analyses dashboard, or in the group problem-solvings dashboard.
  /// In the case of the context analyses, the data retrieved has the format:
  /// \[{"title":"analysis1","date":"12/19/25","filePath":"filePath1"},{"title":"analysis2","date":"12/20/25","filePath":"filePath2"}\]
  Future<List<dynamic>> retrieveAllDashboardMetadata({
    required String typeOfContextData,
  }) async {
    List<dynamic> sessionData;
    File sessionFile = await getSessionMetadataFile(
      typeOfContextData: typeOfContextData,
    );
    String fileContent = sessionFile.readAsStringSync();
    // Empty list if null, at least for testing purposes
    sessionData = jsonDecode(fileContent) ?? [];
    sessionData = sessionData.reversed.toList();

    return sessionData;
  }

  /// Method used to delete a specific session from the dashboard data file.
  /// It identifies the session by its unique file path.
  Future<void> deleteSpecificSessionMetadata({
    required String typeOfContextData,
    required String filePathRelatedToDataToDelete,
  }) async {
    try {
      // Retrieving the correct JSON file based on the context
      File file = await getSessionMetadataFile(typeOfContextData: typeOfContextData);
      
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
        if (sessionDataDebug) pu.printd("Session Data: Session data with path $filePathRelatedToDataToDelete removed from dashboard data.");
      } else {
        if (sessionDataDebug) pu.printd("Session Data: No session data found with path $filePathRelatedToDataToDelete in dashboard data.");
      }
    } catch (e) {
      if (sessionDataDebug) pu.printd("Session Data: Error deleting session data from dashboard data: $e");
    }
  }

  /// Method used to save all session data.  
  Future<void> saveAllSessionsMetadata({required String typeOfContextData, required List<dynamic> allSessionsMetadata}) async
  {
    String fileName = "";
    final applicationSupportDirectory = await getApplicationSupportDirectory();
    final pathToApplicationSupportDirectory = applicationSupportDirectory.path;

    // Getting file name according to context
    if (typeOfContextData == contextAnalysesContext) 
    {
      fileName = 'dashboard_session_data_context_analyses.json';
    } 
    else if (typeOfContextData == groupProblemSolvingsContext) 
    {
      fileName = 'dashboard_session_data_group_problem_solvings.json';
    } 
    else 
    {
      if (sessionDataDebug) pu.printd("Session Data: Error: Unexpected type of context data: $typeOfContextData");
    }

    File sessionFile = File('$pathToApplicationSupportDirectory/$fileName');
    // Creating session file if doesn't exist
    if (!sessionFile.existsSync()) {sessionFile.createSync();}

    // Adding the data to the file
    var savedContent = jsonEncode(allSessionsMetadata);
    await sessionFile.writeAsString(savedContent);
    if (sessionDataDebug) pu.printd("Session Data: Session file for $typeOfContextData restored: $pathToApplicationSupportDirectory/$fileName");
  }

  /// Method used to retrieved all the file names, from the user application folder.
  Future<List<String>> getStoredFileNamesOnMobile() async
  {
    // Getting the list of stored file names
    List<Object?> result;
    if(Platform.isAndroid)
    {result = await _platformAndroid.invokeMethod('listFiles');}
    else
    {result = await _platformIOS.invokeMethod('listFiles');}    

    List<String> retrievedFileNames = result.cast<String>();
    // Verifying that the lists are different
    if(retrievedFileNames. )

    // Updating currentListOfStoredFileNames
    currentListOfStoredFileNames = retrievedFileNames;
    if (sessionDataDebug) pu.printd("Session Data: storedFileNames: $retrievedFileNames");

    return retrievedFileNames;
  }
}
