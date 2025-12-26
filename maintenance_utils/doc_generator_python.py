'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to generate the Python documentation.
'''

# pip install --user mkdocs
# pip install --user "mkdocstrings[python]"
# pip install --user mkdocs-material
# https://www.mkdocs.org/user-guide/configuration/
# https://mkdocstrings.github.io/python/usage/

import os
import platform
import subprocess


project_dir = os.environ.get('JOURNEYERS_DIR')

# Starting from the project root folder to create the directory for the documentation if necessary
doc_parent_folder = os.path.join(project_dir, 'maintenance_utils')
os.chdir(doc_parent_folder)
# Creating doc_python_md if not existant
os.makedirs('doc_python', exist_ok=True)

# Going to the project root folder before starting the command
os.chdir(project_dir)
os_name = platform.system().lower()
print(f"os_name: {os_name}")
# Running the 'mkdocs build -v'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified' on Windows.
if (os_name == 'windows'):
    result = subprocess.run(['mkdocs', 'build', '-v'],shell=True)
else:
    result = subprocess.run(['mkdocs', 'build', '-v'],text=True)

print("Output:", result.stdout)
print("Error:", result.stderr)