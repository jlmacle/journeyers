'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to generate the Python documentation.
'''

import os
import platform
import subprocess

# Starting from the project root folder
PROJECT_FOLDER = os.environ.get('JOURNEYERS_DIR')
os.chdir(PROJECT_FOLDER)

# OS name needed to have the code portable
OS_NAME = platform.system().lower()
print(f"OS_NAME: {OS_NAME}")
# Running the 'mkdocs build -v'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified' on Windows.
if (OS_NAME == 'windows'):
    result = subprocess.run(['mkdocs', 'build', '-v'], shell=True)
else:
# if FileNotFoundError: [Errno 2] No such file or directory: 'mkdocs' on Linux, 
# maybe a virtual environment was used to install mkdocs, but not to run the script.
    result = subprocess.run(['mkdocs', 'build', '-v'])

print("Output:", result.stdout)
print("Error:", result.stderr)