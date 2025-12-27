from the parent folder of setup.py, please run the following command to avoid import issues.

pip install -e . 

You should get a "Successfully installed py_utils-0.1"

---
https://docs.python.org/3/tutorial/venv.html

On Linux, you might have to setup a virtual environment, for example:
python3 -m venv journeyers
source journeyers/bin/activate

pip install mkdocs
pip install "mkdocstrings[python]"
pip install mkdocs-material
https://www.mkdocs.org/user-guide/configuration/
https://mkdocstrings.github.io/python/usage/

You will have to run the python documentation generation from the virtual environment for mkdocs to be found.