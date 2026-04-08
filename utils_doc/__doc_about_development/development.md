# Installation

## Flutter
[Official installation instructions](https://docs.flutter.dev/install).

## Python code 
### Python virtual environment
Installing a [Python virtual environment](https://docs.python.org/3/tutorial/venv.html) seems the most cross-platform way to run the Python code.

Run the following command, in the [utils_Python](../../utils_Python) directory:<br>
<code>python -m venv pyEnv</code><br>


The following command gives access to the virtual environment: <br>
<code>source pyEnv/bin/activate (Linux/macOS)</code><br>
<code>pyEnv/Scripts/activate (Windows)</code><br>


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

## Dart code

## Python code

<br>

# Utils

## Doc generation
Two python files, located in [utils_dev](../../utils_dev), are used to generate the [Dart code documentation](../../utils_doc/__doc_dart/), <br>
and the [Python code documentation](../../utils_doc/__doc_python):
- [doc_generator_dart.py](../../utils_dev/doc_generator_dart.py)
- [doc_generator_python.py](../../utils_dev/doc_generator_python.py)


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