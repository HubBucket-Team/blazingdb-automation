import os

BLAZINGSQL_DIR = os.path.dirname(__file__)
RUNTIME_DIR = os.path.join(BLAZINGSQL_DIR, 'runtime')
LIB_DIR = os.path.join(RUNTIME_DIR, 'lib')
SITE_DIR = os.path.join(LIB_DIR, 'python3.5', 'site-packages')

import sys
sys.path.insert(0, SITE_DIR)

import ctypes
ctypes.cdll.LoadLibrary(os.path.join(LIB_DIR, 'librmm.so'))
ctypes.cdll.LoadLibrary(os.path.join(LIB_DIR, 'libNVStrings.so'))
ctypes.cdll.LoadLibrary(os.path.join(LIB_DIR, 'libcudf.so'))

import importlib
import cudf
importlib.reload(cudf)
