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

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.caContext);
    var sessionToEdit = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePathWhenEdition).first as Map<String,dynamic>;
    var titleWhenEdition = sessionToEdit[DashboardUtils.keyTitle];
    List<String> keywordsWhenEdition = (sessionToEdit[DashboardUtils.keyKeywords] as List).cast<String>();

    // Getting the CSV content
    String fileNameWithExtension = path.basename(filePathWhenEdition);
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;
    String csvContent = await fu.readTextFile(filePath: filePathWhenEdition);

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

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.gpsContext);
    var sessionToEdit = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePathWhenEdition).first as Map<String,dynamic>;
    var titleWhenEdition = sessionToEdit[DashboardUtils.keyTitle];
    List<String> keywordsWhenEdition = (sessionToEdit[DashboardUtils.keyKeywords] as List).cast<String>();

    // Getting the TXT content
    String txtContent = await fu.readTextFile(filePath: filePathWhenEdition);
    String fileNameWithExtension = path.basename(filePathWhenEdition);
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

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
    
    // Getting the TXT content
    String fileNameWithExtension = path.basename(filePath);
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;
    var content = await fu.readTextFile(filePath: filePath);    
    var txtLines = LineSplitter.split(content).toList();

    // Getting the ideas
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
