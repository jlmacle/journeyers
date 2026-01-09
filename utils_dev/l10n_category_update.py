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

en_classes_str = ["class AppLocalizationsEn extends AppLocalizations {", "class AppLocalizationsEnUs extends AppLocalizationsEn {"]
fr_classes_str = ["class AppLocalizationsFr extends AppLocalizations {", "class AppLocalizationsFrFr extends AppLocalizationsFr {"]
no_lang_code_classes_str = ["abstract class AppLocalizations {", "class _AppLocalizationsDelegate"]

association_dict = {"app_localizations_en.dart":en_classes_str, "app_localizations_fr.dart":fr_classes_str, 
                   "app_localizations.dart": no_lang_code_classes_str}

def add_categories_to_both_classes(file_path:str) -> None:
    print(f"\nAdding categories to both classes in: {file_path}")
    # extracting the file name
    file_name = os.path.basename(file_path)
    print(f"file_name: {file_name}")

    # getting the str to find
    list_of_str = association_dict[file_name]
    print(f"list_of_str: {list_of_str}")
    print()

    # getting the content of the file
    content = ""
    with open(file_path, "r", encoding="utf-8") as f:
        content = f.read()

    # replacing original content with new content
    for str_to_find in list_of_str:
        original_content = str_to_find
        new_content = "/// {@category L10n}" + "\n" + str_to_find

        content = content.replace(original_content, new_content)
        with open(file, "w", encoding="utf-8") as fw:
            fw.write(content)


# Building the path to the dart files
project_folder = os.environ.get('JOURNEYERS_DIR')
files_directory_path = Path(os.path.join(project_folder, "lib", "l10n"))

# Checking the validity of the path
if (not files_directory_path.exists()):
    print(f"{files_directory_path} doesn't exist.")
    exit()

# Searching for the app_localizations dart files in the l10n folder
list_of_file_paths = get_files_in_directory(files_directory_path, ".dart", search_is_recursive=True)
print(f"Files found: {list_of_file_paths}\n")

line_to_add = "/// {@category L10n}"

# Opening the files to add the categories in front of each class
for file in list_of_file_paths:
    with open(file, "r", encoding="utf-8") as f:
        content = f.read()
        
        # no categories found in the file. 
        # 2 should be present as 2 classes are present in each file as of 26/01/08 
        if content.count(line_to_add) == 0:
            add_categories_to_both_classes(file)

        # 1 occurrence of dartdoc category is present. 
        # removal of the line, and processing corresponding to "no categories found in file".
        elif content.count(line_to_add) == 1:
            replace_string(file, line_to_add, "")
            add_categories_to_both_classes(file)

        # 2 categories already present.
        elif content.count(line_to_add) == 2:
            print(f"\nCategories already present for the two classes of {file}")

        else:
            print(f"Error: unexpected count for {line_to_add}: {content.count(line_to_add)}")
        



       
        


