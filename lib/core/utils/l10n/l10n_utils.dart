import 'package:journeyers/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class L10nLanguages
{  /// A method getting a list of all the language names, related to a locale, from the l10n data.
  /// The method can be updated with l10n_utils_update.py when adding a new language
  ///
  /// Parameters:
  ///   - [context]:  the build context
  static List<String> getLanguages(BuildContext context)
 {
    List<String> languages = [];
    languages.add(AppLocalizations.of(context)?.lang_en ?? 'Default for en" language');
    languages.add(AppLocalizations.of(context)?.lang_fr ?? 'Default for fr" language');
    languages.sort();
    return languages;
  }
  /// A method getting a language code, being provided a language name, [langName]
  /// Parameters: - [langName]
  static String? getLangCodeFromLangName(String langName)
  {

    /// Code to generate automatically from the base locales l10n data: begin
    List<String> enLanguage = ["English","Anglais"];
    List<String> frLanguage = ["French","Français"];
    if (enLanguage.contains(langName)) return 'en';
    if (frLanguage.contains(langName)) return 'fr';
    /// Code to generate automatically from the base locales l10n data: end

    return null;
  }
}