#!/bin/sh
# artifact-cleanup-proof.sh
# The scratch-copy proof of the artifact cleanup script (task-cleanup-proof,
# spec-artifact-cleanup, spec-cleanup-bundle). This file is a factory test
# runner. It is not shipped. It is not a capability.
#
# The runner copies the feature folders into a scratch project root, builds the
# version 7.0.0 target of `feat-orchestration`, runs the plan form and the apply
# form, and compares each result with the expected plan. The runner proves the
# keep window, the determinism, the no-op fixtures, the apply form, the feature
# README rule, the safety boundary, and the input errors.
#
# The cleanup deletes paths, so `nix flake check` stays free of side effects and
# this proof is a separate shell run. The runner writes only below the scratch
# directory `${TMPDIR:-/tmp}/artifact-cleanup-proof.XXXXXX`. The repository
# `docs/artifact/` tree stays unchanged.
set -eu
LC_ALL=C
export LC_ALL

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO=$(CDPATH= cd -- "$SCRIPT_DIR/../../.." && pwd)
SCRIPT=$REPO/services/factory/assets/scripts/artifact-cleanup.sh

WORK=$(mktemp -d "${TMPDIR:-/tmp}/artifact-cleanup-proof.XXXXXX")
trap 'rm -rf "$WORK"' EXIT INT TERM

ROOT=$WORK/root
ART=$ROOT/docs/artifact
TARGET=$ART/feat-orchestration

status=0
ok() { printf 'ok: %s\n' "$1"; }
bad() {
  printf 'FAIL: %s\n' "$1"
  status=1
}

# Run the cleanup script from the scratch project root. Print the exit code.
# Write the plan to `$1` and the error text to `$2`.
run_script() {
  rs_out=$1
  rs_err=$2
  shift 2
  if ( cd "$ROOT" && sh "$SCRIPT" "$@" ) > "$rs_out" 2> "$rs_err"; then
    rs_ec=0
  else
    rs_ec=$?
  fi
  printf '%s' "$rs_ec"
}

plan_delete() { awk '/^delete: / { sub(/^delete: /, ""); print }' "$1" | sort; }
plan_keep() { awk '/^keep: / { sub(/^keep: /, ""); print }' "$1" | sort; }

# ---------------------------------------------------------------------------
# The scratch project root.
# ---------------------------------------------------------------------------
mkdir -p "$ART"
for f in feat-orchestration feat-design feat-foundation feat-example; do
  cp -R "$REPO/docs/artifact/$f" "$ART/$f"
done

# The version 7.0.0 target: one more version folder and one more `## Versions`
# table row. The target is the exact version 7.0.0 state.
mkdir -p "$TARGET/versions/7.0.0"
printf 'artifact-cleanup proof target 7.0.0\n' > "$TARGET/versions/7.0.0/marker"
printf '| 7.0.0 | [artifact-cleanup](changes/change-artifact-cleanup/README.md) | Requirements |\n' \
  >> "$TARGET/README.md"
sed 's/^\*\*Current version:\*\* .*/**Current version:** 7.0.0/' "$TARGET/README.md" \
  > "$WORK/readme.target"
mv "$WORK/readme.target" "$TARGET/README.md"

cat > "$WORK/expected-delete" <<'EOF'
docs/artifact/feat-orchestration/changes/change-capability-layer
docs/artifact/feat-orchestration/changes/change-initial
docs/artifact/feat-orchestration/changes/change-opencode-v2
docs/artifact/feat-orchestration/changes/change-role-capabilities
docs/artifact/feat-orchestration/versions/1.0.0
docs/artifact/feat-orchestration/versions/2.0.0
docs/artifact/feat-orchestration/versions/3.0.0
docs/artifact/feat-orchestration/versions/4.0.0
EOF

cat > "$WORK/expected-keep" <<'EOF'
docs/artifact/feat-orchestration/changes/change-artifact-cleanup
docs/artifact/feat-orchestration/changes/change-codegraph-mcp
docs/artifact/feat-orchestration/changes/change-coverage-audit
docs/artifact/feat-orchestration/versions/5.0.0
docs/artifact/feat-orchestration/versions/6.0.0
docs/artifact/feat-orchestration/versions/7.0.0
EOF

