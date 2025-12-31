import os
from pathlib import Path
from typing import List, Dict
import json

from py_utils.file_utils import get_files_in_directory

def get_base_locales_file_paths(arbs_dir_path: str) -> List[str]:
    """
    Extracts all the base locales file paths from the arb files directory. 

    Args:
        arbs_dir_path: Path to the arb files directory
    Returns:
        The list of base locales file paths.
    """
    file_list = get_files_in_directory(
        directory_path=arbs_dir_path, 
        file_extension=".arb", 
        search_is_recursive=True
    )
    
    # Keeping only the base locales from the found files (lang_en.arb, lang_fr.arb, not app_en_US.arb)
    base_locales_files_paths = [
        file_path for file_path in file_list
        if os.path.basename(file_path).count('_') != 2
    ]
    
    return base_locales_files_paths


def get_language_code_from_base_locale_file_path(base_locale_file_path: str) -> str:
    """
    Extracts a language code from an arb base locale file path (therefore with no country code in the file name).

    Args:
        base_locale_file_path: Path to the base locale arb file
    Returns:
        The language code.
    """
    if (os.path.basename(base_locale_file_path).count('_') == 2):
        print(f"Error: there shouldn't be two '_' in the base locale file path: {base_locale_file_path}")
        exit()

    return os.path.basename(base_locale_file_path).replace('.arb','').replace('app_','')

def get_all_base_locales_language_codes(arbs_dir_path: str) -> List[str]:
    """
     Extracts all the base locales language codes (en, fr, ...) from the arb files directory. 

    Args:
        arbs_dir_path: Path to the arb files directory
    Returns:
        The list of base locales language codes.
"""
    language_codes = []
    base_locales_file_paths = get_base_locales_file_paths(arbs_dir_path)
    for file_path in base_locales_file_paths:
        language_code = get_language_code_from_base_locale_file_path(file_path)
        language_codes.append(language_code)

    return language_codes


def get_language_translations_for_each_language(arbs_dir_path: str, list_of_base_locales_paths: List[Path], list_of_language_codes: List[str]) ->  Dict[str, List[str]]:
    """
    Extracts all the translations for a given language from all the base locales files (lang_en.arb, lang_fr.arb, ...),
    and returns a dictionary with the language codes as keys, and lists of translations as values.
    For example: {'en': ['English', 'Anglais'], 'fr': ['French', 'Français']}

    Args:
        arbs_dir_path: Path to the arb files directory
        list_of_base_locales_paths: The list of the base locales file paths
        list_of_language_codes: The list of the language codes in the l10n directory

    Returns:
        A Dictionary with a language code as key, and a list of translations for the related language name.
        For example, the key 'en' has for values of the list: English, and the translation of 'English' in French for example.
    """
    languages_values = {}
    # Initializing the dictionary
    lang_codes = get_all_base_locales_language_codes(arbs_dir_path)
    for code in lang_codes:
        languages_values[code] = []    
    
    # Getting the translations of the language names
    for base_locale_path in list_of_base_locales_paths:
        with open(base_locale_path, 'r', encoding="utf-8") as arb_file:
            data = json.load(arb_file)
            for lang_code in list_of_language_codes:  
                # lang_en is the key to find the word 'English' translated in different languages              
                value = data.get(f"lang_{lang_code}")
                languages_values[lang_code].append(value)
    return languages_values