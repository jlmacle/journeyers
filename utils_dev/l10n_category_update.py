'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to add the dartdoc "L10n" category to the app_localizations files.

    Some data to update manually when new app_localizations files are generated.
'''

# file tested manually to avoid having to define another python package

import os
from pathlib import Path

from py_utils.file_utils import get_files_in_directory, replace_string

# Data to update manually when new app_localizations files are generated

EN_CLASSES_STR = ["class AppLocalizationsEn extends AppLocalizations {", "class AppLocalizationsEnUs extends AppLocalizationsEn {"]
FR_CLASSES_STR = ["class AppLocalizationsFr extends AppLocalizations {", "class AppLocalizationsFrFr extends AppLocalizationsFr {"]
NO_LANG_CODE_CLASSES_STR = ["abstract class AppLocalizations {", "class _AppLocalizationsDelegate"]

ASSOCIATION_DICT = {"app_localizations_en.dart":EN_CLASSES_STR, "app_localizations_fr.dart":FR_CLASSES_STR, 
                   "app_localizations.dart": NO_LANG_CODE_CLASSES_STR}

LINE_TO_ADD = "/// {@category L10n}"

def add_categories_to_both_classes(file_path:str) -> None:
    print(f"\nAdding categories to both classes in: {file_path}")
    # extracting the file name
    file_name = os.path.basename(file_path)
    print(f"file_name: {file_name}")

    # getting the str to find
    list_of_str = ASSOCIATION_DICT[file_name]
    print(f"list_of_str: {list_of_str}")
    print()

    # getting the content of the file
    content = ""
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # replacing original content with new content
    for str_to_find in list_of_str:
        original_content = str_to_find
        new_content = LINE_TO_ADD + "\n" + str_to_find

        content = content.replace(original_content, new_content)
        with open(file, "w", encoding="utf-8") as fw:
            fw.write(content)


# Building the path to the dart files
PROJECT_FOLDER = os.environ.get('JOURNEYERS_DIR')
FILES_DIRECTORY_PATH = Path(os.path.join(PROJECT_FOLDER, "lib", "l10n"))

# Checking the validity of the path
if (not FILES_DIRECTORY_PATH.exists()):
    print(f"{FILES_DIRECTORY_PATH} doesn't exist.")
    exit()

# Searching for the app_localizations dart files in the l10n folder
LIST_OF_FILE_PATHS = get_files_in_directory(FILES_DIRECTORY_PATH, ".dart", search_is_recursive=True)
print(f"Files found: {LIST_OF_FILE_PATHS}\n")

# Opening the files to add the categories in front of each class
for file in LIST_OF_FILE_PATHS:
    with open(file, "r", encoding="utf-8") as f:
        content = f.read()
        
        # no categories found in the file. 
        # 2 should be present as 2 classes are present in each file as of 26/01/08 
        if content.count(LINE_TO_ADD) == 0:
            add_categories_to_both_classes(file)

        # 1 occurrence of dartdoc category is present. 
        # removal of the line, and processing corresponding to "no categories found in file".
        elif content.count(LINE_TO_ADD) == 1:
            replace_string(file, LINE_TO_ADD, "")
            add_categories_to_both_classes(file)

        # 2 categories already present.
        elif content.count(LINE_TO_ADD) == 2:
            print(f"\nCategories already present for the two classes of {file}")

        else:
            print(f"Error: unexpected count for {LINE_TO_ADD}: {content.count(LINE_TO_ADD)}")
        



       
        


