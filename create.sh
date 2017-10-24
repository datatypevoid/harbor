#!/usr/bin/env bash

# script/create.sh

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
  image=""
  cmd=""
  args=""

  process_options ${_script_path} "$@"

  validate ${image} ${cmd}

  docker create ${opts} ${image} ${cmd} ${args}

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
      --add-host)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --add-host ${_arg}"
          shift
        else
          die 'ERROR: "--add-host" requires a non-empty option argument.'
        fi
        ;;
      --attach)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --attach ${_arg}"
          shift
        else
          die 'ERROR: "--attach" requires a non-empty option argument.'
        fi
        ;;
      --blkio-weight)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --blkio-weight ${_arg}"
          shift
        else
          die 'ERROR: "--blkio-weight" requires a non-empty option argument.'
        fi
        ;;
      --blkio-weight-device)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --blkio-weight-device ${_arg}"
          shift
        else
          die 'ERROR: "--blkio-weight-device" requires a non-empty option argument.'
        fi
        ;;
      --cap-add)
        opts="${opts} --cap-add"
        ;;
      --cap-drop)
        opts="${opts} --cap-drop"
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
      --cidfile)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cidfile ${_arg}"
          shift
        else
          die 'ERROR: "--cidfile" requires a non-empty option argument.'
        fi
        ;;
      --cpu-count)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-count ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-count" requires a non-empty option argument.'
        fi
        ;;
      --cpu-percent)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-percent ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-percent" requires a non-empty option argument.'
        fi
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
      --cpu-rt-period)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-rt-period ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-rt-period" requires a non-empty option argument.'
        fi
        ;;
      --cpu-rt-runtime)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpu-rt-runtime ${_arg}"
          shift
        else
          die 'ERROR: "--cpu-rt-runtime" requires a non-empty option argument.'
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
      --cpus)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --cpus ${_arg}"
          shift
        else
          die 'ERROR: "--cpus" requires a non-empty option argument.'
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
      --device)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --device ${_arg}"
          shift
        else
          die 'ERROR: "--device" requires a non-empty option argument.'
        fi
        ;;
      --device-cgroup-rule)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --device-cgroup-rule ${_arg}"
          shift
        else
          die 'ERROR: "--device-cgroup-rule" requires a non-empty option argument.'
        fi
        ;;
      --device-read-bps)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --device-read-bps ${_arg}"
          shift
        else
          die 'ERROR: "--device-read-bps" requires a non-empty option argument.'
        fi
        ;;
      --device-read-iops)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --device-read-iops ${_arg}"
          shift
        else
          die 'ERROR: "--device-read-iops" requires a non-empty option argument.'
        fi
        ;;
      --device-write-bps)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --device-write-bps ${_arg}"
          shift
        else
          die 'ERROR: "--device-write-bps" requires a non-empty option argument.'
        fi
        ;;
      --device-write-iops)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --device-write-iops ${_arg}"
          shift
        else
          die 'ERROR: "--device-write-iops" requires a non-empty option argument.'
        fi
        ;;
      --disable-content-trust)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --disable-content-trust ${_arg}"
          shift
        else
          die 'ERROR: "--disable-content-trust" requires a non-empty option argument.'
        fi
        ;;
      --dns)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --dns ${_arg}"
          shift
        else
          die 'ERROR: "--dns" requires a non-empty option argument.'
        fi
        ;;
      --dns-opt)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --dns-opt ${_arg}"
          shift
        else
          die 'ERROR: "--dns-opt" requires a non-empty option argument.'
        fi
        ;;
      --dns-option)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --dns-option ${_arg}"
          shift
        else
          die 'ERROR: "--dns-option" requires a non-empty option argument.'
        fi
        ;;
      --dns-search)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --dns-search ${_arg}"
          shift
        else
          die 'ERROR: "--dns-search" requires a non-empty option argument.'
        fi
        ;;
      --entrypoint)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --entrypoint ${_arg}"
          shift
        else
          die 'ERROR: "--entrypoint" requires a non-empty option argument.'
        fi
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
      --group-add)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --group-add ${_arg}"
          shift
        else
          die 'ERROR: "--group-add" requires a non-empty option argument.'
        fi
        ;;
      --health-cmd)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --health-cmd ${_arg}"
          shift
        else
          die 'ERROR: "--health-cmd" requires a non-empty option argument.'
        fi
        ;;
      --health-interval)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --health-interval ${_arg}"
          shift
        else
          die 'ERROR: "--health-interval" requires a non-empty option argument.'
        fi
        ;;
      --health-retries)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --health-retries ${_arg}"
          shift
        else
          die 'ERROR: "--health-retries" requires a non-empty option argument.'
        fi
        ;;
      --health-start-period)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --health-start-period ${_arg}"
          shift
        else
          die 'ERROR: "--health-start-period" requires a non-empty option argument.'
        fi
        ;;
      --health-timeout)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --health-timeout ${_arg}"
          shift
        else
          die 'ERROR: "--health-timeout" requires a non-empty option argument.'
        fi
        ;;
      --hostname|-h)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --hostname ${_arg}"
          shift
        else
          die 'ERROR: "--hostname" requires a non-empty option argument.'
        fi
        ;;
      --init)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --init ${_arg}"
          shift
        else
          die 'ERROR: "--init" requires a non-empty option argument.'
        fi
        ;;
      --interactive|-i)
        opts="${opts} --interactive"
        ;;
      --io-maxbandwidth)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --io-maxbandwidth ${_arg}"
          shift
        else
          die 'ERROR: "--io-maxbandwidth" requires a non-empty option argument.'
        fi
        ;;
      --io-maxiops)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --io-maxiops ${_arg}"
          shift
        else
          die 'ERROR: "--io-maxiops" requires a non-empty option argument.'
        fi
        ;;
      --ip)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --ip ${_arg}"
          shift
        else
          die 'ERROR: "--ip" requires a non-empty option argument.'
        fi
        ;;
      --ip6)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --ip6 ${_arg}"
          shift
        else
          die 'ERROR: "--ip6" requires a non-empty option argument.'
        fi
        ;;
      --ip6)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --ip6 ${_arg}"
          shift
        else
          die 'ERROR: "--ip6" requires a non-empty option argument.'
        fi
        ;;
      --ipc)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --ipc ${_arg}"
          shift
        else
          die 'ERROR: "--ipc" requires a non-empty option argument.'
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
      --kernel-memory)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --kernel-memory ${_arg}"
          shift
        else
          die 'ERROR: "--kernel-memory" requires a non-empty option argument.'
        fi
        ;;
      --label)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --label ${_arg}"
          shift
        else
          die 'ERROR: "--label" requires a non-empty option argument.'
        fi
        ;;
      --label-file)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --label-file ${_arg}"
          shift
        else
          die 'ERROR: "--label-file" requires a non-empty option argument.'
        fi
        ;;
      --link)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --link ${_arg}"
          shift
        else
          die 'ERROR: "--link" requires a non-empty option argument.'
        fi
        ;;
      --link-local-ip)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --link-local-ip ${_arg}"
          shift
        else
          die 'ERROR: "--link-local-ip" requires a non-empty option argument.'
        fi
        ;;
      --log-driver)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --log-driver ${_arg}"
          shift
        else
          die 'ERROR: "--log-driver" requires a non-empty option argument.'
        fi
        ;;
      --log-opt)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --log-opt ${_arg}"
          shift
        else
          die 'ERROR: "--log-opt" requires a non-empty option argument.'
        fi
        ;;
      --mac-address)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --mac-address ${_arg}"
          shift
        else
          die 'ERROR: "--mac-address" requires a non-empty option argument.'
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
      --memory-reservation)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --memory-reservation ${_arg}"
          shift
        else
          die 'ERROR: "--memory-reservation" requires a non-empty option argument.'
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
      --memory-swapiness)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --memory-swapiness ${_arg}"
          shift
        else
          die 'ERROR: "--memory-swapiness" requires a non-empty option argument.'
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
      --net)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --net ${_arg}"
          shift
        else
          die 'ERROR: "--net" requires a non-empty option argument.'
        fi
        ;;
      --net-alias)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --net-alias ${_arg}"
          shift
        else
          die 'ERROR: "--net-alias" requires a non-empty option argument.'
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
      --network-alias)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --network-alias ${_arg}"
          shift
        else
          die 'ERROR: "--network-alias" requires a non-empty option argument.'
        fi
        ;;
      --no-healthcheck)
        opts="${opts} --no-healthcheck"
        ;;
      --oom-kill-disable)
        opts="${opts} --oom-kill-disable"
        ;;
      --oom-score-adj)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --oom-score-adj ${_arg}"
          shift
        else
          die 'ERROR: "--oom-score-adj" requires a non-empty option argument.'
        fi
        ;;
      --pid)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --pid ${_arg}"
          shift
        else
          die 'ERROR: "--pid" requires a non-empty option argument.'
        fi
        ;;
      --pids-limit)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --pids-limit ${_arg}"
          shift
        else
          die 'ERROR: "--pids-limit" requires a non-empty option argument.'
        fi
        ;;
      --privileged)
        opts="${opts} --privileged"
        ;;
      --publish|-p)
        opts="${opts} --publish"
        ;;
      --publish-all)
        opts="${opts} --publish-all"
        ;;
      --read-only)
        opts="${opts} --read-only"
        ;;
      --restart)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --restart ${_arg}"
          shift
        else
          die 'ERROR: "--restart" requires a non-empty option argument.'
        fi
        ;;
      --rm)
        opts="${opts} --rm"
        ;;
      --runtime)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --runtime ${_arg}"
          shift
        else
          die 'ERROR: "--runtime" requires a non-empty option argument.'
        fi
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
      --stop-signal)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --stop-signal ${_arg}"
          shift
        else
          die 'ERROR: "--stop-signal" requires a non-empty option argument.'
        fi
        ;;
      --stop-timeout)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --stop-timeout ${_arg}"
          shift
        else
          die 'ERROR: "--stop-timeout" requires a non-empty option argument.'
        fi
        ;;
      --storage-opt)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --storage-opt ${_arg}"
          shift
        else
          die 'ERROR: "--storage-opt" requires a non-empty option argument.'
        fi
        ;;
      --sysctl)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --sysctl ${_arg}"
          shift
        else
          die 'ERROR: "--sysctl" requires a non-empty option argument.'
        fi
        ;;
      --tmpfs)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --tmpfs ${_arg}"
          shift
        else
          die 'ERROR: "--tmpfs" requires a non-empty option argument.'
        fi
        ;;
      # Prints a trace of simple commands, for commands, case commands, select
      # commands, and arithmetic for commands and their arguments or associated
      # word lists after they are expanded and before they are executed.
      --trace|-t)
        set -x
        ;;
      --tty|-t)
        opts="${opts} --tty"
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
      --user|-u)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --user ${_arg}"
          shift
        else
          die 'ERROR: "--user" requires a non-empty option argument.'
        fi
        ;;
      --userns)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --userns ${_arg}"
          shift
        else
          die 'ERROR: "--userns" requires a non-empty option argument.'
        fi
        ;;
      --uts)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --uts ${_arg}"
          shift
        else
          die 'ERROR: "--uts" requires a non-empty option argument.'
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
      --volume|-v)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --volume ${_arg}"
          shift
        else
          die 'ERROR: "--volume" requires a non-empty option argument.'
        fi
        ;;
      --volume-driver)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --volume-driver ${_arg}"
          shift
        else
          die 'ERROR: "--volume-driver" requires a non-empty option argument.'
        fi
        ;;
      --volumes-from)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --volumes-from ${_arg}"
          shift
        else
          die 'ERROR: "--volumes-from" requires a non-empty option argument.'
        fi
        ;;
      --workdir|-w)
        if [ "$2" ]; then
          local _arg="$2"
          opts="${opts} --workdir ${_arg}"
          shift
        else
          die 'ERROR: "--workdir" requires a non-empty option argument.'
        fi
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

  # All options should have been dealt with, leaving only the image and
  # commands.

  image="$1"
  shift
  cmd="$1"
  shift
  args="$*"

  # Trim trailing and leading whitespace.
  opts=$(trim ${opts})
  image=$(trim ${image})
  cmd=$(trim ${cmd})
  args=$(trim ${args})

}

validate () {
  local _image=$1
  local _cmd=$2
  if [[ -z "$_image" ]]; then
    die "ERROR: harbor create requires at least two arguments.\nSee 'harbor create --help'\n"
  elif [[ -z "$_cmd" ]]; then
    die "ERROR: harbor create requires at least two arguments.\nSee 'harbor create --help'\n"
  fi
}

# Execute script.
main "$@"

exit 0
