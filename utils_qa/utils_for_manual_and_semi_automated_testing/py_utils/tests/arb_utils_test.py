import platform, os
from pathlib import Path, WindowsPath, PosixPath
from py_utils.arb_utils import *

# Directory of the test arb files
ARBS_DIR_PATH = Path('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data')

# Starting from the project root folder to allow running pytest from different folders
PROJECT_FOLDER = os.environ.get('JOURNEYERS_DIR')
os.chdir(PROJECT_FOLDER)

# Getting the operating system name
OS_NAME = platform.system().lower()

def test_get_base_locales_file_paths():
    expected = [] 
    if OS_NAME.startswith('windows'):
        expected = [WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb')]
    if OS_NAME.startswith('linux') or OS_NAME.startswith('darwin'):        
        expected = [PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb')]
    
    list_of_base_locales_paths =  get_base_locales_file_paths(ARBS_DIR_PATH)
    # on macOS, issue with the order of the file paths. Using sets to assert.
    assert set(list_of_base_locales_paths) == set(expected)

def test_get_language_code_from_base_locale_file_path():
    expected = 'en'
    assert get_language_code_from_base_locale_file_path(Path('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb')) == expected

def test_get_all_base_locales_language_codes():
    expected = ['en','fr']
    list_of_language_codes = get_all_base_locales_language_codes(ARBS_DIR_PATH)
    assert set(list_of_language_codes) == set(expected)

def test_get_language_translations_for_each_language():
    list_of_base_locales_paths = get_base_locales_file_paths(ARBS_DIR_PATH)
    list_of_language_codes = get_all_base_locales_language_codes(ARBS_DIR_PATH)
    
    expected = {'en': ['English', 'Anglais'], 'fr': ['French', 'Français']}
    language_values = get_language_translations_for_each_language(ARBS_DIR_PATH, list_of_base_locales_paths, list_of_language_codes)
    assert set(language_values) == set(expected)


