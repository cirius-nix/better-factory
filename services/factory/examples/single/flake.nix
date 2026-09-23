# Example: single repository (spec-arch-seed).
# Selects arch single and exposes checks.<system>.seed-check (spec-e2e-seed).
{
  description = "Factory example: single repository.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/b134951a4c9f3c995fd7be05f3243f8ecd65d798";
    factory.url = "path:../..";
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
      mkSeedCheck = import (factory + "/modules/seed-check.nix");
    in
    {
      checks.${system}.seed-check = mkSeedCheck {
        inherit pkgs;
        factoryDir = factory;
        arch = "single";
      };
    };
}
