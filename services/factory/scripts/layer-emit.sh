#!/bin/sh
# Emit layer (spec-copymode).
# Each planned path exists. No emitted file is empty. Each template file is
# byte-equal to its source. The copy-mode layer owns managed and seed files;
# this layer owns template files and planned paths. The subsets are disjoint.
# Usage: layer-emit.sh <manifest> <work-dir>
# Prints nothing on success; prints "<layer>: red: <path>: <reason>" on failure.
set -eu
manifest=${1:?manifest file}
work=${2:?work directory}
TAB=$(printf '\t')
fail() { echo "emit: red: $1: $2"; exit 1; }
while IFS="$TAB" read -r mode rel src || [ -n "${mode:-}" ]; do
  case "${mode:-}" in ""|\#*) continue ;; esac
  [ -e "$work/$rel" ] || fail "$rel" "missing after copy step"
  [ -s "$work/$rel" ] || fail "$rel" "empty after copy step"
  if [ "$mode" = "template" ]; then
    cmp -s "$src" "$work/$rel" || fail "$rel" "differs from source"
  fi
done < "$manifest"
