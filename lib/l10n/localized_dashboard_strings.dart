import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedDashboardStrings
{
  AppLocalizations? _l10n;

  // ─── SORTING AND FILTERING ───────────────────────────────────────
  var filterByKeywordsLabel = "";
  var sortByDate = "";
  var sortByTitle = "";

  // ─── SNACKBARS ───────────────────────────────────────
  var snackbarMessageSessionSavedSuccessfully = "";

  // ─── KEYWORDS ───────────────────────────────────────
  var keywordsLabel = "";
  var keywordsEntryTextFieldHint = "";

  // ─── PREVIEW ───────────────────────────────────────
  var previewTooltipLabel = "";
  var previewClosingTooltipLabel = "";

  // ─── DATA DELETION ───────────────────────────────────────
  var deleteTooltipLabel = "";
  var snackbarMessageDataDeleted = "";

  // ─── DATA EDITION ───────────────────────────────────────
  var editFromDashboardItemTooltipLabel = "";

  // ─── KEYWORDS EDITION ───────────────────────────────────────
  var keywordsTextFieldLabel = "";
  var keywordsTooltipLabel = "";  
  var snackbarMessageKeywordsUpdated = "";
  
  // ─── TITLE EDITION ───────────────────────────────────────
  var emptyTitleEditError = "";
  var snackbarMessageTitleUpdated = "";

  // TODO: to clean
  LocalizedDashboardStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    // ─── SORTING AND FILTERING ───────────────────────────────────────
    filterByKeywordsLabel = _l10n?.dashboard_filter_by_keywords ?? "Issue with the 'Filter by Keywords' label";
    sortByDate = _l10n?.dashboard_sort_by_date ?? "Issue with the 'Sort by Date' label";
    sortByTitle = _l10n?.dashboard_sort_by_title ?? "Issue with the 'Sort by Title' label";

    // ─── SNACKBARS ───────────────────────────────────────
    snackbarMessageSessionSavedSuccessfully = _l10n?.dashboard_snackbar_message_session_saved_successfully ?? "Issue with the l10n for the 'Session data saved' snackbar message";
    
    // ─── KEYWORDS ───────────────────────────────────────
    keywordsLabel = _l10n?.dashboard_keywords ?? "Issue with the 'Keywords' label";
    keywordsEntryTextFieldHint = _l10n?.l10n_keywords_entry_text_field_hint ?? "Issue with the l10n for the keywords entry text field hint";
    
      
    // ─── PREVIEW ───────────────────────────────────────
    previewTooltipLabel = _l10n?.dashboard_tooltip_preview ?? "Issue with the l10n for the 'Preview' tooltip";
    previewClosingTooltipLabel = _l10n?.dashboard_preview_close_preview_tooltip ?? "Issue with the l10n for the preview 'Close the preview' tooltip";
    
    // ─── DATA DELETION ───────────────────────────────────────
    deleteTooltipLabel = _l10n?.dashboard_tooltip_delete ?? "Issue with the l10n for the 'Delete data' tooltip";
    snackbarMessageDataDeleted = _l10n?.dashboard_snackbar_message_data_deleted ?? "Issue with the l10n for the 'Data deleted' snackbar message";
    
    // ─── DATA EDITION ───────────────────────────────────────
    editFromDashboardItemTooltipLabel = _l10n?.dashboard_tooltip_edit_session_data ?? "Issue with the l10n for the 'Edit session data' tooltip";
    
    // ─── KEYWORDS EDITION ───────────────────────────────────────
    keywordsTextFieldLabel = _l10n?.dashboard_edit_keywords_sheet_label_text ?? "Issue with the l10n for the 'Keywords Edition' label text";
    keywordsTooltipLabel = _l10n?.dashboard_tooltip_edit_keywords ?? "Issue with the l10n for the 'Edit Keywords' tooltip";
    snackbarMessageKeywordsUpdated = _l10n?.dashboard_snackbar_message_keywords_updated ?? "Issue with the l10n for the 'Keywords updated' snackbar message";
   
    // ─── TITLE EDITION ───────────────────────────────────────
    emptyTitleEditError = _l10n?.dashboard_edit_title_error_empty_title ?? "Issue with the l10n for the 'Title cannot be empty.' error message";
    snackbarMessageTitleUpdated = _l10n?.dashboard_edit_title_snackbar_message ?? "Issue with the l10n for the 'Title updated' snackbar message";
   
  }
}
