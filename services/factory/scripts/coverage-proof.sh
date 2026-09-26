#!/bin/sh
# coverage-proof.sh
# The scan proof of the two targets (task-scan-proof, spec-coverage-scan).
# This file is a factory test runner. It is not shipped. It is not a
# capability (C-FCA-07-04, C-FCA-08-02).
#
# The runner runs the deterministic coverage scan on two targets:
#   1. the factory repository root, the report target. The expected exit code
#      is 1. The report holds three rows for the class patterns `services/*`,
#      `libs/*`, and `deployment/*`. The target is a report, not a gate.
#   2. the materialized consumer tree, the clean gate. The expected exit code
#      is 0.
#
# The runner states the expected exit code of each target. The runner fails
# when a target differs. The runner writes no repository file. It writes only
# below the temporary directory $TMPDIR.
#
# The global-config precondition (spec-agent-read, C-FCA-02-04, C-FCA-07-09):
# the run pins HOME and XDG_CONFIG_HOME to an empty temporary directory. No
# `opencode/opencode.json*` document exists outside the target. The two runs
# are reproducible.
set -eu
LC_ALL=C
export LC_ALL

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
REPO=$(CDPATH= cd -- "$SCRIPT_DIR/../../.." && pwd)
CONSUMER=services/factory/examples/consumer
AUDIT=.opencode/scripts/coverage-audit.sh
EXPECTED_FACTORY=1
EXPECTED_CONSUMER=0
EXPECTED_MISSING=2

WORK=$(mktemp -d "${TMPDIR:-/tmp}/coverage-proof.XXXXXX")
trap 'rm -rf "$WORK"' EXIT INT TERM
mkdir -p "$WORK/home" "$WORK/xdg" "$WORK/none"
HOME=$WORK/home
XDG_CONFIG_HOME=$WORK/xdg
export HOME XDG_CONFIG_HOME

TAB=$(printf '\t')
status=0

ok() { printf 'ok: %s\n' "$1"; }
bad() {
  printf 'FAIL: %s\n' "$1"
  status=1
}

# Run the scan script on one root. Print the exit code. Write the report to
# the file $3 and the error text to the file $3.err.
scan() {
  script=$1
  root=$2
  out=$3
  if ( cd "$root" && sh "$script" "$root" ) > "$out" 2> "$out.err"; then
    ec=0
  else
    ec=$?
  fi
  printf '%s' "$ec"
}

# Print the class pattern of each report row.
rows() {
  awk -F"$TAB" 'NF >= 4 { print $1 }' "$1" | sort
}

# ---------------------------------------------------------------------------
# Target 1: the factory repository root. The report target.
# ---------------------------------------------------------------------------
printf 'target: factory repository root (%s), expected exit %s\n' "$REPO" "$EXPECTED_FACTORY"
factory_out=$WORK/factory.out
factory_ec=$(scan "$REPO/$AUDIT" "$REPO" "$factory_out")
if [ "$factory_ec" -eq "$EXPECTED_FACTORY" ]; then
  ok "the factory root scan exits $EXPECTED_FACTORY"
else
  bad "the factory root scan exits $factory_ec, expected $EXPECTED_FACTORY"
fi
cat "$factory_out"

factory_rows=$(rows "$factory_out" | tr '\n' ' ')
expected_rows=$(printf 'deployment/*\nlibs/*\nservices/*\n' | sort | tr '\n' ' ')
if [ "$factory_rows" = "$expected_rows" ]; then
  ok "the factory root report holds the three class-pattern rows"
else
  bad "the factory root report rows are [$factory_rows], expected [$expected_rows]"
fi

factory_out2=$WORK/factory2.out
factory_ec2=$(scan "$REPO/$AUDIT" "$REPO" "$factory_out2")
if [ "$factory_ec2" -eq "$EXPECTED_FACTORY" ] && cmp -s "$factory_out" "$factory_out2"; then
  ok "the factory root scan is deterministic"
else
  bad "the factory root scan differs between two runs"
fi

