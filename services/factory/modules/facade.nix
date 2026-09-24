# services/factory/modules/facade.nix
# Facade root factory.project (spec-facade-root).
# Pure validation with one naming message per invariant. No nixpkgs dependency.
let
  orchestration = import ./orchestration.nix;
  designMod = import ./design.nix;
  deliveryMod = import ./delivery.nix;
  presetsLib = import ../lib/presets.nix;
  modeledKeys = [
    "arch"
    "advanced"
    "secrets"
    "agents"
    "design"
    "ux"
    "ci"
    "site"
    "publish"
    "notify"
    "preset"
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
    agents = {
      type = "group agents";
      default = { };
      description = "Harness settings of the repository (spec-harness-merge).";
    };
    design = {
      type = "group design";
      default = { };
      description = "Design method and design tool (spec-design-option).";
    };
    ux = {
      type = "bool";
      default = false;
      description = "Activates the designer work (spec-designer-role).";
    };
    ci = {
      type = "group ci";
      default = { };
      description = "CI provider and folder (spec-ci-options).";
    };
    site = {
      type = "group site";
      default = { };
      description = "Docs site settings (spec-site-render).";
    };
    publish = {
      type = "group publish";
      default = { };
      description = "Publish target and deploy tool (spec-publish).";
    };
    notify = {
      type = "group notify";
      default = { };
      description = "Deploy notifier channels (spec-notify-fanout).";
    };
    preset = {
      type = "enum minimal docs-only full";
      description = "Named preset bundle; absent gives no bundle (spec-presets).";
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
      # The selected bundle applies to the project value before the group
      # evaluation. The effective settings feed each gate and each emitted
      # file set. The tables come from the option tables of the modules.
      presetName =
        if !(project ? preset) || project.preset == null then
          null
        else
          deliveryMod.evalPreset project.preset;
      tables = {
        agents = orchestration.agentsOptions;
        design = designMod.designOptions;
        ux = designMod.uxOptions;
        delivery = deliveryMod.deliveryOptions;
      };
      effective = presetsLib.applyPreset {
        preset = presetName;
        inherit project tables;
      };
      advanced =
        if !(effective ? advanced) then
          { }
        else if builtins.isAttrs effective.advanced then
          effective.advanced
        else
          throw "root-type: the group `advanced` below the root `factory.project` must be an attribute set, got `${builtins.typeOf effective.advanced}`";
      secrets =
        if !(effective ? secrets) then
          [ ]
        else if builtins.isList effective.secrets then
          effective.secrets
        else
          throw "secret-name: the group `secrets` below the root `factory.project` must be a list of names matching `${secretPattern}`";
      agents =
        if !(effective ? agents) || effective.agents == null then
          orchestration.emptyAgents
        else
          orchestration.evalAgents effective.agents;
      design =
        if !(effective ? design) || effective.design == null then
          designMod.evalDesign null
        else
          designMod.evalDesign effective.design;
      ux =
        if !(effective ? ux) || effective.ux == null then
          designMod.evalUx null
        else
          designMod.evalUx effective.ux;
      ci =
        if !(effective ? ci) || effective.ci == null then
          deliveryMod.evalCi null
        else
          deliveryMod.evalCi effective.ci;
      site =
        if !(effective ? site) || effective.site == null then
          deliveryMod.evalSite null
        else
          deliveryMod.evalSite effective.site;
      publish =
        if !(effective ? publish) || effective.publish == null then
          deliveryMod.evalPublish null
        else
          deliveryMod.evalPublish effective.publish;
      notify =
        if !(effective ? notify) || effective.notify == null then
          deliveryMod.evalNotify null
        else
          deliveryMod.evalNotify effective.notify;
      preset =
        if !(effective ? preset) || effective.preset == null then
          deliveryMod.evalPreset null
        else
          deliveryMod.evalPreset effective.preset;
    in
    assert strict;
    assert topOk;
    assert failNow;
    {
      arch = project.arch;
      inherit
        advanced
        secrets
        agents
        design
        ux
        ci
        site
        publish
        notify
        preset
        ;
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
