# services/factory/modules/foundation.nix
# Module shell of the factory component.
# Holds the option set, the config block, and the layout contract of the
# emitted docs/artifact tree (spec-layout): the starter feature feat-example
# and the first change change-initial.
# The facade root factory.project (spec-facade-root) lives in facade.nix.
let
  facade = import ./facade.nix;
  filePlan = import ./file-plan.nix;
  copyModes = import ./copy-modes.nix;
  yamlRenderer = import ./yaml-renderer.nix;
  layout = {
    starterFeature = "feat-example";
    firstChange = "change-initial";
    starterFiles = [
      "docs/artifact/README.md"
      "docs/artifact/feat-example/README.md"
      "docs/artifact/feat-example/changes/change-initial/README.md"
    ];
  };
  options = {
    factory.project = facade.rootOptions;
  };
  config = {
    inherit layout;
    modeledKeys = facade.modeledKeys;
    archValues = facade.archValues;
    secretPattern = facade.secretPattern;
    assertionTable = builtins.map (a: {
      inherit (a) name message;
    }) (facade.facadeAssertions { });
  };
in
{
  inherit
    layout
    options
    config
    facade
    filePlan
    copyModes
    yamlRenderer
    ;
}
