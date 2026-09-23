#!/bin/sh
# Facade layer (spec-facade-root).
# The emitted factory.nix evaluates against the factory module set only. The
# evaluation happens when the check derivation is built: the proof file is
# green only when evalFactory accepted the declaration with the factory
# modules, never the devenv modules of the factory repository. This layer
# proves that the evaluated bytes are the emitted bytes.
# Usage: layer-facade.sh <work-dir> <proof> <factory-source>
# Prints nothing on success; prints "<layer>: red: <path>: <reason>" on failure.
set -eu
work=${1:?work directory}
proof=${2:?proof file}
factory_src=${3:?factory source}
fail() { echo "facade: red: $1: $2"; exit 1; }
[ "$(cat "$proof")" = "green" ] || fail "factory.nix" "facade proof is not green"
cmp -s "$factory_src" "$work/factory.nix" || fail "factory.nix" "emitted bytes differ from evaluated declaration"
