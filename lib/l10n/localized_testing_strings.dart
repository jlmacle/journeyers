import "package:flutter/material.dart";

import "package:journeyers/l10n/app_localizations.dart";

class LocalizedTestingStrings
{
  AppLocalizations? _l10n;

  // titles
  var caTitleRoot = "";
  var gpsTitleRoot = "";

  // keywords
  var kw = "";
  var kwCompanionship = "";

  // ideas
  var idea = "";

  // file name
  var fileNameWithoutExtensionRoot = "";

  // edition
  var editionSuffix = "";
  
  LocalizedTestingStrings(BuildContext context)
  {
    _l10n = AppLocalizations.of(context);
    
    // titles
    caTitleRoot = _l10n?.testing_ca_title_root ?? "Issue with the l10n for the context analysis title root";
    gpsTitleRoot = _l10n?.testing_gps_title_root ?? "Issue with the l10n for the group problem-solving title root";
    
    // keywords
    kw = _l10n?.l10n_keyword ?? "Issue with the l10n for 'Keyword'";
    kwCompanionship = _l10n?.testing_kw_companionship ?? "Issue with the l10n for the 'Companionship' keyword";
    
    // ideas
    idea = _l10n?.l10n_idea ?? "Issue with the l10n for the 'Idea 1'";
    
    // file name
    fileNameWithoutExtensionRoot = _l10n?.l10n_file ?? "Issue with the l10n for 'file'";
    
    // edition
    editionSuffix = _l10n?.testing_edition_suffix ?? "Issue with the l10n for the edition suffix";
  }
}
