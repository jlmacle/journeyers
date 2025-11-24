import 'package:flutter/material.dart';

import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';

/// Kept for illustration purposes. The rectangular dismissable area is used instead.

/// A helper method to show a custom snackbar
void showCustomSnackbarStartMessage
({
  /// The build context
  required BuildContext buildContext, 
  /// The message to display 
  required String message, 
  /// The color of the message to display
  required Color messageColor,
  /// The duration of the snackbar display
  required Duration duration, 
  /// The text to act upon to dismiss the snackbar
  required String actiontext
}) 
{
  final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

  /// A helper method to hide the custom snackbar
  void hideStartMessage() 
  {
    scaffoldMessenger.hideCurrentSnackBar();
    saveStartSnackbarMessageAcknowledgement();    
  }

  scaffoldMessenger.showSnackBar(
    SnackBar(
      content: Text(
        message,
        style: TextStyle(color: messageColor),
      ),
      duration: duration,
      action: SnackBarAction
      (
        label: actiontext, 
        onPressed: hideStartMessage

      )
    ),
  );
}