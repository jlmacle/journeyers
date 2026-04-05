# Installation

## Flutter
[Official installation instructions](https://docs.flutter.dev/install).

## Python code 
### Python virtual environment
Installing a [Python virtual environment](https://docs.python.org/3/tutorial/venv.html) seems the most cross-platform way to run the Python code.

You might choose to run the following command, in the root directory:<br>
python -m venv journeyers <br>



The following command gives access to the virtual environment: <br>
source journeyers/bin/activate (Linux/macOS) <br>
journeyers\Scripts\activate (Windows) <br>


### py_utils
Assuming the Python virtual environment activated, 
and the terminal pointing to the folder "utils_for_manual_and_semi_automated_testing",
the following command should install py_utils.

pip install -e .

You should get a "Successfully installed py_utils-0.1".

<br>

# Documentation

## Dart code

## Python code

<br>

# Utils

## Doc generation
Two python files are used to generate the Dart code documentation, and the Python code documentation:
- [doc_generator_dart.py](../../utils_dev/doc_generator_dart.py)
- [doc_generator_python.py](../../utils_dev\doc_generator_python.py)

### Troubleshooting "ModuleNotFoundError: No module named 'py_utils'"

If running "python .\doc_generator_dart.py" returns "ModuleNotFoundError: No module named 'py_utils'",
 a workaround is to install py_utils with a specific Python version, for example: <br>
 python3.11 -m pip install -e .

Then running<br>
python3.11 .\doc_generator_dart.py
in the file's directory should fix the issue.

<br>

# Testing

Testing is developped in the following files:

[unit_testing.md](../__doc_about_testing/unit_testing.md)

[integration_testing.md](../__doc_about_testing/integration_testing.md)

[screen_reader_testing.md](../__doc_about_testing/screen_reader_testing.md)

<br>

# Releases

The topic is developped in this file:

[releases.md](utils_doc/__doc_about_releases/releases.md)