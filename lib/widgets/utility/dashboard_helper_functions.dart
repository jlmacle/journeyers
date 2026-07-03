import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as path;

import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_process_widgets/dto_ca_form.dart';
import 'package:journeyers/utils/generic/dashboard/dashboard_utils.dart';
import 'package:journeyers/utils/generic/dev/test_utils.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';


// Method used to edit context analysis session data
Future<void> editCASessionData
({
  required String dashboardContext,
  required String filePath, 
  required OnEditSessionDataCallbackFunctionType onEditCASessionDataCallbackFunction
}) async {
    // to clean
    String csvContent = "";
    String fileNameWithExtension = filePath.split('/').last;
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    // Getting the title
    List<dynamic> sessionDataRetrieved  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.caContext);
    var session = sessionDataRetrieved.where((session) => session[DashboardUtils.keyFilePath] == filePath).first as Map<String,dynamic>;
    var title = session[DashboardUtils.keyTitle];
    List<String> keywords = (session[DashboardUtils.keyKeywords] as List).cast<String>();

    // Getting the CSV content
    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: editCASessionData on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!isInTestEnvironment) { csvContent = await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: editCASessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Editing: Exception: CA on Android:$filePath: $e: $s"); }
    }
    else if (Platform.isIOS)
    {
      if (editDebug) pu.printd("Editing: editCASessionData on iOS");
      try
      {
        // Outside of testing
        if (!isInTestEnvironment) { csvContent = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Editing: editCASessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e, s) {pu.printd("Editing: Exception: CA on iOS: $e: $s"); }
    }
    else if (Platform.isLinux || Platform.isMacOS | Platform.isWindows)
    {
      if (editDebug) pu.printd("Editing: editCASessionData on desktop");
      // Checking if the CSV file exists
      File csvFile = File(filePath);
      if (!csvFile.existsSync()) throw Exception("The CSV file doesn't exist: $filePath (${Platform.operatingSystem})");
      csvContent = await csvFile.readAsString();
    }

    // Loading the data from the CSV into a DTO
    DTOCAForm dtoForEdition = DTOCAForm.fromCSV(csvContent);
    dtoForEdition.printToConsole();

    Set<String> keywordsForEdition = keywords.toSet();

    // Deleting the previous file and metadata
    await deleteFile(filePath: filePath);
    if (editDebug) pu.printd("Editing: editCASessionData: sessionDataRetrieved (before file deletion): $sessionDataRetrieved");
    sessionDataRetrieved.removeWhere
    (
      (session) => (session[DashboardUtils.keyFilePath]).contains(filePath)
    );
    if (editDebug) pu.printd("Editing: editCASessionData: sessionDataRetrieved (after file deletion): $sessionDataRetrieved");
    // Saving the updated metadata
    await du.saveAllSessionsMetadata(typeOfDashboardContext: DashboardUtils.caContext, sessionsMetadataAll: sessionDataRetrieved);

    if (editDebug) pu.printd("Editing: editCASessionData: title: $title");
    if (editDebug) pu.printd("Editing: editCASessionData: keywordsForEdition: $keywordsForEdition");
    if (editDebug) pu.printd("Editing: editCASessionData: dtoForEdition: ");
    if (editDebug) dtoForEdition.printToConsole();
    if (editDebug) pu.printd("Editing: editCASessionData: fileNameWithoutExtension: $fileNameWithoutExtension");


    // Need to re-build the dashboard page    
    onEditCASessionDataCallbackFunction
    (
      dashboardContext: dashboardContext,
      isSessionDataBeingEdited: true, 
      dtoForEdition: dtoForEdition, 
      fileNameWithoutExtensionWhenEdition: fileNameWithoutExtension, 
      titleWhenEdition: title, 
      keywordsWhenEdition: keywordsForEdition
    );

  }


// Method used to edit group problem-solving session data
Future<List<String>> retrieveGPSIdeas(String filePath, OnEditSessionDataCallbackFunctionType onEditGPSSessionDataCallbackFunction) async {

    // Getting the title
    List<dynamic> sessionsMetadataAll  = await du.retrieveAllDashboardMetadata(typeOfDashboardContext: DashboardUtils.gpsContext);
    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: sessionsMetadataAll : $sessionsMetadataAll");
    var sessionToEditMetadata = sessionsMetadataAll.where((session) => session[DashboardUtils.keyFilePath] == filePath).first as Map<String,dynamic>;
    if (editDebug) pu.printd("Editing: retrieveGPSIdeas: sessionToEditMetadata : $sessionToEditMetadata");
    
    var title = sessionToEditMetadata[DashboardUtils.keyTitle];

    var content = "";
    String fileNameWithExtension = filePath.split('/').last;
    String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

    if (Platform.isAndroid)
    {      
      if (editDebug) pu.printd("Editing: retrieveGPSIdeas on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!isInTestEnvironment) { content = await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension);}
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
        if (!isInTestEnvironment) { content = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
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

  
Future<void> deleteFile({required String filePath}) async
{
  String fileNameWithExtension = path.basename(filePath);
  String fileNameWithoutExtension = fileNameWithExtension.split('.').first;

  if (editDebug) pu.printd("Editing: deleteFile: filePath: $filePath");
  if (editDebug) pu.printd("Editing: deleteFile: fileNameWithExtension: $fileNameWithExtension");
  if (editDebug) pu.printd("Editing: deleteFile: fileNameWithoutExtension: $fileNameWithoutExtension");

  // Removing existing file and metadata before saving
  try 
  {
      String? folderPath = await rtdu.getApplicationFolderPath();
      filePath = "$folderPath/$fileNameWithExtension";
      var fileExtension = ".csv";

      // On Android
      if (Platform.isAndroid) 
      {
        if (!isInTestEnvironment) {
          await fu.deleteFile(filePath);
          await du.deleteSpecificSessionMetadata(typeOfDashboardContext: DashboardUtils.caContext, filePathRelatedToDataToDelete: filePath);
        }
        else {
          var applicationFolderPath = await rtdu.getApplicationFolderPath();
          filePath = path.join(applicationFolderPath!, "$fileNameWithoutExtension$fileExtension");
          await fu.deleteFile(filePath);
          await du.deleteSpecificSessionMetadata(typeOfDashboardContext: DashboardUtils.caContext, filePathRelatedToDataToDelete: filePath);
        }
      } 

      // On iOS
      else if (Platform.isIOS) 
      {
        if (!isInTestEnvironment) {
          await fu.deleteFile(filePath);
          await du.deleteSpecificSessionMetadata(typeOfDashboardContext: DashboardUtils.caContext, filePathRelatedToDataToDelete: filePath);
           }
        else {
          var applicationFolderPath = await rtdu.getApplicationFolderPath();
          filePath = path.join(applicationFolderPath!, "$fileNameWithoutExtension$fileExtension");
          await fu.deleteFile(filePath);
          await du.deleteSpecificSessionMetadata(typeOfDashboardContext: DashboardUtils.caContext, filePathRelatedToDataToDelete: filePath);
        }
      } 
      // On desktop
      else 
      {
        await fu.deleteFile(filePath);
        await du.deleteSpecificSessionMetadata(typeOfDashboardContext: DashboardUtils.caContext, filePathRelatedToDataToDelete: filePath);     
      }    
  } catch (e) {
    pu.printd("Delete Error: $e");
  }  

}
