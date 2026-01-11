from pathlib import Path
from typing import List

def get_files_in_directory(directory_path: str, file_extension: str, search_is_recursive: bool = True) -> List[Path]:
    """
    Extracts the files paths from a directory.

    Args:
        directory_path: Path to the directory
        file_extension: The file extension to take into account
        search_is_recursive: A boolean to state if the search should be recursive.

    Returns:
        A list of Path objects.
    """
    path_to_potential_dir = Path(directory_path)
    if not path_to_potential_dir.is_dir():
        print("No directory found")
        return []

    if search_is_recursive:
        # rglob for recursive search
        return list(path_to_potential_dir.rglob(f'*{file_extension}'))
    else:
        # glob for non-recursive search
        return list(path_to_potential_dir.glob(f'*{file_extension}'))

def create_file_if_necessary_and_write_content(file_path: str, text: str) -> None:
    """
    Writes content in a file, creating the file if necessary.

    Args:
        file_path: Path to the file
        text: The text to write

    Returns:
        None.
    """
    path_to_file = Path(file_path)
    try:
        with open(path_to_file, 'w', encoding='utf-8') as f:
            f.write(text)
    except IOError as e:
        print(f"Error writing in file {file_path}: {e}")


def replace_string(file_path: str, string_old: str, string_new: str) -> None:
    path_to_file = Path(file_path)
    content = ""

    try:
        with open(path_to_file, 'r', encoding='utf-8') as f:
            content = f.read()
            # replacing string
            content = content.replace(string_old, string_new)
        
        # writing new content in file
        create_file_if_necessary_and_write_content(file_path, content)

    except IOError as e:
        print(f"Error reading from, or writing in, file {file_path}: {e}")