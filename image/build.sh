#!/usr/bin/env bash

# image/build.sh

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

  opts="--label harbor"
  path_or_url=""

  process_options ${_script_path} "$@"

  validate ${path_or_url}

  docker image build ${opts} ${path_or_url}

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
      --add-host)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --add-host ${_arg}"
          shift
        else
          die 'ERROR: "--add-host" requires a non-empty option argument.'
        fi
        ;;
      --build-arg)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --build-arg ${_arg}"
          shift
        else
          die 'ERROR: "--build-arg" requires a non-empty option argument.'
        fi
        ;;
      --cache-from)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cache-from ${_arg}"
          shift
        else
          die 'ERROR: "--cache-from" requires a non-empty option argument.'
        fi
        ;;
      --cgroup-parent)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cgroup-parent ${_arg}"
          shift
        else
          die 'ERROR: "--cgroup-parent" requires a non-empty option argument.'
        fi
        ;;
      --cgroup-parent)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cgroup-parent ${_arg}"
          shift
        else
          die 'ERROR: "--cgroup-parent" requires a non-empty option argument.'
        fi
        ;;
      --compress)
        opts="${opts} --compress"
        ;;
      --cpu-period)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-period ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-period" requires a non-empty option argument.'
        fi
        ;;
      --cpu-quota)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-quota ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-quota" requires a non-empty option argument.'
        fi
        ;;
      --cpu-shares|-c)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-shares ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-shares" requires a non-empty option argument.'
        fi
        ;;
      --cpuset-cpus)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpuset-cpus ${_arg}"
          shift
        else
          die 'ERROR: "--cpuset-cpus" requires a non-empty option argument.'
        fi
        ;;
      --cpuset-mems)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpuset-mems ${_arg}"
          shift
        else
          die 'ERROR: "--cpuset-mems" requires a non-empty option argument.'
        fi
        ;;
      --disable-content-trust)
        opts="${opts} --disable-content-trust"
        ;;
      --file|-f)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --file ${_arg}"
          shift
        else
          die 'ERROR: "--file" requires a non-empty option argument.'
        fi
        ;;
      --force-rm)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --force-rm ${_arg}"
          shift
        else
          die 'ERROR: "--force-rm" requires a non-empty option argument.'
        fi
        ;;
      --iidfile)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --iidfile ${_arg}"
          shift
        else
          die 'ERROR: "--iidfile" requires a non-empty option argument.'
        fi
        ;;
      --isolation)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --isolation ${_arg}"
          shift
        else
          die 'ERROR: "--isolation" requires a non-empty option argument.'
        fi
        ;;
      --memory|-m)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --memory ${_arg}"
          shift
        else
          die 'ERROR: "--memory" requires a non-empty option argument.'
        fi
        ;;
      --memory-swap)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --memory-swap ${_arg}"
          shift
        else
          die 'ERROR: "--memory-swap" requires a non-empty option argument.'
        fi
        ;;
      --network)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --network ${_arg}"
          shift
        else
          die 'ERROR: "--network" requires a non-empty option argument.'
        fi
        ;;
      --no-cache)
        opts="${opts} --no-cache"
        ;;
      --pull)
        opts="${opts} --pull"
        ;;
      --quiet|-q)
        opts="${opts} --quiet"
        ;;
      --rm)
        opts="${opts} --rm"
        ;;
      --security-opt)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --security-opt ${_arg}"
          shift
        else
          die 'ERROR: "--security-opt" requires a non-empty option argument.'
        fi
        ;;
      --shm-size)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --shm-size ${_arg}"
          shift
        else
          die 'ERROR: "--shm-size" requires a non-empty option argument.'
        fi
        ;;
      --squash)
        opts="${opts} --squash"
        ;;
      --stream)
        opts="${opts} --stream"
        ;;
      --tag|-t)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --tag ${_arg}"
          shift
        else
          die 'ERROR: "--tag" requires a non-empty option argument.'
        fi
        ;;
      --target)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --target ${_arg}"
          shift
        else
          die 'ERROR: "--target" requires a non-empty option argument.'
        fi
        ;;
      --ulimit)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --ulimit ${_arg}"
          shift
        else
          die 'ERROR: "--ulimit" requires a non-empty option argument.'
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
        die 'ERROR: Unknown option (FATAL): %s\nSee "docker image build --help".\n' "$1"
        ;;
      # Default case: No more options, so break out of the loop.
      *)
        break
    esac

    shift

  done

  path_or_url=$1
  shift

  if [[ "$#" != "0" ]]; then
    die "ERROR: invalid argument '%s' passed to harbor image build.\nSee 'harbor image build --help'\n" "${@}"
  fi

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})
  path_or_url=$(trim ${path_or_url})

}

validate () {
  local _path_or_url=$1
  if [[ -z "$_path_or_url" ]]; then
    die "ERROR: harbor image build requires at least one argument.\nSee 'harbor image build --help'\n"
  fi
}

# Execute script.
main "$@"

exit 0
