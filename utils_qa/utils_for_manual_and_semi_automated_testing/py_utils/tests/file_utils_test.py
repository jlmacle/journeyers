import platform
from pathlib import WindowsPath, PosixPath
from py_utils.file_utils import *

# Getting the operating system name
os_name = platform.system().lower()

# Path to the folder of the files created (tests of file_create_file_if_necessary_and_write_content)
output_files_folder_path = 'utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/file_utils_test_data/output_files/'

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

    # creating the files folder if absent
    os.makedirs(output_files_folder_path, exist_ok=True)

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
    file_path_str = 'utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/file_utils_test_data/output_files/absent_file.txt'
    text_to_add = 'hello world'

    # creating the files folder if absent
    os.makedirs(output_files_folder_path, exist_ok=True)

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

def test_replace_string():
    # creating the output file folder if absent
    os.makedirs(output_files_folder_path, exist_ok=True)

    # testing if the output file already exists() to remove it and to start with a fresh file
    file_path = Path("utils_qa/utils_for_manual_and_semi_automated_testing/py_utils/tests/file_utils_test_data/input_files/string_replacement.txt")
    if file_path.exists():
        os.remove(file_path)
    # adding the file with "string2" as content
    with open(file_path, "w", encoding="utf-8") as f:
        f.write("string2")

    new_string = f"string1\nstring2"
    # replacing the string in the file
    replace_string(file_path, "string2", new_string)
     
    # getting the content from the file
    result = ""
    with open(file_path, "r", encoding="utf-8") as f:
        result = f.read()

    expected = new_string
    assert (result == expected)
