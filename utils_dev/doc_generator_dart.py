'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to generate the Dart/Flutter documentation.
'''
import os
import platform
import subprocess

DOC_FOLDER = "utils_dev/doc_dart"
PROJECT_FOLDER = os.environ.get('JOURNEYERS_DIR')
L10N_CATEGORY_UPDATE_SCRIPT_FOLDER = os.path.join(PROJECT_FOLDER, 'utils_dev')

# changing directory before running the script adding the L10n dartdoc category if necessary
os.chdir(L10N_CATEGORY_UPDATE_SCRIPT_FOLDER)
try:
    result = subprocess.run(['python', 'l10n_category_update.py'])
except FileNotFoundError:
    result = subprocess.run(['python3', 'l10n_category_update.py'])
    print("FileNotFoundError caught. python3 used in the command, instead of python.")

# changing directory before using dartdoc
os.chdir(PROJECT_FOLDER)

OS_NAME = platform.system().lower()
print()
print(f"OS_NAME: {OS_NAME}")
# Running the 'dart doc'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified' on Windows.
if (OS_NAME == 'windows'):
    result = subprocess.run(['dart', 'doc', '-o', f'{DOC_FOLDER}'], shell=True)
else:
    result = subprocess.run(['dart', 'doc', '-o', f'{DOC_FOLDER}'])

print("Output:", result.stdout)
print("Error:", result.stderr)
