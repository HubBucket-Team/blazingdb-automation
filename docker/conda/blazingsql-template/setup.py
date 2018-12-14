# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
from setuptools.command.install import install
import os

class MyInstall(install):

    def run(self):
        install.run(self)
        print("X\n\n\n\nI did it!!!!\n\n\n\nZ")

os.system("echo 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA'")

setup(
    name='blazingsql',
    version='1.0',
    description='BlazingDB SQL',
    author='BlazingDB',
    author_email='blazing@blazingdb',
    packages=find_packages(include=['blazingsql', 'blazingsql.*']),
    install_requires=['flatbuffers'],
    cmdclass={'install': MyInstall},
    zip_safe=False
)



os.system("echo 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB'")

