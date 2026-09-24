# services/factory/default.nix
# Explicit module import list of the factory component.
# The trees assets/ and examples/ hold data only and never appear here.
let
  factoryModules = [
    ./modules/foundation.nix
    ./modules/orchestration.nix
    ./modules/design.nix
    ./modules/delivery.nix
  ];
  isAssetOrExample =
    m:
    let
      s = toString m;
    in
    (builtins.match ".*/assets(/.*)?" s) != null || (builtins.match ".*/examples(/.*)?" s) != null;
  checkModuleImports =
    mods:
    let
      bad = builtins.filter isAssetOrExample mods;
    in
    if bad == [ ] then mods else throw "asset check: module import list holds an asset or example path";
in
{
  inherit factoryModules checkModuleImports;
  checkedModules = checkModuleImports factoryModules;
}
