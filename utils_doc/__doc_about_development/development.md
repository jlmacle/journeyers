# Installation

## Flutter
[Assuming the Flutter installation being finished](https://docs.flutter.dev/install), you should be able to start the code using:<br>
<code>flutter run</code><br>

In case that would not be done automatically,<br>
the path to "flutter/bin" needs to be set in the PATH environment variable.<br>
If <code>flutter run</code> doesn't function after updating the PATH variable,<br>
login out, and re-login in, might be the most cross-platform way to solve the issue.

### Troubleshooting "ERROR: Target dart_build failed: Error: Failed to find any of [ld.lld, ld] in LocalDirectory: '/usr/lib/llvm-20/bin'"

Run <code>whereis ld</code>.<br>
If you get <code>/usr/bin/ld</code>,<br>
creating a symbolic link with the following command should solve the issue:<br>
<code>sudo ln -s /usr/bin/ld /usr/lib/llvm-20/bin/ld</code>

---

__Please note__:<br>
The links to folders are kept for the operating systems where they bring value.<br>
With apologies for the cases where those links are not yet functioning.

---

## Python code 
### Python virtual environment
Installing a [Python virtual environment](https://docs.python.org/3/tutorial/venv.html) seems the most cross-platform way to run the Python code.

Run the following command, in the [utils_Python](../../utils_Python) directory:<br>
<code>python -m venv pyEnv</code><br>


The following command gives access to the virtual environment: <br>
<code>source pyEnv/bin/activate</code> (Linux/macOS)<br>
<code>pyEnv/Scripts/activate</code> (Windows)<br>


### py_utils
Assuming the Python virtual environment activated,<br>
and the terminal pointing to the folder [utils_Python](../../utils_Python),<br>
the following command should install py_utils.

<code>pip install -e .</code>

You should get a "Successfully installed py_utils-0.1".
<br>

### JOURNEYERS_DIR environment variable

The value of the environment variable <code>JOURNEYERS_DIR</code> needs to be the project root folder.<br> 

### mkdocs installation
Assuming the Python virtual environment activated,<br>
and the terminal pointing to the folder [utils_Python](../../utils_Python),<br>
run the following commands:<br>
<code>pip install mkdocs</code><br>
<code>pip install "mkdocstrings[python]"</code><br>
<code>pip install mkdocs-material</code><br>


# Documentation
## Documentation about the project
Documentation about the project can be found in [utils_doc](../../utils_doc).

## Dart code
The Dart code documentation is located in [utils_doc/__doc_dart](../../utils_doc/__doc_dart).

## Python code
The Python code documentation is located in [utils_doc/__doc_python](../../utils_doc/__doc_python).


<br>

# Utils

## Doc generation
Two python files, located in [utils_Python](../../utils_Python), are used to generate the [Dart code documentation](../../utils_doc/__doc_dart/), <br>
and the [Python code documentation](../../utils_doc/__doc_python):
- [doc_generator_dart.py](../../utils_Python/doc_generator_dart.py)
- [doc_generator_python.py](../../utils_Python/doc_generator_python.py)


### Troubleshooting "TypeError: expected str, bytes or os.PathLike object, not NoneType"

The value of the environment variable <code>JOURNEYERS_DIR</code> needs to be the project root folder.<br> 

### Troubleshooting "ModuleNotFoundError: No module named 'py_utils'"

If running "python ./doc_generator_dart.py" returns "ModuleNotFoundError: No module named 'py_utils'",<br>
 a workaround is to install py_utils with a specific Python version, for example: <br>
 <code>python3.11 -m pip install -e .</code>

Then running<br>
<code>python3.11 ./doc_generator_dart.py</code><br>
in the file's directory, should fix the issue.

### Troubleshooting "ModuleNotFoundError: No module named 'mkdocs'"
Within the Python virtual environment activated, run the following commands:<br>
<code>pip install mkdocs</code><br>
<code>pip install "mkdocstrings[python]"</code><br>
<code>pip install mkdocs-material</code><br>

<br>

# The code
## Utils
### Generic utils
[lib/utils/generic](../../lib/utils/generic) contains non project-specific utils.

### Project specific utils
[lib/utils/project_specific](../../lib/utils/project_specific) contains project-specific utils.

<br>

# Testing

Testing is developped in the following files:

- [unit_testing.md](../__doc_about_testing/unit_testing.md)

- [widget_testing.md](../__doc_about_testing/widget_testing.md)

- [integration_testing.md](../__doc_about_testing/integration_testing.md)

- [screen_reader_testing.md](../__doc_about_testing/screen_reader_testing.md)

- [responsiveness_testing.md](../__doc_about_testing/responsiveness_testing.md)

<br>

# Releases

The topic is developped in this file:

- [releases.md](../../utils_doc/__doc_about_releases/releases.md)