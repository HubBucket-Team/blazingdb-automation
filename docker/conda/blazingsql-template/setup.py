# Copyright (c) 2018, BlazingDB

from setuptools import setup, find_packages
from setuptools.command.install import install
import os


class cudf_installer(install):

    def run(self):
        self._install_libgdf_cffi()
        # self._install_cudf_python()

        install.run(self)

    def _install_libgdf_cffi(self):

        print("YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY")
        print(str(self.prefix))
        print(str(self.install_base))
        print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA Installing custom libgdf for BlazingSQL ...")
        blazingsql_dir = os.path.dirname(os.path.realpath(__file__))
        # patch_libgdf_cmd = "sed -i 's/..\/..\//%s\/cudf\/cpp\//g' cudf/cpp/python/libgdf_cffi/libgdf_build.py" % blazingsql_dir
        # patch_librmm_cmd = "sed -i 's/..\/..\//%s\/cudf\/cpp\//g' cudf/cpp/python/librmm_cffi/librmm_build.py" % blazingsql_dir
        # print(patch_libgdf_cmd)
        # os.system(patch_libgdf_cmd)
        # print(patch_librmm_cmd)
        # os.system(patch_libgdf_cmd)
        
        # TODO percy add ld path library del runtime/lib antes de buold insalarlo
        
        runtime_dir = self.prefix + "/lib/python3.5/site-packages/blazingsql/runtime"
        pypkg = blazingsql_dir + "/cudf/cpp/python/"
        # libgdf_install_cmd = "pip install --target=%s %s" % (runtime_dir, pypkg)
        libgdf_install_cmd = "python %s/setup.py build_ext --inplace" % pypkg
        print(libgdf_install_cmd)
        working_dir = os.getcwd()
        os.chdir(blazingsql_dir + "/cudf/cpp/build/python")
        os.system(libgdf_install_cmd)

        print("INSTALLLLLLLLLLLL")
        ai = "python %s/setup.py install --prefix=%s --single-version-externally-managed --record=record.txt" % (pypkg, runtime_dir)
        os.system(ai)

        os.chdir(working_dir)
        print("Custom libgdf for BlazingSQL installed!")

    def _install_cudf_python(self):
        print("Installing custom cudf for BlazingSQL ...")
        cudf_include_dir = blazingsql_dir + "/cudf/cpp/include"
        cudf_lib_dir = blazingsql_dir + "/cudf/cpp/install/lib"
        env_vars = 'CFLAGS="-I%s" CXXFLAGS="-I%s" LDFLAGS="-L%s"' % (cudf_include_dir, cudf_include_dir, cudf_lib_dir)
        runtime_dir = blazingsql_dir + "/runtime"
        cudf_pip_cmd = "pip install --target=%s cudf/python" % (runtime_dir)
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
    package_data = {'blazingsql': [
        'runtime/bin/BlazingCalcite.jar',
        'runtime/bin/blazingdb_orchestator_service',
        'runtime/bin/testing-libgdf',
        'runtime/lib/libcudf.so',
        'runtime/lib/librmm.so'
    ]},
    include_package_data = True,
    install_requires = [],
    cmdclass = {'install': cudf_installer},
    zip_safe = False
)
