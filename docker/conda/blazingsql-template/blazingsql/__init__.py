#=============================================================================
# Copyright 2018 BlazingDB, Inc.
#     Copyright 2018 Cristhian Gonzales <cristhian@blazingdb.com>
#     Copyright 2018 Percy Camilo Triveño Aucahuasi <percy@blazingdb.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#=============================================================================

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

sys.path.insert(0, BLAZINGSQL_DIR)

import blazingdb
import pyblazing

