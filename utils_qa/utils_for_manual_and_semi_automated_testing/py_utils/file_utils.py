from pathlib import Path
from typing import List
import os


def get_files_in_directory(directory_path: str, file_extension: str, search_is_recursive: bool = True) -> List[Path]:
    """
    Extracts the files paths from a directory.

    Args:
        directory_path: Path to the directory
        file_extension: The file extension to take into account
        search_is_recursive: A boolean to state if the search should be recursive.

    Returns:
        A list of path names.
    """
    target_dir = Path(directory_path)
    if not target_dir.is_dir():
        print("No directory found")
        return []

    if search_is_recursive:
        # Use rglob for recursive search
        return list(target_dir.rglob(f'*{file_extension}'))
    else:
        # Use glob for non-recursive search
        return list(target_dir.glob(f'*{file_extension}'))

def create_file_if_necessary_and_add_content(file_path: str, text: str) -> None:
    """
    Adds content to a file, creating the file if necessary.

    Args:
        file_path: Path to the file
        text: The text to add

    Returns:
        None.
    """
    target_file = Path(file_path)
    try:
        with open(target_file, 'w', encoding='utf-8') as f:
            f.write(text)
    except IOError as e:
        print(f"Error writing file {file_path}: {e}")

