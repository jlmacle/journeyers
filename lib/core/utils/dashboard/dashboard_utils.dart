import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:path_provider/path_provider.dart';


late int dataRank;
String contextAnalysesData = "contextAnalysesData";
String contextGroupProblemSolvingData = "contextGroupProblemSolvingData";
String recordsKey = 'records';
String titleKey = 'title';
String dateKey = 'date';
String filePathKey = 'filePath';

/// Method used to retrieve session data
Future<File> getSessionFile(String typeOfContextData) async {
  final directory = await getApplicationSupportDirectory();
  final path = directory.path;
  String fileName = "";
  if (typeOfContextData == contextAnalysesData) {fileName = 'dashboard_session_data_context_analyses.json';}
  else if (typeOfContextData == contextGroupProblemSolvingData) {fileName = 'dashboard_session_data_group_problem_solvings.json';}
  else {printd("Error: Unexpected type of context data: $typeOfContextData");}

  File sessionFile = File('$path/$fileName');
  if (!sessionFile.existsSync()) {sessionFile.createSync();}
  return sessionFile;
}

/// Method used to store on file session data
Future<void> saveSessionData(String typeOfContextData, Map<String,String> sessionContent) async {

  final file = await getSessionFile(typeOfContextData);
  if (!file.existsSync()){printd("Error: saveSessionData: file doesn't exist: $file");}
  
  String updatedContent = "";

  // if the file is empty
  if (file.readAsStringSync().trim() == "")
  {
     Map<String,List<Map<String,String>>> records = {recordsKey:[sessionContent]};    
     updatedContent = jsonEncode(records);
  }
  else
  {
    // if the file is not empty
    // Reading and decoding the records content
    String jsonContent = file.readAsStringSync();
    Map<String,dynamic> records =  jsonDecode(jsonContent);
    var recordsList = records[recordsKey];
    // Adding to the records
    recordsList?.add(sessionContent);
    records[recordsKey] = recordsList!;
    // Encoding the data to String
    updatedContent = jsonEncode(records);
  }
    
  await file.writeAsString(updatedContent);
  printd('Session saved to: ${file.path}');
}


/// Method called by the widget to store the session data 
void dashboardDataSaving(String typeOfContextData, String analysisTitle, String filePath) async
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
  Map<String,String> sessionData = {titleKey:analysisTitle, dateKey:formattedDate, filePathKey:filePath};  
  // Saving the session data
  await saveSessionData(typeOfContextData, sessionData);
}

/// Method used to retrieved all the session data stored
Future<Map<String,dynamic>> sessionDataRetrieval(String typeOfContextData) async
{ 
  Map<String,dynamic> completeSessionData;
  File sessionFile = await getSessionFile(typeOfContextData);
  String fileContent = sessionFile.readAsStringSync();
  completeSessionData = jsonDecode(fileContent);

  return completeSessionData;
}
