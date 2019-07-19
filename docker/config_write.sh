#!/bin/bash
# Usage: 
# config_write.sh
# (arg 1) # blazingdb_toolchain_branch
# (arg 2) # custrings_branch
# (arg 3) # cudf_branch
# (arg 4) # protocol_branch
# (arg 5) # io_branch
# (arg 6) # blazingdb_communication_branch
# (arg 7) # ral_branch
# (arg 8) # orchestrator_branch
# (arg 9) # calcite_branch
# (arg 10) # pyblazing_branch
# (arg 11) # blazingdb_toolchain_clean_before_build
# (arg 12) # custrings_clean_before_build
# (arg 13) # cudf_clean_before_build
# (arg 14) # blazingdb_protocol_clean_before_build
# (arg 15) # blazingdb_io_clean_before_build
# (arg 16) # blazingdb_communication_clean_before_build
# (arg 17) # blazingdb_ral_clean_before_build
# (arg 18) # blazingdb_orchestrator_clean_before_build
# (arg 19) # blazingdb_calcite_clean_before_build
# (arg 20) # pyblazing_clean_before_build
# (arg 21) # workspace_maven_clean_repository
# Example: ./config_write.sh develop develop develop develop develop develop develop develop develop develop false false false false false false false false false false false

# Parametrize branchs
blazingdb_toolchain_branch=$1
custrings_branch=$2
cudf_branch=$3
blazingdb_protocol_branch=$4
blazingdb_io_branch=$5
blazingdb_communication_branch=$6
blazingdb_ral_branch=$7
blazingdb_orchestrator_branch=$8
blazingdb_calcite_branch=$9
pyblazing_branch=${10}

# Parametrize clean before build options
blazingdb_toolchain_clean_before_build=${11}
custrings_clean_before_build=${12}
cudf_clean_before_build=${13}
blazingdb_protocol_clean_before_build=${14}
blazingdb_io_clean_before_build=${15}
blazingdb_communication_clean_before_build=${16}
blazingdb_ral_clean_before_build=${17}
blazingdb_orchestrator_clean_before_build=${18}
blazingdb_calcite_clean_before_build=${19}
pyblazing_clean_before_build=${20}
workspace_maven_repository=${21}

# set default branches
echo "Forcing build dependencies: $blazingdb_toolchain_clean_before_build"

# Mandatory args

if [ -z "$blazingdb_toolchain_branch" ]; then
    blazingdb_toolchain_branch=develop
fi

if [ -z "$cudf_branch" ]; then
    cudf_branch=develop
fi

if [ -z "$blazingdb_protocol_branch" ]; then
    blazingdb_protocol_branch=develop
fi

if [ -z "$blazingdb_io_branch" ]; then
    blazingdb_io_branch=develop
fi

if [ -z "$blazingdb_communication_branch" ]; then
    blazingdb_communication_branch=develop
fi

if [ -z "$blazingdb_ral_branch" ]; then
    blazingdb_ral_branch=develop
fi

if [ -z "$blazingdb_orchestrator_branch" ]; then
    blazingdb_orchestrator_branch=develop
fi

if [ -z "$blazingdb_calcite_branch" ]; then
    blazingdb_calcite_branch=develop
fi

if [ -z "$pyblazing_branch" ]; then
    pyblazing_branch=develop
fi

echo "********************************"
echo "Branches input:"
echo "********************************"
echo "blazingdb_toolchain_branch: $blazingdb_toolchain_branch"
echo "custrings_branch: $custrings_branch"
echo "cudf_branch: $cudf_branch"
echo "blazingdb_protocol_branch: $blazingdb_protocol_branch"
echo "blazingdb_io_branch: $blazingdb_io_branch"
echo "blazingdb_communication_branch: $blazingdb_communication_branch"
echo "blazingdb_ral_branch: $blazingdb_ral_branch"
echo "blazingdb_orchestrator_branch: $blazingdb_orchestrator_branch"
echo "blazingdb_calcite_branch: $blazingdb_calcite_branch"
echo "pyblazing_branch: $pyblazing_branch"

# define the properties template
cat << EOF > ./blazingsql-build.properties
#mandatory: branches
blazingdb_toolchain_branch=$blazingdb_toolchain_branch
custrings_branch=$custrings_branch
cudf_branch=$cudf_branch
blazingdb_protocol_branch=$blazingdb_protocol_branch
blazingdb_io_branch=$blazingdb_io_branch
blazingdb_communication_branch=$blazingdb_communication_branch
blazingdb_ral_branch=$blazingdb_ral_branch
blazingdb_orchestrator_branch=$blazingdb_orchestrator_branch
blazingdb_calcite_branch=$blazingdb_calcite_branch
pyblazing_branch=$pyblazing_branch

#optional: enable build (default is true)
blazingdb_toolchain_enable=true
custrings_enable=true
cudf_enable=true
blazingdb_protocol_enable=true
blazingdb_io_enable=true
blazingdb_communication_enable=true
blazingdb_ral_enable=true
blazingdb_orchestrator_enable=true
blazingdb_calcite_enable=true
pyblazing_enable=true

#optional: build type for C/C++ projects (default is Release, i.e. -DCMAKE_BUILD_TYPE=Release)
# For debug mode use: Debug ... more info here: https://cmake.org/cmake/help/v3.12/variable/CMAKE_BUILD_TYPE.html#variable:CMAKE_BUILD_TYPE
custrings_build_type=Release
cudf_build_type=Release
blazingdb_protocol_build_type=Release
blazingdb_io_build_type=Release
blazingdb_communication_build_type=Release
blazingdb_ral_build_type=Release
blazingdb_orchestrator_build_type=Release

#optional: tests build & run (default is false)
blazingdb_toolchain_tests=false
custrings_tests=false
cudf_tests=false
blazingdb_protocol_tests=false
blazingdb_io_tests=false
blazingdb_communication_tests=false
blazingdb_ral_tests=false
blazingdb_orchestrator_tests=false
blazingdb_calcite_tests=false
pyblazing_tests=false

#optional: parallel builds for make -jX and mvn -T XC (default is 4)
blazingdb_toolchain_parallel=4
custrings_parallel=4
cudf_parallel=4
blazingdb_protocol_parallel=4
blazingdb_io_parallel=4
blazingdb_communication_parallel=4
blazingdb_ral_parallel=4
blazingdb_orchestrator_parallel=4
blazingdb_calcite_parallel=4

#optional: build options (precompiler definitions, etc.)
blazingdb_ral_definitions="-DLOG_PERFORMANCE"

#optional: clean options for selected branch (will delete the build folder before build)
blazingdb_toolchain_clean_before_build=$blazingdb_toolchain_clean_before_build
custrings_clean_before_build=$custrings_clean_before_build
cudf_clean_before_build=$cudf_clean_before_build
blazingdb_protocol_clean_before_build=$blazingdb_protocol_clean_before_build
blazingdb_io_clean_before_build=$blazingdb_io_clean_before_build
blazingdb_communication_clean_before_build=$blazingdb_communication_clean_before_build
blazingdb_ral_clean_before_build=$blazingdb_ral_clean_before_build
blazingdb_orchestrator_clean_before_build=$blazingdb_orchestrator_clean_before_build
blazingdb_calcite_clean_before_build=$blazingdb_calcite_clean_before_build
pyblazing_clean_before_build=$pyblazing_clean_before_build

EOF

echo "********************************"
echo "The blazingsql-build.properties:"
echo "********************************"
cat blazingsql-build.properties
echo "********************************"
