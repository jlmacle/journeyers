import 'package:flutter/material.dart';

import 'package:journeyers/app_themes.dart';
import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';

//**************** UTILITY CLASS ****************//
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils(); 

/// {@category Utility widgets}
/// A widget used for choosing a file name, and saving a session file, on desktop platforms.
class FileNameDesktopPlatforms extends StatefulWidget 
{
  final VoidCallback parentCallbackFunctionToSaveDataAndMetadata;
  const FileNameDesktopPlatforms
  ({
    super.key,
    required this.parentCallbackFunctionToSaveDataAndMetadata,
  });

  @override
  State<FileNameDesktopPlatforms> createState() => _FileNameDesktopPlatformsState();
}

class _FileNameDesktopPlatformsState extends State<FileNameDesktopPlatforms> 
{

  @override
  Widget build(BuildContext context) {
    return 
    ElevatedButton
    (       
      onPressed: ()
      {
        widget.parentCallbackFunctionToSaveDataAndMetadata();        
      },
      child: const Text(
        'Click to save your data in CSV, \nspreadsheet-compatible format',
        style: elevatedButtonSaveDataOnDesktopStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}