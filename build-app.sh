#!/usr/bin/env bash

# script/build-app.sh

set -e

main () {

  local _script_path=""
  get_abs_path_to_script _script_path

  # shellcheck source=/dev/null
  source "${_script_path}/lib/config.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/docker.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/log.shlib"

  local _build_script=""
  config_get _build_script "script:build-app"

  local _DEFAULT_DOCKER_IMAGE=""
  config_get _DEFAULT_DOCKER_IMAGE "build-container-image"

  local _DEFAULT_MOUNT_SOURCE=""
  config_get _DEFAULT_MOUNT_SOURCE "app-mount-source"

  local _DEFAULT_MOUNT_TARGET=""
  config_get _DEFAULT_MOUNT_TARGET "app-mount-target"

  local _DEFAULT_CONTAINER_NAME=""
  _DEFAULT_CONTAINER_NAME="$(${_script_path}/namegen.sh)"

  local _DEFAULT_VERBOSITY_LEVEL=""
  config_get _DEFAULT_VERBOSITY_LEVEL "verbosity"

  container_started=false

  # Initialize all the option variables.
  # This ensures we are not contaminated by variables from the environment.

  verbosity=${_DEFAULT_VERBOSITY_LEVEL}

  build_type="Debug"

  container_name="${_DEFAULT_CONTAINER_NAME}"

  docker_image="${_DEFAULT_DOCKER_IMAGE}"

  mount_source="${_DEFAULT_MOUNT_SOURCE}"
  mount_target="${_DEFAULT_MOUNT_TARGET}"

  process_options ${_script_path} "$@"

  debug 1 "INFO: %s\n" "Verbosity level: ${verbosity}"
  debug 1 "INFO: %s\n" "Script path: ${_script_path}"
  debug 1 "INFO: %s\n" "Build type: ${build_type}"
  debug 2 "INFO: %s\n" "Container name: ${container_name}"
  debug 2 "INFO: %s\n" "Script source: ${_build_script}"
  debug 2 "INFO: %s\n" "App source volume: ${mount_source}"
  debug 2 "INFO: %s\n" "App volume mount path: ${mount_target}"
  debug 2 "INFO: %s\n" "Docker image: ${docker_image}"

  start_container \
    ${container_name} \
    ${mount_source} \
    ${mount_target} \
    ${docker_image} \
    container_started

  build_app \
    ${verbosity} \
    ${build_type} \
    ${container_name} \
    ${mount_target} \
    ${_build_script} \
    "/build-app.sh"

}

on_exit () {
  printf --  "INFO: %s\n" "Trapped EXIT code; executing handler"
  local _container_name=${container_name}
  local _container_started=${container_started}
  printf --  "INFO: %s\n" "Checking if this script started a Docker container..."
  if [ "$_container_started" = true ]; then
    printf --  "INFO: %s\n" "Container ${_container_name} was started by this script"
    printf --  "INFO: %s\n" "Attempting to clean-up container: ${_container_name}"
    printf --  "INFO: %s\n" "Ran clean-up operation on: $(cleanup_container ${_container_name})"
  fi
}

on_error () {
  printf --  "INFO: %s\n" "Trapped ERROR code; executing handler"
  local _container_name=${container_name}
  local _container_started=${container_started}
  printf --  "INFO: %s\n" "Checking if this script started a Docker container..."
  if [ "$_container_started" = true ]; then
    printf --  "INFO: %s\n" "Container ${_container_name} was started by this script"
    printf --  "INFO: %s\n" "Ran clean-up operation on: $(cleanup_container ${_container_name})"
  fi
}

debug () {
  local _verbosity=${1:?}
  local _formatter=${2:?}
  local _message=${3:?}
  log ${_verbosity} ${verbosity} \"${_formatter}\" ${_message}
}

get_abs_path_to_script () {
  pushd . > /dev/null
  local _path="${BASH_SOURCE[0]}"
  if ([ -h "${_path}" ]); then
    while([ -h "${_path}" ]); do cd "$(dirname "$_path")";
    _path=`readlink "${_path}"`; done
  fi
  cd "$(dirname ${_path})" > /dev/null
  _path=$(pwd);
  popd > /dev/null
  eval "$1=${_path}"
}

