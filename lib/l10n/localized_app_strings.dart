import "package:material_ui/material_ui.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedAppStrings {
  AppLocalizations? _l10n;

  // ─── TITLE AND SUBTITLE ───────────────────────────────────────
  var appSubTitle = "";  

  LocalizedAppStrings(BuildContext context) {
    _l10n = AppLocalizations.of(context);

    // ─── LANGUAGES ───────────────────────────────────────
    appSubTitle = _l10n?.app_sub_title ?? "Issue with the application subtitle text";
  }
}
