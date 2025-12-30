py_utils install:

From the parent folder of setup.py, please run the following command to avoid import issues:
pip install -e . 

You should get a "Successfully installed py_utils-0.1"

"pip show py_utils" helps to know which version of python is relevant to run pytest, 
in case of pytest issue (for example: "python3.12.exe  -m pytest"). 

-----------------------

Python virtual environment:

https://docs.python.org/3/tutorial/venv.html

On Linux, you might have to setup a virtual environment, for example:
python3 -m venv journeyers (in the root directory, for convenience)

On Linux/macOS, the following command gives access to the virtual environment:
source journeyers/bin/activate


pip install mkdocs
pip install "mkdocstrings[python]"
pip install mkdocs-material
https://www.mkdocs.org/user-guide/configuration/
https://mkdocstrings.github.io/python/usage/

You will have to run the python documentation generation from the virtual environment 
for mkdocs to be found, if installing the packages within the virtual environment.

Also, if you use a virtual environment, please run the following command to avoid py_utils import issues,
from the parent folder of setup.py (utils_qa/utils_for_manual_and_semi_automated_testing), 
within the virtual environment:
pip install -e . 

You might have to install pytest in the virtual environment as well:
pip install pytest
