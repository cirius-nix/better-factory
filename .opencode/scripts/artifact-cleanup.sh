#!/bin/sh
# artifact-cleanup.sh
# Deterministic cleanup plan of the version folders and the change folders of
# one feature (spec-artifact-cleanup). The script reads the feature README and
# the two folder kinds, prints the plan as the default form, and deletes the
# plan paths only under the apply form.
#
# The plan form is read-only. The apply form runs the six safety checks on
# each delete path, then deletes the delete-list paths. The script asks no
# question and reads no standard input. The script changes no line of the
# feature README; it reports the README edit in the plan.
#
# Usage:
#   sh artifact-cleanup.sh [--apply] [versions|changes] <feature>
#
# A run with no subcommand covers both kinds and reports the kind `all`.
#
# Plan shape (one line per part):
#   feature: <feature>
#   kind: <versions|changes|all>
#   delete: <path>
#   keep: <path>
#   readme-edit: <## Versions table row>
#
# The delete list and the keep list are in ascending path order. The README
# edit names the table row of each deleted version and of each version whose
# change folder is deleted.
#
# Exit codes: 0 an empty delete list, 1 a non-empty delete list, 2 an input
# error or a failed safety check. The plan form and the apply form give the
# same code for the same feature state.
#
# The declared tool set is POSIX sh, awk, sed, grep, sort, and find. The script
# uses no jq and no yq.
set -eu
LC_ALL=C
export LC_ALL

TAB=$(printf '\t')
ROOT_PHYS=$(pwd -P)

err() {
  printf 'artifact-cleanup: error: %s\n' "$1" >&2
  exit 2
}

# Print the non-blank lines of one newline list.
nonblank() {
  printf '%s\n' "$1" | awk 'NF>0'
}

has_lines() {
  [ -n "$(nonblank "$1")" ]
}

# Print the child folder names of one directory, in ascending order. An absent
# directory is the empty list. A hidden folder is out of the artifact tree.
list_dirs() {
  list_dir=$1
  [ -d "$list_dir" ] || return 0
  for list_entry in "$list_dir"/*/; do
    [ -d "$list_entry" ] || continue
    list_name=${list_entry%/}
    list_name=${list_name##*/}
    printf '%s\n' "$list_name"
  done | sort
}

count_lines() {
  nonblank "$1" | awk 'END { print NR+0 }'
}

# The version regex. Each part is a decimal number without a leading zero.
VERSION_RE='^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$'

# Order the version folder names on the standard input, newest first
# (spec-artifact-cleanup, the version sort key): the number triple in
# descending order, the tie break the folder name in ascending order.
order_versions() {
  awk -F. '{ printf "%d %d %d %s\n", $1, $2, $3, $0 }' \
    | sort -k1,1nr -k2,2nr -k3,3nr -k4,4 \
    | awk '{ print $4 }'
}

# Order the change folder names on the standard input, newest first
# (spec-artifact-cleanup, the change order key): the row index of the change in
# the `## Versions` table of the feature README, in descending order. A change
# folder with no row is newer than each row. The tie break is the folder name
# in ascending order.
order_changes() {
  order_readme=$1
  awk -v readme="$order_readme" '
    BEGIN {
      nrows = 0
      while ((getline line < readme) > 0) {
        if (line ~ /^\| *[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* *\|/) {
          nrows++
          if (match(line, /changes\/change-[^\/]*\/README\.md/)) {
            folder = substr(line, RSTART, RLENGTH)
            sub(/^changes\//, "", folder)
            sub(/\/README\.md$/, "", folder)
            idx[folder] = nrows
          }
        }
      }
      close(readme)
    }
    NF > 0 {
      key = ($0 in idx) ? idx[$0] : nrows + 1
      printf "%d %s\n", key, $0
    }
  ' | sort -k1,1nr -k2,2 | awk '{ print $2 }'
}

# Print the `## Versions` table row of each deleted version and of each version
# whose change folder is deleted, in ascending version order, once (the README
# edit of the plan).
readme_rows() {
  rows_readme=$1
  rows_versions=$2
  rows_changes=$3
  awk -v readme="$rows_readme" -v versions="$rows_versions" -v changes="$rows_changes" '
    BEGIN {
      nv = split(versions, va, "\n")
      nc = split(changes, ca, "\n")
      for (i = 1; i <= nv; i++) if (va[i] != "") wantv[va[i]] = 1
      for (i = 1; i <= nc; i++) if (ca[i] != "") wantc[ca[i]] = 1
      while ((getline line < readme) > 0) {
        if (line !~ /^\| *[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* *\|/) continue
        ver = line
        sub(/^\| */, "", ver)
        sub(/ *\|.*$/, "", ver)
        folder = ""
        if (match(line, /changes\/change-[^\/]*\/README\.md/)) {
          folder = substr(line, RSTART, RLENGTH)
          sub(/^changes\//, "", folder)
          sub(/\/README\.md$/, "", folder)
        }
        if ((ver in wantv) || (folder != "" && folder in wantc)) {
          split(ver, vp, ".")
          printf "%06d.%06d.%06d\t%s\n", vp[1], vp[2], vp[3], line
        }
      }
      close(readme)
    }
  ' | sort -t"$TAB" -k1,1 | awk -F"$TAB" -v OFS="$TAB" '{ $1=""; sub(/^\t/, ""); print }' \
    | awk 'NF>0 && !seen[$0]++'
}

# Prefix each folder name of one newline list with one directory path.
prefix_paths() {
  prefix_dir=$1
  nonblank "$2" | while IFS= read -r prefix_name; do
    printf '%s/%s\n' "$prefix_dir" "$prefix_name"
  done
}

# ---------------------------------------------------------------------------
# The arguments (spec-artifact-cleanup interface 5). `--apply` selects the
# apply form. `versions` or `changes` selects the kind. The remaining
# positional argument is the feature name.
# ---------------------------------------------------------------------------
apply=0
kind=""
feature=""
for arg in "$@"; do
  case "$arg" in
    --apply)
      apply=1
      ;;
    versions | changes)
      [ -z "$kind" ] || err "two subcommands are given"
      kind=$arg
      ;;
    -*)
      err "unknown option $arg"
      ;;
    *)
      [ -z "$feature" ] || err "more than one feature name is given"
      feature=$arg
      ;;
  esac
