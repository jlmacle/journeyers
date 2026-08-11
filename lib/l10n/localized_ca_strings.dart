import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedCAStrings
{
  AppLocalizations? _l10n;

  var dashboardTitle = "";

  LocalizedCAStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    dashboardTitle = _l10n?.ca_dashboard_title ?? "Issue with the dashboard title";
  }

}
