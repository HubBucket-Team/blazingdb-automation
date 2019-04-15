#!/bin/bash

log_delimiter="##########################################################"

function function_log_start() {
    echo "${log_delimiter}"
    echo "$1: $2"
    echo
}

function function_log_end() {
    echo
    echo "$1: $2"
    echo "${log_delimiter}"
}


function package_initialize() {
    # declare associative arrays
    declare -n output="$1"
    eval "declare -A input"=${2#*=}

    # log function
    function_log_start "package_initialize" "${input['package']}"

    # assign package
    output['package']="${input['package']}"

    # assign repository
    if [ "${input['repository']}" ]; then
        output['repository']="${input['repository']}"
    else
        echo "Error | PWD:$PWD | Command:repository not defined"
    fi

    # assign branch or commit
    if [ -z "${input['branch']}" ]; then
        output['branch']="master"
    else
        output['branch']="${input['branch']}"
    fi

    # select build type, default is Release
    if [ -z "${input['build']}" ]; then
        output['build']="Release"
    else
        output['build']="${input['build']}"
    fi

    # number of jobs when 'make' is executed, default is 4
    if [ -z "${input['parallel']}" ]; then
        output['parallel']=4
    else
        output['parallel']="${input['parallel']}"
    fi

    # whether tests are enable, default is false
    if [ -z "${input['tests']}" ]; then
        output['tests']=false
    else
        output['tests']="${input['tests']}"
    fi

    # clean the build directory, default is false
    if [ -z "${input['clean']}" ]; then
        output['clean']=false
    else
        output['clean']="${input['clean']}"
    fi

    #"************************************"
    # print output information
    echo "package: ${output['package']}"
    for i in "${!output[@]}"
    do
        if [ "$i" == "package" ]; then
            continue
        fi
        echo "$i: ${output[$i]}"
    done

    # log function
    function_log_end "package_initialize" "${input['package']}"
}


function package_configure() {
    # declare associative arrays
    eval "declare -A map_config"=${1#*=}

    # log function
    function_log_start "package_configure" "${map_config['package']}"

    # verify to execute operation
    if [ "${map_config['clean']}" == true ]; then
        rm -rf "${map_config['build_dir']}"
        rm -rf "${map_config['install_dir']}"
        echo "deleted build folder: ${map_config['build_dir']}"
        echo "deleted install folder: ${map_config['install_dir']}"
        echo
    fi

    # create directories
    if [ ! -d "${map_config['build_dir']}" ]; then
        mkdir -p "${map_config['build_dir']}"
        echo "created build folder: ${map_config['build_dir']}"
        echo
    fi
    if [ ! -d "${map_config['install_dir']}" ]; then
        mkdir -p "${map_config['install_dir']}"
        echo "created install folder: ${map_config['install_dir']}"
        echo
    fi

    # verify if build folder contains elements
    if [ "$(ls -A ${map_config['build_dir']})" ]; then
        echo "${map_config['build_dir']} folder has build information"
        return
    fi

    # clone repository
    is_repository_empty=false
    if [ ! -d "${map_config['project']}" ]; then
        echo "clone repository: ${map_config['package']}"
        echo "git clone ${map_config['repository']}"
        echo

        is_repository_empty=true

        mkdir -p "${map_config['branch_dir']}"

        cd "${map_config['branch_dir']}"
        if [ $? -ne 0 ]; then
            echo "Error | PWD:$PWD | Command:${map_config['branch_dir']}"
            exit 1
        fi

        git clone "${map_config['repository']}"
        if [ $? -ne 0 ]; then
            echo "Error | PWD:$PWD | Command:git clone ${map_config['repository']}"
            exit 1
        fi
    fi

    # checkout branch or commit
    if [ "${is_repository_empty}" == true ] || [ "${map_config['clean']}" == true ]; then
        echo "checkout repository: ${map_config['package']}"
        echo "git checkout --quiet ${map_config['branch']}"
        echo

        # change directory
        cd "${map_config['project']}"
        if [ $? -ne 0 ]; then
            echo "Error | PWD:$PWD | Command:${map_config['project']}"
            exit 1
        fi

        # fetch repository information
        git fetch

        # checkout to branch or hash commit
        git checkout --quiet "${map_config['branch']}"
        if [ $? -ne 0 ]; then
            echo "Error | PWD:$PWD | Command:git checkout ${map_config['branch']}"
            exit 1
        fi

        # execute git pull when it is a branch
        regex_commit="^[0-9A-Fa-f]+$"
        if ! [[ "${map_config['branch']}" =~ $regex_commit ]]; then
            git pull
            if [ $? -ne 0 ]; then
                echo "Error | PWD:$PWD | Command:git pull"
                exit 1
            fi
        fi

        # download repository submodules
        echo "submodules repository: ${map_config['package']}"
        echo "submodule update --init --remote --recursive"
        echo

        git submodule update --init --remote --recursive
    fi

    # log function
    function_log_end "package_configure" "${map_config['package']}"
}


function execute_cmake() {
    # declare associative arrays
    eval "declare -A map_config"=${1#*=}
    eval "declare -A map_cmake"=${2#*=}
    eval "declare -A map_env"=${3#*=}

    # verify if build folder contains elements
    if [ "$(ls -A ${map_config['build_dir']})" ]; then
        echo "${map_config['build_dir']} folder has build information"
        return
    fi

    # change path
    cd "${map_config['build_dir']}"
    if [ $? -ne 0 ]; then
        echo "Error | PWD:$PWD | Command:${map_config['build_dir']}"
        exit 1
    fi

    # generate cmake parameters
    cmake_params=""
    [[ -v map_cmake['build_type'] ]] && 
    cmake_params="-DCMAKE_BUILD_TYPE=${map_cmake['build_type']}"

    [[ -v map_config['install_dir'] ]] &&
    cmake_params="${cmake_params} -DCMAKE_INSTALL_PREFIX:PATH=${map_config['install_dir']}"

    [[ -v map_cmake['tests'] ]] && 
    cmake_params="${cmake_params} ${map_cmake['tests']}"

    [[ -v map_cmake['dependencies'] ]] &&
    cmake_params="${cmake_params} -DBLAZINGDB_DEPENDENCIES_INSTALL_DIR=${map_cmake['dependencies']}"

    [[ -v map_cmake['python_include'] ]] &&
    cmake_params="${cmake_params} -DPYTHON_INCLUDE_DIR=${map_cmake['python_include']}"
    [[ -v map_cmake['python_library'] ]] &&
    cmake_params="${cmake_params} -DPYTHON_LIBRARY=${map_cmake['python_library']}"

    # generate environment variables
    env_params=""
    for i in "${!map_env[@]}"
    do
        env_params="${env_params} ${map_env[$i]}"
    done

    # generate cmake command
    cmake_command="${env_params} cmake ${cmake_params} ${map_config['source_dir']}"

    # print cmake information
    echo "cmake command:"
    echo "${cmake_command}"
    echo

    # execute cmake command
    eval "${cmake_command}"
    if [ $? -ne 0 ]; then
        echo "Error | PWD:$PWD | Command:${cmake_command}"
        exit 1
    fi
}


function package_execute_cmake() {
    # declare associative arrays
    eval "declare -A map_config"=${1#*=}
    eval "declare -A map_cmake"=${2#*=}
    eval "declare -A map_env"=${3#*=}

    # log function
    function_log_start "package_execute_cmake" "${map_config['package']}"

    # execute command
    execute_cmake "$(declare -p map_config)" "$(declare -p map_cmake)" "$(declare -p map_env)"

    # log function
    function_log_end "package_execute_cmake" "${map_config['package']}"
}


function compile_and_install() {
    # declare associative arrays
    eval "declare -A map_config"=${1#*=}

    # verify if install folder contains elements
    if [ "$(ls -A ${map_config['install_dir']})" ]; then
        echo "${map_config['install_dir']} folder has install information"
        return
    fi

    # change directory to build folder
    cd "${map_config['build_dir']}"
    if [ $? -ne 0 ]; then
        echo "Error | PWD:$PWD | Command:cd ${map_config['build_dir']}"
        exit 1
    fi

    # generate make command
    make_command="make -j${map_config['parallel']}"

    # log information
    echo "${map_config['package']}: ${make_command}"
    echo

    # execute compilation
    eval "${make_command}"
    if [ $? -ne 0 ]; then
        echo "Error | PWD:$PWD | Command:${make_command}"
        exit 1
    fi

    # log information
    echo
    echo "${map_config['package']}: make install"
    echo

    # execute installation
    make install
    if [ $? -ne 0 ]; then
        echo "Error | PWD:$PWD | Command:make install"
        exit 1
    fi
}


function package_compile_and_install() {
    # declare associative arrays
    eval "declare -A map_config"=${1#*=}

    # log function
    function_log_start "package_compile_and_install" "${map_config['package']}"

    # execute command
    compile_and_install "$(declare -p map_config)"

    # log function
    function_log_end "package_compile_and_install" "${map_config['package']}"
}
