import 'package:flutter/material.dart';

import 'package:journeyers/features/settings/user_preferences_helper.dart';

// Kept for educational purposes

void showCustomSnackbarStartMessage({required BuildContext buildContext, required String message, required Color messageColor,
required Duration duration, required String actiontext}) 
{
  final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

  void hideStartMessage() 
  {
    scaffoldMessenger.hideCurrentSnackBar();
    saveStartMessageAcknowledgement();    
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