#!/usr/bin/env bash

# script/clone.sh

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

  local _clone_script=""
  config_get _clone_script "script:clone"

  local _DEFAULT_SSH_TARGET=""
  config_get _DEFAULT_SSH_TARGET "ssh-mount-target"

  local _DEFAULT_APP_TARGET=""
  config_get _DEFAULT_APP_TARGET "app-mount-target"

  local _DEFAULT_DOCKER_IMAGE=""
  config_get _DEFAULT_DOCKER_IMAGE "clone-container-image"

  local _DEFAULT_APP_SOURCE=""
  config_get _DEFAULT_APP_SOURCE "app-mount-source"

  local _DEFAULT_SSH_SOURCE=""
  config_get _DEFAULT_SSH_SOURCE "ssh-source-volume"

  local _DEFAULT_CONTAINER_NAME=""
  _DEFAULT_CONTAINER_NAME="$(${_script_path}/namegen.sh)"

  local _DEFAULT_VERBOSITY_LEVEL=""
  config_get _DEFAULT_VERBOSITY_LEVEL "verbosity"

  container_started=false

  # Initialize all the option variables.
  # This ensures we are not contaminated by variables from the environment.

  verbosity=${_DEFAULT_VERBOSITY_LEVEL}

  branch=""

  container_name=${_DEFAULT_CONTAINER_NAME:?}

  ssh_source=${_DEFAULT_SSH_SOURCE:?}
  ssh_target=${_DEFAULT_SSH_TARGET:?}

  app_source=${_DEFAULT_APP_SOURCE:?}
  app_target=${_DEFAULT_APP_TARGET:?}

  docker_image=${_DEFAULT_DOCKER_IMAGE:?}

  process_options ${_script_path} "$@"

  debug 1 "INFO: %s\n" "Verbosity level: ${verbosity}"
  debug 1 "INFO: %s\n" "Script path: ${_script_path}"
  debug 2 "INFO: %s\n" "Container name: ${container_name}"
  debug 2 "INFO: %s\n" "Repository branch: ${branch}"
  debug 2 "INFO: %s\n" "Script source: ${_clone_script}"
  debug 2 "INFO: %s\n" "SSH source volume: ${ssh_source}"
  debug 2 "INFO: %s\n" "SSH volume mount path: ${ssh_target}"
  debug 2 "INFO: %s\n" "App source volume: ${app_source}"
  debug 2 "INFO: %s\n" "App volume mount path: ${app_target}"
  debug 2 "INFO: %s\n" "Docker image: ${docker_image}"

  delete_app_volume ${_DEFAULT_APP_SOURCE}

  start_container \
    ${container_name} \
    ${ssh_source} \
    ${ssh_target} \
    ${app_source} \
    ${app_target} \
    ${docker_image} \
    container_started

  run_clone_script \
    ${verbosity} \
    ${branch} \
    ${container_name} \
    ${app_target} \
    ${ssh_target} \
    ${_clone_script} \
    "/clone.sh"

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
  printf -- "INFO: %s\n" "Checking if this script started a Docker container..."
  if [ "$_container_started" = true ]; then
    printf -- "INFO: %s\n" "Container ${_container_name} was started by this script"
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
      --app-source)
        if [ "$2" ]; then
          app_source=$2
          shift
        else
          die 'ERROR: "--app-source" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --app-source=?*)
        app_source=${1#*=}
        ;;
      # Handle the case of an empty --app-source=
      --app-source=)
        die 'ERROR: "--app-source" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --app-target)
        if [ "$2" ]; then
          app_target=$2
          shift
        else
          die 'ERROR: "--app-target" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --app-target=?*)
        app_target=${1#*=}
        ;;
      # Handle the case of an empty --app-target=
      --app-target=)
        die 'ERROR: "--app-target" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --branch|-b)
        if [ "$2" ]; then
          branch=$2
          shift
        else
          die 'ERROR: "--branch" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --branch=?*|-b=?*)
        branch=${1#*=}
        ;;
      # Handle the case of an empty --branch=
      --branch=|-b=)
        die 'ERROR: "--branch" requires a non-empty option argument.'
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
      --ssh-source)
        if [ "$2" ]; then
          ssh_source=$2
          shift
        else
          die 'ERROR: "--ssh-source" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --ssh-source=?*)
        ssh_source=${1#*=}
        ;;
      # Handle the case of an empty --ssh-source=
      --ssh-source=)
        die 'ERROR: "--ssh-source" requires a non-empty option argument.'
        ;;
      # Takes an option argument; ensure it has been specified.
      --ssh-target)
        if [ "$2" ]; then
          ssh_target=$2
          shift
        else
          die 'ERROR: "--ssh-target" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --ssh-target=?*)
        ssh_target=${1#*=}
        ;;
      # Handle the case of an empty --ssh-target=
      --ssh-target=)
        die 'ERROR: "--ssh-target" requires a non-empty option argument.'
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
  local _ssh_source=${2:?}
  local _ssh_target=${3:?}
  local _app_source=${4:?}
  local _app_target=${5:?}
  local _docker_image=${6:?}
  local _is_container_running=false
  local _is_container_exited=false

  debug 2 "INFO: %s\n" "Checking if a container with the name ${_container_name} is currently running"
  is_container_running ${_container_name} _is_container_running
  debug 2 "INFO: %s\n" "Checking if a container with the name ${_container_name} is currently exited"
  is_container_exited ${_container_name} _is_container_exited

  debug 3 "INFO: %s\n" "Container status running ? ${_is_container_running}"
  debug 3 "INFO: %s\n" "Container status exited ? ${_is_container_exited}"

  if [ "$_is_container_running" = false ]; then
    if [ "$_is_container_exited" = true ]; then
      # Remove along with volumes.
      debug 1 "INFO: %s\n" "A container with the name ${_container_name} has the status \`exited\`"
      debug 1 "INFO: %s\n" "Attempting to destroy ${_container_name} along with any owned volumes"
      debug 1 "INFO: %s\n" "Ran clean-up operation on: $(cleanup_container ${_container_name})"
    fi
    # Run container
    debug 1 "INFO: %s\n" "Attempting to run container ${_container_name}..."
    debug 1 "INFO: %s\n" "Using Docker image: ${_docker_image}"
    debug 2 "Container ID: %s\n" "$(
      docker run -it \
        --name ${_container_name} \
        --mount source=${_ssh_source},target=${_ssh_target},readonly \
        --mount source=${_app_source},target=${_app_target} \
        -d ${_docker_image}
    )"
    eval "$7=true"
  else
    die "ERROR: Container already exists with the name: ${_container_name}"
  fi
}

