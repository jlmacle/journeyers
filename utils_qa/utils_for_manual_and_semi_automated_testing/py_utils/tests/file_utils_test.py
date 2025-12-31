import platform
from pathlib import WindowsPath, PosixPath
from py_utils.file_utils import *

# Getting the operating system name
os_name = platform.system().lower()

def test_get_files_in_directory():
    directory_path = "utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data"
    file_extension = ".arb"
    expected = []

    if os_name.startswith('windows'):
        expected = [WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en_US.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb'), WindowsPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr_FR.arb')]
    if os_name.startswith('linux') or os_name.startswith('darwin'):        
        expected = [PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_en_US.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr.arb'), PosixPath('utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/arb_utils_test_data/app_fr_FR.arb')]

    assert set(get_files_in_directory(directory_path=directory_path, file_extension=file_extension)) == set(expected)


def test_with_existing_file_create_file_if_necessary_and_write_content():
    file_path_str = 'utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/file_utils_test_data/output_files/existing_file.txt'
    text_to_add = 'hello world'

    # creating an empty file
    open(file_path_str, "x")

    # asserting that the file does exist
    assert Path(file_path_str).exists() == True

    # asserting that the file is empty
    file_content = ""
    with open(file_path_str, "r", encoding="utf-8") as f:
        file_content = f.read()
    assert file_content == ""

    # creating the file and writing content
    create_file_if_necessary_and_write_content(file_path_str, text_to_add)

    #asserting the addition of the text
    file_content = ""
    with open(file_path_str, "r", encoding="utf-8") as f:
        file_content = f.read()
    assert file_content == text_to_add

    # removing the file
    os.remove(file_path_str)


    
def test_with_absent_file_create_file_if_necessary_and_write_content():
    file_path_str = r'utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/file_utils_test_data/output_files/absent_file.txt'
    text_to_add = 'hello world'

    # asserting the absence of the file
    assert Path(file_path_str).exists() == False

    # creating the file and writing content
    create_file_if_necessary_and_write_content(file_path_str, text_to_add)

    #asserting the addition of the text
    file_content = ""
    with open(file_path_str, "r", encoding="utf-8") as f:
        file_content = f.read()
    assert file_content == text_to_add

    # removing the file
    os.remove(file_path_str)
    