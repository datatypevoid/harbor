#!/usr/bin/env bash

# image/tag.sh

set -e

main () {

  local _script_path=""
  get_abs_path_to_script _script_path

  # shellcheck source=/dev/null
  source "${_script_path}/../lib/config.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/../lib/log.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/../lib/utils.shlib"

  local _DEFAULT_VERBOSITY_LEVEL=0

  # Initialize all the option variables.
  # This ensures we are not contaminated by variables from the environment.

  verbosity=${_DEFAULT_VERBOSITY_LEVEL}

  opts=""
  source_image=""
  target_image=""

  process_options ${_script_path} "$@"

  validate ${source_image} ${target_image}

  docker image tag ${opts} ${source_image} ${target_image}

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
        die 'ERROR: Unknown option (FATAL): %s\nSee "docker image tag --help".\n' "$1"
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

  source_image="$1"
  shift

  target_image="$1"
  shift

  if [[ "$#" != "0" ]]; then
    die "ERROR: invalid argument(s) '%s' passed to harbor image tag.\nSee 'harbor image tag --help'\n" "${@}"
  fi

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})
  source_image=$(trim ${source_image})
  target_image=$(trim ${target_image})
}

validate () {
  local _source_image=$1
  local _target_image=$2
  local _is_source_harbor_image=false
  local _is_target_harbor_image=false
  _is_source_harbor_image=$(is_harbor_image ${_source_image})
  _is_target_harbor_image=$(is_harbor_image ${_target_image})
  if [[ -z "$_source_image" ]]; then
    die "ERROR: harbor image tag requires at least two arguments.\nSee 'harbor image tag --help'\n"
  elif [[ -z "$_target_image" ]]; then
    die "ERROR: harbor image tag requires at least two arguments.\nSee 'harbor image tag --help'\n"
  elif [[ "$_is_source_harbor_image" = false ]]; then
    die "ERROR: %s is not a harbor container.\nSee 'harbor image tag --help'.\n" "${_source_image}"
  elif [[ "$_is_target_harbor_image" = false ]]; then
    die "ERROR: %s is not a harbor container.\nSee 'harbor image tag --help'.\n" "${_target_image}"
  fi
}

# Execute script.
main "$@"

exit 0
