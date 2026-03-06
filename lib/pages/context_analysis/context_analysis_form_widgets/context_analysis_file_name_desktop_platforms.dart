import 'package:flutter/material.dart';
import 'package:journeyers/app_themes.dart';

import 'package:journeyers/core/utils/printing_and_logging/print_utils.dart';
import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';
import 'package:journeyers/pages/context_analysis/context_analysis_form_page.dart';

//**************** UTILITY CLASS ****************//
PrintUtils pu = PrintUtils();
UserPreferencesUtils upu = UserPreferencesUtils(); 

// StatefulWidget necessary for overriding dispose() 

/// {@category Pages}
/// {@category Context analysis}
/// Defining file name and saving file for the context analysis, on desktop platforms.
class ContextAnalysisFileNameDesktopPlatforms extends StatefulWidget 
{
  /// A global key for the context analysis form page
  final GlobalKey<ContextAnalysisFormPageState> contextAnalysisFormPageKey;

  const ContextAnalysisFileNameDesktopPlatforms
  ({
    super.key,
    required this.contextAnalysisFormPageKey,
  });

  @override
  State<ContextAnalysisFileNameDesktopPlatforms> createState() => _ContextAnalysisFileNameDesktopPlatformsState();
}

class _ContextAnalysisFileNameDesktopPlatformsState extends State<ContextAnalysisFileNameDesktopPlatforms> 
{

  @override
  Widget build(BuildContext context) {
    return 
    ElevatedButton
    ( 
      onPressed: widget.contextAnalysisFormPageKey.currentState?.print2CSV,
      child: Text(
        'Click to save your data in CSV, \nspreadsheet-compatible format',
        style: elevatedButtonSaveDataOnDesktopStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}