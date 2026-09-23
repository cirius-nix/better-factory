# services/factory/modules/design.nix
# Facade group `factory.project.design` and key `factory.project.ux`
# (spec-design-option, spec-designer-scope, spec-designer-role). Holds the
# option declarations and the validation of the group and the key: the
# typed keys `use` and `tool`, and the bool key `ux`. Pure Nix with no
# nixpkgs dependency, in the style of modules/orchestration.nix.
let
  useValues = [
    "unset"
    "ddd"
  ];

  toolValues = [
    "unset"
    "figma"
    "pencil"
  ];

  designKnownKeys = [
    "use"
    "tool"
  ];

  designOptions = {
    use = {
      type = "enum unset ddd";
      default = "unset";
      description = "Design method; ddd selects domain-driven design (spec-design-option).";
    };
    tool = {
      type = "enum unset figma pencil";
      default = "unset";
      description = "Design tool; selects the canonical MCP entry (spec-designer-scope).";
    };
  };

  uxOptions = {
    type = "bool";
    default = false;
    description = "Activates the designer work (spec-designer-role).";
  };

  show = v: if builtins.isString v then "`${v}`" else builtins.toJSON v;

  # Validate one design group value and return the dense validated group:
  # absent keys take their defaults. An unknown key or an unknown value
  # fails evaluation with a message that names the key and the value set.
  evalDesign =
    value:
    if value == null then
      {
        use = "unset";
        tool = "unset";
      }
    else if !(builtins.isAttrs value) then
      throw "design-type: the group `design` below the root `factory.project` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k designKnownKeys)) keys;
      in
      if outside != [ ] then
        throw "design-key: the key `${builtins.head outside}` of the group `design` is outside the value set use, tool"
      else
        let
          use = if value ? use then value.use else "unset";
          tool = if value ? tool then value.tool else "unset";
        in
        if !(builtins.isString use) || !(builtins.elem use useValues) then
          throw "design-use: the key `use` of the group `design` must be one of unset, ddd, got ${show use}"
        else if !(builtins.isString tool) || !(builtins.elem tool toolValues) then
          throw "design-tool: the key `tool` of the group `design` must be one of unset, figma, pencil, got ${show tool}"
        else
          { inherit use tool; };

  # Validate one ux key value and return the bool. An absent value gives
  # false. Another type fails evaluation with a message that names the key
  # and the type.
  evalUx =
    value:
    if value == null then
      false
    else if !(builtins.isBool value) then
      throw "ux-type: the key `ux` below the root `factory.project` must be a bool, got `${builtins.typeOf value}`"
    else
      value;

  # One assertion entry per invariant of the seed-check fixture: the group
  # keys, the `use` value, the `tool` value, the `ux` type, and the
  # modeled-key list. Each message names the item. Takes the evaluated
  # settings and the modeled-key list.
  designAssertions =
    settings: modeledKeys:
    let
      design = settings.design or null;
      keys = if builtins.isAttrs design then builtins.attrNames design else [ ];
      use = if builtins.isAttrs design && design ? use then design.use else null;
      tool = if builtins.isAttrs design && design ? tool then design.tool else null;
      ux = if settings ? ux then settings.ux else null;
    in
    [
      {
        name = "design-keys";
        assertion =
          builtins.sort builtins.lessThan keys == [
            "tool"
            "use"
          ];
        message = "design-keys: the group `design` must hold exactly the keys `use` and `tool`, got ${builtins.toJSON keys}";
      }
      {
        name = "design-use";
        assertion = builtins.elem use useValues;
        message =
          if use == null then
            "design-use: the key `use` of the group `design` is absent; it must be `unset` or `ddd`"
          else
            "design-use: the key `use` of the group `design` must be `unset` or `ddd`, got ${show use}";
      }
      {
        name = "design-tool";
        assertion = builtins.elem tool toolValues;
        message =
          if tool == null then
            "design-tool: the key `tool` of the group `design` is absent; it must be `unset`, `figma`, or `pencil`"
          else
            "design-tool: the key `tool` of the group `design` must be `unset`, `figma`, or `pencil`, got ${show tool}";
      }
      {
        name = "ux-type";
        assertion = builtins.isBool ux;
        message = "ux-type: the key `ux` must be a bool, got `${builtins.typeOf ux}`";
      }
      {
        name = "design-modeled";
        assertion = builtins.elem "design" modeledKeys && builtins.elem "ux" modeledKeys;
        message = "design-modeled: the modeled-key list must hold `design` and `ux`, got ${builtins.toJSON modeledKeys}";
      }
    ];
  # One chapter map for the role set (C-13, spec-design-option,
  # spec-designer-role). Takes the evaluated settings and returns an
  # attribute set. The key is the name of a role. The value is the ordered
  # chapter list of that role. When the method is `ddd`, the map holds the
  # DDD chapter for requirement-expert and solution-expert. When the key
  # `ux` is true, the map holds the UX chapter for artifact-master,
  # solution-expert, and artifact-release-expert. The order of the
  # solution-expert list is the DDD chapter first and the UX chapter
  # second. The chapter texts are read from the asset tree.
  chapterMap =
    settings:
    let
      ddd = (settings.design or { }).use or "unset" == "ddd";
      ux = settings.ux or false;
      dddReq = builtins.readFile ../assets/design/ddd/chapters/requirement-expert.md;
      dddSol = builtins.readFile ../assets/design/ddd/chapters/solution-expert.md;
      uxMaster = builtins.readFile ../assets/design/ux/chapters/artifact-master.md;
      uxSol = builtins.readFile ../assets/design/ux/chapters/solution-expert.md;
      uxRelease = builtins.readFile ../assets/design/ux/chapters/artifact-release-expert.md;
    in
    {
      requirement-expert = if ddd then [ dddReq ] else [ ];
      solution-expert = (if ddd then [ dddSol ] else [ ]) ++ (if ux then [ uxSol ] else [ ]);
      artifact-master = if ux then [ uxMaster ] else [ ];
      artifact-release-expert = if ux then [ uxRelease ] else [ ];
    };
  # The tool feed (C-14, spec-designer-scope). Takes the evaluated
  # settings and returns the selected tool name (`unset`, `figma`, or
  # `pencil`). The feed selects the canonical entry of the tool in the
  # harness merge.
  toolFeed = settings: (settings.design or { }).tool or "unset";

  # The emitted design files (C-15, spec-domain-templates). Each entry
  # holds the emitted path, the content source under `assets/design/ddd/`,
  # and the copy mode of the emitted-files table. When the method is
  # `ddd`, each file joins the plan as an `extraFiles` entry whose
  # `source` is a `builtins.toFile` store path of the asset content, and
  # the same store path joins the rendered-source list of the run. When
  # the method is `unset`, the plan holds no design file.
  emittedDesignFiles = [
    {
      rel = "docs/wiki/design/ddd/README.md";
      asset = ../assets/design/ddd/README.md;
      copyMode = "managed";
    }
    {
      rel = "docs/wiki/design/ddd/artifact-driven.md";
      asset = ../assets/design/ddd/artifact-driven.md;
      copyMode = "managed";
    }
    {
      rel = "docs/wiki/design/ddd/templates/domain/README.md";
      asset = ../assets/design/ddd/templates/domain/README.md;
      copyMode = "managed";
    }
    {
      rel = "docs/wiki/design/ddd/templates/domain/context-map.md";
      asset = ../assets/design/ddd/templates/domain/context-map.md;
      copyMode = "managed";
    }
    {
      rel = "docs/wiki/design/ddd/templates/domain/glossary.md";
      asset = ../assets/design/ddd/templates/domain/glossary.md;
      copyMode = "managed";
    }
    {
      rel = "docs/wiki/design/ddd/templates/domain/context-name/README.md";
      asset = ../assets/design/ddd/templates/domain/context-name/README.md;
      copyMode = "managed";
    }
    {
      rel = "docs/wiki/design/ddd/templates/domain/context-name/agg-name.md";
      asset = ../assets/design/ddd/templates/domain/context-name/agg-name.md;
      copyMode = "managed";
    }
    {
      rel = "docs/domain/README.md";
      asset = ../assets/design/ddd/seeds/domain/README.md;
      copyMode = "seed";
    }
    {
      rel = "docs/domain/context-map.md";
      asset = ../assets/design/ddd/seeds/domain/context-map.md;
      copyMode = "seed";
    }
    {
      rel = "docs/domain/glossary.md";
      asset = ../assets/design/ddd/seeds/domain/glossary.md;
      copyMode = "seed";
    }
  ];

  designFiles =
    settings:
    if (settings.design or { }).use or "unset" != "ddd" then
      {
        extraFiles = [ ];
        renderedSources = [ ];
      }
    else
      let
        entries = builtins.map (
          f:
          let
            source = builtins.toFile "design-file" (builtins.readFile f.asset);
          in
          {
            rel = f.rel;
            inherit source;
            copyMode = f.copyMode;
          }
        ) emittedDesignFiles;
      in
      {
        extraFiles = entries;
        renderedSources = builtins.map (e: e.source) entries;
      };

  # The emitted review skill (C-17, spec-review). Takes the evaluated
  # settings and reads the selected harnesses from the agents group. One
  # `.agents/skills/ddd-review/` entry joins the plan when `opencode` or
  # `codex` is selected; one `.claude/skills/ddd-review/` entry joins when
  # `claude` is selected. The plan holds the `.agents/` path one time when
  # `opencode` and `codex` are both selected. Each skill file has the copy
  # mode `managed`. No skill file joins when the method is `unset` or no
  # harness is selected.
  skillFiles =
    settings:
    let
      ddd = (settings.design or { }).use or "unset" == "ddd";
      uses = (settings.agents or { }).uses or [ ];
      source = builtins.toFile "SKILL.md" (builtins.readFile ../assets/design/ddd/skill/SKILL.md);
    in
    if !ddd then
      {
        extraFiles = [ ];
        renderedSources = [ ];
      }
    else
      let
        entries =
          (
            if builtins.elem "opencode" uses || builtins.elem "codex" uses then
              [
                {
                  rel = ".agents/skills/ddd-review/SKILL.md";
                  inherit source;
                  copyMode = "managed";
                }
              ]
            else
              [ ]
          )
          ++ (
            if builtins.elem "claude" uses then
              [
                {
                  rel = ".claude/skills/ddd-review/SKILL.md";
                  inherit source;
                  copyMode = "managed";
                }
              ]
            else
              [ ]
          );
      in
      {
        extraFiles = entries;
        renderedSources = if entries == [ ] then [ ] else [ source ];
      };
in
{
  inherit
    useValues
    toolValues
    designKnownKeys
    designOptions
    uxOptions
    evalDesign
    evalUx
    designAssertions
    chapterMap
    toolFeed
    emittedDesignFiles
    designFiles
    skillFiles
    ;
}