done

[ -n "$feature" ] || err "a feature name is required"

feature_dir="docs/artifact/$feature"
[ -d "$feature_dir" ] || err "the feature folder $feature_dir is absent"
readme="$feature_dir/README.md"
versions_dir="$feature_dir/versions"
changes_dir="$feature_dir/changes"

do_versions=0
do_changes=0
case "$kind" in
  "" | versions)
    do_versions=1
    ;;
esac
case "$kind" in
  "" | changes)
    do_changes=1
    ;;
esac

case "$kind" in
  "") plan_kind=all ;;
  *) plan_kind=$kind ;;
esac

versions_list=$(list_dirs "$versions_dir")
changes_list=$(list_dirs "$changes_dir")
versions_count=$(count_lines "$versions_list")
changes_count=$(count_lines "$changes_list")

# ---------------------------------------------------------------------------
# The no-op rule (spec-artifact-cleanup keep window 4 and 5, FAC-03-04). A kind
# with three or fewer folders holds an empty delete list and reads no feature
# README for the kind. The input errors apply only to a kind with more than
# three folders, so the starter feature `feat-example` is a no-op.
# ---------------------------------------------------------------------------
want_versions=0
want_changes=0
if [ "$do_versions" -eq 1 ] && [ "$versions_count" -gt 3 ]; then
  want_versions=1
fi
if [ "$do_changes" -eq 1 ] && [ "$changes_count" -gt 3 ]; then
  want_changes=1
fi

current=""
if [ "$want_versions" -eq 1 ] || [ "$want_changes" -eq 1 ]; then
  [ -f "$readme" ] || err "the feature README $readme is absent"
fi

if [ "$want_versions" -eq 1 ]; then
  current=$(sed -n 's/^\*\*Current version:\*\*[[:space:]]*//p' "$readme" | head -n 1)
  [ -n "$current" ] || err "the feature README $readme holds no current-version line"
fi

if [ "$want_changes" -eq 1 ]; then
  if ! grep -q '^| *[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]* *|' "$readme"; then
    err "the feature README $readme holds no ## Versions table"
  fi
fi

# The folder name shape (spec-artifact-cleanup errors). Only a kind with more
# than three folders reads the names.
if [ "$want_versions" -eq 1 ]; then
  bad=$(nonblank "$versions_list" | grep -Ev "$VERSION_RE" || true)
  [ -z "$bad" ] || err "a version folder name is outside <major>.<minor>.<patch>: $(printf '%s' "$bad" | head -n 1)"
fi
if [ "$want_changes" -eq 1 ]; then
  bad=$(nonblank "$changes_list" | grep -Ev '^change-' || true)
  [ -z "$bad" ] || err "a change folder name does not start with change-: $(printf '%s' "$bad" | head -n 1)"
fi

# ---------------------------------------------------------------------------
# The keep window (spec-artifact-cleanup invariant 1 and 2). The first three
# folders of the ordered list are the keep list. The remaining folders are the
# delete list. A kind with three or fewer folders keeps each folder.
# ---------------------------------------------------------------------------
versions_keep=""
versions_delete=""
if [ "$do_versions" -eq 1 ]; then
  if [ "$want_versions" -eq 1 ]; then
    versions_ordered=$(nonblank "$versions_list" | order_versions)
    versions_keep=$(nonblank "$versions_ordered" | head -n 3)
    versions_delete=$(nonblank "$versions_ordered" | tail -n +4)
  else
    versions_keep=$versions_list
  fi
