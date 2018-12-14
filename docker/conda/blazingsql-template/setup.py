# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
from setuptools.command.install import install
import os

class cudf_installer(install):
    def run(self):
        print("Installing custom cudf for BlazingSQL ...")
        os.system("cd cudf/python && pip install .")
        print("Custom cudf for BlazingSQL installed!")
        
        install.run(self)

setup(
    name='blazingsql',
    version='1.0',
    description='BlazingDB SQL',
    author='BlazingDB',
    author_email='blazing@blazingdb',
    packages=find_packages(include=['blazingsql', 'blazingsql.*']),
    install_requires=[],
    cmdclass={'install': cudf_installer},
    zip_safe=False
)
