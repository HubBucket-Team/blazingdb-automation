# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
from setuptools.command.install import install
import os


class cudf_installer(install):

    def run(self):
        self._install_libgdf()
        self._install_cudf()

        install.run(self)

    def _install_libgdf(self):
        print("Installing custom libgdf for BlazingSQL ...")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        a = blazingsql_dir + "/cudf/cpp/python"
        #patch_libgdf_cmd = "sed -i 's/..\/..\//%s\/cudf\/cpp\//g' cudf/cpp/python/libgdf_cffi/libgdf_build.py" % blazingsql_dir
        #patch_librmm_cmd = "sed -i 's/..\/..\//%s\/cudf\/cpp\//g' cudf/cpp/python/librmm_cffi/librmm_build.py" % blazingsql_dir
        #print(patch_libgdf_cmd)
        #os.system(patch_libgdf_cmd)
        #print(patch_librmm_cmd)
        #os.system(patch_libgdf_cmd)
        libgdf_install_cmd = "pip install cudf/cpp/python/"
        print(libgdf_install_cmd)
        os.system(libgdf_install_cmd)
        print("Custom libgdf for BlazingSQL installed!")

    def _install_cudf(self):
        print("Installing custom cudf for BlazingSQL ...")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        cudf_include_dir = blazingsql_dir + "/cudf/cpp/include"
        cudf_lib_dir = blazingsql_dir + "/cudf/cpp/build"
        env_vars = 'CFLAGS="-I%s" CXXFLAGS="-I%s" LDFLAGS="-L%s"' % (cudf_include_dir, cudf_include_dir, cudf_lib_dir)
        cudf_pip_cmd = "pip install cudf/python"
        cudf_install_cmd = "%s %s" % (env_vars, cudf_pip_cmd)
        print(cudf_install_cmd)
        os.system(cudf_install_cmd)
        print("Custom cudf for BlazingSQL installed!")


setup(
    name = 'blazingsql',
    version = '1.0',
    description = 'BlazingDB SQL',
    author = 'BlazingDB',
    author_email = 'blazing@blazingdb',
    packages = find_packages(include = ['blazingsql', 'blazingsql.*']),
    install_requires = [],
    cmdclass = {'install': cudf_installer},
    zip_safe = False
)
