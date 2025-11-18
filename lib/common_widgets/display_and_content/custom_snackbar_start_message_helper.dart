import 'package:flutter/material.dart';

import 'package:journeyers/core/utils/settings_and_preferences/user_preferences_utils.dart';

// Kept for educational purposes

void showCustomSnackbarStartMessage({required BuildContext buildContext, required String message, required Color messageColor,
required Duration duration, required String actiontext}) 
{
  final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

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