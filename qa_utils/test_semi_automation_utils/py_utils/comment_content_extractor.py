import os

eol = os.linesep

def first_comment_extraction(file_path: str, delimiter_line: str) -> str:
    """
    Extracts the first comment between two delimiter lines from a file.

    Args:
        file_path: Path to the file to read.
        delimiter_line: The line that acts as a delimiter.

    Returns:
        The extracted comment as a string.
    """
    comment = ""
    nbr_delimiter_lines_found = 0
    nbr_comment_found = 0
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if delimiter_line in line:
                nbr_delimiter_lines_found += 1
                continue
            if nbr_comment_found == 1 or nbr_delimiter_lines_found == 2:
                break
            elif nbr_delimiter_lines_found == 1:
                trimmed_comment_line = line.strip()
                comment += f"{trimmed_comment_line}{eol}"
                nbr_comment_found += 1
    return comment
