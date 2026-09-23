#!/bin/sh
# Arch layer (spec-arch-seed).
# The emitted tree holds the base files and exactly one overlay. The inactive
# overlay is absent. The emitted factory.nix selects the arch.
# Usage: layer-arch.sh <work-dir> <arch>
# Prints nothing on success; prints "<layer>: red: <path>: <reason>" on failure.
set -eu
work=${1:?work directory}
arch=${2:?arch}
fail() { echo "arch: red: $1: $2"; exit 1; }
for rel in factory.nix .markdownlint.yaml README.md docs/artifact/README.md docs/artifact/feat-example/README.md docs/artifact/feat-example/changes/change-initial/README.md; do
  [ -f "$work/$rel" ] || fail "$rel" "missing base file"
done
grep -q "arch = \"$arch\"" "$work/factory.nix" || fail "factory.nix" "arch is not $arch"
case "$arch" in
  single)
    [ -f "$work/docs/wiki/repo-arch/single-repository.md" ] || fail "docs/wiki/repo-arch/single-repository.md" "missing single overlay"
    [ ! -e "$work/docs/wiki/repo-arch/multiple-repositories.md" ] || fail "docs/wiki/repo-arch/multiple-repositories.md" "inactive overlay present"
    [ ! -e "$work/e2e/README.md" ] || fail "e2e/README.md" "inactive overlay present"
    ;;
  multiple)
    [ -f "$work/docs/wiki/repo-arch/multiple-repositories.md" ] || fail "docs/wiki/repo-arch/multiple-repositories.md" "missing multiple overlay"
    [ -f "$work/e2e/README.md" ] || fail "e2e/README.md" "missing multiple overlay"
    [ ! -e "$work/docs/wiki/repo-arch/single-repository.md" ] || fail "docs/wiki/repo-arch/single-repository.md" "inactive overlay present"
    ;;
  *) fail "factory.nix" "unknown arch $arch" ;;
esac
