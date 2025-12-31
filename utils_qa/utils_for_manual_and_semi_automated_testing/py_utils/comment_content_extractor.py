import logging
import os

eol = os.linesep

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )

def first_comment_extraction(file_path: str, delimiter_line: str) -> str:
    """
    Extracts the first comment between two delimiter lines from a file.

    Args:
        file_path: Path to the file to read
        delimiter_line: The line that acts as a delimiter

    Returns:
        The extracted comment as a string.
    """

    setup_logging()
    logger = logging.getLogger("comment_content_extractor")

    comment = ""
    nbr_delimiter_lines_found = 0
    with open(file_path, 'r') as file:
        lines = file.readlines()
        for line in lines:
            # searching for the first delimiter line
            if delimiter_line in line:
                nbr_delimiter_lines_found += 1
            # extracting the line if delimiter line found
            elif nbr_delimiter_lines_found == 1:
                trimmed_comment_line = line.strip()
                comment += f"{trimmed_comment_line}{eol}"
                # exiting the loop
                break
        # if no comment extracted (could happen also with two delimiter lines in a row)
        if comment == "":
            logger.error(f"Empty comment found from {file_path}")
    return comment
