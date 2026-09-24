#!/bin/sh
# Adopt step (spec-copymode).
# Applies the copy step to the author tree: copies each planned file into
# the consumer repository as its copy mode says.
# Usage: adopt.sh <manifest> <root> [--dry-run]
# The flag is accepted in any argument position. A dry run prints the action
# of each planned path and writes nothing; a real run prints the actions and
# writes the files. The step never deletes a path outside the plan and never
# writes below .git/ or .devenv/. Unknown modes fail in the copy step.
set -eu
dry_run=0
manifest=""
root=""
for arg in "$@"; do
  if [ "$arg" = "--dry-run" ]; then
    dry_run=1
  elif [ -z "$manifest" ]; then
    manifest=$arg
  elif [ -z "$root" ]; then
    root=$arg
  else
    echo "adopt: red: args: too many arguments" >&2
    exit 1
  fi
done
if [ -z "$manifest" ]; then
  echo "adopt: red: manifest: missing argument" >&2
  exit 1
fi
if [ -z "$root" ]; then
  echo "adopt: red: root: missing argument" >&2
  exit 1
fi
script_dir=$(dirname "$0")
copy_step="$script_dir/copy-step.sh"
work=$(mktemp -d)
filtered="$work/manifest"
trap 'rm -rf "$work"' EXIT INT TERM
TAB=$(printf '\t')
: > "$filtered"
while IFS="$TAB" read -r mode rel src || [ -n "${mode:-}" ]; do
  case "${mode:-}" in ""|\#*) continue ;; esac
  case "$rel" in
    .git|.git/*|.devenv|.devenv/*) continue ;;
  esac
  case "$rel" in
    /*)
      echo "adopt: red: $rel: absolute path" >&2
      exit 1
      ;;
  esac
  case "/$rel/" in
    *"/../"*)
      echo "adopt: red: $rel: path holds .. component" >&2
      exit 1
      ;;
  esac
  printf '%s\t%s\t%s\n' "$mode" "$rel" "$src" >> "$filtered"
done < "$manifest"
dry_out="$work/dry.out"
sh "$copy_step" "$filtered" "$root" --dry-run > "$dry_out"
sed 's/^copy-step: /adopt: /' "$dry_out"
if [ "$dry_run" = 0 ]; then
  sh "$copy_step" "$filtered" "$root"
fi
