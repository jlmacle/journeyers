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

  /// The root key for the session data stored for the dashboards.
  static String keyRecords = 'records';

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
      Map<String, List<Map<String, String>>> records = {keyRecords: []};
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
  Future<void> saveSessionDataUsefulForDashboard
  ({
    required String typeOfContextData,
    required Map<String, dynamic> sessionData,
  }) async 
  {
    final file = await getSessionFile(typeOfContextData: typeOfContextData);
    // file created in getSessionFile if needed

    String updatedContent = "";
    // Reading and decoding the records content
    String jsonContent = file.readAsStringSync();
    Map<String, dynamic> records = jsonDecode(jsonContent);
    var recordsList = records[keyRecords];
    // Adding to the records
    recordsList.add(sessionData);
    records[keyRecords] = recordsList;
    // Encoding the data to String
    updatedContent = jsonEncode(records);

    await file.writeAsString(updatedContent);
    _pu.printd('Session data: $sessionData saved to: ${file.path}');
  }

  /// Method used to save dashboard data, either for a context analysis, or for a group problem-solving.
  void saveDashboardData
  ({
    required String typeOfContextData,
    required String analysisTitle,
    required List<String> keywords,
    required String pathToCSVFile,
  }) 
  async {
    // Date
    var now = DateTime.now();
    var formatter = DateFormat('MM/dd/yy');
    var formattedDate = formatter.format(now);

    _pu.printd("formattedDate: $formattedDate");
    _pu.printd("analysisTitle: $analysisTitle");

    // Session data storage sample:
    // {"records":[{"title":"Title session 1","keywords":["keyword1","keyword2"], "date":"01/18/26","filePath":"filePath1"},
    // {"title":"Title session 2","keywords":["keyword1","keyword3"], "date":"01/18/26","filePath":"filePath2"},
    // {"title":"Title session 3","keywords":["keyword1","keyword4"], "date":"01/18/26","filePath":"filePath3"}]}

    // Building the session data
    // In the context analysis form page, filePath is tested for not null
    // if (filePath != null) dashboardDataSaving(contextAnalysesData, analysisTitle, filePath);
    Map<String, dynamic> sessionData = 
    {
      keyTitle: analysisTitle,
      keyKeywords: keywords,
      keyDate: formattedDate,
      keyFilePath: pathToCSVFile,
    };
    // Saving the session data
    await saveSessionDataUsefulForDashboard
    (
      typeOfContextData: typeOfContextData,
      sessionData: sessionData,
    );
  }

  /// Method used to retrieved all the session data used for a dashboard.
  /// This data is used in the context analyses dashboard, or in the group problem-solvings dashboard.
  /// In the case of the context analyses, the data retrieved has the format:
  /// {"records":\[{"title":"analysis1","date":"12/19/25","filePath":"filePath1"},{"title":"analysis2","date":"12/20/25","filePath":"filePath2"}\]}
  Future<Map<String, dynamic>> retrieveAllDashboardSessionData({
    required String typeOfContextData,
  }) async {
    Map<String, dynamic> completeSessionData;
    File sessionFile = await getSessionFile(
      typeOfContextData: typeOfContextData,
    );
    String fileContent = sessionFile.readAsStringSync();
    completeSessionData = jsonDecode(fileContent);

    return completeSessionData;
  }
}