fi

changes_keep=""
changes_delete=""
if [ "$do_changes" -eq 1 ]; then
  if [ "$want_changes" -eq 1 ]; then
    changes_ordered=$(nonblank "$changes_list" | order_changes "$readme")
    changes_keep=$(nonblank "$changes_ordered" | head -n 3)
    changes_delete=$(nonblank "$changes_ordered" | tail -n +4)
  else
    changes_keep=$changes_list
  fi
fi

delete_paths=$( { prefix_paths "$versions_dir" "$versions_delete"; prefix_paths "$changes_dir" "$changes_delete"; } | sort)
keep_paths=$( { prefix_paths "$versions_dir" "$versions_keep"; prefix_paths "$changes_dir" "$changes_keep"; } | sort)

readme_edit=""
if [ "$want_versions" -eq 1 ] || [ "$want_changes" -eq 1 ]; then
  readme_edit=$(readme_rows "$readme" "$versions_delete" "$changes_delete")
fi

# ---------------------------------------------------------------------------
# The plan (spec-artifact-cleanup interface 3 and 4, C-FAC-01-02).
# ---------------------------------------------------------------------------
printf 'feature: %s\n' "$feature"
printf 'kind: %s\n' "$plan_kind"
nonblank "$delete_paths" | sed 's/^/delete: /'
nonblank "$keep_paths" | sed 's/^/keep: /'
nonblank "$readme_edit" | sed 's/^/readme-edit: /'

# ---------------------------------------------------------------------------
# The safety boundary check (spec-artifact-cleanup "The safety boundary
# check", C-FAC-01-03). Each delete path passes the six checks before the
# delete. A failed check stops the cleanup with the exit code 2 and deletes no
# path.
# ---------------------------------------------------------------------------
safety_check() {
  check_path=$1

  # 1. The path is a folder, not a file.
  [ -d "$check_path" ] || err "the delete path $check_path is not a folder"

  # 2. The path is below the feature kind folder.
  case "$check_path" in
    "$versions_dir"/* | "$changes_dir"/*) ;;
    *) err "the delete path $check_path is outside the feature kind folders" ;;
  esac

  # 3. The path resolves below the project root. The check rejects a relative
  #    step and a symbolic link that escapes the feature folder.
  check_phys=$(CDPATH= cd -- "$check_path" 2>/dev/null && pwd -P) \
    || err "the delete path $check_path does not resolve to a folder"
  case "$check_phys" in
    "$ROOT_PHYS/$versions_dir"/* | "$ROOT_PHYS/$changes_dir"/*) ;;
    *) err "the delete path $check_path resolves outside the feature kind folders" ;;
  esac

  # 4. The path name shape. A version folder name is
  #    `<major>.<minor>.<patch>`. A change folder name starts with `change-`.
  case "$check_path" in
    "$versions_dir"/*)
      check_name=${check_path#"$versions_dir"/}
      case "$check_name" in
        */*) err "the delete path $check_path is below a version folder" ;;
      esac
      printf '%s\n' "$check_name" | grep -Eq "$VERSION_RE" \
        || err "the version folder name $check_name is outside <major>.<minor>.<patch>"
      ;;
    "$changes_dir"/*)
      check_name=${check_path#"$changes_dir"/}
      case "$check_name" in
        */*) err "the delete path $check_path is below a change folder" ;;
      esac
      case "$check_name" in
        change-*) ;;
        *) err "the change folder name $check_name does not start with change-" ;;
      esac
      ;;
  esac

  # 5. The path is in the delete list of the plan.
  nonblank "$delete_paths" | grep -Fxq "$check_path" \
    || err "the delete path $check_path is not in the delete list"

  # 6. The path is not the current version folder.
  if [ -n "$current" ] && [ "$check_path" = "$versions_dir/$current" ]; then
    err "the delete path $check_path is the current version folder"
  fi
}

if [ "$apply" -eq 1 ]; then
  while IFS= read -r delete_path; do
    [ -n "$delete_path" ] || continue
    safety_check "$delete_path"
  done <<DELETE_PATHS_EOF
$(nonblank "$delete_paths")
DELETE_PATHS_EOF

  while IFS= read -r delete_path; do
    [ -n "$delete_path" ] || continue
    rm -rf "$delete_path"
  done <<DELETE_PATHS_EOF
$(nonblank "$delete_paths")
DELETE_PATHS_EOF
fi

if has_lines "$delete_paths"; then
  exit 1
fi
exit 0
