import 'dart:convert';
import 'dart:io';

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';

// Method used to edit context analysis session data
Future<void> editCASessionData(String filePath, FunctionDTOCAForm2StringsAndBool onEditSessionDataCallbackFunction) async {
    // to clean
    String csvContent = "";
    String fileNameWithExtension = filePath.split('/').last;
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.caContext);
    var session = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePath).first as Map<String,dynamic>;
    var title = session[DashboardUtils.keyTitle];

    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: editCASessionData on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!runningTests) { csvContent = await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: editCASessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e) {pu.printd("Editing: Exception: CA on Android: $e"); }
    }
    else if (Platform.isIOS)
    {
      if (previewBuildingDebug) pu.printd("Editing: editCASessionData on iOS");
      try
      {
        // Outside of testing
        if (!runningTests) { csvContent = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Editing: editCASessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e) {pu.printd("Editing: Exception: CA on iOS: $e"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      // Checking if the CSV file exists
      File csvFile = File(filePath);
      if (!csvFile.existsSync()) throw Exception("The CSV file doesn't exist: $filePath (${Platform.operatingSystem})");
      csvContent = csvFile.readAsStringSync();
    }

    // Loading the data from the CSV into a DTO
    DTOCAForm dtoForEdition = DTOCAForm.fromCSV(csvContent);

    // Building the edited versions of title and file name
    String editedFileNameWithoutExtension = "$fileNameWithoutExtension-edited";
    String editedTitle = "$title-for-edition";

    if (editDebug) dtoForEdition.printToConsole();
    if (editDebug) pu.printd("Editing: editCASessionData: editedFileNameWithoutExtension: $editedFileNameWithoutExtension");
    if (editDebug) pu.printd("Editing: editCASessionData: editedTitle: $editedTitle");
    onEditSessionDataCallbackFunction(sessionDataEdition: true, dtoForEdition: dtoForEdition, editedFileNameWithoutExtension: editedFileNameWithoutExtension, editedTitle: editedTitle);
    
  }


// Method used to edit group problem-solving session data
Future<List<String>> editGPSSessionData(String filePath, FunctionDTOCAForm2StringsAndBool onEditSessionDataCallbackFunction) async {
    if (editDebug) pu.printd("Editing: editGPSSessionData : $editGPSSessionData");

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.gpsContext);
    if (editDebug) pu.printd("Editing: sessionDataRetrieved : $sessionDataRetrieved");
    var sessionData = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePath).first as Map<String,dynamic>;
    if (editDebug) pu.printd("Editing: sessionData : $sessionData");
    
    var title = sessionData[DashboardUtils.keyTitle];

    var content = "";
    String fileNameWithExtension = filePath.split('/').last;
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: editGPSSessionData on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!runningTests) { content = await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: editGPSSessionData: Reading $fileNameWithExtension from tmp folder");
          content = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e) {pu.printd("Editing: Exception: GPS on Android: $e"); }
    }
    else if (Platform.isIOS)
    {
      if (previewBuildingDebug) pu.printd("Editing: editGPSSessionData on iOS");
      try
      {
        // Outside of testing
        if (!runningTests) { content = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Editing: editGPSSessionData: Reading $fileNameWithExtension from tmp folder");
          content = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e) {pu.printd("Editing: Exception: CA on iOS: $e"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      // Checking if the CSV file exists
      File csvFile = File(filePath);
      if (!csvFile.existsSync()) throw Exception("The CSV file doesn't exist: $filePath (${Platform.operatingSystem})");
      content = csvFile.readAsStringSync();
    }

    var txtLines = LineSplitter.split(content).toList();
    List<String> ideas = [];
    if (txtLines.length >= 2) {       
        // Ideas start after the "---" separator (index 3 onwards)
        // We strip the "1. ", "2. " numbering prefix
        ideas = txtLines
            .skip(4)
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceFirst(RegExp(r'^\d+\.\s'), ''))
            .toList();        
      }

    // Loading the data from the CSV into a DTO
    DTOCAForm dtoForEdition = DTOCAForm.fromCSV(content);

    // Building the edited versions of title and file name
    String editedFileNameWithoutExtension = "$fileNameWithoutExtension-edited";
    String editedTitle = "$title-for-edition";

    if (editDebug) pu.printd("Editing: editGPSSessionData: ideas: $ideas");

    if (editDebug) pu.printd("Editing: editGPSSessionData: editedFileNameWithoutExtension: $editedFileNameWithoutExtension");
    if (editDebug) pu.printd("Editing: editGPSSessionData: editedTitle: $editedTitle");
    // onEditSessionDataCallbackFunction(sessionDataEdition: true, dtoForEdition: dtoForEdition, editedFileNameWithoutExtension: editedFileNameWithoutExtension, editedTitle: editedTitle);
    
    return ideas;
  }

  

