#!/usr/bin/env bash

# image/import.sh

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
  file_or_url=""
  repo_or_tag=""

  process_options ${_script_path} "$@"

  validate ${file_or_url}

  docker image import ${opts} ${file_or_url} ${repo_or_tag}

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
      --change)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --change ${_arg}"
          shift
        else
          die 'ERROR: "--change" requires a non-empty option argument.'
        fi
        ;;
      --message)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --message ${_arg}"
          shift
        else
          die 'ERROR: "--message" requires a non-empty option argument.'
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
        die 'ERROR: Unknown option (FATAL): %s\nSee "docker image import --help".\n' "$1"
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

  file_or_url=$1
  shift

  repo_or_tag=$1
  shift

  if [[ "$#" != "0" ]]; then
    die "ERROR: invalid argument '%s' passed to harbor image import.\nSee 'harbor image import --help'\n" "${@}"
  fi

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})
  file_or_url=$(trim ${file_or_url})
  repo_or_tag=$(trim ${repo_or_tag})

}

validate () {
  local _file_or_url=$1
  if [[ -z "$_file_or_url" ]]; then
    die "ERROR: harbor image import requires at least one argument.\nSee 'harbor image import --help'\n"
  fi
}

# Execute script.
main "$@"

exit 0
