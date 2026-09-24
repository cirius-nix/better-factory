# Consumer example (spec-consumer-import, spec-consumer-entry).
# Declares the factory input at the repository root, imports the composed
# entrypoint by the documented path, and wires emit, check, and manifest.
# The example selects one harness and declares no role; the entrypoint
# discovers the shipped role set. The manifest feeds the adopt step
# (spec-copymode).
{
  description = "Factory example: consumer entrypoint.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/b134951a4c9f3c995fd7be05f3243f8ecd65d798";
    factory.url = "path:../../../..";
    factory.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      factory,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      mkFactory = import (factory + "/services/factory/modules/entrypoint.nix");
      entry = mkFactory {
        inherit pkgs;
        factoryDir = factory + "/services/factory";
        project = ./factory.nix;
        repoRoot = ./.;
      };
    in
    {
      checks.${system}.seed-check = entry.check;
      packages.${system} = {
        emit = entry.emit;
        manifest = entry.manifest;
      };
    };
}
