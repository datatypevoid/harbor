#!/usr/bin/env bash

# script/rm.sh

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
  cmd=""

  process_options ${_script_path} "$@"

  validate "${cmd}" # quote to prevent word-splitting

  docker rm ${opts} ${cmd}

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
      --force|-f)
        opts="${opts} --force"
        ;;
      --link|-l)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --filter ${_arg}"
          shift
        else
          die 'ERROR: "--link" requires a non-empty option argument.'
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
      die 'ERROR: Unknown option (FATAL): %s\nSee "docker rm --help".\n' "$1"
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

  # All options should have been dealt with, leaving only the command target,
  # i.e. the docker container's name
  cmd="$*"

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})
  cmd=$(trim ${cmd})

}

validate () {
  local _cmd=$1
  if [[ -z "$_cmd" ]]; then
    die "ERROR: harbor rm requires at least one argument.\nSee 'harbor rm --help'\n"
  fi
  for c in $_cmd
  do
    local _is_harbor_container=false
    _is_harbor_container=$(is_harbor_container ${c})
    if [[ -z "$_is_harbor_container" ]]; then
      die "ERROR: %s is not a harbor container.\nSee 'harbor rm --help'.\n" "${c}"
    fi
  done
}

# Execute script.
main "$@"

exit 0
