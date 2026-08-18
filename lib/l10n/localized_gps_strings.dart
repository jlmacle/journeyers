import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedGPSStrings
{
  AppLocalizations? _l10n;

  // Dashboard customization
  var gpsTitleSuffix = "";

  // GPSProcess  
  var gpsDefaultProcessSessionTitle = "";
  var gpsDefaultSavedSessionTitle = "";
  var participantIdentifiersSingleDeletionLabel = "";
  var participantIdentifiersBulkDeletionLabel = "";

  // GPSProblemToSolveDeclaration
  var gpsProcessTitleTextFieldHint = "";

  // GPSChecklist
  var checkListTitle = "";

  // GPSKeywordsDeclaration
  var gpsKeywordsTitle = "";

  // GPSIdeasList
  var ideasListTitle = "";
  var ideasListPlaceholder = "";
  var ideasListEmptyListSnackbarMessage = "";

  LocalizedGPSStrings(BuildContext context)
  { 
    _l10n = AppLocalizations.of(context);
    
    // Dashboard customization
    gpsTitleSuffix = _l10n?.gps_title_suffix ?? "Issue with the title suffix for a problem-solving session.";
  
    // GPSProcess
    gpsDefaultProcessSessionTitle = _l10n?.gps_process_default_title ?? "Issue with the l10n for the default title for a problem-solving session.";
    gpsDefaultSavedSessionTitle = _l10n?.gps_process_default_saved_title ?? "Issue with the default title when saving a problem-solving session.";
    participantIdentifiersSingleDeletionLabel = _l10n?.gps_process_edit_identifiers_clear_one ?? "Issue with the l10n for 'Clear\nOne'";
    participantIdentifiersBulkDeletionLabel = _l10n?.gps_process_edit_identifiers_clear_all ?? "Issue with the l10n for 'Clear\nAll'";
  
    // GPSProblemToSolveDeclaration
    gpsProcessTitleTextFieldHint = _l10n?.gps_process_edit_title_text_field_hint ?? "Issue with the l10n for the 'Please enter a title or select below' text field hint'";

    // GPSChecklist
    checkListTitle = _l10n?.gps_process_checklist_title ?? "Issue with the title for the checklist-related widget.";

    // GPSKeywordsDeclaration
    gpsKeywordsTitle = _l10n?.l10n_keywords ?? "Issue with the l10n for 'Keywords'.";

    // GPSIdeasList
    ideasListTitle =  _l10n?.gps_process_list_of_ideas_title ?? "Issue with the l10n for the 'List of ideas' title'";
    ideasListPlaceholder = _l10n?.gps_process_list_of_ideas_placeholder ?? "Issue with the l10n for the 'No ideas added yet.";
    ideasListEmptyListSnackbarMessage = _l10n?.gps_process_snackbar_message_no_ideas_to_save ?? "Issue with the l10n for the 'No ideas to save' snackbar message";
  }

}
