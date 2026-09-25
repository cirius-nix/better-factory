# Factory repository runner: the `factory-expert` body (adr-seed-check-body-input,
# C-CL36). The flake passes the repo-local role directory `utils/agent/role/factory-expert`
# through the path input `factoryExpertRole`, with `flake = false`, and calls
# `mkSeedCheck` with `factoryExpertBody = factoryExpertRole + "/ROLE.md"` and the
# arch `multiple`, because the declaration `factory.nix` of the factory repository
# selects it.
{
  description = "Factory repository runner: the `factory-expert` body.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/b134951a4c9f3c995fd7be05f3243f8ecd65d798";
    factory.url = "path:../..";
    factory.flake = false;
    factoryExpertRole.url = "path:../../../../utils/agent/role/factory-expert";
    factoryExpertRole.flake = false;
  };

  outputs =
    {
      self,
      nixpkgs,
      factory,
      factoryExpertRole,
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
        arch = "multiple";
        factoryExpertBody = factoryExpertRole + "/ROLE.md";
      };
    };
}
