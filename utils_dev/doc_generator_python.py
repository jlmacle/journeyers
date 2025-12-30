'''
    [Uses the environment variable JOURNEYERS_DIR to point to the project directory.]
    
    Script used to generate the Python documentation.
'''


import os
import platform
import subprocess

# Starting from the project root folder
root_folder = os.environ.get('JOURNEYERS_DIR')
os.chdir(root_folder)

os_name = platform.system().lower()
print(f"os_name: {os_name}")
# Running the 'mkdocs build -v'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified' on Windows.
if (os_name == 'windows'):
    result = subprocess.run(['mkdocs', 'build', '-v'],shell=True)
else:
# if FileNotFoundError: [Errno 2] No such file or directory: 'mkdocs' on Linux, 
# maybe a virtual environment was used to install mkdocs, but not to run the script.
    result = subprocess.run(['mkdocs', 'build', '-v'])

print("Output:", result.stdout)
print("Error:", result.stderr)