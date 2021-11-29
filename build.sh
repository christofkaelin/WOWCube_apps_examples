#!/usr/bin/env bash
#
# This script builds cubelets, packages rootfs and can be used in SDK Firmware mode.
#
# Usage: ./build.sh [CUBELETS_LIST...]
#   CUBELETS_LIST  Space separated enumeration of cubelet names to be build.
#                  Empty argument and variable will build all available cubelets.
#
# Examples:
#   ./build.sh             # Build all
#   ./build.sh Menu Pipes  # Build Menu and Pipes
#
# Overridable variables:
# - `CUBELETS_LIST` (default: empty)
#    Comma separated enumeration of cubelet names to be build.
# - `DO_BUILD_CUBELETS` (type: boolean, default: `1`)
# - `DO_PACK_ROOTFS` (type: boolean, default: `1`)
#    Pack cubelets into `./Resources_prj/flash/rootfs.img`.
#
# - `PYTHON` (default: `pypy3`/`python3`/`python`)
#    Tries to search for Python in PATH.
# - `MAKE` (default: `make`)
#    Tries to search for Make build system in PATH. May be found in `./bin/<os>` directory.
# - `FF` (default: `ff`)
#    Tries to search for FatFs tool in PATH. May be found in `./bin/<os>` directory.
#
# Outputs variables:
# - `FLASH_DIR` (default: `./Resources_prj/flash`)
#   Path to Flash directory required by SDK Firmware mode.
#
ROOT_DIR=$( (cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P) )
SCRIPT_VERSION="1.0"

# check if stdout is a terminal
if test -t 1; then
  # see if it supports colors
  ncolors=$(tput colors 2>/dev/null)
  # shellcheck disable=SC2034
  if [[ -n $ncolors && $ncolors -ge 8 ]]; then
    tty_bold="$(tput bold)"
    tty_underline="$(tput smul)"
    tty_standout="$(tput smso)"
    tty_reset="$(tput sgr0)"
    tty_black="$(tput setaf 0)"
    tty_red="$(tput setaf 1)"
    tty_green="$(tput setaf 2)"
    tty_yellow="$(tput setaf 3)"
    tty_blue="$(tput setaf 4)"
    tty_magenta="$(tput setaf 5)"
    tty_cyan="$(tput setaf 6)"
    tty_white="$(tput setaf 7)"
  fi
fi

function backtrace() {
  local strip="${1:-'1'}"
  echo "Backtrace ($((${#FUNCNAME[@]}-strip))):";
  for ((i="$((${#FUNCNAME[@]}-1))"; i>="${strip}"; i--)); do
    echo "  ${BASH_SOURCE[$i]}:${BASH_LINENO[$i-1]} ${FUNCNAME[$i]}";
  done
}

function error() {
  local return_code=$?
  local message="$*"
  local version=$'\n'"Script version: $SCRIPT_VERSION"
  local trace
  message=${message:-"no message"}
  [[ $return_code != 0 ]] && trace=$'\n'"$(backtrace 2) [return code ${return_code}]"
  echo "${tty_red}Error: ${message}${version}${trace}${tty_reset}"
  exit 1
}

function ohai() {
  echo "${tty_blue}==>${tty_bold} $*${tty_reset}"
}

function get_os() {
  local unameOut
  unameOut="$(uname -s 2>/dev/null)"
  case "${unameOut}" in
    Linux*) echo -n "linux"; return 0 ;;
    Darwin*) echo -n "macos"; return 0 ;;
    CYGWIN*|MINGW32*|MSYS*|MINGW*) echo -n "windows"; return 0 ;;
    *) echo -n "${unameOut}"; return 1 ;;
  esac
}

function find_python() {
  function _test() {
    local python
    python=$(command -v "$1")
    # Windows (and macOS) returns path to python installer, so test and check result code instead
    if "$python" -V &>/dev/null; then printf "%s" "$python"; return 0; fi
    return 1
  }

  # Pillow on PyPy on Windows is not working
  [[ $(get_os) != windows ]] && _test pypy3 && return 0
  _test python3 && return 0
  _test python && return 0
  return 1
}

function build_scripts() {
  ohai "Building scripts"
  command -v "${MAKE}" &>/dev/null || error "MAKE not found"
  (
    cd "$ROOT_DIR/pawn" || error
    "$MAKE" -j "$NUMBER_OF_PROCESSORS" || error "cannot build amx files"
  ) || exit $?
}

