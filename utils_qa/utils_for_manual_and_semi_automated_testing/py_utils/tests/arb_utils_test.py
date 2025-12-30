import platform
from pathlib import Path, WindowsPath, PosixPath
from py_utils.arb_utils import *

# Directory of the test arb files
arbs_dir_path = Path('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data')

# Starting from the project root folder to allow running pytest from different folders
root_folder = os.environ.get('JOURNEYERS_DIR')
os.chdir(root_folder)

# Getting the operating system name
os_name = platform.system().lower()

def test_get_base_locales_file_paths():
    expected = [] 
    if os_name.startswith('windows'):
        expected = [WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb')]
    if os_name.startswith('linux') or os_name.startswith('darwin'):        
        expected = [PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb')]
    
    list_of_base_locales_paths =  get_base_locales_file_paths(arbs_dir_path)
    # on macOS, issue with the order of the file paths. Using sets to assert.
    assert set(list_of_base_locales_paths) == set(expected)

def test_get_language_code_from_base_locale_file_path():
    expected = 'en'
    assert get_language_code_from_base_locale_file_path(Path('./utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb')) == expected

def test_get_all_base_locales_language_codes():
    expected = ['en','fr']
    list_of_language_codes = get_all_base_locales_language_codes(arbs_dir_path)
    assert set(list_of_language_codes) == set(expected)

def test_get_language_translations_for_each_language():
    list_of_base_locales_paths = get_base_locales_file_paths(arbs_dir_path)
    list_of_language_codes = get_all_base_locales_language_codes(arbs_dir_path)
    
    expected = {'en': ['English', 'Anglais'], 'fr': ['French', 'Français']}
    language_values = get_language_translations_for_each_language(arbs_dir_path, list_of_base_locales_paths, list_of_language_codes)
    assert set(language_values) == set(expected)


