'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to generate the Dart/Flutter documentation.
'''
import os
import platform
import subprocess

doc_folder = "utils_dev/doc_dart"
project_folder = os.environ.get('JOURNEYERS_DIR')
l10n_category_update_script_folder = os.path.join(project_folder, 'utils_dev')

# changing directory before running the script adding the L10n dartdoc category if necessary
os.chdir(l10n_category_update_script_folder)
try:
    result = subprocess.run(['python', 'l10n_category_update.py'])
except FileNotFoundError:
    result = subprocess.run(['python3', 'l10n_category_update.py'])
    print("FileNotFoundError caught. python3 used in the command, instead of python.")

# changing directory before using dartdoc
os.chdir(project_folder)

os_name = platform.system().lower()
print()
print(f"os_name: {os_name}")
# Running the 'dart doc'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified' on Windows.
if (os_name == 'windows'):
    result = subprocess.run(['dart', 'doc', '-o', f'{doc_folder}'], shell=True)
else:
    result = subprocess.run(['dart', 'doc', '-o', f'{doc_folder}'])

print("Output:", result.stdout)
print("Error:", result.stderr)
