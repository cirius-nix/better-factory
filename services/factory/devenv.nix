# services/factory/devenv.nix
# Devenv module (spec-consumer-devenv). A consumer devenv project imports the
# module through devenv.yaml with inputs.factory (flake = false) and
# imports: [factory/services/factory]. The module composes the entrypoint
# mkFactory with the owned declaration factory.nix at the root of the
# consumer repository and exposes the scripts factory-emit, factory-check,
# and factory-adopt. The module adds no option group and no settings root:
# the one declaration file factory.nix is the source of the settings.
# factory-adopt runs the adopt step (spec-copymode) with the manifest of the
# entrypoint (spec-consumer-entry) and the consumer repository root passed
# as a string: a path value copies the repository to the store, and the
# write misses the author tree. Extra arguments forward to the adopt step.
{
  pkgs, # the package set of the consumer devenv
  config, # the devenv configuration
  ...
}:
let
  # factoryDir: the directory services/factory/ of the factory source,
  # derived from the module location. The evaluation copies it to the store:
  # a path input of devenv.yaml resolves in place, and the plan manifest
  # holds factoryDir-derived sources that the sandboxed build must read.
  # Devenv state directories stay out of the store copy.
  factoryDir = builtins.path {
    path = ./.;
    name = "factory";
    filter = path: type: builtins.baseNameOf path != ".devenv";
  };
  # Consumer repository root: the devenv root, converted to a path value.
  repoRoot = /. + config.devenv.root;
  # Owned declaration at the root of the consumer repository.
  project = repoRoot + "/factory.nix";
  mkFactory = import (factoryDir + "/modules/entrypoint.nix");
  # Compat: recent nixpkgs moved markdownlint-cli to the top level and
  # removed the nodePackages set; the entrypoint still reads
  # pkgs.nodePackages.markdownlint-cli. The shim re-exposes the top-level
  # package below the old attribute path. No other package changes.
  compatPkgs = pkgs // {
    nodePackages = {
      markdownlint-cli = pkgs.markdownlint-cli;
    };
  };
  entry = mkFactory {
    pkgs = compatPkgs;
    inherit factoryDir project repoRoot;
  };
in
{
  scripts.factory-check.exec = "cat ${entry.check}/output";
  scripts.factory-emit.exec = "echo ${entry.emit}";
  scripts.factory-adopt.exec = "sh ${factoryDir}/scripts/adopt.sh ${entry.manifest} '${config.devenv.root}' \"$@\"";
}
