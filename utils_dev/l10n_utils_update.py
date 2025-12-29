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
arbs_dir_path = os.path.join("..", "lib","l10n")
print("")
print(f"Searching the arbs in: {arbs_dir_path}")

# Getting the language codes present in the arb directory
language_codes = get_all_base_locales_language_codes(arbs_dir_path)

# Getting the files paths for the base locales files only
base_locales_files_paths = get_base_locales_file_paths(arbs_dir_path)
print(f"Base locales files paths: {base_locales_files_paths}")

# Getting the different ways the same language is called, from the base locales, to generate code for the getLangCodeFromLangName method
language_values_for_each_base_locales = get_language_translations_for_each_language(arbs_dir_path, base_locales_files_paths, language_codes)
print(f"Language translations for each language: {language_values_for_each_base_locales}")

# Spaces + begin/end of class
spaces_2 = "  "
spaces_4 = "    "
class_begin = (
  "import 'package:journeyers/l10n/app_localizations.dart'; \n"
  "import 'package:flutter/material.dart'; \n"
  "\n"
  "/// {@category Utils} \n"
  "/// A utility class related to localization. \n"
  "class L10nLanguages \n"
  "{  \n"
)
class_end = "}"


#  Generates the code for the first method of l10n utils

#   Args: 
#           None
#   Returns: 
#           A string with the code.
def code_generation_for_method_1() -> str:
  code = ""

  method_1_begin = (
    '\n'
    '/// A method used to get a list of all the language names, related to a locale, from the l10n data. \n'
    '/// For example, \\["Arabic", "Chinese", "English", "French", "Hindi", "Portuguese", "Spanish"\\]. \n'
    '/// When adding a new base locale, file and method can be updated using l10n_utils_update.py. \n'
    '//  Note:  \[ and \] for dart doc \n'
    'static List<String> getLanguages(BuildContext context) \n'
    '{\n'
    '  List<String> languages = []; \n'
    f'{spaces_2}// Code to generate automatically from the base locales l10n data: begin \n'
  )

  method_1_add_begin = f"{spaces_2}languages.add(AppLocalizations.of(context)?.lang_"

  method_1_add_middle = " ?? 'Default for \""

  method_1_add_end = "\" language');"

  method_1_end = (
    f"{spaces_2}// Code to generate automatically from the base locales l10n data: end \n"
    f"{spaces_2}languages.sort(); \n"
    f"{spaces_2}return languages; \n"
    "}"
  )

  code += method_1_begin
  for lang_code in language_codes:
      code += method_1_add_begin+lang_code + method_1_add_middle+lang_code + method_1_add_end + "\n"
  code += method_1_end + "\n"

  return code


  #  Generates the code for the second method of l10n utils

  #   Args: 
  #           None   
  #   Returns:
  #       A string with the code.
def code_generation_for_method_2() -> str:
  code = ""
  method_2_begin = (
    "/// A method used to get a language code, being provided a language name. \n"
    "static String? getLangCodeFromLangName(String langName) \n"
    "{ \n"
    ""
    "  // Code to generate automatically from the base locales l10n data: begin \n"
  )

    # List<String> frLanguage = ['French', 'Français']
  method_2_list_line_begin = (
    f"{spaces_2}List<String> "
  )
  method_2_list_line_variable_name_end = "Language = ["
  method_2_list_line_end = "]; \n"
  # if (frLanguage.contains(langName)) return 'fr';
  method_2_if_line_begin = f"{spaces_2}if ("
  method_2_if_line_middle = "Language.contains(langName)) return '"
  method_2_if_line_end = "'; \n"
  method_2_end =  (
    f"{spaces_2}// Code to generate automatically from the base locales l10n data: end \n"
    f"{spaces_2}return null; \n"
    "}"
  )

  code += method_2_begin
  code_list_part = ""
  code_if_part = ""
  for lang_code in language_codes:        
      # List<String> enLanguage = ["English","Anglais"];
      code_list_part += method_2_list_line_begin + lang_code+method_2_list_line_variable_name_end 
      languages_for_specific_lang_code = get_language_translations_for_each_language(arbs_dir_path, base_locales_files_paths, language_codes)
      code_language_part = ""
      languages_values = languages_for_specific_lang_code[lang_code]
      for language_value in languages_values:
          code_language_part += '"'+language_value+'",'
      code_language_part = code_language_part.rstrip(',')
      code_language_part += method_2_list_line_end
      code_list_part += code_language_part

      # if (enLanguage.contains(langName)) return 'en';
      code_if_part += method_2_if_line_begin + lang_code + method_2_if_line_middle + lang_code + method_2_if_line_end
        
  code += code_list_part
  code += code_if_part
  code += method_2_end+"\n"
  return code

def main():    
  code = ""
  print('')
  ## Generating code for l10n_utils.dart
  code += class_begin    
  code += code_generation_for_method_1()
  code +=  "\n"
  code += code_generation_for_method_2()
  code += class_end
  
  print(code) 
  with open('l10n_utils.dart', 'w', encoding="utf-8") as f:
      f.write(code)

if __name__ == "__main__":
    main()