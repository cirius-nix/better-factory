#!/bin/sh
# Copy-mode layer (spec-copymode).
# Compares each managed file with its source. Proves that an existing seed
# file keeps its bytes and its modification time after a second copy step.
# Usage: layer-copymode.sh <manifest> <work-dir> <copy-step>
# Prints nothing on success; prints "<layer>: red: <path>: <reason>" on failure.
set -eu
manifest=${1:?manifest file}
work=${2:?work directory}
copy_step=${3:?copy-step script}
TAB=$(printf '\t')
fail() { echo "copy-mode: red: $1: $2"; exit 1; }
while IFS="$TAB" read -r mode rel src || [ -n "${mode:-}" ]; do
  case "${mode:-}" in ""|\#*) continue ;; esac
  if [ "$mode" = "managed" ]; then
    [ -e "$work/$rel" ] || fail "$rel" "missing after copy step"
    cmp -s "$src" "$work/$rel" || fail "$rel" "differs from source"
  fi
done < "$manifest"
while IFS="$TAB" read -r mode rel src || [ -n "${mode:-}" ]; do
  case "${mode:-}" in ""|\#*) continue ;; esac
  if [ "$mode" = "seed" ]; then
    f="$work/$rel"
    printf '# author edit\n' >> "$f"
    edited_sum=$(sha256sum "$f" | cut -d' ' -f1)
    edited_mtime=$(stat -c %Y "$f")
    "$copy_step" "$manifest" "$work"
    kept_sum=$(sha256sum "$f" | cut -d' ' -f1)
    kept_mtime=$(stat -c %Y "$f")
    [ "$edited_sum" = "$kept_sum" ] || fail "$rel" "seed bytes changed by copy step"
    [ "$edited_mtime" = "$kept_mtime" ] || fail "$rel" "seed modification time changed by copy step"
  fi
done < "$manifest"
