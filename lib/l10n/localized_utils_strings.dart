import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedUtilsStrings
{
  AppLocalizations? _l10n;

  // ─── LANGUAGES ───────────────────────────────────────
  var englishL10n = "";
  var frenchL10n = "";

  // ─── FILE NAME ───────────────────────────────────────
  var fileNameTextFieldHint = "";

  // ─── OVERLAYS ───────────────────────────────────────
  var keywordsOverlayCloseButtonTooltip = "";
  
  
  LocalizedUtilsStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);

    // ─── LANGUAGES ───────────────────────────────────────
    englishL10n =  _l10n?.app_lang_en ?? "Issue with the l10 for 'English'";
    frenchL10n =  _l10n?.app_lang_fr ?? "Issue with the l10 for 'French'";
    
    // ─── FILE NAME ───────────────────────────────────────
    fileNameTextFieldHint = _l10n?.file_name_process_text_field_hint_on_mobile ?? "Issue with the text field hint inviting to add a file name without extension";
  
    // ─── OVERLAYS ───────────────────────────────────────
    keywordsOverlayCloseButtonTooltip  = _l10n?.l10n_keywords_overlay_close_button_tooltip ?? "Issue with the l10n for the keywords overlay close button tooltip";
  }
}
