#!/bin/sh
# Seed check orchestrator (spec-e2e-seed).
# Materializes the blueprint in a scratch directory below $TMPDIR and runs
# the five layers in order: layout, arch, facade, copy-mode, emit. Writes the
# result to $OUT: exactly five "<layer>: green" lines. A red layer writes
# "<layer>: red: <path>: <reason>" and exits non-zero. Writes only below
# $TMPDIR and $out. The result holds no timestamp, no hostname, no store path.
set -eu
: "${MANIFEST:?manifest file}"
: "${WORK:?scratch directory}"
: "${OUT:?result file}"
: "${ARCH:?arch}"
: "${SCRIPT_DIR:?script directory}"
: "${COPY_STEP:?copy-step script}"
: "${LINT_BIN:?markdownlint binary}"
: "${LINT_CONFIG:?markdownlint config}"
: "${PROOF:?facade proof}"
: "${FACTORY_SRC:?factory source}"
mkdir -p "$WORK"
"$COPY_STEP" "$MANIFEST" "$WORK"
: > "$OUT"
run_layer() {
  name=$1
  shift
  if "$@" > "$WORK/../$name.log" 2>&1; then
    echo "$name: green" >> "$OUT"
  else
    cat "$WORK/../$name.log" >> "$OUT"
    exit 1
  fi
}
run_layer layout "$SCRIPT_DIR/layer-layout.sh" "$WORK" "$LINT_BIN" "$LINT_CONFIG"
run_layer arch "$SCRIPT_DIR/layer-arch.sh" "$WORK" "$ARCH"
run_layer facade "$SCRIPT_DIR/layer-facade.sh" "$WORK" "$PROOF" "$FACTORY_SRC"
run_layer copy-mode "$SCRIPT_DIR/layer-copymode.sh" "$MANIFEST" "$WORK" "$COPY_STEP"
run_layer emit "$SCRIPT_DIR/layer-emit.sh" "$MANIFEST" "$WORK"
