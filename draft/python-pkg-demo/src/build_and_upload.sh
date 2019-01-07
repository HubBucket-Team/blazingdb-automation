#!/bin/bash

rm -rf build dist pkg_mario21ic.egg-info

# Build
python3 setup.py sdist bdist_wheel 


# Upload the package
twine upload --repository-url https://test.pypi.org/legacy/ dist/*

# Try the package
#python3 -m pip install --index-url https://test.pypi.org/simple/ pkg_mario21ic
