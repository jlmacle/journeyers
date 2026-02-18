import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:path_provider/path_provider.dart';

/// {@category Utils}
/// A utility class related to the context analyses dashboard, and to the group problem-solvings dashboard.
class DashboardUtils {
  // Utility class
  final PrintUtils _pu = PrintUtils();

  /// String used to communicate the context of the context analyses.
  static String contextAnalysesContext = "contextAnalysesData";

  /// String used to communicate the context of the group problem-solvings.
  static String groupProblemSolvingsContext = "groupProblemSolvingData";

  /// The key for the session data title.
  static String keyTitle = 'title';

  /// The key for the file keywords
  static String keyKeywords = 'keywords';

  /// The key for the session data date.
  static String keyDate = 'date';

  /// The key for the session data file path.
  static String keyFilePath = 'filePath';

  /// Method used to retrieve the file with all the dashboard session data, either for the context analyses, or for the group problem-solvings.
  Future<File> getSessionFile({required String typeOfContextData}) async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    String fileName = "";
    if (typeOfContextData == contextAnalysesContext) {
      fileName = 'dashboard_session_data_context_analyses.json';
    } else if (typeOfContextData == groupProblemSolvingsContext) {
      fileName = 'dashboard_session_data_group_problem_solvings.json';
    } else {
      _pu.printd("Error: Unexpected type of context data: $typeOfContextData");
    }

    File sessionFile = File('$path/$fileName');
    if (!sessionFile.existsSync()) {
      sessionFile.createSync();
      // Adding an empty map to the file
      List<Map<String, String>> records = [];
      String content = jsonEncode(records);
      await sessionFile.writeAsString(content);
      _pu.printd(
        "Session file for $typeOfContextData created: $path/$fileName",
      );
    }
    return sessionFile;
  }

  /// Method used to save partial session data.
  /// In the case of the context analyses, the partial data saved has the format:
  /// {"title":"analysis1","keywords":["keyword1","keyword2"], "date":"12/19/25","filePath":"filePath1"}
  Future<void> _saveSessionDataHelper
  ({
    required String typeOfContextData,
    required Map<String, dynamic> sessionData,
  }) async 
  {
    File file = await getSessionFile(typeOfContextData: typeOfContextData);
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
    _pu.printd('Session data: $sessionData saved to: ${file.path}');
  }

  /// Method used to save dashboard data, either for a context analysis, or for a group problem-solving.
  Future<void> saveDashboardData
  ({
    required String typeOfContextData,
    required String? analysisTitle,
    required List<String> keywords,
    required String pathToCSVFile,
  }) 
  async {
    // Date
    var now = DateTime.now();
    //.add_jm() to add this hour:minutes format: 5:08 PM
    var formatter = DateFormat('MMMM dd, yyyy').add_jm();
    var formattedDate = formatter.format(now);

    _pu.printd("formattedDate: $formattedDate");
    _pu.printd("analysisTitle: $analysisTitle");

    // Session data storage sample:
    // [{"title":"Title session 1","keywords":["keyword1","keyword2"], "date":"01/18/26","filePath":"filePath1"},
    // {"title":"Title session 2","keywords":["keyword1","keyword3"], "date":"01/18/26","filePath":"filePath2"},
    // {"title":"Title session 3","keywords":["keyword1","keyword4"], "date":"01/18/26","filePath":"filePath3"}]

    // Building the session data
    // In the context analysis form page, filePath is tested for not null
    // if (filePath != null) dashboardDataSaving(contextAnalysesData, analysisTitle, filePath);
    Map<String, dynamic> sessionData = 
    {
      keyTitle: analysisTitle ?? "Untitled",
      keyKeywords: keywords,
      keyDate: formattedDate,
      keyFilePath: pathToCSVFile,
    };
    // Saving the session data
    await _saveSessionDataHelper
    (
      typeOfContextData: typeOfContextData,
      sessionData: sessionData,
    );
  }

  /// Method used to retrieved all the session data used for a dashboard.
  /// This data is used in the context analyses dashboard, or in the group problem-solvings dashboard.
  /// In the case of the context analyses, the data retrieved has the format:
  /// \[{"title":"analysis1","date":"12/19/25","filePath":"filePath1"},{"title":"analysis2","date":"12/20/25","filePath":"filePath2"}\]
  Future<List<dynamic>> retrieveAllDashboardSessionData({
    required String typeOfContextData,
  }) async {
    List<dynamic> completeSessionData;
    File sessionFile = await getSessionFile(
      typeOfContextData: typeOfContextData,
    );
    String fileContent = sessionFile.readAsStringSync();
    completeSessionData = jsonDecode(fileContent);
    completeSessionData = completeSessionData.reversed.toList();
    print("");
    print("");
    print("completeSessionData: $completeSessionData");
    print("");
    return completeSessionData;
  }

  /// Method used to delete a specific session from the dashboard data file.
  /// It identifies the session by its unique file path.
  Future<void> deleteSessionData({
    required String typeOfContextData,
    required String filePathToDelete,
  }) async {
    try {
      // Retrieving the correct JSON file based on the context
      File file = await getSessionFile(typeOfContextData: typeOfContextData);
      
      // Reading and decoding the existing records
      String jsonContent = await file.readAsString();
      List<dynamic> recordsList = jsonDecode(jsonContent);

      // Removing the record where the filePath matches the target
      int originalLength = recordsList.length;
      recordsList.removeWhere((session) => session[keyFilePath] == filePathToDelete);

      // If a record was removed, saving the updated list back to the file
      if (recordsList.length < originalLength) {
        String updatedContent = jsonEncode(recordsList);
        await file.writeAsString(updatedContent);
        _pu.printd('Session with path $filePathToDelete removed from dashboard index.');
      } else {
        _pu.printd('No session found with path $filePathToDelete in dashboard index.');
      }
    } catch (e) {
      _pu.printd("Error deleting session data from dashboard index: $e");
    }
  }

  /// Method used to restore session data from copied session data 
  Future<void> restoreCopiedSessionData({required String typeOfContextData, required List<dynamic> savedData}) async
  {
    String fileName = "";
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;

    // Getting file name according to context
    if (typeOfContextData == contextAnalysesContext) 
    {
      fileName = 'dashboard_session_data_context_analyses.json';
    } else if (typeOfContextData == groupProblemSolvingsContext) 
    {
      fileName = 'dashboard_session_data_group_problem_solvings.json';
    } 
    else 
    {
      _pu.printd("Error: Unexpected type of context data: $typeOfContextData");
    }

    File sessionFile = File('$path/$fileName');
    // Creating session file if doesn't exist
    if (!sessionFile.existsSync()) {sessionFile.createSync();}

    // Adding the data to the file
    var savedContent = jsonEncode(savedData);
    await sessionFile.writeAsString(savedContent);
    _pu.printd("Session file for $typeOfContextData restored: $path/$fileName");

  }

  /// Method used to save session data  
  Future<void> saveSessionData({required String typeOfContextData, required List<dynamic> savedData}) async
  {
      await restoreCopiedSessionData(typeOfContextData: typeOfContextData, savedData: savedData);
  }
}
