#!/bin/sh
# Imperative check-then-write wrapper (spec-copymode).
# Runs in the author tree, outside the Nix store.
# Usage: copy-step.sh <manifest> <dest-dir>
# Manifest lines: <mode><TAB><repo-relative-path><TAB><source-path>
set -eu
manifest=${1:?manifest file}
dest=${2:?destination directory}
TAB=$(printf '\t')
while IFS="$TAB" read -r mode rel src || [ -n "${mode:-}" ]; do
  case "${mode:-}" in ""|\#*) continue ;; esac
  target="$dest/$rel"
  if [ ! -e "$target" ]; then
    mkdir -p "$(dirname "$target")"
    cp "$src" "$target"
    chmod u+w "$target"
  else
    case "$mode" in
      seed) ;;
      managed|template) cp -f "$src" "$target" && chmod u+w "$target" ;;
      *) echo "copy-step: red: $rel: unknown mode \`$mode\`" >&2; exit 1 ;;
    esac
  fi
done < "$manifest"
