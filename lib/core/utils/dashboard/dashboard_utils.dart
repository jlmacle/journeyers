import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:path_provider/path_provider.dart';

/// {@category Utils}
/// A utility class related to the context analyses dashboard, and to the group problem-solvings dashboard.
class DashboardUtils {

  /// String used to communicate the context of the context analyses.
  static String dataContextAnalyses = "contextAnalysesData";
  /// String used to communicate the context of the group problem-solvings.
  static String dataGroupProblemSolvings = "groupProblemSolvingData";
  /// The root key for the session data stored for the dashboards.
  static String keyRecords = 'records';
  /// The key for the session data title.
  static String keyTitle = 'title';
  /// The key for the session data date.
  static String keyDate = 'date';
  /// The key for the session data file path.
  static String keyFilePath = 'filePath';

  /// Method used to retrieve the file with all the dashboard session data, either for the context analyses, or for the group problem-solvings. 
  Future<File> getSessionFile(String typeOfContextData) async {
    final directory = await getApplicationSupportDirectory();
    final path = directory.path;
    String fileName = "";
    if (typeOfContextData == dataContextAnalyses) {fileName = 'dashboard_session_data_context_analyses.json';}
    else if (typeOfContextData == dataGroupProblemSolvings) {fileName = 'dashboard_session_data_group_problem_solvings.json';}
    else {printd("Error: Unexpected type of context data: $typeOfContextData");}

    File sessionFile = File('$path/$fileName');
    if (!sessionFile.existsSync()) 
    {
      sessionFile.createSync();
      // Adding an empty map to the file
      Map<String,List<Map<String,String>>> records = {keyRecords:[]};    
      String content = jsonEncode(records);
      await sessionFile.writeAsString(content);
      printd("Session file for $typeOfContextData created: $path/$fileName");
    }
    return sessionFile;
  }

  /// Method used to save partial session data. 
  /// In the case of the context analyses, the partial data saved has the format:
  /// {"title":"analysis1","date":"12/19/25","filePath":"filePath1"}
  Future<void> saveSessionDataUsefulForDashboard(String typeOfContextData, Map<String,String> sessionData) async {

    final file = await getSessionFile(typeOfContextData);
    // file created in getSessionFile if needed
    
    String updatedContent = "";
    // Reading and decoding the records content
    String jsonContent = file.readAsStringSync();
    Map<String,dynamic> records =  jsonDecode(jsonContent);
    var recordsList = records[keyRecords];
    // Adding to the records
    recordsList.add(sessionData);
    records[keyRecords] = recordsList;
    // Encoding the data to String
    updatedContent = jsonEncode(records);
        
    await file.writeAsString(updatedContent);
    printd('Session data: $sessionData saved to: ${file.path}');
  }


  /// Method used to save dashboard data, either for a context analysis, or for a group problem-solving. 
  void saveDashboardData(String typeOfContextData, String analysisTitle, String filePath) async
  {
    // Date 
    var now = DateTime.now();
    var formatter = DateFormat('MM/dd/yy');
    var formattedDate = formatter.format(now);

    printd("formattedDate: $formattedDate");
    printd("analysisTitle: $analysisTitle");

    // Session data storage sample:
    // {"records":[{"title":"Title session 1","date":"12/12/25"]},
    // {"title":"Title session 2","date":"12/12/25},
    // {"title":"Title session 3","date":"12/12/25"}]}

    // Building the session data
    // In the context analysis form page, filePath is tested for not null
    // if (filePath != null) dashboardDataSaving(contextAnalysesData, analysisTitle, filePath);
    Map<String,String> sessionData = {keyTitle:analysisTitle, keyDate:formattedDate, keyFilePath:filePath};  
    // Saving the session data
    await saveSessionDataUsefulForDashboard(typeOfContextData, sessionData);
  }

  /// Method used to retrieved all the session data used for a dashboard.
  /// This data is used in the context analyses dashboard, or in the group problem-solvings dashboard.
  /// In the case of the context analyses, the data retrieved has the format:
  /// {"records":\[{"title":"analysis1","date":"12/19/25","filePath":"filePath1"},{"title":"analysis2","date":"12/20/25","filePath":"filePath2"}\]} 
  Future<Map<String,dynamic>> retrieveAllDashboardSessionData(String typeOfContextData) async
  { 
    Map<String,dynamic> completeSessionData;
    File sessionFile = await getSessionFile(typeOfContextData);
    String fileContent = sessionFile.readAsStringSync();
    completeSessionData = jsonDecode(fileContent);

    return completeSessionData;
  }
}