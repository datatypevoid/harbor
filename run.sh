#!/usr/bin/env bash

# script/run.sh

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

  opts="--label harbor"

  process_options ${_script_path} "$@"

  docker run ${opts}

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
      --env-file)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --env-file ${_arg}"
          shift
        else
          die 'ERROR: "--env-file" requires a non-empty option argument.'
        fi
        ;;
      --expose)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --expose ${_arg}"
          shift
        else
          die 'ERROR: "--expose" requires a non-empty option argument.'
        fi
        ;;
      --interactive|-i)
        opts="${opts} --interactive"
        ;;
      --label|-l)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --label ${_arg}"
          shift
        else
          die 'ERROR: "--label" requires a non-empty option argument.'
        fi
        ;;
      --mount)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --mount ${_arg}"
          shift
        else
          die 'ERROR: "--mount" requires a non-empty option argument.'
        fi
        ;;
      --name)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --name ${_arg}"
          shift
        else
          die 'ERROR: "--name" requires a non-empty option argument.'
        fi
        ;;
      --publish|-p)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --expose ${_arg}"
          shift
        else
          die 'ERROR: "--expose" requires a non-empty option argument.'
        fi
        ;;
      --tty|-t)
        opts="${opts} --tty"
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
        printf 'ERROR: Unknown option (FATAL): %s\n' "$1" >&2
        die $'See "docker run --help".\n'
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

  # All options should have been dealt with, leaving only the command target,
  # i.e. the docker container's name
  opts="${opts} $(echo -- "$@")"

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})

}

# Execute script.
main "$@"

exit 0
