#!/usr/bin/env bash
function check() { rc=$?; LINE=$1; MSG=$2; [[ $rc != 0 ]] && echo "${BASH_SOURCE[0]}:${LINE} exited with return code ${rc}. ${MSG}" && exit 1; }
ROOT_DIR=$(readlink -f "$(dirname "${BASH_SOURCE[0]}")")

if [[ $(command -v python3) ]]; then
  PYTHON=python3
elif [[ $(command -v python) ]]; then
  PYTHON=python
elif [[ $(command -v python2) ]]; then
  PYTHON=python2
  echo
else
  echo "Cannot find Python in your PATH environment"
  exit 1
fi

# Build Pawn scripts
#"$ROOT_DIR"/pawn/build.sh || check $LINENO  # Do not rebuild unchanged files
cd "$ROOT_DIR"/pawn || check $LINENO
PATH="$(pwd):${PATH}" make -j "$(nproc)" || check $LINENO

# Remove old cublets (because they will be rebuilt anyway, and old not listed cublets will be added to rootfs further)
rm -rf "$ROOT_DIR/Resources_prj/build_output" || check $LINENO
rm -f "$ROOT_DIR/Resources_prj/build_output/*.cub" || check $LINENO
rm -f "$ROOT_DIR/Resources_prj/build_output/*.img" || check $LINENO

# Build cublets in build_output
cd "$ROOT_DIR/Resources_prj" || check $LINENO
"$PYTHON" build_cubios_apps.py || check $LINENO

echo
echo "No errors"