process_options () {

  local _script_path=${1:?}

  # drop _script_path parameter
  shift

  while :; do
    case $1 in
      # Display a usage synopsis.
      -h|-\?|--help)
        show_help ${_script_path}
        exit
        ;;
      # Takes an option argument; ensure it has been specified.
      --build-type)
        if [ "$2" ]; then
          build_type=$2
          shift
        else
          die 'ERROR: "--build-type" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --build-type=?*)
        build_type=${1#*=}
        ;;
      # Handle the case of an empty --build-type=
      --build-type=)
        die 'ERROR: "--build-type" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --container-name|-n)
        if [ "$2" ]; then
          container_name=$2
          shift
        else
          die 'ERROR: "--container-name" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --container-name=?*|-n=?*)
        container_name=${1#*=}
        ;;
      # Handle the case of an empty --container-name=
      --container-name=|-n=)
        die 'ERROR: "--container-name" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --image|-i)
        if [ "$2" ]; then
          docker_image=$2
          shift
        else
          die 'ERROR: "--image" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --image=?*|-i=?*)
        docker_image=${1#*=}
        ;;
      # Handle the case of an empty --image=
      --image=|-i=)
        die 'ERROR: "--image" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --mount-source|-s)
        if [ "$2" ]; then
          mount_source=$2
          shift
        else
          die 'ERROR: "--mount-source" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --mount-source=?*|-s=?*)
        mount_source=${1#*=}
        ;;
      # Handle the case of an empty --mount-source=
      --mount-source=|-s=)
        die 'ERROR: "--mount-source" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --mount-target|-t)
        if [ "$2" ]; then
          mount_target=$2
          shift
        else
          die 'ERROR: "--mount-target" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --mount-target=?*|-t=?*)
        mount_target=${1#*=}
        ;;
      # Handle the case of an empty --mount-target=
      --mount-target=|-s=)
        die 'ERROR: "--mount-target" requires a non-empty option argument.'
        ;;
       # Each occurence of --verbose adds 1 to verbosity.
      --verbose)
        ((verbosity++))
        ;;
      # Each occurence of v adds 1 to verbosity.
      -v|-vv|-vvv)
        local _size=${#1}
        ((_size--))
        verbosity=${_size}
        ;;
      # Takes an option argument; ensure it has been specified.
      --verbosity)
        if [ "$2" ]; then
          verbosity=$2
          shift
        else
          die 'ERROR: "--verbosity" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --verbosity=?*|-b=?*)
        verbosity=${1#*=}
        ;;
      # Handle the case of an empty --verbosity=
      --verbosity=|-b=)
        die 'ERROR: "--verbosity" requires a non-empty option argument.'
        ;;
      # Prints a trace of simple commands, for commands, case commands, select
      # commands, and arithmetic for commands and their arguments or associated
      # word lists after they are expanded and before they are executed.
      --trace|-t)
        set -x
        ;;
      # Prints a trace of simple commands, for commands, case commands, select
      # commands, and arithmetic for commands and their arguments or associated
      # word lists after they are expanded and before they are executed.
      --trace)
        set -x
        ;;
      # End of all options.
      --)
        shift
        break
        ;;
      -?*)
        printf 'WARN: Unknown option (ignored): %s\n' "$1" >&2
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

}

start_container () {
  local _container_name=${1:?}
  local _mount_source=${2:?}
  local _mount_target=${3:?}
  local _docker_image=${4:?}
  local _is_container_running=false
  local _is_container_exited=false

  debug 2 "INFO: %s\n" "Checking if a container with the name ${_container_name} is currently running"
  is_container_running ${_container_name} _is_container_running
  debug 2 "INFO: %s\n" "Checking if a container with the name ${_container_name} is currently exited"
  is_container_exited ${_container_name} _is_container_exited

  debug 3 "INFO: %s\n" "Container status running | ${_is_container_running}"
  debug 3 "INFO: %s\n" "Container status exited | ${_is_container_exited}"

  if [ "$_is_container_running" = false ]; then
    if [ "$_is_container_exited" = true ]; then
      # Remove along with volumes.
      debug 1 "INFO: %s\n" "A container with the name ${_container_name} has the status \`exited\`"
      debug 1 "INFO: %s\n" "Attempting to destroy ${_container_name} along with any owned volumes"
      debug 1 "INFO: %s\n" "Ran clean-up operation on: $(cleanup_container ${_container_name})"
    fi
    debug 1 "INFO: %s\n" "Attempting to run container ${_container_name}..."
    debug 1 "INFO: %s\n" "Using Docker image: ${_docker_image}"
    # Run container
    debug 2 "Container ID: %s\n" "$(
      docker run -it \
        --name ${_container_name} \
        --mount source=${_mount_source},target=${_mount_target} \
        -d ${_docker_image}
    )"
    eval "$5=true"
  else
    die "ERROR: Container already exists with the name: ${_container_name}"
  fi
}

construct_options () {

  local _opts=""
  local _verbosity=${1:?}
  local _build_type=${2:?}
  local _mount_target=${3:?}

  _opts="${_opts} --verbosity=${_verbosity}"
  _opts="${_opts} --build-type=${_build_type}"
  _opts="${_opts} --mount-target=${_mount_target}"

  echo ${_opts}

}

build_app () {
  local _verbosity=${1:?}
  local _build_type=${2:?}
  local _container_name=${3:?}
  local _mount_target=${4:?}
  local _build_script=${5:?}
  local _script_target=${6:?}
  local _opts=""
  debug 1 "INFO: %s\n" "Constructing options to pass to ${_build_script}"
  _opts="$(construct_options ${verbosity} ${_build_type} ${_mount_target})"
  debug 2 "INFO: options -- %s\n" "${_opts}"
  debug 2 "INFO: %s\n" "Copying ${_build_script} to container ${_container_name}"
  docker cp ${_build_script} ${_container_name}:${_script_target}
  debug 2 "INFO: %s\n" "Making ${_script_target} executable within container ${_container_name}"
  docker exec -it ${_container_name} bash -c "chmod 775 ${_script_target}"
  debug 2 "INFO: %s\n" "Executing ${_script_target} within container ${_container_name}"
  docker exec -it ${_container_name} bash -c "${_script_target} ${_opts}"
}

trap on_error ERR
trap on_exit EXIT

# Execute script.
main "$@"

exit 0
