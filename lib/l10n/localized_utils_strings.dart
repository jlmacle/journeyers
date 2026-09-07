import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedUtilsStrings
{
  AppLocalizations? _l10n;

  var keywordsOverlayCloseButtonTooltip = "";
  
  LocalizedUtilsStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    keywordsOverlayCloseButtonTooltip  = _l10n?.l10n_keywords_overlay_close_button_tooltip ?? "Issue with the l10n for the keywords overlay close button tooltip";
  }
}
