#!/bin/sh
# Layout layer (spec-layout).
# The emitted docs/artifact tree holds the starter feature feat-example and
# the first change change-initial. Names use lowercase letters, digits, and
# hyphens. The change README fields give a version number that follows the
# change type. The pinned markdownlint with .markdownlint.yaml finds no error
# in the emitted markdown.
# Usage: layer-layout.sh <work-dir> <lint-bin> <lint-config>
# Prints nothing on success; prints "<layer>: red: <path>: <reason>" on failure.
set -eu
work=${1:?work directory}
lint_bin=${2:?markdownlint binary}
lint_config=${3:?markdownlint config}
fail() { echo "layout: red: $1: $2"; exit 1; }
change="docs/artifact/feat-example/changes/change-initial/README.md"
[ -f "$work/docs/artifact/README.md" ] || fail "docs/artifact/README.md" "missing starter index"
[ -f "$work/docs/artifact/feat-example/README.md" ] || fail "docs/artifact/feat-example/README.md" "missing starter feature"
[ -f "$work/$change" ] || fail "$change" "missing starter change"
case "feat-example" in *[!a-z0-9-]*|"") fail "docs/artifact/feat-example" "name outside lowercase letters, digits, hyphens" ;; esac
case "change-initial" in *[!a-z0-9-]*|"") fail "$change" "name outside lowercase letters, digits, hyphens" ;; esac
[ ! -e "$work/docs/artifact/requirements" ] || fail "docs/artifact/requirements" "feature holds a root requirements folder";
[ ! -e "$work/docs/artifact/specifications" ] || fail "docs/artifact/specifications" "feature holds a root specifications folder";
[ ! -e "$work/docs/artifact/decisions" ] || fail "docs/artifact/decisions" "feature holds a root decisions folder";
[ ! -e "$work/docs/artifact/tasks" ] || fail "docs/artifact/tasks" "feature holds a root tasks folder";
from=$(grep '^\*\*From:\*\*' "$work/$change" | sed 's/^\*\*From:\*\* *//') || fail "$change" "missing From field"
to=$(grep '^\*\*To:\*\*' "$work/$change" | sed 's/^\*\*To:\*\* *//') || fail "$change" "missing To field"
rawtype=$(grep '^\*\*Type:\*\*' "$work/$change" | sed 's/^\*\*Type:\*\* *//') || fail "$change" "missing Type field"
first=$(printf '%s' "$rawtype" | cut -d, -f1 | tr -d ' ')
grep -q '^## Code paths' "$work/$change" || fail "$change" "missing Code paths section"
version=$(grep '^\*\*Version:\*\*' "$work/docs/artifact/feat-example/README.md" | sed 's/^\*\*Version:\*\* *//') || fail "docs/artifact/feat-example/README.md" "missing Version field"
case "$from" in
  none)
    [ "$first" = "Requirements" ] || fail "$change" "first change has type $first, want Requirements"
    expected="1.0.0"
    ;;
  *)
    major=${from%%.*}; rest=${from#*.}; minor=${rest%%.*}; patch=${rest##*.}
    case "$major$minor$patch" in *[!0-9]*) fail "$change" "From value $from is not a version" ;; esac
    case "$first" in
      Requirements) expected="$((major + 1)).0.0" ;;
      Specifications|Decisions) expected="$major.$((minor + 1)).0" ;;
      Correction) expected="$major.$minor.$((patch + 1))" ;;
      *) fail "$change" "unknown type $first" ;;
    esac
    ;;
esac
[ "$to" = "$expected" ] || fail "$change" "To value $to, want $expected"
[ "$version" = "$to" ] || fail "docs/artifact/feat-example/README.md" "Version value $version, want $to"
lint_out=$(cd "$work" && "$lint_bin" --config "$lint_config" $(find . -name '*.md' | sort) 2>&1) || {
  first=$(printf '%s\n' "$lint_out" | head -n 1)
  file=${first%%:*}
  file=${file#./}
  fail "$file" "markdownlint error: $first"
}
[ -z "$lint_out" ] || fail "docs/artifact/README.md" "markdownlint wrote unexpected output"
