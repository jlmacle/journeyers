import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedParticipantsStrings
{
  AppLocalizations? _l10n;

  // ─── DASHBOARD ───────────────────────────────────────

  // The title for the participants dashboard
  var listsDashboardTitle = "";

  //  ─── Sorting and filtering ───────────────────────────────────────
  // Sorting by list name label
  var listsSortByLabel = "" ;

  //  ─── Deletion ───────────────────────────────────────
  // Single deletion tooltip
  var listsDeleteTooltipLabel = "";

  // ─── New list ───────────────────────────────────────
  var newListButtonLabel = "";

  // ─── List loading ───────────────────────────────────────
  var loadingButtonLabel = "";

  // ─── Dialog ───────────────────────────────────────
  var saveButtonLabel = "";

  // ─── Error messages ───────────────────────────────────────
  var emptyParticipantsListError = "";
  var emptyLabelEditError = "";

  LocalizedParticipantsStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);    
    
    // ─── DASHBOARD ───────────────────────────────────────

    // The title for the participants dashboard
    listsDashboardTitle = _l10n?.text_lists_dashboard_title ?? "Issue with the title for the participants lists dashboard";
    
    //  ─── Sorting and filtering ───────────────────────────────────────
    // Sorting by list name label
    listsSortByLabel = _l10n?.text_lists_dashboard_sort_by_list_name ?? "Issue with the l10n for the 'List sort' label";
    
    //  ─── Deletion ───────────────────────────────────────
    // Single deletion tooltip
    listsDeleteTooltipLabel = _l10n?.dashboard_tooltip_delete ?? "Issue with the l10n for the 'Delete data' tooltip";
  
    // ─── New list ───────────────────────────────────────
    newListButtonLabel = "";

    // ─── List loading ───────────────────────────────────────
    loadingButtonLabel = _l10n?.text_lists_dashboard_list_loading_button_text ?? "Issue with the l10n for the list loading button text";
  
    // ─── Dialog ───────────────────────────────────────
    saveButtonLabel = _l10n?.l10n_save ?? "Issue with the l10n for 'Save'";
  
    // ─── Error messages ───────────────────────────────────────
    emptyParticipantsListError = _l10n?.text_lists_dashboard_edit_participants_sheet_empty_list_error_message ?? "Issue with the l10n for the 'Participants list cannot be empty' error message";
    emptyLabelEditError = _l10n?.text_lists_new_list_empty_list_name_message ?? "Issue with the message when the list name is empty at saving time";
  
  }
}
