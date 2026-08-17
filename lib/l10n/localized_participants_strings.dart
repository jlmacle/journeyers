import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedParticipantsStrings
{
  AppLocalizations? _l10n;

  // The title for the participants dashboard
  var listsDashboardTitle = "";
  // Sorting by list name label
  var listsSortByLabel = "" ;

  LocalizedParticipantsStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);    
    
     // The title for the participants dashboard
    listsDashboardTitle = _l10n?.text_lists_dashboard_title ?? "Issue with the title for the participants lists dashboard";
    // Sorting by list name label
    listsSortByLabel = _l10n?.text_lists_dashboard_sort_by_list_name ?? "Issue with the l10n for the 'List sort' label";
 
  }
}
