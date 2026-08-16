import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedParticipantsStrings
{
  AppLocalizations? _l10n;

  var listsDashboardTitle = "";

  LocalizedParticipantsStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);    
    
    listsDashboardTitle = _l10n?.text_lists_dashboard_title ?? "Issue with the title for the participants lists dashboard";
   
  }
}