# The repository tree fingerprint, before the runs.
find "$REPO/docs/artifact" | sort > "$WORK/repo.before"

# ---------------------------------------------------------------------------
# The plan of the version 7.0.0 target (spec-cleanup-bundle, "The seed check and
# the proof" 5; spec-artifact-cleanup invariant 1 and 3).
# ---------------------------------------------------------------------------
target_out=$WORK/target.out
target_err=$WORK/target.err
target_ec=$(run_script "$target_out" "$target_err" feat-orchestration)
if [ "$target_ec" -eq 1 ]; then
  ok "the 7.0.0 target plan exits 1"
else
  bad "the 7.0.0 target plan exits $target_ec, expected 1"
fi

plan_delete "$target_out" > "$WORK/target-delete"
plan_keep "$target_out" > "$WORK/target-keep"
if cmp -s "$WORK/expected-delete" "$WORK/target-delete"; then
  ok "the 7.0.0 target delete list holds the four older folders of each kind"
else
  bad "the 7.0.0 target delete list differs from the expected list"
  diff "$WORK/expected-delete" "$WORK/target-delete" || true
fi
if cmp -s "$WORK/expected-keep" "$WORK/target-keep"; then
  ok "the 7.0.0 target keep list holds 5.0.0, 6.0.0, 7.0.0 and the three newest changes"
else
  bad "the 7.0.0 target keep list differs from the expected list"
  diff "$WORK/expected-keep" "$WORK/target-keep" || true
fi

# The determinism (spec-artifact-cleanup invariant 8).
target2_out=$WORK/target2.out
target2_err=$WORK/target2.err
target2_ec=$(run_script "$target2_out" "$target2_err" feat-orchestration)
if [ "$target2_ec" -eq "$target_ec" ] && cmp -s "$target_out" "$target2_out"; then
  ok "the 7.0.0 target plan and exit code are deterministic"
else
  bad "the 7.0.0 target plan differs between two runs"
fi

# ---------------------------------------------------------------------------
# The no-op fixtures (spec-artifact-cleanup invariant 2 and keep window 5,
# FAC-03-04). Each fixture holds three or fewer folders of a kind.
# ---------------------------------------------------------------------------
for f in feat-design feat-foundation feat-example; do
  noop_out=$WORK/noop-$f.out
  noop_err=$WORK/noop-$f.err
  noop_ec=$(run_script "$noop_out" "$noop_err" "$f")
  noop_delete=$(plan_delete "$noop_out")
  if [ "$noop_ec" -eq 0 ] && [ -z "$noop_delete" ]; then
    ok "the no-op fixture $f exits 0 with an empty delete list"
  else
    bad "the no-op fixture $f exits $noop_ec with delete list [$noop_delete], expected 0 and empty"
  fi
done

# ---------------------------------------------------------------------------
# The apply form (spec-artifact-cleanup invariant 1, 6, and 7). The delete-list
# paths are absent after the run. The keep-list paths stay. The feature README
# bytes are equal before and after the run. The safety boundary keeps the
# feature README and the current version folder 7.0.0.
# ---------------------------------------------------------------------------
cp "$TARGET/README.md" "$WORK/readme.before"
apply_out=$WORK/apply.out
apply_err=$WORK/apply.err
apply_ec=$(run_script "$apply_out" "$apply_err" --apply feat-orchestration)
if [ "$apply_ec" -eq 1 ]; then
  ok "the 7.0.0 target apply form exits 1"
else
  bad "the 7.0.0 target apply form exits $apply_ec, expected 1"
fi

apply_delete_ok=1
while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  if [ -e "$ROOT/$rel" ]; then
    apply_delete_ok=0
    bad "the apply form keeps the delete-list path $rel"
  fi
