# services/factory/modules/facade.nix
# Facade root factory.project (spec-facade-root).
# Pure validation with one naming message per invariant. No nixpkgs dependency.
let
  modeledKeys = [
    "arch"
    "advanced"
    "secrets"
  ];
  archValues = [
    "single"
    "multiple"
  ];
  secretPattern = "^[A-Za-z_][A-Z0-9_]*$";

  sortKeys = keys: builtins.sort builtins.lessThan keys;

  rootOptions = {
    arch = {
      type = "enum single multiple";
      description = "Architecture parameter (spec-arch-seed).";
    };
    advanced = {
      type = "attrsOf anything";
      default = { };
      description = "Passthrough copied without a schema check.";
    };
    secrets = {
      type = "list of names";
      default = [ ];
      description = "Environment-variable names only, never values.";
    };
  };

  checkModeledKeys =
    keys:
    if
      sortKeys keys == sortKeys modeledKeys && sortKeys (builtins.attrNames rootOptions) == sortKeys keys
    then
      true
    else
      throw "root: the modeled-key list differs from the root option definitions of `factory.project`";

  isSecretName =
    entry: builtins.isString entry && entry != "" && builtins.match "[A-Za-z_][A-Z0-9_]*" entry != null;

  firstOutside = keys: builtins.filter (k: !(builtins.elem k modeledKeys)) keys;

  # One assertion entry per invariant of spec-facade-root. Each message names
  # the item. Takes the evaluated project value (or null when absent).
  facadeAssertions =
    project:
    let
      isAttrs = builtins.isAttrs project;
      outside = if isAttrs then firstOutside (builtins.attrNames project) else [ ];
      arch = if isAttrs && project ? arch then project.arch else null;
      advanced =
        if isAttrs && project ? advanced && builtins.isAttrs project.advanced then
          project.advanced
        else
          { };
      advancedBad = builtins.filter (k: builtins.elem k modeledKeys) (builtins.attrNames advanced);
      secrets =
        if isAttrs && project ? secrets && builtins.isList project.secrets then project.secrets else [ ];
      secretBad = builtins.filter (e: !isSecretName e) secrets;
      show = v: if builtins.isString v then "`${v}`" else builtins.toJSON v;
    in
    [
      {
        name = "root";
        assertion = !isAttrs || outside == [ ];
        message =
          if isAttrs && outside != [ ] then
            "root: factory setting `${builtins.head outside}` sits outside the root `factory.project`"
          else
            "root: a factory setting sits outside the root `factory.project`";
      }
      {
        name = "root-type";
        assertion = isAttrs;
        message = "root-type: the root `factory.project` must be an attribute set, got `${builtins.typeOf project}`";
      }
      {
        name = "advanced-modeled";
        assertion = advancedBad == [ ];
        message =
          if advancedBad == [ ] then
            "advanced-modeled: a key of the group `advanced` has the name of a modeled root key"
          else
            "advanced-modeled: the key `${builtins.head advancedBad}` of the group `advanced` has the name of a modeled root key";
      }
      {
        name = "secret-name";
        assertion = secretBad == [ ];
        message =
          if secretBad == [ ] then
            "secret-name: an entry is not a name matching `${secretPattern}`"
          else
            let
              bad = builtins.head secretBad;
            in
            "secret-name: the entry ${show bad} is not a name matching `${secretPattern}`";
      }
      {
        name = "arch-value";
        assertion = builtins.elem arch archValues;
        message =
          if arch == null then
            "arch-value: the key `arch` is absent; it must be `single` or `multiple`"
          else
            "arch-value: the key `arch` must be `single` or `multiple`, got ${show arch}";
      }
    ];

  # Evaluate one factory.nix value against the factory module set only.
  # Throws the naming message of the first failing invariant.
  evalFactory =
    factoryNix:
    let
      topExtra =
        if builtins.isAttrs factoryNix then
          builtins.filter (k: k != "factory") (builtins.attrNames factoryNix)
        else
          [ ];
      project =
        if builtins.isAttrs factoryNix && factoryNix ? factory && builtins.isAttrs factoryNix.factory then
          let
            f = factoryNix.factory;
          in
          if !(f ? project) then
            throw "root-type: the root `factory.project` is absent; the root must be an attribute set"
          else if builtins.filter (k: k != "project") (builtins.attrNames f) != [ ] then
            throw "root: factory setting `${
              builtins.head (builtins.filter (k: k != "project") (builtins.attrNames f))
            }` sits outside the root `factory.project`"
          else
            f.project
        else if topExtra != [ ] then
          throw "root: factory setting `${builtins.head topExtra}` sits outside the root `factory.project`"
        else
          throw "root-type: the root `factory.project` must be an attribute set, got `${builtins.typeOf factoryNix}`";
      strict = checkModeledKeys modeledKeys;
      topOk =
        if topExtra != [ ] then
          throw "root: factory setting `${builtins.head topExtra}` sits outside the root `factory.project`"
        else
          true;
      checks = facadeAssertions project;
      failing = builtins.filter (a: !a.assertion) checks;
      failNow = if failing == [ ] then true else throw (builtins.head failing).message;
      advanced =
        if !(project ? advanced) then
          { }
        else if builtins.isAttrs project.advanced then
          project.advanced
        else
          throw "root-type: the group `advanced` below the root `factory.project` must be an attribute set, got `${builtins.typeOf project.advanced}`";
      secrets =
        if !(project ? secrets) then
          [ ]
        else if builtins.isList project.secrets then
          project.secrets
        else
          throw "secret-name: the group `secrets` below the root `factory.project` must be a list of names matching `${secretPattern}`";
    in
    assert strict;
    assert topOk;
    assert failNow;
    {
      arch = project.arch;
      inherit advanced secrets;
    };
in
{
  inherit
    modeledKeys
    archValues
    secretPattern
    rootOptions
    checkModeledKeys
    facadeAssertions
    evalFactory
    isSecretName
    ;
}
