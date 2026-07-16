import "package:flutter/material.dart";

import "package:journeyers/app_themes.dart";

/// {@category Utility widgets}
/// {@category Process}
/// A widget used to display a screenwide button offering to start a new process.
class NewProcessButton extends StatelessWidget 
{
  /// The context of the dashboard (context analyses or group problem-solving sessions).
  final String dashboardContext;
  
  /// The text of the button.
  final String buttonText;

  /// A callback function called after pressing the button to start a new process.
  final VoidCallback onNewProcessButtonPressedCAPageCallbackFunction;

  const NewProcessButton
  ({
    super.key, 
    required this.dashboardContext, 
    required this.buttonText,
    required this.onNewProcessButtonPressedCAPageCallbackFunction
  });

  @override
  Widget build(BuildContext context) {
    return 
    // If so, a screen-wide rectangle, with an invite to start a new process
    SizedBox
    (
      width: double.infinity,
      child: 
        Container
        (
          decoration: BoxDecoration
          (
            border: Border.all(
              color:  blueShade900, 
              width: 5.0,
            ),
          ),
          child: ElevatedButton
          ( 
            // Sets _wasCA/GPS/SessionDataSaved to false to display the process page
            onPressed: () => onNewProcessButtonPressedCAPageCallbackFunction(),
            style: ElevatedButton.styleFrom
            (
              backgroundColor: white,
              padding: const EdgeInsets.only(top: 10, bottom: 16),
              shape: const RoundedRectangleBorder
              (
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: Padding
            (
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: Text
              (
                buttonText, 
                textAlign:TextAlign.center,
                style: elevatedButtonTextStyle
              ),
            ),  
          ),
        ),
    );
  }
}