function build_cubelets() {
  ohai "Building cubelets"
  local CUBELETS_LIST=("$@")
  command -v "${PYTHON}" &>/dev/null || error "PYTHON not found"
  (
    cd "$ROOT_DIR/Resources_prj" || error
    [[ ${#CUBELETS_LIST[@]} != 0 ]] && set -- "-i" "${CUBELETS_LIST[@]}"
    "$PYTHON" build_cubios_apps.py "$@" || error "Cannot build cubelets"
  ) || exit $?

  local GAMES_COUNT
  GAMES_COUNT="$(find "$FLASH_DIR/0/games" -type f -name "*.cub" | wc -l | xargs)"
  [[ -z $GAMES_COUNT || $GAMES_COUNT == 0 ]] && error "Could not find any built cubelet (GAMES_COUNT=$GAMES_COUNT)"
  [[ ${#CUBELETS_LIST[@]} != 0 && "$GAMES_COUNT" != "${#CUBELETS_LIST[@]}" ]] && error "Some requested cubelets are not built (requested ${#CUBELETS_LIST[@]}, found $GAMES_COUNT)"
}

function pack_rootfs() {
  ohai "Packing cubios_rootfs.img"
  command -v "${PYTHON}" &>/dev/null || error "PYTHON not found"
  command -v "${FF}" &>/dev/null || error "FF not found"
  (
    cd "$FLASH_DIR/0" || error

    "$FF" a ../cubios_rootfs.img games || error "Cannot add games folder to cubios_rootfs.img"

    ohai "cubios_rootfs.img content"
    "$FF" l ../cubios_rootfs.img || error "Cannot list files in cubios_rootfs.img"

    cd "$FLASH_DIR" || error
    ohai "Converting cubios_rootfs.img to rootfs.img"
    "$PYTHON" "$ROOT_DIR/Resources_prj/convert.py" \
        -s "cubios_rootfs.img" \
        -d "rootfs.img" \
        || error "Cannot convert cubios_rootfs.img to rootfs.img"
  ) || exit $?

}

function export_sdk() {
  local name=$1
  local value
  eval value='$'"$name"
  echo "export $name=$value"
}

######################################################################
# Entry point
######################################################################
if get_os &>/dev/null; then
  PATH="${PATH}:$ROOT_DIR/bin/$(get_os)"
else
  echo "Unsupported os: $(get_os)"
  exit 1
fi
###################################
PYTHON="${PYTHON:-"$(find_python)"}"
MAKE="${MAKE:-"$(command -v make)"}"
FF="${FF:-"$(command -v ff)"}"
echo "Found Python: '$PYTHON'"
echo "Found make: '$MAKE'"
echo "Found ff: '$FF'"

if [[ ${#@} == 0 ]]; then
  IFS=','; CUBELETS_LIST=($CUBELETS_LIST); unset IFS
else
  CUBELETS_LIST=("$@")
fi
DO_BUILD_CUBELETS="${DO_BUILD_CUBELETS:-"1"}"
DO_PACK_ROOTFS="${DO_PACK_ROOTFS:-"1"}"
###################################

NUMBER_OF_PROCESSORS="$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)"
FLASH_DIR="$ROOT_DIR/Resources_prj/flash"
export_sdk FLASH_DIR


if [[ $DO_BUILD_CUBELETS == 1 ]]; then
  # Remove cubelets because they will be rebuilt anyway
  rm -f "$ROOT_DIR"/Resources_prj/flash/0/games/*.cub || error
  # Remove rootfs.img because old (not requested cubelets) will be added
  rm -f "$ROOT_DIR"/Resources_prj/flash/*.img || error

  build_scripts
  build_cubelets "${CUBELETS_LIST[@]}"
fi

if [[ $DO_PACK_ROOTFS == 1 ]]; then
  pack_rootfs
fi

# Print useful info
if [[ $DO_PACK_ROOTFS == 1 || "${#CUBELETS_LIST[@]}" != 0 ]]; then
  flashBurn="$ROOT_DIR/Resources_prj/flashBurn.py"
  [[ "${#CUBELETS_LIST[@]}" == 1 ]] \
      && flashTarget="$ROOT_DIR/Resources_prj/flash/0/games/${CUBELETS_LIST[0]}.cub" \
      || flashTarget="$ROOT_DIR/Resources_prj/flash/rootfs.img"
  printf "\nFlash %s:\n" "${flashTarget##*/}"
  if command -v wslpath &>/dev/null; then
    printf "Using Windows:\n"
    printf 'python "%s" "%s" -c COM0\n\n' \
        "$(wslpath -m "$flashBurn")" \
        "$(wslpath -m "$flashTarget")"
  else
    printf "'${PYTHON:-python}' '%s' '%s' -c /dev/ttyACM0\n\n" \
        "$flashBurn" "$flashTarget"
  fi
fi

