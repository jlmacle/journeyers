from setuptools import setup, find_packages

setup(
    name="py_utils",
    version="0.1",
    # https://packaging.python.org/en/latest/guides/distributing-packages-using-setuptools/
)

# pip install -e .  (in the directory parent to setup.py) 
# pip show py_utils
# If 'pip show py_utils' returns a location similar to 'Python312\Lib\site-packages', 
# 'python3.12 -m pytest' might be necessary to run pytest without import issues.

