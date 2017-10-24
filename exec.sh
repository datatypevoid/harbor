#!/usr/bin/env bash

# script/exec.sh

set -e

main () {

  local _script_path=""
  get_abs_path_to_script _script_path

  # shellcheck source=/dev/null
  source "${_script_path}/lib/config.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/log.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/utils.shlib"

  local _DEFAULT_VERBOSITY_LEVEL=0

  # Initialize all the option variables.
  # This ensures we are not contaminated by variables from the environment.

  verbosity=${_DEFAULT_VERBOSITY_LEVEL}

  opts=""
  container=""
  cmd=""

  process_options ${_script_path} "$@"

  docker exec ${opts} ${container} ${cmd}

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
        show_help ${_script_path} "exec"
        exit
        ;;
      --detach|-d)
        opts="${opts} --detach"
        ;;
      --env|-e)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --env ${_arg}"
          shift
        else
          die 'ERROR: "--env" requires a non-empty option argument.'
        fi
        ;;
      --interactive|-i)
        opts="${opts} --interactive"
        ;;
      --privileged)
        opts="${opts} --privileged"
        ;;
      --tty|-t)
        opts="${opts} --tty"
        ;;
      --user|-u)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --user ${_arg}"
          shift
        else
          die 'ERROR: "--user" requires a non-empty option argument.'
        fi
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
      --volumes|-v)
        opts="${opts} --volumes"
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
        die 'ERROR: Unknown option (FATAL): %s\nSee "docker exec --help".\n' "$1"
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

  # All options should have been dealt with, leaving only the container and
  # commands.

  container="$1"
  shift
  cmd="$*"

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})
  container=$(trim ${container})
  cmd=$(trim ${cmd})

}

validate () {
  local _container=$1
  local _cmd=$2
  local _is_harbor_container=false
  _is_harbor_container=$(is_harbor_container ${_container})

  if [[ "$_is_harbor_container" = false ]]; then
    die "ERROR: %s is not a harbor container.\nSee 'harbor exec --help'.\n" "${_container}"
  elif [[ -z "$_cmd" ]]; then
    die "ERROR: harbor exec requires at least two arguments.\nSee 'harbor exec --help'\n"
  fi
}

# Execute script.
main "$@"

exit 0