if awk '/^proposal:/ { p = 1 } p' "$factory_out" | grep -q 'repository-expert'; then
  bad "the proposal names repository-expert"
else
  ok "the proposal never names repository-expert"
fi

# ---------------------------------------------------------------------------
# Target 2: the materialized consumer tree. The clean gate.
# ---------------------------------------------------------------------------
printf 'target: materialized consumer tree, expected exit %s\n' "$EXPECTED_CONSUMER"
if consumer_root=$(cd "$REPO" && nix build "./$CONSUMER#emit" --no-link --print-out-paths --override-input factory "path:$REPO" 2> "$WORK/build.err"); then
  :
else
  bad "the consumer emit build failed"
  cat "$WORK/build.err" >&2
  printf 'coverage-proof: red\n'
  exit 1
fi
printf 'consumer tree: %s\n' "$consumer_root"

if [ -f "$consumer_root/surface.tsv" ] && [ -f "$consumer_root/$AUDIT" ]; then
  ok "the materialized consumer tree holds surface.tsv and $AUDIT"
else
  bad "the materialized consumer tree misses surface.tsv or $AUDIT"
fi

if [ ! -e "$REPO/$CONSUMER/surface.tsv" ] && [ ! -d "$REPO/$CONSUMER/.opencode" ]; then
  ok "the consumer source tree is not a scan target"
else
  bad "the consumer source tree holds a surface.tsv or a .opencode tree"
fi

consumer_out=$WORK/consumer.out
consumer_ec=$(scan "$consumer_root/$AUDIT" "$consumer_root" "$consumer_out")
if [ "$consumer_ec" -eq "$EXPECTED_CONSUMER" ]; then
  ok "the consumer scan exits $EXPECTED_CONSUMER"
else
  bad "the consumer scan exits $consumer_ec, expected $EXPECTED_CONSUMER"
fi
cat "$consumer_out"

if grep -q '^coverage: [0-9][0-9]* entries, 0 unowned author paths$' "$consumer_out"; then
  ok "the consumer report holds no unowned author path"
else
  bad "the consumer report holds an unowned author path"
fi

if rows "$consumer_out" | grep -q '^component-'; then
  bad "the consumer report holds a component-* row"
else
  ok "the consumer report holds no component-* row"
fi

consumer_out2=$WORK/consumer2.out
consumer_ec2=$(scan "$consumer_root/$AUDIT" "$consumer_root" "$consumer_out2")
if [ "$consumer_ec2" -eq "$EXPECTED_CONSUMER" ] && cmp -s "$consumer_out" "$consumer_out2"; then
  ok "the consumer scan is deterministic"
else
  bad "the consumer scan differs between two runs"
fi

# ---------------------------------------------------------------------------
# The input-error rule: a root without the declaration exits 2.
# ---------------------------------------------------------------------------
missing_out=$WORK/missing.out
missing_ec=$(scan "$REPO/$AUDIT" "$WORK/none" "$missing_out")
if [ "$missing_ec" -eq "$EXPECTED_MISSING" ]; then
  ok "a root without surface.tsv exits $EXPECTED_MISSING"
else
  bad "a root without surface.tsv exits $missing_ec, expected $EXPECTED_MISSING"
fi

# ---------------------------------------------------------------------------
# The declaration read: the scan holds no hard-coded standard class list.
# ---------------------------------------------------------------------------
if grep -qE 'surface-declaration|repository-readme|factory-declaration|artifact-index|component-service|standardSurface' "$REPO/$AUDIT"; then
  bad "the scan script holds a hard-coded standard class label"
else
  ok "the scan script holds no hard-coded standard class label"
fi

if grep -q "^factory-config${TAB}.*${TAB}factory\.config\.yaml$" "$REPO/surface.tsv"; then
  ok "the factory declaration holds the class factory-config for factory.config.yaml"
else
  bad "the factory declaration misses the class factory-config for factory.config.yaml"
fi

if [ "$status" -eq 0 ]; then
  printf 'coverage-proof: green\n'
  exit 0
fi
printf 'coverage-proof: red\n'
exit 1
