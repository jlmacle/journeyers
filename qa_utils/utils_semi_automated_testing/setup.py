from setuptools import setup, find_packages

setup(
    name="py_utils",
    version="0.1",
    packages=["py_utils"],  # or find_packages() now that layout is standard
)

# pip install -e .  (in the directory parent to setup.py) 
# pip show py_utils
