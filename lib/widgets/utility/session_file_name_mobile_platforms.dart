import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/type_defs.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart' as tfu_gen;
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_checked_using_a_black_list.dart';

// StatefulWidget necessary for overriding dispose() 

/// {@category Utility widgets}
/// A widget used for selecting a folder to save session files, defining a file name, and saving a session file, on mobile platforms.
class SessionFileNameMobilePlatforms extends StatefulWidget 
{
  /// The file extension when saving the session data ('.' included)
  final String fileExtension;

  /// A callback function called after editing the title is complete.
  final ValueChanged<String> onFileNameSubmittedCallbackFunction;

  /// A callback function called to save context analysis data and metadata.
  final VoidCallback parentCallbackFunctionToSaveDataAndMetadata; 

  const SessionFileNameMobilePlatforms
  ({
    super.key,
    required this.fileExtension,
    required this.onFileNameSubmittedCallbackFunction,
    required this.parentCallbackFunctionToSaveDataAndMetadata,
  });

  @override
  State<SessionFileNameMobilePlatforms> createState() => _SessionFileNameMobilePlatformsState();
}

class _SessionFileNameMobilePlatformsState extends State<SessionFileNameMobilePlatforms> 
{
  final TextEditingController _fileNameController = .new();

  /// A map with (CSV files) blacklisting functions as keys, and error messages as values.
  static const Map<BlacklistingFunction, String> blacklistingFunctionsErrorsMappingForCSVFileNames = 
  {
    tfu_gen.TextFieldUtils.fileNameAlreadyUsedCSV : tfu_gen.TextFieldUtils.errorFileNameAlreadyUsed
  }; 

   /// A map with (TXT files) blacklisting functions as keys, and error messages as values.
  static const Map<BlacklistingFunction, String> blacklistingFunctionsErrorsMappingForTXTFileNames = 
  {
    tfu_gen.TextFieldUtils.fileNameAlreadyUsedTXT : tfu_gen.TextFieldUtils.errorFileNameAlreadyUsed
  }; 
  
  final GlobalKey<_SessionFileNameMobilePlatformsState> errorMessageKey = .new();

  // ─── SMARTPHONES CHANNELS ───────────────────────────────────────
  // Android: storage access framework (reading/saving files)
  static const platformAndroid = MethodChannel('dev.journeyers/saf');
  // Android: storage access framework (reading/saving files)
  static const platformIOS = MethodChannel('dev.journeyers/iossaf');

  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  String _applicationFolderPath = "";  

  // method used to get the set folder path for the application
  void getApplicationFolderPathPref() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference

    String? folderPathData = await upu.getApplicationFolderPath();

    if (sessionDataDebug) pu.printd("Session Data: folderPathData: $folderPathData");
    // Application folder path called from the Kotlin/Swift code    
    setState(() 
    {
      _applicationFolderPath = folderPathData ?? "";
    });
  }

  @override
  void initState() {
    super.initState();
    if (sessionDataDebug) pu.printd("Session Data: file extensions: ${widget.fileExtension}");
    getApplicationFolderPathPref();
  }

  @override
  void dispose()
  {
    _fileNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return 
    _applicationFolderPath == ""
    ? ElevatedButton(
      onPressed: () async 
      {
        // Triggers UIDocumentPicker on iOS via the AppDelegate implementation
        String? result;
        if (Platform.isAndroid)
          {result = await platformAndroid.invokeMethod('openDirectory');}
        else if (Platform.isIOS)
          {result = await platformIOS.invokeMethod('openDirectory');}
        
        if (result != null) {
          // Refreshing local state with the new path/bookmark
          getApplicationFolderPathPref(); 
        }
      },
      child: Text(textAlign: TextAlign.center, Platform.isIOS 
          ? 'Please select a folder\nfor app storage' 
          : 'Please select or create a folder\nfor app storage'),
    )
    : TextFieldSanitizedAndCheckedUsingABlackList
    (
      textFieldCounter: tfu_gen.TextFieldUtils.absentCounter,
      textFieldStyle: commonTextFieldStyle , 
      textFieldHint: 'Please add the file name, without ${widget.fileExtension}, here.', 
      textFieldHintStyle: commonTextFieldHintStyle, 
      errorMessageStyle: commonTextFieldErrorMessageStyle, 
      onTextFieldValueSubmittedCallbackFunction: widget.onFileNameSubmittedCallbackFunction, 
      additionalOnSubmittedInstructions: 
        (String newValue) async
        {
          if (newValue.isNotEmpty)
          { // Saving data 
            widget.parentCallbackFunctionToSaveDataAndMetadata();
            await upu.reload();
          }
        },
      stringSanitizerBundlesErrorsMapping: TextFieldstringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForFileNames,
      blacklistingFunctionsErrorsMapping: 
      (widget.fileExtension == tfu_gen.TextFieldUtils.extensionCSV) 
        ? blacklistingFunctionsErrorsMappingForCSVFileNames
        // otherwise .txt
        : blacklistingFunctionsErrorsMappingForTXTFileNames
    );
  }
}