import sys
from pathlib import Path, WindowsPath, PosixPath
from py_utils.arb_utils import *

arbs_dir_path = Path('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data')

def test_get_base_locales_file_paths():
    if sys.platform.startswith('win'):
        expected = [WindowsPath('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), WindowsPath('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb')]
    if sys.platform.startswith('linux'):
        expected = [PosixPath('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), PosixPath('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb')]
    
    list_of_base_locales_paths =  get_base_locales_file_paths(arbs_dir_path)
    assert list_of_base_locales_paths == expected

def test_get_language_code_from_base_locale_file_path():
    expected = 'en'
    assert get_language_code_from_base_locale_file_path(Path('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb')) == expected

def test_get_all_base_locales_language_codes():
    expected = ['en','fr']
    list_of_language_codes = get_all_base_locales_language_codes(arbs_dir_path)
    assert list_of_language_codes == expected

def test_get_language_translations_for_each_language():
    list_of_base_locales_paths = get_base_locales_file_paths(arbs_dir_path)
    list_of_language_codes = get_all_base_locales_language_codes(arbs_dir_path)
    
    expected = {'en': ['English', 'Anglais'], 'fr': ['French', 'Français']}
    language_values = get_language_translations_for_each_language(arbs_dir_path, list_of_base_locales_paths, list_of_language_codes)
    assert language_values == expected


