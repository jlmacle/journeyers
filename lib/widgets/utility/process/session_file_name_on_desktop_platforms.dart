import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";

/// {@category Utility widgets}
/// {@category Process}
/// A widget used for choosing a file name, and saving a session file, on desktop platforms.
class SessionFileNameOnDesktopPlatforms extends StatefulWidget 
{
  final VoidCallback parentCallbackFunctionToSaveDataAndMetadata;
  const SessionFileNameOnDesktopPlatforms
  ({
    super.key,
    required this.parentCallbackFunctionToSaveDataAndMetadata,
  });

  @override
  State<SessionFileNameOnDesktopPlatforms> createState() => _SessionFileNameOnDesktopPlatformsState();
}

class _SessionFileNameOnDesktopPlatformsState extends State<SessionFileNameOnDesktopPlatforms> 
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
        "Click to save your data in CSV, \nspreadsheet-compatible format",
        style: elevatedButtonSaveDataOnDesktopStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}