delete_app_volume () {
  local _volume_name=${1:?}
  debug 2 "INFO: %s\n" "Checking if there is a Docker volume in use with the name: ${_volume_name}"
  if [ "$(docker volume ls -q -f name=${_volume_name})" ]; then
    debug 1 "INFO: %s\n" "Running deletion operation on volume: ${_volume_name}"
    debug 2 "INFO: %s\n" "Ran deletion operation on: $(delete_volume ${_volume_name})"
  fi
}

construct_options () {
  local _opts=""
  local _verbosity=${1:?}
  local _branch=${2:?}
  local _app_target=${3:?}
  local _ssh_target=${4:?}

  _opts="${_opts} --branch=${_branch}"
  _opts="${_opts} --app-target=${_app_target}"
  _opts="${_opts} --ssh-target=${_ssh_target}"
  _opts="${_opts} --verbosity=${_verbosity}"

  printf -- "%s" "${_opts}"
}

run_clone_script () {
  local _verbosity=${1:?}
  local _branch=${2:?}
  local _container_name=${3:?}
  local _app_target=${4:?}
  local _ssh_target=${5:?}
  local _clone_script=${6:?}
  local _script_target=${7:?}
  local _opts=""
  debug 1 "INFO: %s\n" "Constructing options to pass to ${_clone_script}"
  _opts="$(construct_options ${_verbosity} ${_branch} ${_app_target} ${_ssh_target})"
  debug 2 "INFO: options -- %s\n" "${_opts}"
  debug 2 "INFO: %s\n" "Copying ${_clone_script} to container ${_container_name}"
  docker cp ${_clone_script} ${_container_name}:${_script_target}
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
