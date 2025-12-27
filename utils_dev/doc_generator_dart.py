'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to generate the Dart/Flutter documentation.
'''
import os
import platform
import subprocess

# Starting from the project root folder
root_folder = os.environ.get('JOURNEYERS_DIR')
os.chdir(root_folder)

# Doc folder creation if needed
doc_folder = "utils_dev/doc_dart"
# https://docs.python.org/3/library/os.html#os.makedirs
# exist_ok=True to avoid an error when the folder already exists.
os.makedirs(doc_folder, exist_ok=True)

os_name = platform.system().lower()
print(f"os_name: {os_name}")
# Running the 'dart doc'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified' on Windows.
if (os_name == 'windows'):
    result = subprocess.run(['dart', 'doc', '-o', f'{doc_folder}'], shell=True)
else:
    result = subprocess.run(['dart', 'doc', '-o', f'{doc_folder}'], text=True)

print("Output:", result.stdout)
print("Error:", result.stderr)
# TODO: to add the dart doc category to the l10n files if was removed by re-generation.
