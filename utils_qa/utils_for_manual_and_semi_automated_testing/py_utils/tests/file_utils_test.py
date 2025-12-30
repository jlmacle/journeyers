import platform
from pathlib import WindowsPath, PosixPath
from py_utils.file_utils import *

# Getting the operating system name
os_name = platform.system().lower()

def test_get_files_in_directory():
    file_extension = ".arb"
    directory_path = ""
    expected = []

    if os_name.startswith('windows'):
        directory_path = WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/')
        expected = [WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr_FR.arb')]
    if os_name.startswith('linux') or os_name.startswith('darwin'):        
        directory_path = PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/')
        expected = [PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en_US.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr_FR.arb')]

    # on macOS, issue with the order of the file paths. Using sets to assert.
    assert set(get_files_in_directory(directory_path=directory_path, file_extension=file_extension)) == set(expected)
    