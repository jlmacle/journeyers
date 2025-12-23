import os
import subprocess

root_folder = os.environ.get('JOURNEYERS_DIR')
doc_folder = "maintenance_utils/doc"
os.chdir(root_folder)
os.makedirs(doc_folder, exist_ok=True)

# Running the 'dart doc'command
# shell=True to avoid 'FileNotFoundError: The system cannot find the file specified'
result = subprocess.run(['dart', 'doc', '-o', f'{doc_folder}'],shell=True)

print("Output:", result.stdout)
print("Error:", result.stderr)
