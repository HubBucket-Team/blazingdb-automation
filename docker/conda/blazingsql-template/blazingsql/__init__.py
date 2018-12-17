import os

BLAZINGSQL_DIR = os.dirname(__file__)
RUNTIME_DIR = os.path.join(BLAZINGSQL_DIR, 'runtime')

os.environ['LD_LIBRARY_PATH'] = RUNTIME_DIR

import sys
sys.path.insert(0, RUNTIME_DIR)

import importlib
import cudf
importlib.reload(cudf)
