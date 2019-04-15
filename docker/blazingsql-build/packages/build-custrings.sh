#!/bin/bash

# depedencies
# variables: workspace_dir, all custrings input variables
# functions: normalize_branch_name
function package_custrings() {
    ### verify whether package is enabled
    if [ "${custrings_enable}" == false ]; then
        return
    fi

    ### perform data initialization
    declare -n output="$1"
    declare -A custrings_data
    declare -A custrings_inputs

    ### TODO: Hardcoded python path - fix it
    custrings_python_include="$2"
    custrings_python_library="$3"

    ### initialization of the parameters
    custrings_inputs=(
        ['package']="custrings"
        ['repository']="$custrings_repository"
        ['branch']="$custrings_branch"
        ['build']="$custrings_build_type"
        ['parallel']="$custrings_parallel"
        ['tests']="$custrings_tests"
        ['clean']="$custrings_clean_before_build"
    )

    if [ -z "${custrings_inputs['repository']}" ]; then
        custrings_inputs['repository']="git@github.com:rapidsai/custrings.git"
    fi
    if [ -z "${custrings_inputs['branch']}" ]; then
        custrings_inputs['branch']="master"
    fi

    package_initialize custrings_data "$(declare -p custrings_inputs)"

    ### configuration of the package (git)
    branch_name="$(normalize_branch_name ${custrings_data['branch']})"
    custrings_data['branch_dir']="${workspace_dir}/custrings_project/${branch_name}"
    custrings_data['project']="${custrings_data['branch_dir']}/custrings"

    custrings_data['build_dir']="${custrings_data['branch_dir']}/build"
    custrings_data['source_dir']="${custrings_data['branch_dir']}/custrings/cpp"
    custrings_data['install_dir']="${custrings_data['branch_dir']}/install"

    package_configure "$(declare -p custrings_data)"

    ### perform the 'cmake' operation
    declare -A custrings_env
    declare -A custrings_cmake

    custrings_env['cuda']="CUDACXX=/usr/local/cuda/bin/nvcc"

    custrings_cmake=(
        ['package']="${custrings_data['package']}"
        ['build_type']="${custrings_data['build']}"
        ['python_include']="${custrings_python_include}"
        ['python_library']="${custrings_python_library}"
    )

    if [ "${custrings_data['tests']}" == true ]; then
        custrings_cmake['tests']="-DBUILD_TESTS=ON"
    fi

    package_execute_cmake "$(declare -p custrings_data)" "$(declare -p custrings_cmake)" "$(declare -p custrings_env)"

    ### compile and install the package
    package_compile_and_install "$(declare -p custrings_data)"

    ### result
    output['project']="${custrings_data['project']}"
    output['branch_name']="${branch_name}"
    output['install_dir']="${custrings_data['install_dir']}"
}
