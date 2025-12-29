import 'package:journeyers/l10n/app_localizations.dart'; 
import 'package:flutter/material.dart'; 

/// {@category Utils} 
/// A utility class related to localization. 
class L10nLanguages 
{  

/// A method used to get a list of all the language names, related to a locale, from the l10n data. 
/// For example, \["Arabic", "Chinese", "English", "French", "Hindi", "Portuguese", "Spanish"\]. 
/// When adding a new base locale, file and method can be updated using l10n_utils_update.py. 
//  Note:  \[ and \] for dart doc 
static List<String> getLanguages(BuildContext context) 
{
  List<String> languages = []; 
  // Code to generate automatically from the base locales l10n data: begin 
  languages.add(AppLocalizations.of(context)?.lang_en ?? 'Default for "en" language');
  languages.add(AppLocalizations.of(context)?.lang_fr ?? 'Default for "fr" language');
  // Code to generate automatically from the base locales l10n data: end 
  languages.sort(); 
  return languages; 
}

/// A method used to get a language code, being provided a language name. 
static String? getLangCodeFromLangName(String langName) 
{ 
  // Code to generate automatically from the base locales l10n data: begin 
  List<String> enLanguage = ["English","Anglais"]; 
  List<String> frLanguage = ["French","Français"]; 
  if (enLanguage.contains(langName)) return 'en'; 
  if (frLanguage.contains(langName)) return 'fr'; 
  // Code to generate automatically from the base locales l10n data: end 
  return null; 
}
}