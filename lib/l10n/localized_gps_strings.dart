import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedGPSStrings
{
  AppLocalizations? _l10n;

  var gpsTitleSuffix = "";

  var ideasListTitle = "";

  // GPSProcess
  var participantIdentifiersSingleDeletionLabel = "";
  var participantIdentifiersBulkDeletionLabel = "";

  LocalizedGPSStrings(BuildContext context)
  { 
    _l10n = AppLocalizations.of(context);
       
    gpsTitleSuffix = _l10n?.gps_title_suffix ?? "Issue with the title suffix for a problem-solving session.";
  
    participantIdentifiersSingleDeletionLabel = _l10n?.gps_process_edit_identifiers_clear_one ?? "Issue with the l10n for 'Clear\nOne'";
  
    participantIdentifiersBulkDeletionLabel = _l10n?.gps_process_edit_identifiers_clear_all ?? "Issue with the l10n for 'Clear\nAll'";
  }

}
