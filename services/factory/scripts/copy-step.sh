#!/bin/sh
# Imperative check-then-write wrapper (spec-copymode).
# Runs in the author tree, outside the Nix store.
# Usage: copy-step.sh <manifest> <dest-dir> [--dry-run]
# Manifest lines: <mode><TAB><repo-relative-path><TAB><source-path>
# With --dry-run print one action line per planned path and write nothing:
# copy-step: <action> <path>, where action is create, keep, or replace.
# Without the flag write the files and print no action line.
set -eu
manifest=${1:?manifest file}
dest=${2:?destination directory}
dry_run=0
if [ "${3:-}" = "--dry-run" ]; then dry_run=1; fi
TAB=$(printf '\t')
while IFS="$TAB" read -r mode rel src || [ -n "${mode:-}" ]; do
  case "${mode:-}" in ""|\#*) continue ;; esac
  case "$mode" in
    seed|managed|template) ;;
    *) echo "copy-step: red: $rel: unknown mode \`$mode\`" >&2; exit 1 ;;
  esac
  target="$dest/$rel"
  if [ "$dry_run" = 1 ]; then
    if [ ! -e "$target" ]; then
      echo "copy-step: create $rel"
    elif [ "$mode" = "seed" ]; then
      echo "copy-step: keep $rel"
    else
      echo "copy-step: replace $rel"
    fi
  elif [ ! -e "$target" ]; then
    mkdir -p "$(dirname "$target")"
    cp "$src" "$target"
    chmod u+w "$target"
  else
    case "$mode" in
      seed) ;;
      managed|template) cp -f "$src" "$target" && chmod u+w "$target" ;;
    esac
  fi
done < "$manifest"
