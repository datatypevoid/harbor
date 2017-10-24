#!/usr/bin/env bash

# script/namegen.sh

set -e

main () {

  local _script_path=""
  get_abs_path_to_script _script_path

  # shellcheck source=/dev/null
  source "${_script_path}/lib/config.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/utils.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/1337.shlib"
  # shellcheck source=/dev/null
  source "${_script_path}/lib/log.shlib"

  local _first_word_list=""
  config_get _first_word_list "wordlist0"

  local _second_word_list=""
  config_get _second_word_list "wordlist1"

  _first_word_list="${_script_path}/${_first_word_list}"
  _second_word_list="${_script_path}/${_second_word_list}"

  local _DEFAULT_VERBOSITY_LEVEL=0

  # Initialize all the option variables.
  # This ensures we are not contaminated by variables from the environment.

  verbosity=${_DEFAULT_VERBOSITY_LEVEL}

  iterations=1

  enable_leet_transformation=false

  process_options ${_script_path} "$@"

  debug 1 "INFO: %s\n" "Verbosity level: ${verbosity}"
  debug 1 "INFO: %s\n" "Script path: ${_script_path}"
  debug 2 "INFO: %s\n" "Interations: ${iterations}"
  debug 2 "INFO: %s\n" "Enable leet transformation | ${enable_leet_transformation}"
  debug 2 "INFO: %s\n" "First word list: ${_first_word_list}"
  debug 2 "INFO: %s\n" "Second word list: ${_second_word_list}"

  debug 2 "INFO: %s\n" "Entering loop for ${iterations} iterations"
  for ((i=1; i<=${iterations}; i++))
  do
    local _random_name=""
    local _format="%s"
    debug 3 "\nINFO: %s\n" "Generating random word combo"
    generate_random_word_combo ${_first_word_list} ${_second_word_list} _random_name
    if [[ "$enable_leet_transformation" = true ]]; then
      debug 3 "INFO: %s\n" "Running generated word combo through leet text filter."
      _random_name="$(text_to_leet -e ${_random_name})"
    fi
    debug 3 "INFO: %s\n" "Generated ${_random_name} during iteration ${i}"
    if [[ "${iterations}" -gt 1 ]]; then _format="${_format}\n"; fi
    printf "${_format}" "${_random_name}"
  done

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
      --iterations|-i)
        if [ "$2" ]; then
          iterations=$2
          shift
        else
          die 'ERROR: "--iterations" requires a non-empty option argument.'
        fi
        ;;
      # Delete everything up to "=" and assign the remainder.
      --iterations=?*|-i=?*)
        iterations=${1#*=}
        ;;
      # Handle the case of an empty --iterations=
      --iterations=|-i=)
        die 'ERROR: "--iterations" requires a non-empty option argument.'
        ;;
      --leet|--1337|-l)
        enable_leet_transformation=true
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

# Execute script.
main "$@"

exit 0
