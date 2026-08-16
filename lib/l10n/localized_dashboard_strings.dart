import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedDashboardStrings
{
  AppLocalizations? _l10n;

  // Sorting and filtering
  var filterByKeywordsLabel = "";
  var sortByDate = "";
  var sortByTitle = "";

  // ─── SNACKBARS ───────────────────────────────────────
  var snackbarMessageSessionSavedSuccessfully = "";
  var snackbarMessageDataDeleted = "";
  var snackbarMessageKeywordsUpdated = "";

  // ─── SESSIONS ITEM ───────────────────────────────────────
  var keywordsLabel = "";

  // Tooltips
  var previewTooltipLabel = "";
  var previewClosingTooltipLabel = "";
  var editFromDashboardItemTooltipLabel = "";
  var keywordsTooltipLabel = "";
  var deleteTooltipLabel = "";

  // Text field labels
  var keywordsTextFieldLabel = "";

  // Placeholder messages
  var placeholderForEdit = "";

  // Error messages
  var emptyTitleEditError = "";

  LocalizedDashboardStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    // Sorting and filtering
    filterByKeywordsLabel = _l10n?.dashboard_filter_by_keywords ?? "Issue with the 'Filter by Keywords' label";
    sortByDate = _l10n?.dashboard_sort_by_date ?? "Issue with the 'Sort by Date' label";
    sortByTitle = _l10n?.dashboard_sort_by_title ?? "Issue with the 'Sort by Title' label";

    // ─── SNACKBARS ───────────────────────────────────────
    snackbarMessageSessionSavedSuccessfully = _l10n?.dashboard_snackbar_message_session_saved_successfully ?? "Issue with the l10n for the 'Session data saved' snackbar message";
    snackbarMessageDataDeleted = _l10n?.dashboard_snackbar_message_data_deleted ?? "Issue with the l10n for the 'Data deleted' snackbar message";
    snackbarMessageKeywordsUpdated = _l10n?.dashboard_snackbar_message_keywords_updated ?? "Issue with the l10n for the 'Keywords updated' snackbar message";

    // ─── SESSIONS ITEM ───────────────────────────────────────
    keywordsLabel = _l10n?.dashboard_keywords ?? "Issue with the 'Keywords' label";
    
    // Tooltips
    previewTooltipLabel = _l10n?.dashboard_tooltip_preview ?? "Issue with the l10n for the 'Preview' tooltip";
    previewClosingTooltipLabel = _l10n?.dashboard_preview_close_preview_tooltip ?? "Issue with the l10n for the preview 'Close the preview' tooltip";
    editFromDashboardItemTooltipLabel = _l10n?.dashboard_tooltip_edit_session_data ?? "Issue with the l10n for the 'Edit session data' tooltip";
    keywordsTooltipLabel = _l10n?.dashboard_tooltip_edit_keywords ?? "Issue with the l10n for the 'Edit Keywords' tooltip";
    deleteTooltipLabel = _l10n?.dashboard_tooltip_delete ?? "Issue with the l10n for the 'Delete data' tooltip";

    // Text field labels
    keywordsTextFieldLabel = _l10n?.dashboard_edit_keywords_sheet_label_text ?? "Issue with the l10n for the 'Keywords Edition' label text";

    // Error messages
    emptyTitleEditError = _l10n?.dashboard_edit_title_error_empty_title ?? "Issue with the l10n for the 'Title cannot be empty.' error message";
  }
}
