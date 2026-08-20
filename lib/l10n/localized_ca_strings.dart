import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedCAStrings
{
  AppLocalizations? _l10n;

  // ─── CA PROCESS ───────────────────────────────────────
  // ─── Title ───────────────────────────────────────
  var caTitleTextFieldHint = "";

  // ─── Keywords ───────────────────────────────────────
  var caKeywordsTextFieldHint = "";


  // ─── CA Form ───────────────────────────────────────
  var invitationToUnfoldExpansionTile = "";

  // Text field hints
  var pastOutcomesTextFieldHint = "";
  var helpingAndHouseholdTextFieldHint = "";
  var caFormPleaseDevelopTextFieldHint = "";

  // Segmented button options
  var yes = "";
  var no = "";
  var iDontKnow = "";

  // ─── DASHBOARD ───────────────────────────────────────
  // CA dashboard title
  var dashboardTitle = "";


          

  LocalizedCAStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    // ─── CA PROCESS ───────────────────────────────────────
    // ─── Title ───────────────────────────────────────
    caTitleTextFieldHint = _l10n?.ca_process_title_text_field_hint ?? "Issue with the context analysis title text field hint";

    // ─── Keywords ───────────────────────────────────────
    caKeywordsTextFieldHint = _l10n?.l10n_keywords_entry_text_field_hint ?? "Issue with the l10n for the keywords entry text field hint";

    // ─── CA Form ───────────────────────────────────────
    invitationToUnfoldExpansionTile = _l10n?.ca_process_invitation_to_unfold_expansion_tile ?? "Issue with the l10n for 'Please click to unfold'";
  
    // Text field hints
    pastOutcomesTextFieldHint = _l10n?.ca_process_past_outcomes_text_field_hint ?? "Issue with the text field hint, for the past outcomes of the problem for the household";
    helpingAndHouseholdTextFieldHint = _l10n?.ca_process_helping_household_text_field_hint ?? "Issue with the text field hint, for the reasons and potential impacts of an imbalance between faithfulness towards your own and consideration towards others";
    caFormPleaseDevelopTextFieldHint = _l10n?.ca_process_please_develop_text_field_hint ?? "Issue with the text field hint inviting to develop";

    yes =  _l10n?.segmented_button_yes ?? "Issue with the l10n for Yes";
    no = _l10n?.segmented_button_no ?? "Issue with the l10n for No";
    iDontKnow = _l10n?.segmented_button_I_don_t_know ?? "Issue with the l10n for I don't know";
    
    // ─── DASHBOARD ───────────────────────────────────────
    // CA dashboard title
    dashboardTitle = _l10n?.ca_dashboard_title ?? "Issue with the dashboard title";

    
          
  
  }

}
