import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedGPSStrings
{
  AppLocalizations? _l10n;

  // Dashboard customization
  var gpsTitleSuffix = "";

  // GPSProcess  
  var defaultSessionTitle = "";
  var participantIdentifiersSingleDeletionLabel = "";
  var participantIdentifiersBulkDeletionLabel = "";

  // GPSIdeasList
  var ideasListTitle = "";
  var ideasListPlaceholder = "";

  LocalizedGPSStrings(BuildContext context)
  { 
    _l10n = AppLocalizations.of(context);
    
    // Dashboard customization
    gpsTitleSuffix = _l10n?.gps_title_suffix ?? "Issue with the title suffix for a problem-solving session.";
  
    // GPSProcess
    defaultSessionTitle = _l10n?.gps_process_default_saved_title ?? "Issue with the default title when saving a problem-solving session.";
    participantIdentifiersSingleDeletionLabel = _l10n?.gps_process_edit_identifiers_clear_one ?? "Issue with the l10n for 'Clear\nOne'";
    participantIdentifiersBulkDeletionLabel = _l10n?.gps_process_edit_identifiers_clear_all ?? "Issue with the l10n for 'Clear\nAll'";
  
    // GPSIdeasList
    ideasListTitle =  _l10n?.gps_process_list_of_ideas_title ?? "Issue with the l10n for the 'List of ideas' title'";
    ideasListPlaceholder = _l10n?.gps_process_list_of_ideas_placeholder ?? "Issue with the l10n for the 'No ideas added yet.";
  }

}
