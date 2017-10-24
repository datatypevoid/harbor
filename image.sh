#!/usr/bin/env bash

# script/image.sh

set -e

main () {

  local _script_path=""
  get_abs_path_to_script _script_path

  # shellcheck source=/dev/null
  source "${_script_path}/lib/utils.shlib"

  local _image_scripts_path="${_script_path}/image"

  process_command ${_script_path} "$@"

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

process_command () {

  local _script_path=$1

  # drop script_path parameter
  shift

  case $1 in
    # Display a usage synopsis.
    -h|-\?|--help)
      show_help ${_script_path}
      exit
      ;;
    build)
      # drop command parameter, leaving options passed by user
      shift
      # call build script, forwarding options
      ${_image_scripts_path}/build.sh "${@}"
      ;;
    history)
      # drop command parameter, leaving options passed by user
      shift
      # call history script, forwarding options
      ${_image_scripts_path}/history.sh "${@}"
      ;;
    import)
      # drop command parameter, leaving options passed by user
      shift
      # call import script, forwarding options
      ${_image_scripts_path}/import.sh "${@}"
      ;;
    inspect)
      # drop command parameter, leaving options passed by user
      shift
      # call inspect script, forwarding options
      ${_image_scripts_path}/inspect.sh "${@}"
      ;;
    load)
      # drop command parameter, leaving options passed by user
      shift
      # call load script, forwarding options
      ${_image_scripts_path}/load.sh "${@}"
      ;;
    ls)
      # drop command parameter, leaving options passed by user
      shift
      # call ls script, forwarding options
      ${_image_scripts_path}/ls.sh "${@}"
      ;;
    prune)
      # drop command parameter, leaving options passed by user
      shift
      # call prune script, forwarding options
      ${_image_scripts_path}/prune.sh "${@}"
      ;;
    pull)
      # drop command parameter, leaving options passed by user
      shift
      # call pull script, forwarding options
      ${_image_scripts_path}/pull.sh "${@}"
      ;;
    push)
      # drop command parameter, leaving options passed by user
      shift
      # call push script, forwarding options
      ${_image_scripts_path}/push.sh "${@}"
      ;;
    rm)
      # drop command parameter, leaving options passed by user
      shift
      # call rm script, forwarding options
      ${_image_scripts_path}/rm.sh "${@}"
      ;;
    save)
      # drop command parameter, leaving options passed by user
      shift
      # call save script, forwarding options
      ${_image_scripts_path}/save.sh "${@}"
      ;;
    tag)
      # drop command parameter, leaving options passed by user
      shift
      # call tag script, forwarding options
      ${_image_scripts_path}/tag.sh "${@}"
      ;;
    # Default case: No more options, error if reached.
    *)
      die "ERROR: Unknown command (FATAL): ${1}"
  esac

}

# Execute script.
main "$@"

exit 0
