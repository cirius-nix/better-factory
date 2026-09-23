# services/factory/modules/seed-check.nix
# Seed check (spec-e2e-seed): mkSeedCheck builds the sandboxed derivation.
# The derivation materializes the blueprint in a scratch directory below
# $TMPDIR and runs the five layers in order: layout, arch, facade, copy-mode,
# emit. The result file holds exactly the five green lines, with no
# timestamp, no hostname, and no store path. The derivation needs no network.
# The facade declaration is evaluated here, at derivation build time, against
# the factory module set only; the facade layer of the build script proves
# that the evaluated bytes are the emitted bytes.
{
  pkgs,
  factoryDir,
  arch,
}:
let
  facade = import ./facade.nix;
  filePlan = import ./file-plan.nix;
  copyModes = import ./copy-modes.nix;
  yamlRenderer = import ../lib/yaml.nix;
  orchestration = import ./orchestration.nix;
  harnessLib = orchestration.harness;
  rolesLib = import ../lib/roles.nix;
  design = import ./design.nix;

  facadeSrc =
    if arch == "single" then
      factoryDir + "/assets/base/factory.nix"
    else if arch == "multiple" then
      factoryDir + "/assets/overlays/multiple/factory.nix"
    else
      throw "arch-value: the key `arch` must be `single` or `multiple`, got `${arch}`";

  settings = facade.evalFactory (import facadeSrc);

  archMatch =
    if settings.arch == arch then
      true
    else
      throw "arch-value: the declaration selects `${settings.arch}`, the check runs `${arch}`";

  # The starter declaration of each arch holds the group `agents` and
  # selects no harness (spec-harness-merge point 7). The modeled-key list
  # and the root option definitions hold `agents` (C-05); evalFactory above
  # already enforces their agreement.
  agentsMatch =
    if settings.agents.uses or null == [ ] && builtins.elem "agents" facade.modeledKeys then
      true
    else
      throw "seed check: the starter declaration of `${arch}` must hold the group `agents` with `uses = [ ]`";

  # The starter declaration of each arch holds the group `design` with the
  # keys `use` and `tool` and the key `ux` (spec-design-option,
  # spec-designer-role, C-16). The fixture proves the group keys, the flag,
  # and the modeled-key list with one assertion per invariant.
  designFixture = design.designAssertions settings facade.modeledKeys;
  designFailing = builtins.filter (a: !a.assertion) designFixture;
  designMatch =
    if designFailing == [ ] then
      true
    else
      throw "seed check: the starter declaration of `${arch}` fails ${(builtins.head designFailing).message}";

  # Chapter map fixture (spec-design-option, spec-designer-role, C-13): one
  # fixture with the method `ddd`, one with the method `ddd` and the flag
  # true, and one with the method `unset`. The chapter map of the role set
  # goes to the render. The fixture proves the DDD chapter placement, the
  # UX chapter placement and order, the headings, the codex body, the five
  # phases, and the empty list of an absent role name.
  chapterRoles = {
    requirement-expert = {
      description = "requirement expert fixture";
      source = factoryDir + "/assets/roles/requirement-expert/ROLE.md";
    };
    solution-expert = {
      description = "solution expert fixture";
      source = factoryDir + "/assets/roles/solution-expert/ROLE.md";
    };
    artifact-master = {
      description = "artifact master fixture";
      source = factoryDir + "/assets/roles/artifact-master/ROLE.md";
    };
    artifact-release-expert = {
      description = "artifact release expert fixture";
      source = factoryDir + "/assets/roles/artifact-release-expert/ROLE.md";
    };
  };
  dddSettings = {
    design = {
      use = "ddd";
      tool = "unset";
    };
    ux = false;
  };
  dddUxSettings = {
    design = {
      use = "ddd";
      tool = "unset";
    };
    ux = true;
  };
  unsetSettings = {
    design = {
      use = "unset";
      tool = "unset";
    };
    ux = false;
  };
  flatten = s: builtins.replaceStrings [ "\n" ] [ " " ] s;
  fileByRel = decls: rel: builtins.head (builtins.filter (d: d.rel == rel) decls);
  contentOf = rendered: rel: builtins.readFile (fileByRel rendered.fileDecls rel).source;
  hasDdd = content: builtins.match ".*## Domain-Driven Design.*" (flatten content) != null;
  hasUx = content: builtins.match ".*## UX Design.*" (flatten content) != null;
  dddBeforeUx =
    content: builtins.match ".*## Domain-Driven Design.*## UX Design.*" (flatten content) != null;
  renderedDdd = rolesLib.renderRoles {
    roles = chapterRoles;
    uses = [
      "opencode"
      "codex"
    ];
    chapterMap = design.chapterMap dddSettings;
  };
  renderedDddUx = rolesLib.renderRoles {
    roles = chapterRoles;
    uses = [
      "opencode"
      "codex"
    ];
    chapterMap = design.chapterMap dddUxSettings;
  };
  renderedUnset = rolesLib.renderRoles {
    roles = chapterRoles;
    uses = [
      "opencode"
      "codex"
    ];
    chapterMap = design.chapterMap unsetSettings;
  };
  renderedBare = rolesLib.renderRoles {
    roles = chapterRoles;
    uses = [ "opencode" ];
    chapterMap = { };
  };
  reqSource = builtins.readFile (factoryDir + "/assets/roles/requirement-expert/ROLE.md");
  bareExpected = rolesLib.composeBody reqSource [ ];
  bareContent = contentOf renderedBare ".opencode/agents/requirement-expert.md";
  endsWith =
    s: suffix:
    builtins.substring (
      builtins.stringLength s - builtins.stringLength suffix
    ) (builtins.stringLength suffix) s == suffix;
  dddReqChapter = builtins.readFile (
    factoryDir + "/assets/design/ddd/chapters/requirement-expert.md"
  );
  dddSolChapter = builtins.readFile (factoryDir + "/assets/design/ddd/chapters/solution-expert.md");
  uxMasterChapter = builtins.readFile (factoryDir + "/assets/design/ux/chapters/artifact-master.md");
  uxSolChapter = builtins.readFile (factoryDir + "/assets/design/ux/chapters/solution-expert.md");
  uxReleaseChapter = builtins.readFile (
    factoryDir + "/assets/design/ux/chapters/artifact-release-expert.md"
  );
  startsWith = s: prefix: builtins.substring 0 (builtins.stringLength prefix) s == prefix;
  chapterAssertions = [
    {
      name = "ddd-requirement";
      assertion = hasDdd (contentOf renderedDdd ".opencode/agents/requirement-expert.md");
      message = "ddd-requirement: the `ddd` fixture holds no DDD chapter in requirement-expert";
    }
    {
      name = "ddd-solution";
      assertion = hasDdd (contentOf renderedDdd ".opencode/agents/solution-expert.md");
      message = "ddd-solution: the `ddd` fixture holds no DDD chapter in solution-expert";
    }
    {
      name = "ddd-only";
      assertion =
        !(hasDdd (contentOf renderedDdd ".opencode/agents/artifact-master.md"))
        && !(hasDdd (contentOf renderedDdd ".opencode/agents/artifact-release-expert.md"));
      message = "ddd-only: the `ddd` fixture holds a DDD chapter outside requirement-expert and solution-expert";
    }
    {
      name = "ddd-ux-order";
      assertion = dddBeforeUx (contentOf renderedDddUx ".opencode/agents/solution-expert.md");
      message = "ddd-ux-order: the `ddd` fixture with the flag true holds no DDD chapter first and UX chapter second in solution-expert";
    }
    {
      name = "ddd-ux-master";
      assertion =
        hasUx (contentOf renderedDddUx ".opencode/agents/artifact-master.md")
        && !(hasDdd (contentOf renderedDddUx ".opencode/agents/artifact-master.md"));
      message = "ddd-ux-master: the `ddd` fixture with the flag true holds no UX chapter only in artifact-master";
    }
    {
      name = "ddd-ux-release";
      assertion =
        hasUx (contentOf renderedDddUx ".opencode/agents/artifact-release-expert.md")
        && !(hasDdd (contentOf renderedDddUx ".opencode/agents/artifact-release-expert.md"));
      message = "ddd-ux-release: the `ddd` fixture with the flag true holds no UX chapter only in artifact-release-expert";
    }
    {
      name = "unset-chapters";
      assertion =
        !(hasDdd (contentOf renderedUnset ".opencode/agents/requirement-expert.md"))
        && !(hasDdd (contentOf renderedUnset ".opencode/agents/solution-expert.md"))
        && !(hasUx (contentOf renderedUnset ".opencode/agents/artifact-master.md"))
        && !(hasUx (contentOf renderedUnset ".opencode/agents/solution-expert.md"));
      message = "unset-chapters: the `unset` fixture holds a DDD chapter or a UX chapter";
    }
    {
      name = "chapter-headings";
      assertion =
        startsWith dddReqChapter "## Domain-Driven Design"
        && startsWith dddSolChapter "## Domain-Driven Design"
        && startsWith uxMasterChapter "## UX Design"
        && startsWith uxSolChapter "## UX Design"
        && startsWith uxReleaseChapter "## UX Design";
      message = "chapter-headings: a chapter file starts without the heading `## Domain-Driven Design` or `## UX Design`";
    }
    {
      name = "codex-body";
      assertion =
        let
          codex = contentOf renderedDdd ".codex/agents/solution-expert.toml";
        in
        builtins.match ".*developer_instructions.*" (flatten codex) != null && hasDdd codex;
      message = "codex-body: the codex file holds no composed body with the chapters of the map in `developer_instructions`";
    }
    {
      name = "five-phases";
      assertion = builtins.all (t: builtins.match ".*([Pp]hase 6|sixth phase).*" (flatten t) == null) [
        dddReqChapter
        dddSolChapter
        uxMasterChapter
        uxSolChapter
        uxReleaseChapter
      ];
      message = "five-phases: a chapter adds a sixth phase";
    }
    {
      name = "absent-role";
      assertion = endsWith bareContent bareExpected && !(hasDdd bareContent) && !(hasUx bareContent);
      message = "absent-role: a role without a key in the chapter map holds more than the role source";
    }
  ];
  chapterFailing = builtins.filter (a: !a.assertion) chapterAssertions;
  chapterMatch =
    if chapterFailing == [ ] then
      true
    else
      throw "seed check: the chapter fixture of `${arch}` fails ${(builtins.head chapterFailing).message}";

  # Tool feed fixture (spec-designer-scope, C-14): one fixture with the
  # tool `figma` and one fixture with the tool `unset`. The `unset`
  # fixture declares the entry `mcp.figma`. The fixture proves the
  # selected entry default, the unselected entry default, the layer
  # overrides with last-layer-wins, the managed fields with one log line,
  # and that no gate reads the tool.
  toolFig = harnessLib.mergeMcp null null "figma";
  toolUnsetFig = harnessLib.mergeMcp { figma = { }; } null "unset";
  toolMixedFig = harnessLib.mergeMcp { pencil = { }; } null "figma";
  toolProjOff = harnessLib.mergeMcp {
    figma = {
      enabled = false;
    };
  } null "figma";
  toolLocalOn =
    harnessLib.mergeMcp
      {
        figma = {
          enabled = false;
        };
      }
      {
        figma = {
          enabled = true;
        };
      }
      "figma";
  toolCmdOver = harnessLib.mergeMcp {
    figma = {
      command = "other";
    };
  } null "figma";
  toolAgentsFig = harnessLib.mergeAgents {
    project = orchestration.evalAgents { uses = [ ]; };
    tool = "figma";
  };
  toolPlanFor = tool: filePlan.planForArch { inherit arch factoryDir; };
  toolPlansSame =
    let
      a = builtins.attrNames (toolPlanFor "unset").files;
      b = builtins.attrNames (toolPlanFor "figma").files;
      c = builtins.attrNames (toolPlanFor "pencil").files;
    in
    builtins.sort builtins.lessThan a == builtins.sort builtins.lessThan b
    && builtins.sort builtins.lessThan b == builtins.sort builtins.lessThan c;
  toolAssertions = [
    {
      name = "tool-selected";
      assertion =
        toolFig.entries.figma.enabled == true
        && toolFig.entries.figma.command == "npx"
        &&
          toolFig.entries.figma.args == [
            "-y"
            "figma-ui-mcp"
          ]
        && toolFig.entries.figma.env.FIGMA_UI_MCP_TARGET == "Figma Desktop";
      message = "tool-selected: the `figma` fixture holds no canonical `figma` entry with `enabled = true`";
    }
    {
      name = "tool-unselected";
      assertion =
        toolUnsetFig.entries.figma.command == "npx"
        &&
          toolUnsetFig.entries.figma.args == [
            "-y"
            "figma-ui-mcp"
          ]
        && toolUnsetFig.entries.figma.env.FIGMA_UI_MCP_TARGET == "Figma Desktop"
        && toolUnsetFig.entries.figma.enabled == false;
      message = "tool-unselected: the `unset` fixture holds no declared canonical `figma` entry with `enabled = false`";
    }
    {
      name = "tool-mixed";
      assertion =
        toolMixedFig.entries.pencil.enabled == false && toolMixedFig.entries.figma.enabled == true;
      message = "tool-mixed: a canonical entry that the tool does not select holds no `enabled = false`";
    }
    {
      name = "tool-project-wins";
      assertion = toolProjOff.entries.figma.enabled == false;
      message = "tool-project-wins: a project value of `enabled = false` loses over the tool selection";
    }
    {
      name = "tool-local-wins";
      assertion = toolLocalOn.entries.figma.enabled == true;
      message = "tool-local-wins: a local value of `enabled` loses over the project value and the tool selection";
    }
    {
      name = "tool-managed";
      assertion =
        toolCmdOver.entries.figma.command == "npx"
        && toolCmdOver.traces == [ "managed-wins: mcp.figma.command from project" ];
      message = "tool-managed: a project value of a managed field wins or keeps no log line";
    }
    {
      name = "tool-agents";
      assertion = toolAgentsFig.mcp.figma.enabled == true;
      message = "tool-agents: the merged entry set of the agents merge holds no selected `figma` entry";
    }
    {
      name = "tool-gates";
      assertion = toolPlansSame;
      message = "tool-gates: a gate reads `design.tool`; the plan differs with the tool value";
    }
  ];
  toolFailing = builtins.filter (a: !a.assertion) toolAssertions;
  toolMatch =
    if toolFailing == [ ] then
      true
    else
      throw "seed check: the tool fixture of `${arch}` fails ${(builtins.head toolFailing).message}";

  # Design asset fixture (spec-domain-templates, spec-review, C-15, C-17,
  # C-19): one fixture with the method `ddd` and one fixture with the
  # method `unset`. The fixture proves each file of the emitted-files
  # table with its content source and its copy mode, the rendered sources,
  # the harness gate with the one-time `.agents/` path, the absence of a
  # direct asset path, and the empty plan of the `unset` fixture. The
  # review check reads the skill source and proves the frontmatter, the
  # required sections, the four report fields, the review-only rule, the
  # designer-ownership check, the phase owners, and the guide and phase
  # mapping content.
  contains = text: needle: builtins.replaceStrings [ needle ] [ "" ] text != text;
  pairsOk =
    text: needles:
    let
      f = flatten text;
      go =
        xs:
        if builtins.length xs < 2 then
          true
        else
          builtins.match (".*" + builtins.head xs + ".*" + builtins.elemAt xs 1 + ".*") f != null
          && go (builtins.tail xs);
    in
    go needles;
  assetPlanSettings = {
    design = {
      use = "ddd";
      tool = "unset";
    };
    agents = {
      uses = [
        "opencode"
        "codex"
      ];
    };
    ux = false;
  };
  assetDesignOut = design.designFiles assetPlanSettings;
  assetSkillOut = design.skillFiles assetPlanSettings;
  assetPlan = filePlan.planForArch {
    inherit arch factoryDir;
    extraFiles = assetDesignOut.extraFiles ++ assetSkillOut.extraFiles;
    renderedSources = assetDesignOut.renderedSources ++ assetSkillOut.renderedSources;
  };
  assetClaudeOut = design.skillFiles (
    assetPlanSettings
    // {
      agents = {
        uses = [ "claude" ];
      };
    }
  );
  unsetPlanSettings = {
    design = {
      use = "unset";
      tool = "unset";
    };
    agents = {
      uses = [ "opencode" ];
    };
    ux = false;
  };
  unsetDesignOut = design.designFiles unsetPlanSettings;
  unsetSkillOut = design.skillFiles unsetPlanSettings;
  agentsSkillRels = builtins.filter (
    e: e.rel == ".agents/skills/ddd-review/SKILL.md"
  ) assetSkillOut.extraFiles;
  claudeSkillRels = builtins.filter (
    e: e.rel == ".claude/skills/ddd-review/SKILL.md"
  ) assetClaudeOut.extraFiles;
  agentsSkillRelsClaude = builtins.filter (
    e: e.rel == ".agents/skills/ddd-review/SKILL.md"
  ) assetClaudeOut.extraFiles;
  directAssetRejected =
    (builtins.tryEval (
      filePlan.checkSourceAllowed {
        inherit arch;
        baseDir = factoryDir + "/assets/base";
        overlayDir = factoryDir + "/assets/overlays/${arch}";
        renderedSources = [ ];
        rel = "docs/wiki/design/ddd/README.md";
        source = factoryDir + "/assets/design/ddd/README.md";
      }
    )).success == false;
  guideText = builtins.readFile ../assets/design/ddd/README.md;
  phaseText = builtins.readFile ../assets/design/ddd/artifact-driven.md;
  skillText = builtins.readFile ../assets/design/ddd/skill/SKILL.md;
  skillFlat = flatten skillText;
  assetAssertions = [
    {
      name = "emitted-table";
      assertion = builtins.all (
        f:
        builtins.hasAttr f.rel assetPlan.files
        && assetPlan.files.${f.rel}.copyMode == f.copyMode
        && builtins.elem (toString assetPlan.files.${f.rel}.source) (
          builtins.map toString assetDesignOut.renderedSources
        )
      ) design.emittedDesignFiles;
      message = "emitted-table: the `ddd` fixture misses a file of the emitted-files table with its content source and copy mode";
    }
    {
      name = "skill-agents-once";
      assertion =
        builtins.length agentsSkillRels == 1
        && (builtins.head agentsSkillRels).copyMode == "managed"
        && builtins.elem (toString (builtins.head agentsSkillRels).source) (
          builtins.map toString assetSkillOut.renderedSources
        );
      message = "skill-agents-once: the `.agents/` skill path appears never or more than one time";
    }
    {
      name = "skill-claude";
      assertion =
        builtins.length claudeSkillRels == 1
        && agentsSkillRelsClaude == [ ]
        && (builtins.head claudeSkillRels).copyMode == "managed";
      message = "skill-claude: the `claude` fixture holds no `.claude/` skill file only";
    }
    {
      name = "unset-empty";
      assertion = unsetDesignOut.extraFiles == [ ] && unsetSkillOut.extraFiles == [ ];
      message = "unset-empty: the `unset` fixture holds a design file or a skill file";
    }
    {
      name = "no-direct-asset";
      assertion = directAssetRejected;
      message = "no-direct-asset: the file-plan check accepts a direct source under `assets/design/ddd/`";
    }
    {
      name = "guide-sections";
      assertion = pairsOk guideText [
        "# Domain-Driven Design"
        "## Strategic design"
        "### Subdomains"
        "### Bounded contexts"
        "### Ubiquitous language"
        "### Context map"
        "## Tactical design"
        "## Where a context lives"
        "## Select the implementation pattern"
        "## The domain model"
        "## Procedure: add a bounded context"
      ];
      message = "guide-sections: the guide misses a required section of spec-domain-templates point 7 or breaks the order";
    }
    {
      name = "phase-columns";
      assertion =
        contains phaseText "| Phase | Owner | DDD step | Output |"
        && pairsOk phaseText [
          "1 Requirements"
          "2 Specifications"
          "3 Plan"
          "4 Implementation"
          "5 Version"
        ];
      message = "phase-columns: the phase mapping page misses the columns or the five phases";
    }
    {
      name = "skill-frontmatter";
      assertion = startsWith skillText "---\nname: ddd-review\n";
      message = "skill-frontmatter: the skill source misses the frontmatter fields `name` and `description`";
    }
    {
      name = "skill-sections";
      assertion = pairsOk skillText [
        "## When to use"
        "## Read first"
        "## Procedure"
        "## Checks"
        "## Report"
        "## Rules"
      ];
      message = "skill-sections: the skill source misses a required section or breaks the order";
    }
    {
      name = "skill-report";
      assertion =
        contains skillFlat "| Artifact |"
        && pairsOk skillFlat [
          "Artifact"
          "Failed rule"
          "Evidence"
          "Owner"
        ];
      message = "skill-report: the skill source misses the four report fields";
    }
    {
      name = "skill-review-only";
      assertion = contains skillFlat "Write no artifact";
      message = "skill-review-only: the skill source misses the review-only rule";
    }
    {
      name = "skill-designer-check";
      assertion = contains skillFlat "never the designer";
      message = "skill-designer-check: the skill source misses the designer-ownership check";
    }
    {
      name = "skill-owners";
      assertion =
        contains skillFlat "phase 1 finding is the requirement expert"
        && contains skillFlat "phase 2 or a phase 3 finding is the solution expert";
      message = "skill-owners: the skill source misses the phase owners";
    }
  ];
  assetFailing = builtins.filter (a: !a.assertion) assetAssertions;
  assetMatch =
    if assetFailing == [ ] then
      true
    else
      throw "seed check: the asset fixture of `${arch}` fails ${(builtins.head assetFailing).message}";

  # Designer fixture (spec-designer-scope, spec-designer-role, C-18): one
  # fixture with the ux flag true and one fixture with the flag false. The
  # fixture proves the designer-expert file of each selected harness, the
  # managed mode, the reserved-name failure, the factory-injected
  # declaration, the rendered body statements, the no-subagent rule, and
  # the UX chapter of the role map.
  uxFixtureRoles = {
    artifact-master = {
      description = "artifact master fixture";
      source = factoryDir + "/assets/roles/artifact-master/ROLE.md";
    };
    solution-expert = {
      description = "solution expert fixture";
      source = factoryDir + "/assets/roles/solution-expert/ROLE.md";
    };
    artifact-release-expert = {
      description = "artifact release expert fixture";
      source = factoryDir + "/assets/roles/artifact-release-expert/ROLE.md";
    };
  };
  uxProject = orchestration.evalAgents {
    uses = [
      "opencode"
      "claude"
      "codex"
    ];
    roles = uxFixtureRoles;
  };
  uxMergedTrue = harnessLib.mergeAgents {
    project = uxProject;
    roleNames = [
      "artifact-master"
      "designer-expert"
    ];
    tool = "unset";
    ux = true;
  };
  uxMergedFalse = harnessLib.mergeAgents {
    project = uxProject;
    roleNames = [ "artifact-master" ];
    tool = "unset";
    ux = false;
  };
  uxSettingsTrue = {
    design = {
      use = "unset";
      tool = "unset";
    };
    ux = true;
  };
  uxRenderTrue = rolesLib.renderRoles {
    roles = uxMergedTrue.roles;
    uses = [
      "opencode"
      "claude"
      "codex"
    ];
    chapterMap = design.chapterMap uxSettingsTrue;
  };
  uxRenderOne = rolesLib.renderRoles {
    roles = uxMergedTrue.roles;
    uses = [ "opencode" ];
    chapterMap = design.chapterMap uxSettingsTrue;
  };
  uxRenderFalse = rolesLib.renderRoles {
    roles = uxMergedFalse.roles;
    uses = [
      "opencode"
      "claude"
      "codex"
    ];
    chapterMap = design.chapterMap unsetSettings;
  };
  uxSelectedTrue = harnessLib.renderSelected {
    merged = uxMergedTrue;
    uses = [
      "opencode"
      "claude"
      "codex"
    ];
    agentsFragment = uxRenderTrue.agentsFragment;
  };
  uxFileByRel = decls: rel: builtins.head (builtins.filter (d: d.rel == rel) decls);
  uxHasRel = decls: rel: builtins.any (d: d.rel == rel) decls;
  uxDesignerOpencode = builtins.readFile (uxFileByRel uxRenderTrue.fileDecls ".opencode/agents/designer-expert.md")
  .source;
  uxDesignerFlat = flatten uxDesignerOpencode;
  uxReservedProject = builtins.tryEval (
    orchestration.evalAgents {
      uses = [ ];
      roles = {
        designer-expert = {
          description = "user declaration fixture";
          source = factoryDir + "/assets/roles/artifact-master/ROLE.md";
        };
      };
    }
  );
  uxReservedLocalFile = builtins.toFile "devenv.local.nix" ''
    { factory.local.agents = { roles = { designer-expert = { description = "user declaration fixture"; source = ${factoryDir}/assets/roles/artifact-master/ROLE.md; }; }; }; }
  '';
  uxReservedLocal = builtins.tryEval (orchestration.readLocalAgents uxReservedLocalFile);
  uxOpencodeJson = builtins.fromJSON (
    builtins.readFile (uxFileByRel uxSelectedTrue.fileDecls ".opencode/opencode.jsonc").source
  );
  uxCodexConfig = flatten (
    builtins.readFile (uxFileByRel uxSelectedTrue.fileDecls ".codex/config.toml").source
  );
  uxAssertions = [
    {
      name = "reserved-project";
      assertion = uxReservedProject.success == false;
      message = "reserved-project: a project declaration of the name `designer-expert` passes evaluation";
    }
    {
      name = "reserved-local";
      assertion = uxReservedLocal.success == false;
      message = "reserved-local: a local declaration of the name `designer-expert` passes evaluation";
    }
    {
      name = "designer-harness";
      assertion =
        builtins.all (rel: uxHasRel uxRenderTrue.fileDecls rel) [
          ".opencode/agents/designer-expert.md"
          ".claude/agents/designer-expert.md"
          ".codex/agents/designer-expert.toml"
        ]
        && builtins.all (d: d.copyMode == "managed") (
          builtins.filter (d: builtins.match ".*designer-expert.*" d.rel != null) uxRenderTrue.fileDecls
        );
      message = "designer-harness: the ux-true fixture misses a designer-expert file of a selected harness or its mode";
    }
    {
      name = "designer-one";
      assertion =
        uxHasRel uxRenderOne.fileDecls ".opencode/agents/designer-expert.md"
        && !(uxHasRel uxRenderOne.fileDecls ".claude/agents/designer-expert.md")
        && !(uxHasRel uxRenderOne.fileDecls ".codex/agents/designer-expert.toml");
      message = "designer-one: the ux-true fixture with one selected harness writes a file for an unselected harness";
    }
    {
      name = "designer-absent";
      assertion =
        !(builtins.any (d: builtins.match ".*designer-expert.*" d.rel != null) uxRenderFalse.fileDecls);
      message = "designer-absent: the ux-false fixture holds a designer-expert file";
    }
    {
      name = "designer-body";
      assertion =
        contains uxDesignerFlat "design/README.md"
        && contains uxDesignerFlat "## UX"
        && contains uxDesignerFlat "## Layout"
        && contains uxDesignerFlat "## Interaction"
        && contains uxDesignerFlat "## Components"
        && contains uxDesignerFlat "## Design System"
        && contains uxDesignerFlat "never own a business rule"
        && contains uxDesignerFlat "aids you only";
      message = "designer-body: the rendered body misses the Design artifact path, the sections, the boundary, or the tool rule";
    }
    {
      name = "designer-no-subagent";
      assertion =
        contains uxDesignerFlat "call no subagent and directly task no"
        && contains uxDesignerFlat "directly task no expert";
      message = "designer-no-subagent: the rendered body misses the no-subagent rule";
    }
    {
      name = "designer-injected";
      assertion =
        (uxMergedTrue.roles.designer-expert.description or "") == harnessLib.designerBuiltIn.description
        && builtins.pathExists (uxMergedTrue.roles.designer-expert.source or "/nonexistent");
      message = "designer-injected: the factory-injected declaration misses the description or the role source";
    }
    {
      name = "designer-permission";
      assertion = uxOpencodeJson.agent."designer-expert".permission.task == "deny";
      message = "designer-permission: `.opencode/opencode.jsonc` holds no `agent.designer-expert.permission.task = \"deny\"`";
    }
    {
      name = "designer-ux-chapter";
      assertion =
        hasUx (contentOf uxRenderTrue ".opencode/agents/artifact-master.md")
        && hasUx (contentOf uxRenderTrue ".opencode/agents/solution-expert.md")
        && hasUx (contentOf uxRenderTrue ".opencode/agents/artifact-release-expert.md");
      message = "designer-ux-chapter: the ux-true fixture misses the UX chapter in a role of the UX chapter map";
    }
    {
      name = "designer-codex";
      assertion = contains uxCodexConfig "designer-expert" && contains uxCodexConfig "config_file";
      message = "designer-codex: `.codex/config.toml` holds no `agents.designer-expert` entry with the description and `config_file`";
    }
  ];
  uxFailing = builtins.filter (a: !a.assertion) uxAssertions;
  uxMatch =
    if uxFailing == [ ] then
      true
    else
      throw "seed check: the designer fixture of `${arch}` fails ${(builtins.head uxFailing).message}";

  # Log check fixture (C-12): one managed key set in the project layer and
  # in the local layer. Forcing the merge writes one pinned line per ignored
  # value to the standard error of the evaluation. The result file of the
  # seed check stays exactly five lines; the trace never enters the result
  # file or the layer logs.
  logFixtureLocalFile = builtins.toFile "devenv.local.nix" ''
    { factory.local.agents = { uses = [ "opencode" ]; opencode = { extraSubagent_depth = 9; }; }; }
  '';
  logFixture = harnessLib.mergeAgents {
    project = orchestration.evalAgents {
      uses = [ "opencode" ];
      opencode = {
        extraSubagent_depth = 5;
      };
    };
    local = orchestration.readLocalAgents logFixtureLocalFile;
    roleNames = [ "artifact-master" ];
    tool = design.toolFeed settings;
  };
  logFixtureDepth = logFixture.opencode.subagent_depth == 1;

  modes = {
    ".gitignore" = "managed";
    ".markdownlint.yaml" = "managed";
    "docs/wiki/repo-arch/single-repository.md" = "managed";
    "docs/wiki/repo-arch/multiple-repositories.md" = "managed";
    "e2e/README.md" = "managed";
    "factory.config.yaml" = "template";
  };

  plan = filePlan.planForArch {
    inherit arch factoryDir modes;
    renderedSources = [ configYaml ] ++ designOut.renderedSources ++ skillOut.renderedSources;
    extraFiles = [
      {
        rel = "factory.config.yaml";
        source = configYaml;
        copyMode = "template";
      }
    ]
    ++ designOut.extraFiles
    ++ skillOut.extraFiles;
  };

  # The design files and the skill file join the one transaction that
  # holds the base files, the overlay files, the role files, the MCP
  # files, and the skill file (C-15, C-17). The starter selects the method
  # `unset`, so the starter plan holds no design file and no skill file.
  designOut = design.designFiles settings;
  skillOut = design.skillFiles settings;

  configYaml = builtins.toFile "factory.config.yaml" (
    yamlRenderer.renderYaml {
      advanced = settings.advanced;
      arch = settings.arch;
      secrets = settings.secrets;
    }
  );

  files = plan.files;

  paths = builtins.attrNames files;

  expectedOverlay =
    if arch == "single" then
      [ "docs/wiki/repo-arch/single-repository.md" ]
    else
      [
        "docs/wiki/repo-arch/multiple-repositories.md"
        "e2e/README.md"
        "factory.nix"
      ];

  inactiveMarkers =
    if arch == "single" then
      [
        "docs/wiki/repo-arch/multiple-repositories.md"
        "e2e/README.md"
      ]
    else
      [ "docs/wiki/repo-arch/single-repository.md" ];

  foundation = import ./foundation.nix;

  evalAssertions =
    let
      baseCovered = builtins.all (rel: builtins.elem rel paths) plan.baseFiles;
      baseGitignore = builtins.elem ".gitignore" plan.baseFiles;
      oneOverlay =
        builtins.sort builtins.lessThan plan.overlayFiles
        == builtins.sort builtins.lessThan expectedOverlay;
      inactiveAbsent = builtins.all (rel: !(builtins.elem rel paths)) inactiveMarkers;
      starterCovered = builtins.all (rel: builtins.elem rel paths) foundation.layout.starterFiles;
    in
    if !baseCovered then
      throw "seed check: the file plan of `${arch}` misses a base file"
    else if !baseGitignore then
      throw "seed check: the file plan of `${arch}` misses the base file `.gitignore`"
    else if !oneOverlay then
      throw "seed check: the file plan of `${arch}` holds ${builtins.toJSON plan.overlayFiles}"
    else if !inactiveAbsent then
      throw "seed check: the file plan of `${arch}` holds the inactive overlay"
    else if !starterCovered then
      throw "seed check: the emitted starter tree of `${arch}` misses a layout file"
    else
      true;

  proof = builtins.toFile "facade-proof" "green";

  manifest = pkgs.writeText "plan-manifest" (copyModes.manifestText files);

  lintBin = pkgs.nodePackages.markdownlint-cli + "/bin/markdownlint";
in
assert archMatch;
assert agentsMatch;
assert designMatch;
assert chapterMatch;
assert toolMatch;
assert assetMatch;
assert uxMatch;
assert logFixtureDepth;
assert evalAssertions;
pkgs.stdenv.mkDerivation {
  name = "seed-check-${arch}";
  buildCommand = ''
    export MANIFEST=${manifest} WORK=$TMPDIR/work OUT=$TMPDIR/output ARCH=${arch}
    export SCRIPT_DIR=${factoryDir}/scripts COPY_STEP=${factoryDir}/scripts/copy-step.sh
    export LINT_BIN=${lintBin} LINT_CONFIG=${factoryDir}/assets/base/.markdownlint.yaml
    export PROOF=${proof} FACTORY_SRC=${facadeSrc}
    sh ${factoryDir}/scripts/seed-check.sh
    mkdir -p $out
    cp $TMPDIR/output $out/output
  '';
}
