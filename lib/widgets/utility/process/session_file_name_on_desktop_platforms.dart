import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";

/// {@category Utility widgets}
/// {@category Process}
/// A widget used for choosing a file name, and saving a session file, on desktop platforms.
class SessionFileNameOnDesktopPlatforms extends StatefulWidget 
{
  /// The text for the 'Save' button.
  final String savebuttonText;

  /// The callback function called when saving data.
  final VoidCallback parentCallbackFunctionToSaveDataAndMetadata;

  const SessionFileNameOnDesktopPlatforms
  ({
    super.key,
    required this.savebuttonText,
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
      child: Text(
        widget.savebuttonText,
        style: elevatedButtonSaveDataOnDesktopStyle,
        textAlign: TextAlign.center,
      ),
    );
  }
}