done < "$WORK/expected-delete"
if [ "$apply_delete_ok" -eq 1 ]; then
  ok "the apply form removes each delete-list path"
fi

apply_keep_ok=1
while IFS= read -r rel; do
  [ -n "$rel" ] || continue
  if [ ! -d "$ROOT/$rel" ]; then
    apply_keep_ok=0
    bad "the apply form removes the keep-list path $rel"
  fi
done < "$WORK/expected-keep"
if [ "$apply_keep_ok" -eq 1 ]; then
  ok "the apply form keeps each keep-list path"
fi

if cmp -s "$WORK/readme.before" "$TARGET/README.md"; then
  ok "the apply form changes no line of the feature README"
else
  bad "the apply form changes the feature README bytes"
fi

if [ -f "$TARGET/README.md" ] && [ -d "$TARGET/versions/7.0.0" ]; then
  ok "the safety boundary keeps the feature README and the current version folder 7.0.0"
else
  bad "the safety boundary removes the feature README or the current version folder 7.0.0"
fi

# ---------------------------------------------------------------------------
# The input errors (spec-artifact-cleanup errors). Each plan run exits 2 and
# deletes no path.
# ---------------------------------------------------------------------------
badver=$ART/proof-badver
mkdir -p "$badver/versions/1.0.0" "$badver/versions/2.0.0" "$badver/versions/3.0.0" \
  "$badver/versions/4.0.0" "$badver/versions/v9"
mkdir -p "$badver/changes"
printf '**Current version:** 4.0.0\n' > "$badver/README.md"
badver_out=$WORK/badver.out
badver_err=$WORK/badver.err
badver_ec=$(run_script "$badver_out" "$badver_err" proof-badver)
if [ "$badver_ec" -eq 2 ] && [ -d "$badver/versions/v9" ]; then
  ok "a version folder name outside <major>.<minor>.<patch> exits 2 and deletes no path"
else
  bad "a bad version folder name exits $badver_ec, expected 2 with no delete"
fi

badchg=$ART/proof-badchg
mkdir -p "$badchg/changes/change-a" "$badchg/changes/change-b" "$badchg/changes/change-c" \
  "$badchg/changes/change-d" "$badchg/changes/bogus"
mkdir -p "$badchg/versions"
{
  printf '**Current version:** 1.0.0\n'
  printf '\n| Version | Change | Type |\n| --- | --- | --- |\n'
  printf '| 1.0.0 | [a](changes/change-a/README.md) | Requirements |\n'
} > "$badchg/README.md"
badchg_out=$WORK/badchg.out
badchg_err=$WORK/badchg.err
badchg_ec=$(run_script "$badchg_out" "$badchg_err" proof-badchg)
if [ "$badchg_ec" -eq 2 ] && [ -d "$badchg/changes/bogus" ]; then
  ok "a change folder name without the prefix change- exits 2 and deletes no path"
else
  bad "a bad change folder name exits $badchg_ec, expected 2 with no delete"
fi

missing_out=$WORK/missing.out
missing_err=$WORK/missing.err
missing_ec=$(run_script "$missing_out" "$missing_err")
if [ "$missing_ec" -eq 2 ]; then
  ok "a run without a feature name exits 2"
else
  bad "a run without a feature name exits $missing_ec, expected 2"
fi

# ---------------------------------------------------------------------------
# The repository `docs/artifact/` tree stays unchanged (task-cleanup-proof
# step 12). The runner reads the tree and writes only below `$WORK`.
# ---------------------------------------------------------------------------
find "$REPO/docs/artifact" | sort > "$WORK/repo.after"
if cmp -s "$WORK/repo.before" "$WORK/repo.after"; then
  ok "the repository docs/artifact/ tree is unchanged"
else
  bad "the repository docs/artifact/ tree changed"
  diff "$WORK/repo.before" "$WORK/repo.after" || true
fi

if [ "$status" -eq 0 ]; then
  printf 'artifact-cleanup-proof: green\n'
  exit 0
fi
printf 'artifact-cleanup-proof: red\n'
exit 1
