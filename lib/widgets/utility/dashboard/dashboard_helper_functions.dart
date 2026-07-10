import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/pages/group_problem_solving/group_problem_solving_process_widgets/dto_gps_form.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/test_utils.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';


// Method used to retrieve context analysis session data before edition
Future<void> retrieveCASessionData
({
  required String dashboardContext,
  required String filePathWhenEdition, 
  required OnRetrievedSessionDataBeforeEditionCallbackFunctionType onRetrievedCASessionDataBeforeEditionCallbackFunction
}) async {
    String csvContent = "";
    String fileNameWithExtension = path.basename(filePathWhenEdition);
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.caContext);
    var sessionToEdit = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePathWhenEdition).first as Map<String,dynamic>;
    var titleWhenEdition = sessionToEdit[DashboardUtils.keyTitle];
    List<String> keywordsWhenEdition = (sessionToEdit[DashboardUtils.keyKeywords] as List).cast<String>();

    // Getting the CSV content
    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: retrieveCASessionData on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!isInTestEnvironment) { csvContent = await fu.readTextFileOnAndroidTmp(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: retrieveCASessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePathWhenEdition).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Editing: retrieveCASessionData: Exception: CA on Android:$filePathWhenEdition: $e: $s"); }
    }
    else if (Platform.isIOS)
    {
      if (editDebug) pu.printd("Editing: retrieveCASessionData on iOS");
      try
      {
        // Outside of testing
        if (!isInTestEnvironment) { csvContent = await fu.readTextFileOnIOSTmp(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Editing: retrieveCASessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePathWhenEdition).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Editing: retrieveCASessionData: Exception: CA on iOS: $e: $s"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      if (editDebug) pu.printd("Editing: retrieveCASessionData on desktop");
      // Checking if the CSV file exists
      File csvFile = File(filePathWhenEdition);
      if (!csvFile.existsSync()) throw Exception("Editing: retrieveCASessionData: The CSV file doesn't exist: $filePathWhenEdition (${Platform.operatingSystem})");
      csvContent = await csvFile.readAsString();
    }

    // Loading the data from the CSV into a DTO
    DTOCAForm dtoWhenEdition = DTOCAForm.fromCSV(csvContent);
    dtoWhenEdition.printToConsole();

    Set<String> keywordsSetWhenEdition = keywordsWhenEdition.toSet();

    if (editDebug) pu.printd("Editing: retrieveCASessionData: titleWhenEdition: $titleWhenEdition");
    if (editDebug) pu.printd("Editing: retrieveCASessionData: keywordsWhenEdition: $keywordsSetWhenEdition");
    if (editDebug) pu.printd("Editing: retrieveCASessionData: dtoWhenEdition: ");
    if (editDebug) dtoWhenEdition.printToConsole();
    if (editDebug) pu.printd("Editing: retrieveCASessionData: fileNameWithoutExtension: $fileNameWithoutExtension");

    // CA process page re-build with the loaded data
    onRetrievedCASessionDataBeforeEditionCallbackFunction
    (
      dashboardContext: dashboardContext,
      isSessionDataBeingEdited: true, 
      dtoWhenEdition: dtoWhenEdition, 
      fileNameWithoutExtensionWhenEdition: fileNameWithoutExtension, 
      titleWhenEdition: titleWhenEdition, 
      keywordsWhenEdition: keywordsSetWhenEdition,
      filePathWhenEdition: filePathWhenEdition
    );
  }

// Method used to retrieve group problem-solving session data before edition
Future<void> retrieveGPSSessionData
({
  required String dashboardContext,
  required String filePathWhenEdition, 
  required OnRetrievedSessionDataBeforeEditionCallbackFunctionType onRetrievedGPSSessionDataBeforeEditionCallbackFunction
}) async {
    String txtContent = "";
    String fileNameWithExtension = path.basename(filePathWhenEdition);
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.gpsContext);
    var sessionToEdit = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePathWhenEdition).first as Map<String,dynamic>;
    var titleWhenEdition = sessionToEdit[DashboardUtils.keyTitle];
    List<String> keywordsWhenEdition = (sessionToEdit[DashboardUtils.keyKeywords] as List).cast<String>();

    // Getting the TXT content
    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: retrieveGPSSessionData on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!isInTestEnvironment) { txtContent = await fu.readTextFileOnAndroidTmp(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: retrieveGPSSessionData: Reading $fileNameWithExtension from tmp folder");
          txtContent = await File(filePathWhenEdition).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Editing: retrieveGPSSessionData: Exception: GPS on Android:$filePathWhenEdition: $e: $s"); }
    }
    else if (Platform.isIOS)
    {
      if (editDebug) pu.printd("Editing: retrieveGPSSessionData on iOS");
      try
      {
        // Outside of testing
        if (!isInTestEnvironment) { txtContent = await fu.readTextFileOnIOSTmp(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Editing: retrieveGPSSessionData: Reading $fileNameWithExtension from tmp folder");
          txtContent = await File(filePathWhenEdition).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Editing: retrieveGPSSessionData: Exception: GPS on iOS: $e: $s"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      if (editDebug) pu.printd("Editing: retrieveGPSSessionData on desktop");
      // Checking if the TXT file exists
      File txtFile = File(filePathWhenEdition);
      if (!txtFile.existsSync()) throw Exception("Editing: retrieveGPSSessionData: The CSV file doesn't exist: $filePathWhenEdition (${Platform.operatingSystem})");
      txtContent = await txtFile.readAsString();
    }

    // Loading the data from the TXT into a DTO
    DTOGPSForm dtoWhenEdition = await DTOGPSForm.fromTXT(txtContent);
    dtoWhenEdition.printToConsole();

    Set<String> keywordsSetWhenEdition = keywordsWhenEdition.toSet();

    if (editDebug) pu.printd("Editing: retrieveGPSSessionData: titleWhenEdition: $titleWhenEdition");
    if (editDebug) pu.printd("Editing: retrieveGPSSessionData: keywordsWhenEdition: $keywordsSetWhenEdition");
    if (editDebug) pu.printd("Editing: retrieveGPSSessionData: dtoWhenEdition: ");
    if (editDebug) dtoWhenEdition.printToConsole();
    if (editDebug) pu.printd("Editing: retrieveGPSSessionData: fileNameWithoutExtension: $fileNameWithoutExtension");

    // GPS process page re-build with the loaded data
    onRetrievedGPSSessionDataBeforeEditionCallbackFunction
    (
      dashboardContext: dashboardContext,
      isSessionDataBeingEdited: true, 
      dtoWhenEdition: dtoWhenEdition, 
      fileNameWithoutExtensionWhenEdition: fileNameWithoutExtension, 
      titleWhenEdition: titleWhenEdition, 
      keywordsWhenEdition: keywordsSetWhenEdition,
      filePathWhenEdition: filePathWhenEdition
    );
  }


// Method used to edit group problem-solving session data
Future<List<String>> retrieveGPSIdeas(String filePath, OnRetrievedSessionDataBeforeEditionCallbackFunctionType onEditGPSSessionDataCallbackFunction) async {

    // Getting the title
    List<dynamic> sessionsMetadataAll  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.gpsContext);
    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: sessionsMetadataAll : $sessionsMetadataAll");
    var sessionToEditMetadata = sessionsMetadataAll.where((session) => session[DashboardUtils.keyFilePath] == filePath).first as Map<String,dynamic>;
    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: sessionToEditMetadata : $sessionToEditMetadata");
    
    var title = sessionToEditMetadata[DashboardUtils.keyTitle];

    var content = "";
    String fileNameWithExtension = path.basename(filePath);
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: retrieveGPSIdeas on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!isInTestEnvironment) { content = await fu.readTextFileOnAndroidTmp(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: Editing: retrieveGPSIdeas: Reading $fileNameWithExtension from tmp folder");
          content = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Dashboard helper functions: retrieveGPSIdeas: Exception: GPS on Android: $e: $s"); }
    }
    else if (Platform.isIOS)
    {
      if (editDebug) pu.printd("Editing: retrieveGPSIdeas on iOS");
      try
      {
        // Outside of testing
        if (!isInTestEnvironment) { content = await fu.readTextFileOnIOSTmp(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: Editing: retrieveGPSIdeas: Reading $fileNameWithExtension from tmp folder");
          content = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Dashboard helper functions: retrieveGPSIdeas: Exception: GPS on iOS: $e: $s"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      // Checking if the CSV file exists
      File txtFile = File(filePath);
      if (!txtFile.existsSync()) throw Exception("Dashboard helper functions: retrieveGPSIdeas: The TXT file doesn't exist: $filePath (${Platform.operatingSystem})");
      content = txtFile.readAsStringSync();
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

    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: original ideas: $ideas");
    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: original fileNameWithoutExtension: $fileNameWithoutExtension");
    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: original title: $title");
    
    return ideas;
  }
