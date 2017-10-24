#!/usr/bin/env bash

# script/harbor.sh

set -e

main () {

  local _script_path=""
  get_abs_path_to_script _script_path

  # shellcheck source=/dev/null
  source "${_script_path}/lib/utils.shlib"

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
    namegen)
      # drop command parameter, leaving options passed by user
      shift
      # call clone script, forwarding options
      ${_script_path}/namegen.sh "${@}"
      ;;
    build-app)
      # drop command parameter, leaving options passed by user
      shift
      # call clone script, forwarding options
      ${_script_path}/build-app.sh "${@}"
      ;;
    clone)
      # drop command parameter, leaving options passed by user
      shift
      # call clone script, forwarding options
      ${_script_path}/clone.sh "${@}"
      ;;
    deploy)
      # drop command parameter, leaving options passed by user
      shift
      # call deploy script, forwarding options
      ${_script_path}/deploy.sh "${@}"
      ;;
    exec)
      # drop command parameter, leaving options passed by user
      shift
      # call exec script, forwarding options
      ${_script_path}/exec.sh "${@}"
      ;;
    dev-box)
      # drop command parameter, leaving options passed by user
      shift
      # call dev-box script, forwarding options
      ${_script_path}/dev-box.sh "${@}"
      ;;
    image)
      # drop command parameter, leaving options passed by user
      shift
      # call image script, forwarding options
      ${_script_path}/image.sh "${@}"
      ;;
    images)
      # drop command parameter, leaving options passed by user
      shift
      # call images script, forwarding options
      ${_script_path}/images.sh "${@}"
      ;;
    package)
      # drop command parameter, leaving options passed by user
      shift
      # call package script, forwarding options
      ${_script_path}/package.sh "${@}"
      ;;
    ps)
      # drop command parameter, leaving options passed by user
      shift
      # call ps script, forwarding options
      ${_script_path}/ps.sh "${@}"
      ;;
    rm)
      # drop command parameter, leaving options passed by user
      shift
      # call rm script, forwarding options
      ${_script_path}/rm.sh "${@}"
      ;;
    rmi)
      # drop command parameter, leaving options passed by user
      shift
      # call rmi script, forwarding options
      ${_script_path}/rmi.sh "${@}"
      ;;
    run)
      # drop command parameter, leaving options passed by user
      shift
      # call run script, forwarding options
      ${_script_path}/run.sh "${@}"
      ;;
    stop)
      # drop command parameter, leaving options passed by user
      shift
      # call stop script, forwarding options
      ${_script_path}/stop.sh "${@}"
      ;;
    # Default case: No more options, error if reached.
    *)
      die "ERROR: Unknown command (FATAL): ${1}"
  esac

}

# Execute script.
main "$@"

exit 0
