'''
The script is used to generate dynamically the l10n_utils.dart (/lib/core/utils/l10n/) 
when new base locale files have been added to l10n.
"flutter run" updates the "lang_langCode" as needed.
'''
# TODO: previous file to backup automatically + rollback script

import os

# Assuming that "pip install -e ." has been run in the parent folder of setup.py ("pip show py_utils" to confirm installation)
# Imports potentially declared unresolved by the IDE, should be nevertheless successful at being found.
from py_utils.arb_utils import get_base_locales_file_paths, get_all_base_locales_language_codes, get_language_translations_for_each_language 

# Defines the relative path to the arb files directory
ARBS_DIR_PATH = os.path.join("..", "lib","l10n")
print("")
print(f"Searching the arbs in: {ARBS_DIR_PATH}")

# Getting the language codes present in the arb directory
LANGUAGE_CODES = get_all_base_locales_language_codes(ARBS_DIR_PATH)

# Getting the files paths for the base locales files only
BASE_LOCALES_FILES_PATHS = get_base_locales_file_paths(ARBS_DIR_PATH)
print(f"Base locales files paths: {BASE_LOCALES_FILES_PATHS}")

# Getting the different ways the same language is called, from the base locales, to generate code for the getLangCodeFromLangName method
LANGUAGE_VALUES_FOR_EACH_BASE_LOCALES = get_language_translations_for_each_language(ARBS_DIR_PATH, BASE_LOCALES_FILES_PATHS, LANGUAGE_CODES)
print(f"Language translations for each language: {LANGUAGE_VALUES_FOR_EACH_BASE_LOCALES}")

# Spaces + begin/end of class
INDENT_LEVEL_1 = "  "
INDENT_LEVEL_2 = "    "
CLASS_BEGIN = (
  "import 'package:journeyers/l10n/app_localizations.dart'; \n"
  "import 'package:flutter/material.dart'; \n"
  "\n"
  "/// {@category Utils} \n"
  "/// A utility class related to localization. \n"
  "class L10nLanguages \n"
  "{  \n"
)
CLASS_END = "}"


#  Generates the code for the first method of l10n utils

#   Args: 
#           None
#   Returns: 
#           A string with the code.
def code_generation_for_method_get_languages() -> str:
  code = ""

  method_1_begin = (
    '\n'
    '/// A method used to get a list of all the language names, related to a locale, from the l10n data. \n'
    '/// For example, \\["Arabic", "Chinese", "English", "French", "Hindi", "Portuguese", "Spanish"\\]. \n'
    '/// When adding a new base locale, file and method can be updated using l10n_utils_update.py. \n'
    '//  Note:  \\[ and \\] for dart doc \n'
    'static List<String> getLanguages({required BuildContext buildContext}) \n'
    '{\n'
    '  List<String> languages = []; \n'
    f'{INDENT_LEVEL_1}// Code to generate automatically from the base locales l10n data: begin \n'
  )

  method_1_add_begin = f"{INDENT_LEVEL_1}languages.add(AppLocalizations.of(buildContext)?.lang_"

  method_1_add_middle = " ?? 'Default for \""

  method_1_add_end = "\" language');"

  method_1_end = (
    f"{INDENT_LEVEL_1}// Code to generate automatically from the base locales l10n data: end \n"
    f"{INDENT_LEVEL_1}languages.sort(); \n"
    f"{INDENT_LEVEL_1}return languages; \n"
    "}"
  )

  code += method_1_begin
  for lang_code in LANGUAGE_CODES:
      code += method_1_add_begin+lang_code + method_1_add_middle+lang_code + method_1_add_end + "\n"
  code += method_1_end + "\n"

  return code


  #  Generates the code for the second method of l10n utils

  #   Args: 
  #           None   
  #   Returns:
  #       A string with the code.
def code_generation_for_method_get_lang_code_from_lang_name() -> str:
  code = ""
  method_2_begin = (
    "/// A method used to get a language code, being provided a language name. \n"
    "static String? getLangCodeFromLangName({required String languageName}) \n"
    "{ \n"
    ""
    "  // Code to generate automatically from the base locales l10n data: begin \n"
  )

  # List<String> frLanguage = ['French', 'Français']
  method_2_list_line_begin = (
    f"{INDENT_LEVEL_1}List<String> "
  )
  method_2_list_line_variable_name_end = "Language = ["
  method_2_list_line_end = "]; \n"
  # if (frLanguage.contains(languageName)) return 'fr';
  method_2_if_line_begin = f"{INDENT_LEVEL_1}if ("
  method_2_if_line_middle = "Language.contains(languageName)) return '"
  method_2_if_line_end = "'; \n"
  method_2_end =  (
    f"{INDENT_LEVEL_1}// Code to generate automatically from the base locales l10n data: end \n"
    f"{INDENT_LEVEL_1}return null; \n"
    "}"
  )

  code += method_2_begin
  code_list_part = ""
  code_if_part = ""
  for lang_code in LANGUAGE_CODES:        
      # List<String> enLanguage = ["English","Anglais"];
      code_list_part += method_2_list_line_begin + lang_code+method_2_list_line_variable_name_end 
      languages_for_specific_lang_code = get_language_translations_for_each_language(ARBS_DIR_PATH, BASE_LOCALES_FILES_PATHS, LANGUAGE_CODES)
      code_language_part = ""
      languages_values = languages_for_specific_lang_code[lang_code]
      for language_value in languages_values:
          code_language_part += '"'+language_value+'",'
      code_language_part = code_language_part.rstrip(',')
      code_language_part += method_2_list_line_end
      code_list_part += code_language_part

      # if (enLanguage.contains(languageName)) return 'en';
      code_if_part += method_2_if_line_begin + lang_code + method_2_if_line_middle + lang_code + method_2_if_line_end
        
  code += code_list_part
  code += code_if_part
  code += method_2_end+"\n"
  return code

def main():    
  code = ""
  print('')
  ## Generating code for l10n_utils.dart
  code += CLASS_BEGIN    
  code += code_generation_for_method_get_languages()
  code +=  "\n"
  code += code_generation_for_method_get_lang_code_from_lang_name()
  code += CLASS_END
  
  print(code) 
  
  # Building the path to save the data
  PROJECT_FOLDER = os.environ.get('JOURNEYERS_DIR')
  file_path = os.path.join(PROJECT_FOLDER,'utils_dev','l10n_utils.dart')
  # Saving the data 
  with open(file_path, 'w', encoding="utf-8") as f:
      f.write(code)
  print(f"Data saved at: {file_path}")

if __name__ == "__main__":
    main()