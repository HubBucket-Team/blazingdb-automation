# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
from setuptools.extension import Extension

setup(name='blazingsql',
      version='1.0',
      description='BlazingDB SQL',
      author='BlazingDB',
      author_email='blazing@blazingdb',
      packages=find_packages(),
      install_requires=['flatbuffers']
)


from Cython.Build import cythonize
import numpy

import versioneer
from distutils.sysconfig import get_python_lib


install_requires = [
    'numba',
    'cython'
]

try:
    numpy_include = numpy.get_include()
except AttributeError:
    numpy_include = numpy.get_numpy_include()

cython_files = ['cudf/bindings/*.pyx']

extensions = [
    Extension("*",
              sources=cython_files,
              include_dirs=[numpy_include, '../cpp/include/'],
              library_dirs=[get_python_lib()],
              libraries=['cudf'],
              language='c++',
              extra_compile_args=['-std=c++11'])
]


