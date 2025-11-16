import 'package:flutter/material.dart';

import 'package:journeyers/features/settings/user_preferences_helper.dart';

void showCustomMaterialBanner({required BuildContext buildContext, required String message, required Color messageColor,
required IconData iconData, required Color iconColor, 
required String actionText, required Color actionTextColor, required FontWeight actionTextFontweight}) {

final scaffoldMessenger = ScaffoldMessenger.of(buildContext);

  void hideBanner() {
    scaffoldMessenger.hideCurrentMaterialBanner();
    saveMaterialBannerDismissal();
    
  }

  scaffoldMessenger.showMaterialBanner(
    MaterialBanner(
      content: Text(
        message,
        style: TextStyle(color: messageColor),
      ),
      leading: Icon(iconData, color: iconColor),
      actions: <Widget>[
        TextButton(
          onPressed: hideBanner, 
          child: Text(
            actionText,
            style: TextStyle(color: actionTextColor, fontWeight: actionTextFontweight),
          ),
        ),
      ],
    ),
  );
}