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
  delivery = import ./delivery.nix;

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

  # Delivery fixture (feat-delivery task-delivery-facade): the starter
  # declaration of each arch holds the four groups and the key preset with
  # the off values. One assertion per invariant proves the group keys, each
  # value set, the duplicate rule of notify.uses, and the modeled-key list.
  deliveryFixture = delivery.deliveryAssertions settings facade.modeledKeys;
  deliveryFailing = builtins.filter (a: !a.assertion) deliveryFixture;
  deliveryStarterMatch =
    if
      (settings.preset or null) == "minimal"
      && (settings.ci.use or "other") == "unset"
      && (settings.site.enable or null) == false
      && (settings.notify.uses or null) == [ ]
    then
      true
    else
      throw "seed check: the starter declaration of `${arch}` must hold preset = \"minimal\", ci.use = \"unset\", site.enable = false, and notify.uses = [ ]";
  deliveryMatch =
    if deliveryFailing == [ ] then
      deliveryStarterMatch
    else
      throw "seed check: the starter declaration of `${arch}` fails ${(builtins.head deliveryFailing).message}";

  # Chapter map fixture (spec-design-option, spec-designer-role, C-13): one
  # fixture with the method `ddd`, one with the method `ddd` and the flag
  # true, and one with the method `unset`. The chapter map of the role set
  # goes to the render. The fixture proves the DDD chapter placement, the
  # UX chapter placement and order, the headings, the five
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
    uses = [ "opencode" ];
    chapterMap = design.chapterMap dddSettings;
  };
  renderedDddUx = rolesLib.renderRoles {
    roles = chapterRoles;
    uses = [ "opencode" ];
    chapterMap = design.chapterMap dddUxSettings;
  };
  renderedUnset = rolesLib.renderRoles {
    roles = chapterRoles;
    uses = [ "opencode" ];
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
      uses = [ "opencode" ];
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
  designText = builtins.readFile ./design.nix;
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
      name = "unset-empty";
      assertion = unsetDesignOut.extraFiles == [ ] && unsetSkillOut.extraFiles == [ ];
      message = "unset-empty: the `unset` fixture holds a design file or a skill file";
    }
    {
      name = "skill-branch-opencode-only";
      assertion =
        !(contains designText "builtins.elem \"codex\"")
        && !(contains designText ".claude/skills/ddd-review/SKILL.md");
      message = "skill-branch-opencode-only: the skill branch holds a superseded harness item";
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
    uses = [ "opencode" ];
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
    uses = [ "opencode" ];
    chapterMap = design.chapterMap uxSettingsTrue;
  };
  uxRenderOne = rolesLib.renderRoles {
    roles = uxMergedTrue.roles;
    uses = [ "opencode" ];
    chapterMap = design.chapterMap uxSettingsTrue;
  };
  uxRenderFalse = rolesLib.renderRoles {
    roles = uxMergedFalse.roles;
    uses = [ "opencode" ];
    chapterMap = design.chapterMap unsetSettings;
  };
  uxSelectedTrue = harnessLib.renderSelected {
    merged = uxMergedTrue;
    uses = [ "opencode" ];
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
        uxHasRel uxRenderTrue.fileDecls ".opencode/agents/designer-expert.md"
        && builtins.all (d: d.copyMode == "managed") (
          builtins.filter (d: builtins.match ".*designer-expert.*" d.rel != null) uxRenderTrue.fileDecls
        );
      message = "designer-harness: the ux-true fixture misses the opencode designer-expert file or its mode";
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
      assertion =
        uxOpencodeJson.agents."designer-expert".permissions == [
          {
            action = "subagent";
            resource = "*";
            effect = "deny";
          }
        ];
      message = "designer-permission: `.opencode/opencode.jsonc` holds no `agents.\"designer-expert\".permissions` rule with `effect = \"deny\"`";
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
      name = "harness-plural";
      assertion =
        (uxOpencodeJson.agents."artifact-master".permissions or null) == [
          {
            action = "subagent";
            resource = "*";
            effect = "allow";
          }
        ]
        && !(uxOpencodeJson ? agent)
        && !(uxOpencodeJson ? permission)
        && !(uxOpencodeJson ? subagent_depth);
      message = "harness-plural: `.opencode/opencode.jsonc` misses the plural key `agents` with the ordered array `permissions`, or it holds a singular key `agent`, a singular key `permission`, or `subagent_depth`";
    }
    {
      name = "selected-files";
      assertion = builtins.all (
        rel:
        builtins.match ".*\\.claude/.*" rel == null
        && builtins.match ".*\\.mcp\\.json" rel == null
        && builtins.match ".*\\.codex/.*" rel == null
      ) (builtins.map (d: d.rel) uxSelectedTrue.fileDecls);
      message = "selected-files: the file declaration list of the selected-harness fixture holds a `.claude/` path, a `.mcp.json` path, or a `.codex/` path";
    }
  ];
  uxFailing = builtins.filter (a: !a.assertion) uxAssertions;
  uxMatch =
    if uxFailing == [ ] then
      true
    else
      throw "seed check: the designer fixture of `${arch}` fails ${(builtins.head uxFailing).message}";

  # Log check fixture (C-12, C-F03, C-F04): one managed key set in the
  # project layer and in the local layer. Forcing the merge writes one
  # pinned line per ignored value to the standard error of the evaluation.
  # The result file of the seed check stays exactly five lines; the trace
  # never enters the result file or the layer logs.
  logFixtureLocalFile = builtins.toFile "devenv.local.nix" ''
    { factory.local.agents = { uses = [ "opencode" ]; opencode = { extraAgents = { artifact-master = { permissions = "custom"; }; }; }; }; }
  '';
  logFixture = harnessLib.mergeAgents {
    project = orchestration.evalAgents {
      uses = [ "opencode" ];
      opencode = {
        extraAgents = {
          artifact-master = {
            permissions = "custom";
          };
        };
      };
    };
    local = orchestration.readLocalAgents logFixtureLocalFile;
    roleNames = [ "artifact-master" ];
    tool = design.toolFeed settings;
  };
  logFixturePermissions =
    logFixture.opencode.agents."artifact-master".permissions == [
      {
        action = "subagent";
        resource = "*";
        effect = "allow";
      }
    ];

  # MCP version 2 fixture (C-F05): one user entry and the canonical entries
  # with mixed values. The fixture proves the `mcp.servers` dialect key, the
  # joined `command` array, the `environment` rename, the `disabled` inverse,
  # and the empty-entry case with no group.
  mcpV2Project = orchestration.evalAgents {
    uses = [ "opencode" ];
    mcp = {
      custom = {
        command = "my-server";
        args = [ "--flag" ];
        env = {
          CUSTOM_VAR = "1";
        };
        enabled = true;
      };
      figma = {
        enabled = true;
      };
      pencil = {
        enabled = false;
      };
    };
  };
  mcpV2Merged = harnessLib.mergeAgents {
    project = mcpV2Project;
    roleNames = [ ];
    tool = "unset";
  };
  mcpV2Rendered = harnessLib.renderSelected {
    merged = mcpV2Merged;
    uses = [ "opencode" ];
  };
  mcpV2Doc = builtins.fromJSON (
    builtins.readFile (fileByRel mcpV2Rendered.fileDecls ".opencode/opencode.jsonc").source
  );
  mcpV2EmptyMerged = harnessLib.mergeAgents {
    project = orchestration.evalAgents {
      uses = [ "opencode" ];
    };
    roleNames = [ ];
    tool = "unset";
  };
  mcpV2EmptyRendered = harnessLib.renderSelected {
    merged = mcpV2EmptyMerged;
    uses = [ "opencode" ];
  };
  mcpV2EmptyDoc = builtins.fromJSON (
    builtins.readFile (fileByRel mcpV2EmptyRendered.fileDecls ".opencode/opencode.jsonc").source
  );
  mcpV2Assertions = [
    {
      name = "mcp-servers-figma";
      assertion =
        mcpV2Doc.mcp.servers.figma.command == [
          "npx"
          "-y"
          "figma-ui-mcp"
        ]
        && mcpV2Doc.mcp.servers.figma.type == "local"
        && mcpV2Doc.mcp.servers.figma.environment.FIGMA_UI_MCP_TARGET == "Figma Desktop"
        && mcpV2Doc.mcp.servers.figma.disabled == false;
      message = "mcp-servers-figma: the rendered `mcp.servers.figma` entry misses the joined `command` array, `type = \"local\"`, the `environment` map, or `disabled = false`";
    }
    {
      name = "mcp-servers-custom";
      assertion =
        mcpV2Doc.mcp.servers.custom.command == [
          "my-server"
          "--flag"
        ]
        && mcpV2Doc.mcp.servers.custom.type == "local"
        && mcpV2Doc.mcp.servers.custom.environment.CUSTOM_VAR == "1"
        && mcpV2Doc.mcp.servers.custom.disabled == false
        && !(mcpV2Doc.mcp.servers.custom ? env)
        && !(mcpV2Doc.mcp.servers.custom ? enabled);
      message = "mcp-servers-custom: the rendered user entry misses the version 2 shape or it holds the key `env` or the key `enabled`";
    }
    {
      name = "mcp-servers-disabled";
      assertion = mcpV2Doc.mcp.servers.pencil.disabled == true;
      message = "mcp-servers-disabled: the disabled `pencil` entry holds no `disabled = true`";
    }
    {
      name = "mcp-no-legacy-group";
      assertion = !(mcpV2Doc ? mcpServers) && !(mcpV2Doc ? mcp_servers);
      message = "mcp-no-legacy-group: the rendered document holds a `mcpServers` group or a `mcp_servers` group";
    }
    {
      name = "mcp-empty";
      assertion = !(mcpV2EmptyDoc ? mcp);
      message = "mcp-empty: the rendered document with no entry holds a `mcp` group";
    }
    {
      name = "mcp-one-file";
      assertion = builtins.map (d: d.rel) mcpV2Rendered.fileDecls == [ ".opencode/opencode.jsonc" ];
      message = "mcp-one-file: the file declaration list of the MCP fixture holds more than `.opencode/opencode.jsonc`";
    }
  ];
  mcpV2Failing = builtins.filter (a: !a.assertion) mcpV2Assertions;
  mcpV2Match =
    if mcpV2Failing == [ ] then
      true
    else
      throw "seed check: the MCP fixture of `${arch}` fails ${(builtins.head mcpV2Failing).message}";

  modes = filePlan.foundationModes;

  plan = filePlan.planForArch {
    inherit arch factoryDir modes;
    renderedSources = [
      configYaml
    ]
    ++ designOut.renderedSources
    ++ skillOut.renderedSources
    ++ deliveryOut.renderedSources;
    extraFiles = [
      {
        rel = "factory.config.yaml";
        source = configYaml;
        copyMode = "template";
      }
    ]
    ++ designOut.extraFiles
    ++ skillOut.extraFiles
    ++ deliveryOut.extraFiles;
  };

  # The design files and the skill file join the one transaction that
  # holds the base files, the overlay files, the role files, the MCP
  # files, and the skill file (C-15, C-17). The starter selects the method
  # `unset`, so the starter plan holds no design file and no skill file.
  designOut = design.designFiles settings;
  skillOut = design.skillFiles settings;

  # Delivery files of the starter run (feat-delivery task-site-lib): the
  # site files join the one transaction. The starter selects
  # site.enable = false, so the starter plan holds no site file.
  deliveryOut = delivery.deliveryFiles settings factoryDir;

  # Site fixtures (spec-site-render): one fixture with enable = true, one
  # with enable = false, one fixture index, and one fixture without an
  # index. The check proves the emitted-files table, the rendered sources,
  # the site.json round trip, and the derived order with its fallbacks.
  siteLib = import ../lib/site.nix;
  siteIndexRoot = factoryDir + "/assets/delivery/fixtures/index";
  siteNoIndexRoot = factoryDir + "/assets/delivery/fixtures/no-index";
  sitePartialRoot = factoryDir + "/assets/delivery/fixtures/partial";
  siteEnabledSettings = {
    site = {
      enable = true;
      title = "Documentation";
      url = "https://owner.github.io";
      baseUrl = "/repository/";
      staticDirectories = [ "static" ];
    };
  };
  siteDisabledSettings = {
    site = {
      enable = false;
      title = "Documentation";
      url = "";
      baseUrl = "/";
      staticDirectories = [ ];
    };
  };
  siteEnabledOut = siteLib.siteFiles siteEnabledSettings siteIndexRoot;
  siteDisabledOut = siteLib.siteFiles siteDisabledSettings siteIndexRoot;
  siteJsonEntry = builtins.head (
    builtins.filter (e: e.rel == "apps/documentation/site.json") siteEnabledOut.extraFiles
  );
  siteJsonValue = builtins.fromJSON (builtins.readFile siteJsonEntry.source);
  siteConfigText = builtins.readFile ../assets/delivery/site/docusaurus.config.js;
  siteLibText = builtins.readFile ../lib/site.nix;
  deliveryText = builtins.readFile ./delivery.nix;
  siteScriptTexts = builtins.concatStringsSep "\n" (
    builtins.map (s: builtins.readFile (../scripts + "/${s}")) [
      "seed-check.sh"
      "layer-layout.sh"
      "layer-arch.sh"
      "layer-facade.sh"
      "layer-copymode.sh"
      "layer-emit.sh"
      "copy-step.sh"
    ]
  );
  sitePkgNeedle = builtins.concatStringsSep "" [
    "n"
    "pm"
  ];
  siteDirectRejected =
    (builtins.tryEval (
      filePlan.checkSourceAllowed {
        inherit arch;
        baseDir = factoryDir + "/assets/base";
        overlayDir = factoryDir + "/assets/overlays/${arch}";
        renderedSources = siteEnabledOut.renderedSources;
        rel = "apps/documentation/package.json";
        source = factoryDir + "/assets/delivery/site/package.json";
      }
    )).success == false;
  siteAssertions = [
    {
      name = "site-disabled";
      assertion = siteDisabledOut.extraFiles == [ ] && siteDisabledOut.renderedSources == [ ];
      message = "site-disabled: the enable = false fixture holds a site file";
    }
    {
      name = "site-table";
      assertion = builtins.all (
        f: builtins.any (e: e.rel == f.rel && e.copyMode == f.copyMode) siteEnabledOut.extraFiles
      ) siteLib.emittedSiteFiles;
      message = "site-table: the enable = true fixture misses a file of the emitted-files table with its copy mode";
    }
    {
      name = "site-json-entry";
      assertion =
        builtins.any (
          e: e.rel == "apps/documentation/site.json" && e.copyMode == "managed"
        ) siteEnabledOut.extraFiles
        && builtins.elem (toString siteJsonEntry.source) (
          builtins.map toString siteEnabledOut.renderedSources
        );
      message = "site-json-entry: the rendered site.json misses its plan entry or its rendered source";
    }
    {
      name = "site-rendered";
      assertion = builtins.all (
        e: builtins.elem (toString e.source) (builtins.map toString siteEnabledOut.renderedSources)
      ) siteEnabledOut.extraFiles;
      message = "site-rendered: a site file misses its rendered source";
    }
    {
      name = "site-no-direct";
      assertion = siteDirectRejected;
      message = "site-no-direct: the file-plan check accepts a direct source under `assets/delivery/site/`";
    }
    {
      name = "site-json-roundtrip";
      assertion =
        siteJsonValue.title == "Documentation"
        && siteJsonValue.url == "https://owner.github.io"
        && siteJsonValue.baseUrl == "/repository/"
        && siteJsonValue.staticDirectories == [ "static" ]
        &&
          siteJsonValue.featureOrder == [
            "feat-gamma"
            "feat-alpha"
            "feat-beta"
          ];
      message = "site-json-roundtrip: the rendered site.json differs from the fixture settings and the derived order";
    }
    {
      name = "site-index-order";
      assertion =
        siteLib.featureOrder siteIndexRoot == [
          "feat-gamma"
          "feat-alpha"
          "feat-beta"
        ];
      message = "site-index-order: the derived order differs from the row order of the fixture index";
    }
    {
      name = "site-partial-order";
      assertion =
        siteLib.featureOrder sitePartialRoot == [
          "feat-beta"
          "feat-alpha"
          "feat-delta"
        ];
      message = "site-partial-order: an unlisted folder does not follow the listed folders in alphabetical order";
    }
    {
      name = "site-no-index-order";
      assertion =
        siteLib.featureOrder siteNoIndexRoot == [
          "feat-alpha"
          "feat-beta"
        ];
      message = "site-no-index-order: the order without an index is not the alphabetical order of the feature folders";
    }
    {
      name = "site-config-markers";
      assertion = builtins.all (m: contains siteConfigText m) [
        "site.featureOrder"
        "index"
        "README"
        "requirements"
        "specifications"
        "decisions"
        "tasks"
        "change-initial"
        "toLowerCase"
        "versions"
        "changes"
      ];
      message = "site-config-markers: the config asset misses the read of `site.featureOrder` or a comparator-rule marker";
    }
    {
      name = "site-no-package-manager";
      assertion = builtins.replaceStrings [ sitePkgNeedle ] [ "" ] siteScriptTexts == siteScriptTexts;
      message = "site-no-package-manager: the seed check runs a package-manager command";
    }
    {
      name = "site-no-hand-list";
      assertion =
        builtins.all
          (
            n: builtins.replaceStrings [ n ] [ "" ] (siteLibText + deliveryText) == (siteLibText + deliveryText)
          )
          [
            "feat-foundation"
            "feat-orchestration"
            "feat-design"
            "feat-delivery"
          ];
      message = "site-no-hand-list: the factory holds a hand list of feature names";
    }
    {
      name = "site-seed-mode";
      assertion =
        builtins.all (rel: builtins.any (e: e.rel == rel && e.copyMode == "seed") siteEnabledOut.extraFiles)
          [
            "apps/documentation/src/css/custom.css"
            "apps/documentation/README.md"
          ];
      message = "site-seed-mode: a seed site file misses the copy mode seed";
    }
  ];
  siteFailing = builtins.filter (a: !a.assertion) siteAssertions;
  siteMatch =
    if siteFailing == [ ] then
      true
    else
      throw "seed check: the site fixture of `${arch}` fails ${(builtins.head siteFailing).message}";

  # CI fixtures (spec-ci-options): one fixture with each provider, each
  # publish target, the default folder, and a custom folder. The check
  # proves the gate, the emitted paths, the trigger order, the build-step
  # order, the typed steps, the provider shapes, the rendered sources, the
  # pinned bytes, and the single-renderer rules.
  ciLib = import ../lib/ci.nix;
  ciSiteOn = {
    enable = true;
    title = "Documentation";
    url = "";
    baseUrl = "/";
    staticDirectories = [ ];
  };
  ciSiteOff = ciSiteOn // {
    enable = false;
  };
  ciBuildEmpty = {
    beforeNodeSetup = [ ];
    beforeSiteBuild = [ ];
    afterSiteBuild = [ ];
  };
  ciHookSteps = {
    beforeNodeSetup = [
      {
        name = "First hook";
        run = "echo first";
      }
    ];
    beforeSiteBuild = [
      {
        name = "Second hook";
        uses = "actions/cache@v4";
        "with" = {
          path = "cache";
        };
      }
    ];
    afterSiteBuild = [
      {
        name = "Third hook";
        run = "echo third";
        workingDirectory = "utils";
      }
    ];
  };
  ciSettingsOf = ci: site: {
    inherit ci site;
    publish = {
      target = "github-pages";
      deployTool = "official-task";
    };
    notify = {
      uses = [ ];
      google-chat = {
        secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      };
      slack = {
        secret = "NOTIFY_SLACK_WEBHOOK";
      };
      telegram = {
        secret = "NOTIFY_TELEGRAM_TOKEN";
        chatId = "";
      };
    };
  };
  ciUnsetOut = ciLib.ciFiles (
    ciSettingsOf {
      use = "unset";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciGhOut = ciLib.ciFiles (
    ciSettingsOf {
      use = "github-actions";
      folder = "azure-pipelines";
      watchPaths = [ "utils/**" ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciAzOut = ciLib.ciFiles (
    ciSettingsOf {
      use = "azure-pipelines";
      folder = "azure-pipelines";
      watchPaths = [ "utils/**" ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciAzCustomOut = ciLib.ciFiles (
    ciSettingsOf {
      use = "azure-pipelines";
      folder = "custom-folder";
      watchPaths = [ "utils/**" ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciDisabledOut = ciLib.ciFiles (
    ciSettingsOf {
      use = "github-actions";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = ciBuildEmpty;
    } ciSiteOff
  );
  ciGhText = ciLib.githubWorkflow (
    ciSettingsOf {
      use = "github-actions";
      folder = "azure-pipelines";
      watchPaths = [ "utils/**" ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciAzText = ciLib.azurePipeline "azure-pipelines" (
    ciSettingsOf {
      use = "azure-pipelines";
      folder = "azure-pipelines";
      watchPaths = [ "utils/**" ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciAzCustomText = ciLib.azurePipeline "custom-folder" (
    ciSettingsOf {
      use = "azure-pipelines";
      folder = "custom-folder";
      watchPaths = [ "utils/**" ];
      build = ciBuildEmpty;
    } ciSiteOn
  );
  ciGhHookText = ciLib.githubWorkflow (
    ciSettingsOf {
      use = "github-actions";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = ciHookSteps;
    } ciSiteOn
  );
  ciAzHookText = ciLib.azurePipeline "azure-pipelines" (
    ciSettingsOf {
      use = "azure-pipelines";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = ciHookSteps;
    } ciSiteOn
  );
  ciGhSource = (builtins.head ciGhOut.extraFiles).source;
  ciAzSource = (builtins.head ciAzOut.extraFiles).source;
  ciHookSettings = ciSettingsOf {
    use = "github-actions";
    folder = "azure-pipelines";
    watchPaths = [ ];
    build = ciHookSteps;
  } ciSiteOn;
  ciEvalFails =
    project:
    (builtins.tryEval (builtins.deepSeq (facade.evalFactory { factory.project = project; }) true))
    .success == false;
  ciBaseProject = {
    arch = "single";
    advanced = { };
    secrets = [ ];
  };
  ciBadFolders = [
    "/abs"
    "a//b"
    "a/../b"
    "a\\b"
  ];
  ciBadUses = [
    "unset"
    "github-actions"
    "azure-pipelines"
  ];
  ciFolderFails = builtins.all (
    use:
    builtins.all (folder: ciEvalFails (ciBaseProject // { ci = { inherit use folder; }; })) ciBadFolders
  ) ciBadUses;
  ciBadSteps = [
    { }
    {
      uses = "actions/cache@v4";
      run = "echo both";
    }
    {
      run = "echo with";
      "with" = {
        path = "cache";
      };
    }
    {
      uses = "actions/cache@v4";
      workingDirectory = "utils";
    }
    {
      run = "echo unknown";
      bogus = 1;
    }
    {
      uses = "";
    }
    {
      run = "";
    }
  ];
  ciStepsFail = builtins.all (
    step:
    ciEvalFails (
      ciBaseProject
      // {
        ci = {
          use = "github-actions";
          build = {
            beforeNodeSetup = [ step ];
            beforeSiteBuild = [ ];
            afterSiteBuild = [ ];
          };
        };
      }
    )
  ) ciBadSteps;
  countOcc =
    needle: text:
    (
      builtins.stringLength text - builtins.stringLength (builtins.replaceStrings [ needle ] [ "" ] text)
    )
    / builtins.stringLength needle;
  listNixFiles =
    dir:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      walk =
        name:
        let
          kind = entries.${name};
        in
        if kind == "directory" then
          listNixFiles (dir + "/${name}")
        else if kind == "regular" && builtins.match ".*\\.nix" name != null then
          [ (dir + "/${name}") ]
        else
          [ ];
    in
    builtins.concatLists (builtins.map walk names);
  ciComponentFiles = listNixFiles (factoryDir + "/lib") ++ listNixFiles (factoryDir + "/modules");
  ciYamlNeedle = builtins.concatStringsSep "" [
    "render"
    "Yaml ="
  ];
  ciYamlDefs = builtins.filter (f: countOcc ciYamlNeedle (builtins.readFile f) > 0) ciComponentFiles;
  ciLibText = builtins.readFile ../lib/ci.nix;
  ciDirectRejected =
    (builtins.tryEval (
      filePlan.checkSourceAllowed {
        inherit arch;
        baseDir = factoryDir + "/assets/base";
        overlayDir = factoryDir + "/assets/overlays/${arch}";
        renderedSources = ciGhOut.renderedSources;
        rel = ".github/workflows/docs-site.yml";
        source = factoryDir + "/assets/delivery/site/package.json";
      }
    )).success == false;
  ciAssertions = [
    {
      name = "ci-folder-rule";
      assertion = ciFolderFails;
      message = "ci-folder: an invalid `folder` value passes evaluation for a `use` value";
    }
    {
      name = "ci-step-model";
      assertion = ciStepsFail;
      message = "ci-step-model: an invalid build step passes evaluation";
    }
    {
      name = "ci-unset";
      assertion = ciUnsetOut.extraFiles == [ ] && ciUnsetOut.renderedSources == [ ];
      message = "ci-unset: the `unset` fixture holds a CI file";
    }
    {
      name = "ci-github-path";
      assertion =
        builtins.map (e: e.rel) ciGhOut.extraFiles == [ ".github/workflows/docs-site.yml" ]
        && builtins.all (e: e.copyMode == "managed") ciGhOut.extraFiles
        && builtins.elem (toString ciGhSource) (builtins.map toString ciGhOut.renderedSources);
      message = "ci-github-path: the `github-actions` fixture misses `.github/workflows/docs-site.yml` with a rendered managed source";
    }
    {
      name = "ci-azure-path";
      assertion = builtins.map (e: e.rel) ciAzOut.extraFiles == [ "azure-pipelines/docs-site.yml" ];
      message = "ci-azure-path: the `azure-pipelines` fixture misses its folder path docs-site.yml";
    }
    {
      name = "ci-custom-folder";
      assertion =
        builtins.map (e: e.rel) ciAzCustomOut.extraFiles == [ "custom-folder/docs-site.yml" ]
        && builtins.replaceStrings [ "custom-folder" ] [ "azure-pipelines" ] ciAzCustomText == ciAzText;
      message = "ci-custom-folder: a custom folder changes more than the emitted path and the trigger self-path";
    }
    {
      name = "ci-site-gate";
      assertion = ciDisabledOut.extraFiles == [ ] && ciDisabledOut.renderedSources == [ ];
      message = "ci-site-gate: a CI fixture with the site disabled holds a CI file";
    }
    {
      name = "ci-trigger";
      assertion =
        ciLib.triggerPaths ".github/workflows/docs-site.yml" ciHookSettings == [
          "docs/**"
          "apps/documentation/**"
          ".github/workflows/docs-site.yml"
        ]
        && contains ciGhText "\"docs/**\""
        && contains ciGhText "\"apps/documentation/**\""
        && contains ciGhText "\"utils/**\"";
      message = "ci-trigger: the trigger misses the three factory paths first or the watch paths in order";
    }
    {
      name = "ci-build-order";
      assertion =
        pairsOk ciGhText [
          "actions/checkout@v4"
          "actions/setup-node@v4"
          "npm install"
          "npm run build"
        ]
        && pairsOk ciAzText [
          "checkout"
          "NodeTool@0"
          "npm install"
          "npm run build"
        ];
      message = "ci-build-order: the build steps miss a step or break the build-step order";
    }
    {
      name = "ci-empty-hook";
      assertion =
        countOcc "echo" ciGhText == 0
        && pairsOk ciGhHookText [
          "echo first"
          "actions/setup-node@v4"
          "echo third"
        ];
      message = "ci-empty-hook: an empty hook list adds a step or a typed step misses its hook";
    }
    {
      name = "ci-hook-order";
      assertion =
        pairsOk ciGhHookText [
          "echo first"
          "npm install"
          "actions/cache@v4"
          "npm run build"
          "echo third"
        ]
        && pairsOk ciAzHookText [
          "echo first"
          "npm install"
          "actions/cache@v4"
          "npm run build"
          "echo third"
        ];
      message = "ci-hook-order: a typed step misses its hook or breaks the list order";
    }
    {
      name = "ci-gh-shape";
      assertion = builtins.all (m: contains ciGhText m) [
        "actions/setup-node@v4"
        "cache-dependency-path"
        "apps/documentation/package.json"
        "working-directory"
        "workflow_dispatch"
      ];
      message = "ci-gh-shape: the GitHub Actions render misses its provider shape";
    }
    {
      name = "ci-az-shape";
      assertion = builtins.all (m: contains ciAzText m) [
        "NodeTool@0"
        "versionSpec"
        "displayName"
        "workingDirectory"
      ];
      message = "ci-az-shape: the Azure Pipelines render misses its provider shape";
    }
    {
      name = "ci-no-direct";
      assertion = ciDirectRejected;
      message = "ci-no-direct: the file-plan check accepts a direct source under `assets/delivery/`";
    }
    {
      name = "ci-pinned";
      assertion =
        ciLib.githubWorkflow (
          ciSettingsOf {
            use = "github-actions";
            folder = "azure-pipelines";
            watchPaths = [ "utils/**" ];
            build = ciBuildEmpty;
          } ciSiteOn
        ) == ciGhText;
      message = "ci-pinned: two renders of one fixture differ";
    }
    {
      name = "ci-one-yaml";
      assertion = ciYamlDefs == [ (factoryDir + "/lib/yaml.nix") ];
      message = "ci-one-yaml: the component holds a second YAML renderer definition";
    }
    {
      name = "ci-two-renderers";
      assertion =
        countOcc "githubWorkflow =" ciLibText == 1
        && countOcc "azurePipeline =" ciLibText == 1
        && countOcc "Workflow =" ciLibText == 1
        && countOcc "Pipeline =" ciLibText == 1;
      message = "ci-two-renderers: lib/ci.nix misses a provider renderer or holds a third one";
    }
  ];
  ciFailing = builtins.filter (a: !a.assertion) ciAssertions;
  ciMatch =
    if ciFailing == [ ] then
      true
    else
      throw "seed check: the CI fixture of `${arch}` fails ${(builtins.head ciFailing).message}";

  # Notifier fixtures (spec-notify-fanout): one fixture with uses = [ ],
  # one fixture with uses = [ "slack" ], and the secret-name and
  # chat-ID rules. The check proves the gate, the managed file with its
  # rendered source, the absence of a direct asset source, the
  # notification step of each provider, and the option validation. The
  # stub test runs in the derivation with the python3 interpreter of
  # pkgs; the result file stays exactly five lines.
  notifyLib = import ../lib/notify.nix;
  notifyBase = {
    ci = {
      use = "github-actions";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = {
        beforeNodeSetup = [ ];
        beforeSiteBuild = [ ];
        afterSiteBuild = [ ];
      };
    };
    site = {
      enable = true;
      title = "Documentation";
      url = "https://owner.github.io";
      baseUrl = "/";
      staticDirectories = [ ];
    };
    publish = {
      target = "github-pages";
      deployTool = "official-task";
    };
  };
  notifyOffSettings = notifyBase // {
    notify = {
      uses = [ ];
      google-chat = {
        secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      };
      slack = {
        secret = "NOTIFY_SLACK_WEBHOOK";
      };
      telegram = {
        secret = "NOTIFY_TELEGRAM_TOKEN";
        chatId = "";
      };
    };
  };
  notifyOnSettings = notifyBase // {
    notify = {
      uses = [ "slack" ];
      google-chat = {
        secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      };
      slack = {
        secret = "NOTIFY_SLACK_WEBHOOK";
      };
      telegram = {
        secret = "NOTIFY_TELEGRAM_TOKEN";
        chatId = "";
      };
    };
  };
  notifyOffOut = notifyLib.notifyFiles notifyOffSettings;
  notifyOnOut = notifyLib.notifyFiles notifyOnSettings;
  notifyGhText = ciLib.githubWorkflow notifyOnSettings;
  notifyAzText = ciLib.azurePipeline "azure-pipelines" notifyOnSettings;
  notifyOffGhText = ciLib.githubWorkflow notifyOffSettings;
  notifyEvalFails =
    notify:
    (builtins.tryEval (
      builtins.deepSeq (facade.evalFactory {
        factory.project = ciBaseProject // {
          inherit notify;
        };
      }) true
    )).success == false;
  notifyAssertions = [
    {
      name = "notify-secret-rule";
      assertion = notifyEvalFails {
        uses = [ "slack" ];
        google-chat = {
          secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
        };
        slack = {
          secret = "https://hooks.example/secret";
        };
        telegram = {
          secret = "NOTIFY_TELEGRAM_TOKEN";
          chatId = "";
        };
      };
      message = "notify-secret-rule: a secret value outside the name pattern passes evaluation";
    }
    {
      name = "notify-chatid-rule";
      assertion = notifyEvalFails {
        uses = [ "telegram" ];
        google-chat = {
          secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
        };
        slack = {
          secret = "NOTIFY_SLACK_WEBHOOK";
        };
        telegram = {
          secret = "NOTIFY_TELEGRAM_TOKEN";
          chatId = "";
        };
      };
      message = "notify-chatid-rule: the selected channel telegram without a chatId passes evaluation";
    }
    {
      name = "notify-off";
      assertion = notifyOffOut.extraFiles == [ ] && notifyOffOut.renderedSources == [ ];
      message = "notify-off: the uses = [ ] fixture holds a notifier file";
    }
    {
      name = "notify-file";
      assertion =
        builtins.map (e: e.rel) notifyOnOut.extraFiles == [ "scripts/notify.py" ]
        && builtins.all (e: e.copyMode == "managed") notifyOnOut.extraFiles
        && builtins.all (
          e: builtins.elem (toString e.source) (builtins.map toString notifyOnOut.renderedSources)
        ) notifyOnOut.extraFiles;
      message = "notify-file: the uses = [ \"slack\" ] fixture misses scripts/notify.py with a rendered managed source";
    }
    {
      name = "notify-no-direct";
      assertion =
        (builtins.tryEval (
          filePlan.checkSourceAllowed {
            inherit arch;
            baseDir = factoryDir + "/assets/base";
            overlayDir = factoryDir + "/assets/overlays/${arch}";
            renderedSources = notifyOnOut.renderedSources;
            rel = "scripts/notify.py";
            source = factoryDir + "/assets/delivery/notify.py";
          }
        )).success == false;
      message = "notify-no-direct: the file-plan check accepts a direct source under `assets/delivery/`";
    }
    {
      name = "notify-step";
      assertion =
        contains notifyGhText "python3 scripts/notify.py"
        && contains notifyAzText "python3 scripts/notify.py"
        && contains notifyGhText "NOTIFY_SLACK_WEBHOOK"
        && contains notifyAzText "NOTIFY_SLACK_WEBHOOK"
        && builtins.replaceStrings [ "NOTIFY_GOOGLE_CHAT_WEBHOOK" ] [ "" ] notifyGhText == notifyGhText
        && builtins.replaceStrings [ "NOTIFY_TELEGRAM_TOKEN" ] [ "" ] notifyGhText == notifyGhText
        &&
          builtins.replaceStrings [ "python3 scripts/notify.py" ] [ "" ] notifyOffGhText == notifyOffGhText;
      message = "notify-step: the notification step misses the script run, adds an unselected channel, or appears with uses = [ ]";
    }
  ];
  notifyFailing = builtins.filter (a: !a.assertion) notifyAssertions;
  notifyMatch =
    if notifyFailing == [ ] then
      true
    else
      throw "seed check: the notifier fixture of `${arch}` fails ${(builtins.head notifyFailing).message}";

  # Publish fixtures (spec-publish): one fixture for each provider and
  # each target, one fixture for each deploy tool, and one fixture for
  # the default values. The check proves the target matrix, the deploy
  # tool, the pinned CLI, the single occurrence of each fixed constant in
  # lib/ci.nix, and the step order.
  publishSettingsOf = use: target: tool: uses: {
    ci = {
      inherit use;
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = {
        beforeNodeSetup = [ ];
        beforeSiteBuild = [ ];
        afterSiteBuild = [ ];
      };
    };
    site = {
      enable = true;
      title = "Documentation";
      url = "https://owner.github.io";
      baseUrl = "/";
      staticDirectories = [ ];
    };
    publish = {
      inherit target;
      deployTool = tool;
    };
    notify = {
      inherit uses;
      google-chat = {
        secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      };
      slack = {
        secret = "NOTIFY_SLACK_WEBHOOK";
      };
      telegram = {
        secret = "NOTIFY_TELEGRAM_TOKEN";
        chatId = "";
      };
    };
  };
  publishDefault = delivery.evalPublish null;
  publishGhPagesGh = ciLib.githubWorkflow (
    publishSettingsOf "github-actions" "github-pages" "official-task" [ "slack" ]
  );
  publishGhPagesAz = ciLib.azurePipeline "azure-pipelines" (
    publishSettingsOf "azure-pipelines" "github-pages" "official-task" [ ]
  );
  publishSwaGh = ciLib.githubWorkflow (
    publishSettingsOf "github-actions" "azure-static-web-app" "official-task" [ ]
  );
  publishSwaAz = ciLib.azurePipeline "azure-pipelines" (
    publishSettingsOf "azure-pipelines" "azure-static-web-app" "official-task" [ ]
  );
  publishCliGh = ciLib.githubWorkflow (
    publishSettingsOf "github-actions" "azure-static-web-app" "swa-cli" [ ]
  );
  publishCliAz = ciLib.azurePipeline "azure-pipelines" (
    publishSettingsOf "azure-pipelines" "azure-static-web-app" "swa-cli" [ ]
  );
  publishOptionsJson = builtins.toJSON delivery.deliveryOptions;
  publishAssertions = [
    {
      name = "publish-default";
      assertion = publishDefault.target == "github-pages" && publishDefault.deployTool == "official-task";
      message = "publish-default: the default target is not github-pages or the default deploy tool is not official-task";
    }
    {
      name = "publish-pages-gh";
      assertion = builtins.all (m: contains publishGhPagesGh m) [
        "actions/upload-pages-artifact@v3"
        "actions/deploy-pages@v4"
        "github-pages"
        "pages"
        "id-token"
      ];
      message = "publish-pages-gh: the github-pages fixture on github-actions misses the upload step, the deploy job, the environment, or the permissions";
    }
    {
      name = "publish-pages-az";
      assertion =
        contains publishGhPagesAz "gh-pages"
        && contains publishGhPagesAz "SITE_PAGES_TOKEN"
        && builtins.replaceStrings [ "Static Web App" ] [ "" ] publishGhPagesAz == publishGhPagesAz
        && builtins.replaceStrings [ "static-web-apps" ] [ "" ] publishGhPagesAz == publishGhPagesAz;
      message = "publish-pages-az: the github-pages fixture on azure-pipelines misses the gh-pages publish or holds Static Web App content";
    }
    {
      name = "publish-swa";
      assertion =
        builtins.all (m: contains publishSwaGh m) [
          "app_location"
          "apps/documentation/build"
          "output_location"
          "skip_app_build"
          "SITE_SWA_DEPLOYMENT_TOKEN"
        ]
        && builtins.all (m: contains publishSwaAz m) [
          "app_location"
          "skip_app_build"
          "SITE_SWA_DEPLOYMENT_TOKEN"
        ]
        && builtins.replaceStrings [ "deploy-pages" ] [ "" ] publishSwaGh == publishSwaGh
        && builtins.replaceStrings [ "pages: write" ] [ "" ] publishSwaGh == publishSwaGh
        && builtins.replaceStrings [ "deploy-pages" ] [ "" ] publishSwaAz == publishSwaAz;
      message = "publish-swa: the azure-static-web-app fixture misses the deploy inputs or holds Pages content";
    }
    {
      name = "publish-official";
      assertion =
        contains publishSwaGh "Azure/static-web-apps-deploy@v1"
        && contains publishSwaAz "AzureStaticWebApp@0"
        && builtins.replaceStrings [ "static-web-apps-cli" ] [ "" ] publishSwaGh == publishSwaGh
        && builtins.replaceStrings [ "static-web-apps-cli" ] [ "" ] publishSwaAz == publishSwaAz;
      message = "publish-official: the official-task fixture misses the official action or task or holds a CLI step";
    }
    {
      name = "publish-cli";
      assertion =
        contains publishCliGh "npm install --global @azure/static-web-apps-cli@2.0.10"
        && contains publishCliAz "npm install --global @azure/static-web-apps-cli@2.0.10"
        && contains publishCliGh "swa deploy ./build"
        && contains publishCliAz "swa deploy ./build"
        && builtins.replaceStrings [ "static-web-apps-deploy" ] [ "" ] publishCliGh == publishCliGh
        && builtins.replaceStrings [ "AzureStaticWebApp@0" ] [ "" ] publishCliAz == publishCliAz;
      message = "publish-cli: the swa-cli fixture misses the pinned install or deploy command or holds the official action or task";
    }
    {
      name = "publish-constants-once";
      assertion =
        countOcc "SITE_PAGES_TOKEN" ciLibText == 1
        && countOcc "SITE_SWA_DEPLOYMENT_TOKEN" ciLibText == 1
        && countOcc "@azure/static-web-apps-cli" ciLibText == 1
        && countOcc "2.0.10" ciLibText == 1;
      message = "publish-constants-once: a fixed constant occurs never or more than one time in lib/ci.nix";
    }
    {
      name = "publish-no-option";
      assertion =
        builtins.all (m: builtins.replaceStrings [ m ] [ "" ] publishOptionsJson == publishOptionsJson)
          [
            "SITE_PAGES_TOKEN"
            "SITE_SWA_DEPLOYMENT_TOKEN"
            "static-web-apps-cli"
            "2.0.10"
          ];
      message = "publish-no-option: the option table deliveryOptions holds a token name or a CLI version";
    }
    {
      name = "publish-order";
      assertion = pairsOk publishGhPagesGh [
        "npm run build"
        "actions/upload-pages-artifact@v3"
        "actions/deploy-pages@v4"
        "python3 scripts/notify.py"
      ];
      message = "publish-order: the deploy step misses its place after the build steps and before the notification step";
    }
  ];
  publishFailing = builtins.filter (a: !a.assertion) publishAssertions;
  publishMatch =
    if publishFailing == [ ] then
      true
    else
      throw "seed check: the publish fixture of `${arch}` fails ${(builtins.head publishFailing).message}";

  # Preset fixtures (spec-presets): one fixture for each preset, one
  # fixture without a bundle, one fixture with an author value other
  # than the table value, and one fixture with a bundle value on a table
  # value. The check proves the file set of each preset, the author win,
  # the bundle fill, the table-driven comparison, the dead-key rule, and
  # the starter values.
  presetsLib = import ../lib/presets.nix;
  presetTables = {
    agents = orchestration.agentsOptions;
    design = design.designOptions;
    ux = design.uxOptions;
    delivery = delivery.deliveryOptions;
  };
  presetLeaves = presetsLib.leafTable presetTables;
  presetBase = {
    arch = "single";
    advanced = { };
    secrets = [ ];
  };
  presetMinimalEff = facade.evalFactory {
    factory.project = presetBase // {
      preset = "minimal";
    };
  };
  presetDocsEff = facade.evalFactory {
    factory.project = presetBase // {
      preset = "docs-only";
    };
  };
  presetFullEff = facade.evalFactory {
    factory.project = presetBase // {
      preset = "full";
    };
  };
  presetNoneEff = facade.evalFactory { factory.project = presetBase; };
  presetAuthorEff = facade.evalFactory {
    factory.project = presetBase // {
      preset = "docs-only";
      site = {
        title = "Custom";
      };
    };
  };
  presetFillEff = facade.evalFactory {
    factory.project = presetBase // {
      preset = "docs-only";
      ci = {
        use = "unset";
      };
    };
  };
  presetDeliveryOf =
    eff:
    delivery.deliveryFiles {
      ci = eff.ci;
      site = eff.site;
      publish = eff.publish;
      notify = eff.notify;
    } siteIndexRoot;
  presetMinimalFiles = presetDeliveryOf presetMinimalEff;
  presetDocsFiles = presetDeliveryOf presetDocsEff;
  presetFullFiles = presetDeliveryOf presetFullEff;
  presetMinimalDesign = design.designFiles presetMinimalEff;
  presetDocsDesign = design.designFiles presetDocsEff;
  presetFullDesign = design.designFiles presetFullEff;
  presetFullSkill = design.skillFiles presetFullEff;
  presetFullMerged = harnessLib.mergeAgents {
    project = orchestration.evalAgents presetFullEff.agents;
    roleNames = [ "designer-expert" ];
    tool = design.toolFeed presetFullEff;
    ux = presetFullEff.ux;
  };
  presetFullChapters = design.chapterMap presetFullEff;
  presetFullRoleRender = rolesLib.renderRoles {
    roles = presetFullMerged.roles;
    uses = presetFullMerged.uses;
    chapterMap = presetFullChapters;
  };
  presetFullHarnessRender = harnessLib.renderSelected {
    merged = presetFullMerged;
    uses = presetFullMerged.uses;
  };
  presetFullRels =
    builtins.map (d: d.rel) presetFullHarnessRender.fileDecls
    ++ builtins.map (d: d.rel) presetFullRoleRender.fileDecls
    ++ builtins.map (e: e.rel) presetFullSkill.extraFiles;
  presetCustomTables = presetTables // {
    delivery = presetTables.delivery // {
      ci = presetTables.delivery.ci // {
        use = presetTables.delivery.ci.use // {
          default = "azure-pipelines";
        };
      };
    };
  };
  presetCustomApplied = presetsLib.applyPreset {
    preset = "docs-only";
    project = {
      ci = {
        use = "unset";
      };
    };
    tables = presetCustomTables;
  };
  presetCustomAbsent = presetsLib.applyPreset {
    preset = "docs-only";
    project = { };
    tables = presetCustomTables;
  };
  presetF4Keys = builtins.filter (k: builtins.match "(ci|site|publish|notify)[.]?.*" k != null) (
    builtins.attrNames presetLeaves
  );
  presetF4LeafCount = builtins.length presetF4Keys;
  presetDocsKeys = builtins.attrNames presetsLib.bundles.docs-only;
  presetFullKeys = builtins.attrNames presetsLib.bundles.full;
  presetAssertions = [
    {
      name = "preset-minimal-files";
      assertion = presetMinimalFiles.extraFiles == [ ] && presetMinimalDesign.extraFiles == [ ];
      message = "preset-minimal-files: the minimal fixture holds a delivery file or a design file";
    }
    {
      name = "preset-docs-files";
      assertion =
        builtins.any (e: e.rel == "apps/documentation/site.json") presetDocsFiles.extraFiles
        && builtins.any (e: e.rel == ".github/workflows/docs-site.yml") presetDocsFiles.extraFiles
        && presetDocsDesign.extraFiles == [ ];
      message = "preset-docs-files: the docs-only fixture misses the site project or the CI file or holds a design file";
    }
    {
      name = "preset-full-files";
      assertion =
        presetFullDesign.extraFiles != [ ]
        && presetFullSkill.extraFiles != [ ]
        && builtins.any (e: e.rel == "apps/documentation/site.json") presetFullFiles.extraFiles
        && builtins.any (e: e.rel == ".github/workflows/docs-site.yml") presetFullFiles.extraFiles
        && builtins.hasAttr "designer-expert" presetFullMerged.roles
        && (presetFullChapters.artifact-master or [ ]) != [ ];
      message = "preset-full-files: the full fixture misses the design files, the designer role, the UX chapter, the site project, or the CI file";
    }
    {
      name = "preset-full-absence";
      assertion = builtins.all (
        rel:
        builtins.match ".*\\.claude/.*" rel == null
        && builtins.match ".*\\.mcp\\.json" rel == null
        && builtins.match ".*\\.codex/.*" rel == null
      ) presetFullRels;
      message = "preset-full-absence: the file set of the full fixture holds a `.claude/` path, a `.mcp.json` path, or a `.codex/` path";
    }
    {
      name = "preset-full-designer-file";
      assertion =
        uxHasRel presetFullRoleRender.fileDecls ".opencode/agents/designer-expert.md"
        &&
          (fileByRel presetFullRoleRender.fileDecls ".opencode/agents/designer-expert.md").copyMode
          == "managed";
      message = "preset-full-designer-file: the file set of the full fixture misses the managed `.opencode/agents/designer-expert.md` file";
    }
    {
      name = "preset-no-bundle";
      assertion =
        presetNoneEff.ci.use == "unset"
        && presetNoneEff.site.enable == false
        && presetNoneEff.preset == null;
      message = "preset-no-bundle: the fixture without a bundle misses the table values";
    }
    {
      name = "preset-author-wins";
      assertion = presetAuthorEff.site.title == "Custom";
      message = "preset-author-wins: an author value other than the table value loses over the bundle value";
    }
    {
      name = "preset-fill";
      assertion = presetFillEff.ci.use == "github-actions";
      message = "preset-fill: a key with the table value misses the bundle value";
    }
    {
      name = "preset-table-driven";
      assertion = presetCustomApplied.ci.use == "unset" && presetCustomAbsent.ci.use == "github-actions";
      message = "preset-table-driven: the comparison misses the table value of the passed tables";
    }
    {
      name = "preset-dead-key";
      assertion =
        presetsLib.checkBundles presetTables
        && builtins.all (k: builtins.hasAttr k presetLeaves) presetDocsKeys
        && builtins.all (k: builtins.hasAttr k presetLeaves) presetFullKeys
        && builtins.sort builtins.lessThan presetDocsKeys == builtins.sort builtins.lessThan presetF4Keys
        && builtins.length presetFullKeys == builtins.length (builtins.attrNames presetLeaves)
        && presetsLib.bundles.minimal == { };
      message = "preset-dead-key: a bundle key path misses the modeled key set or a bundle misses its leaf keys";
    }
    {
      name = "preset-starter";
      assertion =
        settings.preset == "minimal"
        && (settings.ci.use or "other") == "unset"
        && (settings.site.enable or null) == false
        && (settings.notify.uses or null) == [ ];
      message = "preset-starter: the starter declaration misses preset = \"minimal\" or the off values";
    }
  ];
  presetFailing = builtins.filter (a: !a.assertion) presetAssertions;
  presetMatch =
    if presetFailing == [ ] then
      true
    else
      throw "seed check: the preset fixture of `${arch}` fails ${(builtins.head presetFailing).message}";

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

  # Absence fixture (C-F08): the composed plan of the starter holds no
  # `.claude/` path, no `.mcp.json` path, and no `.codex/` path.
  planPathAssertions = [
    {
      name = "plan-no-claude";
      assertion = builtins.all (rel: builtins.match ".*\\.claude/.*" rel == null) paths;
      message = "plan-no-claude: the composed plan holds a `.claude/` path";
    }
    {
      name = "plan-no-mcp-json";
      assertion = builtins.all (rel: builtins.match ".*\\.mcp\\.json" rel == null) paths;
      message = "plan-no-mcp-json: the composed plan holds a `.mcp.json` path";
    }
    {
      name = "plan-no-codex";
      assertion = builtins.all (rel: builtins.match ".*\\.codex/.*" rel == null) paths;
      message = "plan-no-codex: the composed plan holds a `.codex/` path";
    }
  ];
  planPathFailing = builtins.filter (a: !a.assertion) planPathAssertions;
  planPathMatch =
    if planPathFailing == [ ] then
      true
    else
      throw "seed check: the absence fixture of `${arch}` fails ${(builtins.head planPathFailing).message}";

  proof = builtins.toFile "facade-proof" "green";

  manifest = pkgs.writeText "plan-manifest" (copyModes.manifestText files);

  lintBin = pkgs.nodePackages.markdownlint-cli + "/bin/markdownlint";

  notifyTest = "${pkgs.python3}/bin/python3 ${factoryDir}/assets/delivery/tests/test_notify.py ${factoryDir}/assets/delivery/notify.py";
in
assert archMatch;
assert agentsMatch;
assert designMatch;
assert deliveryMatch;
assert siteMatch;
assert ciMatch;
assert notifyMatch;
assert publishMatch;
assert presetMatch;
assert chapterMatch;
assert toolMatch;
assert assetMatch;
assert uxMatch;
assert mcpV2Match;
assert planPathMatch;
assert logFixturePermissions;
assert evalAssertions;
pkgs.stdenv.mkDerivation {
  name = "seed-check-${arch}";
  buildCommand = ''
    export MANIFEST=${manifest} WORK=$TMPDIR/work OUT=$TMPDIR/output ARCH=${arch}
    export SCRIPT_DIR=${factoryDir}/scripts COPY_STEP=${factoryDir}/scripts/copy-step.sh
    export LINT_BIN=${lintBin} LINT_CONFIG=${factoryDir}/assets/base/.markdownlint.yaml
    export PROOF=${proof} FACTORY_SRC=${facadeSrc}
    sh ${factoryDir}/scripts/seed-check.sh
    ${notifyTest}
    mkdir -p $out
    cp $TMPDIR/output $out/output
  '';
}
