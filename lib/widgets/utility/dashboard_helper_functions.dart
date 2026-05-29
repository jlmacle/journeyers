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
      if (editDebug) pu.printd("Editing: editSessionData on Android");
      try
      {
        // Outside of testing: reading file using SAF
        if (!runningTests) { csvContent = await fu.readTextFileOnAndroid(fileNameWithExtension: fileNameWithExtension);}
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Testing Debug: editSessionData: Reading $fileNameWithExtension from tmp folder");
          csvContent = await File(filePath).readAsString();
        }
      }
      on Exception
      catch(e) {pu.printd("Editing: Exception: CA on Android: $e"); }
    }
    else if (Platform.isIOS)
    {
      if (previewBuildingDebug) pu.printd("Editing: editSessionData on iOS");
      try
      {
        // Outside of testing
        if (!runningTests) { csvContent = await fu.readTextFileOnIOS(fileNameWithExtension: fileNameWithExtension); }
        // While testing
        else 
        { 
          if (testingDebug) pu.printd("Editing: editSessionData: Reading $fileNameWithExtension from tmp folder");
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
    if (editDebug) pu.printd("Editing: editSessionData: editedFileNameWithoutExtension: $editedFileNameWithoutExtension");
    if (editDebug) pu.printd("Editing: editSessionData: editedTitle: $editedTitle");
    onEditSessionDataCallbackFunction(sessionDataEdition: true, dtoForEdition: dtoForEdition, editedFileNameWithoutExtension: editedFileNameWithoutExtension, editedTitle: editedTitle);
    
  }
