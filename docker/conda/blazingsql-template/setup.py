# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
from setuptools.command.install import install
import os


class cudf_installer(install):

    def run(self):
        print("Installing custom cudf for BlazingSQL ...")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        cudf_include_dir = blazingsql_dir + "/cudf/cpp/include"
        cudf_lib_dir = blazingsql_dir + "/cudf/cpp/build"
        env_vars = 'CFLAGS="-I%s" CXXFLAGS="-I%s" LDFLAGS="-L%s"' % (cudf_include_dir, cudf_include_dir, cudf_lib_dir)
        change_dir_cmd = "cd cudf/python"
        cudf_pip_cmd = "pip install ."
        cudf_install_cmd = "%s && %s %s" % (change_dir_cmd, env_vars, cudf_pip_cmd)
        print(cudf_install_cmd)
        os.system(cudf_install_cmd)
        print("Custom cudf for BlazingSQL installed!")

        install.run(self)


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
