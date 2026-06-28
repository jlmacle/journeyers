import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/debug_constants.dart';
import 'package:journeyers/utils/generic/dev/utility_classes_import.dart';
import 'package:journeyers/utils/generic/text_fields/text_field_utils.dart' as tfu_gen;
import 'package:journeyers/utils/project_specific/text_fields/text_field_utils.dart';
import 'package:journeyers/widgets/custom/interaction_and_inputs/custom_text_field_sanitized_and_checked_using_a_blacklist.dart';
import 'package:journeyers/widgets/utility/process_widgets/process_const_strings.dart';

/// {@category Utility widgets}
/// {@category Process}
/// A widget used for selecting a folder to save session files, defining a file name, and saving a session file, on mobile platforms.
class SessionFileNameOnMobilePlatforms extends StatefulWidget 
{
  /// A file name value used at editing time.
  final String fileNameWhenEdition;

  /// The file extension when saving the session data ('.' included)
  final String fileExtension;

  /// The callback function called when the file name is submitted.
  final ValueChanged<String> onFileNameSubmittedProcessCallbackFunction;

  /// A callback function called to save session data and metadata.
  final VoidCallback parentCallbackFunctionToSaveDataAndMetadata; 

  const SessionFileNameOnMobilePlatforms
  ({
    super.key,
    required this.fileNameWhenEdition,
    required this.fileExtension,
    required this.onFileNameSubmittedProcessCallbackFunction,
    required this.parentCallbackFunctionToSaveDataAndMetadata,
  });

  @override
  State<SessionFileNameOnMobilePlatforms> createState() => _SessionFileNameOnMobilePlatformsState();
}

class _SessionFileNameOnMobilePlatformsState extends State<SessionFileNameOnMobilePlatforms> 
{
  final TextEditingController _fileNameTfec = .new();  
  
  final GlobalKey<_SessionFileNameOnMobilePlatformsState> _errorMessageKey = .new();

  // ─── SMARTPHONES CHANNELS ───────────────────────────────────────
  // Android: storage access framework (reading/saving files)
  static const _platformAndroid = MethodChannel('dev.journeyers/saf');
  // Android: storage access framework (reading/saving files)
  static const _platformIOS = MethodChannel('dev.journeyers/iossaf');

  // ─── PREFERENCES related data and methods ───────────────────────────────────────
  String _applicationFolderPath = "";  

  // method used to get the set folder path for the application
  void _getApplicationFolderPath() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference

    String? folderPathData = await rtdu.getApplicationFolderPath();

    if (sessionDataDebug) pu.printd("Session Data: Path to the application folder selected by the user: $folderPathData");
    setState(() 
    {
      _applicationFolderPath = folderPathData ?? "";
    });
  }

  @override
  void didUpdateWidget(covariant SessionFileNameOnMobilePlatforms oldWidget) {
    super.didUpdateWidget(oldWidget);

    pu.printdLine();
    pu.printd("SessionFileNameOnMobilePlatforms: didUpdateWidget");
  }

  @override
  void initState() {
    super.initState();

    pu.printdLine();
    pu.printd("SessionFileNameOnMobilePlatforms");

    if (sessionDataDebug) pu.printd("Session Data: file extension: ${widget.fileExtension}");
    _getApplicationFolderPath();

    // Edited file name value if relevant
    if (editDebug) pu.printd("Editing: SessionFileNameOnMobilePlatforms: initState: file name when edition: ${widget.fileNameWhenEdition}");
    _fileNameTfec.text = widget.fileNameWhenEdition;
  }

  @override
  void dispose()
  {
    _fileNameTfec.dispose();
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
          {result = await _platformAndroid.invokeMethod('openDirectory');}
        else if (Platform.isIOS)
          {result = await _platformIOS.invokeMethod('openDirectory');}
        
        if (result != null) {
          // Refreshing local state with the new path/bookmark
          _getApplicationFolderPath(); 

        // Retrieving the stored file names once the path to the folder is defined
        await du.getStoredFileNamesOnMobile();  
        }
      },
      child: Text
      (
        textAlign: TextAlign.center, 
        Platform.isIOS 
        ? labelFolderPickerIOS  
        : labelFolderPickerAndroid
      ),
    )
    : TextFieldSanitizedAndCheckedUsingABlackList
    (
      textFieldStartValue: widget.fileNameWhenEdition,
      textFieldCounter: tfu_gen.TextFieldUtils.counterAbsent,
      textFieldStyle: commonTextFieldStyle, 
      textFieldHint: 'Please add the file name, without ${widget.fileExtension}, here.', 
      textFieldHintStyle: commonTextFieldHintStyle, 
      errorMessageStyle: commonTextFieldErrorMessageStyle, 
      onTextFieldValueSubmittedCallbackFunction: (value) async
      { widget.onFileNameSubmittedProcessCallbackFunction(value);
      
        if (value.isNotEmpty)
        { // Saving data 
          widget.parentCallbackFunctionToSaveDataAndMetadata();
          await rtdu.reload();
        }
      }, 
     
      stringSanitizerBundlesErrorsMapping: TextFieldStringSanitizerBundlesErrorsMappings.stringSanitizerBundlesErrorsMappingForFileNames,
      blacklistingFunctionsErrorsMapping: 
      (widget.fileExtension == tfu_gen.TextFieldUtils.extensionCSV) 
        ? TextFieldStringSanitizerBundlesErrorsMappings.blacklistingFunctionsErrorsMappingForCSVFileNames
        // otherwise .txt
        : TextFieldStringSanitizerBundlesErrorsMappings.blacklistingFunctionsErrorsMappingForTXTFileNames
    );
  }
}