import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/debug_constants.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//**************** UTILITY CLASS ****************//
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils(); 

// StatefulWidget necessary for overriding dispose() 

/// {@category Pages}
/// {@category Context analysis}
/// A widget used for selecting a folder to save the files, defining file name, and saving file, for the context analysis, on mobile platforms.
class ContextAnalysisFileNameMobilePlatforms extends StatefulWidget 
{
  /// A callback function called after editing the title is complete.
  final ValueChanged<String> parentWidgetCallbackFunctionOnEditingComplete;

  /// A global key for the context analysis form page
  final GlobalKey<ContextAnalysisFormPageState> contextAnalysisFormPageKey;

  const ContextAnalysisFileNameMobilePlatforms
  ({
    super.key,
    required this.parentWidgetCallbackFunctionOnEditingComplete,
    required this.contextAnalysisFormPageKey,
  });

  @override
  State<ContextAnalysisFileNameMobilePlatforms> createState() => _ContextAnalysisFileNameMobilePlatformsState();
}

class _ContextAnalysisFileNameMobilePlatformsState extends State<ContextAnalysisFileNameMobilePlatforms> 
{
  // FILE NAME
  String? _fileName;
  final TextEditingController _fileNameController = TextEditingController();
  String _errorMessageForFileName = "";
  bool _wasErrorMessageModified = false;
  bool _fileNameExists = false;

  //**************** SMARTPHONES CHANNELS ****************//
  // Android: storage access framework (reading/saving files)
  static const platformAndroid = MethodChannel('dev.journeyers/saf');
  // Android: storage access framework (reading/saving files)
  static const platformIOS = MethodChannel('dev.journeyers/iossaf');

  //**************** PREFERENCES related data and methods ****************/
  bool _isApplicationFolderPathLoading = true;
  String _applicationFolderPath = "";  

  // method used to get the set folder path for the application
  void getApplicationFolderPathPref() async
  { 
    var prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // necessary to have access to the newly set preference
    String? folderPathData = await upu.getApplicationFolderPath();
    if (Platform.isAndroid || Platform.isIOS)  {    if (sessionDataDebug) pu.printd("Session Data: folderPathData: $folderPathData");}
    // Application folder path called from the Kotlin code    
    setState(() {_isApplicationFolderPathLoading = false; _applicationFolderPath = folderPathData ?? "";});
  }

  // Method used to avoid an extension in the file name
  // and to avoid the use of a previous file name
  // (Android and iOS only)
  void fileNameCheck(value) async
  {
    // Getting the list of stored file names
    List<Object?> result;
    if(Platform.isAndroid)
    {result = await platformAndroid.invokeMethod('listFiles');}
    else
    {result = await platformIOS.invokeMethod('listFiles');}
    
    List<String> fileNamesList = result.cast<String>();
    pu.printd("Session Data: fileNamesList: $fileNamesList");

    String completeFileName = "$value.csv";
    pu.printd("Session Data: completeFileName: |$completeFileName|");
     
    // if the file name exists already
    if (fileNamesList.contains(completeFileName))
    {
      setState(() 
      {
        // Updates the error message
        _errorMessageForFileName = 'File name not available. Please use a different file name.';        
      });
      _wasErrorMessageModified = true;
      _fileNameExists = true;
      // "The assertiveness level of the announcement is determined by assertiveness.
      // Currently, this is only supported by the web engine and has no effect on other platforms.
      // The default mode is Assertiveness.polite."
      // https://api.flutter.dev/flutter/semantics/SemanticsService/sendAnnouncement.html
      // TODO:  TextDirection.ltr: code to modify for l10n
      // Doesn't seem effective yet. Left for later.
      SemanticsService.sendAnnouncement(View.of(context), _errorMessageForFileName, TextDirection.ltr, assertiveness: Assertiveness.assertive);
    }
    // if the file name contains .
    else if (value.contains('.')) 
    {
      value = value.replaceAll('.', '');
      setState(() 
      {
        // Removes the dots from the file name
        _fileNameController.text = value;
        // Updates the error message
        _errorMessageForFileName = 'Dots are removed, as no extension should be entered in the file name.';
      });
      _fileNameExists = false;
      _wasErrorMessageModified = true;
      // "The assertiveness level of the announcement is determined by assertiveness.
      // Currently, this is only supported by the web engine and has no effect on other platforms.
      // The default mode is Assertiveness.polite."
      // https://api.flutter.dev/flutter/semantics/SemanticsService/sendAnnouncement.html
      // TODO:  TextDirection.ltr: code to modify for l10n
      // Doesn't seem effective yet. Left for later.
      SemanticsService.sendAnnouncement(View.of(context), _errorMessageForFileName, TextDirection.ltr, assertiveness: Assertiveness.assertive);
    }
    // otherwise, the file name doesn't need modification
    else 
    {
      if (_wasErrorMessageModified)
      {
        setState(() 
        {
          _errorMessageForFileName = "";
        });
        _fileNameExists = false;
        _wasErrorMessageModified = false;
      }
      else 
      {
        _wasErrorMessageModified = false; 
        _fileNameExists = false;
      }
    }
  }

  @override
  void initState() {
    super.initState();
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
      child: Text(Platform.isIOS 
          ? 'Please select a folder for app storage' 
          : 'Please select or create a folder for app storage'),
    )
  : TextField(
      controller: _fileNameController,
      style: analysisTextFieldStyle,
      decoration: InputDecoration
      (
          hint: Center(child: Text('Please add the file name, without .csv, here.', style: analysisTextFieldHintStyle)),
          errorText: _errorMessageForFileName,
          errorMaxLines: 3
      ),
      textAlign: TextAlign.center,
      onChanged: (String newValue) {
        fileNameCheck(newValue);                            
      },
      onSubmitted: _fileNameExists
      ?
        (value){}
      : (value) async {
        _fileName = value.trim(); 
        widget.contextAnalysisFormPageKey.currentState?.analysisFileNameUpdate(_fileName!);
        // Saving data 
        await widget.contextAnalysisFormPageKey.currentState?.print2CSV();
        await upu.reload();
      },
    );
  }
}