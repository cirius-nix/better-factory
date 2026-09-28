# services/factory/lib/harness.nix
# Three-layer harness merge of the facade group `factory.project.agents`
# (spec-harness-merge). Pure Nix with no nixpkgs dependency.
#
# Layers merge in the order managed, then project, then local, per leaf key.
# A user-wins leaf takes the value of the last layer that sets the key. A
# managed leaf keeps the managed value, and each ignored project or local
# value writes one log line in the pinned format
# `managed-wins: <key path> from <layer>` to the standard error of the
# evaluation (builtins.trace). The merge forces the comparison of each
# managed key path of each selected harness at each layer (C-02).
let
  harnessNames = [
    "opencode"
  ];

  # Explicit letter table for the extra-key first character (C-01). An `A`
  # to `Z` first character maps to `a` to `z`. An `a` to `z` first character
  # stays. Any other first character fails evaluation.
  upperLetters = [
    "A"
    "B"
    "C"
    "D"
    "E"
    "F"
    "G"
    "H"
    "I"
    "J"
    "K"
    "L"
    "M"
    "N"
    "O"
    "P"
    "Q"
    "R"
    "S"
    "T"
    "U"
    "V"
    "W"
    "X"
    "Y"
    "Z"
  ];
  lowerLetters = [
    "a"
    "b"
    "c"
    "d"
    "e"
    "f"
    "g"
    "h"
    "i"
    "j"
    "k"
    "l"
    "m"
    "n"
    "o"
    "p"
    "q"
    "r"
    "s"
    "t"
    "u"
    "v"
    "w"
    "x"
    "y"
    "z"
  ];
  upperToLower = builtins.listToAttrs (
    builtins.genList (i: {
      name = builtins.elemAt upperLetters i;
      value = builtins.elemAt lowerLetters i;
    }) 26
  );

  lowerFirstChar = c: if builtins.hasAttr c upperToLower then upperToLower.${c} else c;

  isAsciiLetter = c: builtins.hasAttr c upperToLower || builtins.elem c lowerLetters;

  extraPrefix = "extra";

  hasExtraPrefix =
    key:
    builtins.isString key
    && builtins.substring 0 (builtins.stringLength extraPrefix) key == extraPrefix;

  keyRest =
    key:
    builtins.substring (builtins.stringLength extraPrefix) (
      builtins.stringLength key - builtins.stringLength extraPrefix
    ) key;

  firstChar = s: builtins.substring 0 1 s;

  tailChars =
    s: if builtins.stringLength s < 2 then "" else builtins.substring 1 (builtins.stringLength s - 1) s;

  # Rendered key name of a well-formed extra key. Validation failures throw
  # in resolveExtraKey, not here.
  renderedKeyName =
    key:
    let
      rest = keyRest key;
    in
    "${lowerFirstChar (firstChar rest)}${tailChars rest}";

  # Resolve one harness group key to its rendered key name. Example:
  # `extraModel` and `extramodel` both render the key `model`. A key that
  # does not start with `extra`, an empty rest, and a first character
  # outside the letter table each fail evaluation with a named message.
  resolveExtraKey =
    key:
    if !(hasExtraPrefix key) then
      throw "harness-key: the key `${builtins.toJSON key}` of a harness group must start with `extra`"
    else
      let
        rest = keyRest key;
      in
      if rest == "" then
        throw "extra-key: the key `extra` has an empty rest; the rendered key name is absent"
      else
        let
          first = firstChar rest;
        in
        if !(isAsciiLetter first) then
          throw "extra-key: the key `${key}` starts the rendered name with `${first}`; want an ASCII letter A to Z or a to z"
        else
          renderedKeyName key;

  # Resolve one harness group from declaration names to rendered names. The
  # values pass through without a schema check.
  resolveHarnessGroup =
    group:
    if !(builtins.isAttrs group) then
      throw "harness-group: a harness group must be an attribute set, got `${builtins.typeOf group}`"
    else
      let
        pairs = builtins.map (k: {
          name = resolveExtraKey k;
          value = group.${k};
        }) (builtins.attrNames group);
        names = builtins.map (p: p.name) pairs;
        uniq = builtins.foldl' (acc: n: if builtins.elem n acc then acc else acc ++ [ n ]) [ ] names;
      in
      if builtins.length uniq != builtins.length names then
        throw "extra-key: two keys of one harness group render the same key name"
      else
        builtins.listToAttrs pairs;

  # The empty agents group: no harness selected, no entries declared.
  emptyAgents = {
    uses = [ ];
    mcp = { };
    roles = { };
    opencode = { };
  };

  # The seven option kinds are the closed vocabulary (spec-capability-kinds,
  # adr-capability-kind-model). The factory models the live kinds only. The
  # kind `plugin` is not live and holds no render branch and no asset root.
  optionKinds = [
    "skill"
    "command"
    "mcp"
    "reference"
    "plugin"
    "model"
    "worktree"
  ];

  # A file kind emits a file. A config kind writes a key into the rendered
  # opencode file. The kind `mcp` adds no key of its own and no file of its
  # own (spec-capability-kinds, C-CL04).
  fileKinds = [
    "skill"
    "command"
  ];

  configKinds = [
    "reference"
    "model"
    "worktree"
  ];

  homeValues = [
    "shipped"
    "repo-local"
  ];

  whenValues = [
    "always"
    "ddd"
    "design-tool"
  ];

  emitterValues = [
    "capability"
    "design"
  ];

  # The version 3.0.0 skill chain (spec-role-permissions, C-FCL-06-05). The
  # chain maps unconditionally to the `skill` allow rules. The `when`
  # activation filters a bundle instruction skill only.
  legacySkillChain = [
    "asd-ste-100"
    "ddd-review"
    "artifact-master"
    "expert-role"
  ];

  # The factory data table of the config kinds (spec-capability-kinds
  # interface 7, adr-capability-value-source). The sub-table `mcp` is the
  # existing table `canonicalMcp`; the kind `mcp` adds no key of its own. A
  # file kind reads no table entry, and a repo-local model adds no value.
  capabilityValues = {
    reference = {
      opencode-v2 = {
        repository = "sst/opencode";
        branch = "dev";
      };
    };
    model = { };
    worktree = {
      phase4 = "../worktrees";
    };
    mcp = canonicalMcp;
  };

  # Whether the factory data table holds the value of a shipped config
  # capability (spec-capability-kinds Errors).
  hasCapabilityValue =
    kind: name:
    builtins.hasAttr kind capabilityValues
    && builtins.isAttrs capabilityValues.${kind}
    && builtins.hasAttr name capabilityValues.${kind};

  # Validate one capability entry of one role (spec-capability-kinds
  # invariant 1, 2, 6, 7, 9 and spec-capability-ship interface 1 to 5). The
  # field set is exact. The kind `plugin` fails with a message that names
  # the kind. A file kind holds the field `asset`; a config kind holds no
  # asset. The value of a shipped config kind is in `capabilityValues`.
  # Returns the entry.
  validateCapability =
    roleName: cap:
    if !(builtins.isAttrs cap) then
      throw "capability-type: a capability of the role `${roleName}` must be an attribute set, got `${builtins.typeOf cap}`"
    else
      let
        knownFields = [
          "kind"
          "name"
          "home"
          "when"
          "emitter"
          "asset"
          "instruction"
        ];
        unknown = builtins.filter (f: !(builtins.elem f knownFields)) (builtins.attrNames cap);
      in
      if unknown != [ ] then
        throw "capability-field: a capability of the role `${roleName}` holds the unknown field `${builtins.head unknown}`"
      else if
        !(cap ? kind) || !(builtins.isString cap.kind) || !(builtins.elem cap.kind optionKinds)
      then
        throw "capability-kind: a capability of the role `${roleName}` holds a kind outside the seven kinds skill, command, mcp, reference, plugin, model, worktree"
      else if cap.kind == "plugin" then
        throw "capability-kind: the kind `plugin` of a capability of the role `${roleName}` is not live; the factory models the live kinds only"
      else if !(cap ? name) || !(builtins.isString cap.name) || cap.name == "" then
        throw "capability-name: a capability of the role `${roleName}` needs a non-empty string `name`"
      else if !(cap ? home) then
        throw "capability-home: the capability `${cap.name}` of the role `${roleName}` needs the home `shipped` or `repo-local`"
      else if !(builtins.elem cap.home homeValues) then
        throw "capability-home: the capability `${cap.name}` of the role `${roleName}` holds the home `${builtins.toJSON cap.home}`; want `shipped` or `repo-local`"
      else if (cap ? when) && !(builtins.elem cap.when whenValues) then
        throw "capability-when: the capability `${cap.name}` of the role `${roleName}` must hold `when` always, ddd, or design-tool"
      else if (cap ? emitter) && !(builtins.elem cap.emitter emitterValues) then
        throw "capability-emitter: the capability `${cap.name}` of the role `${roleName}` must hold `emitter` capability or design"
      else if builtins.elem cap.kind fileKinds then
        if !(cap ? asset) then
          throw "capability-asset: the file kind `${cap.kind}` of the capability `${cap.name}` of the role `${roleName}` needs the field `asset`"
        else if builtins.typeOf cap.asset != "path" then
          throw "capability-asset: the field `asset` of the capability `${cap.name}` of the role `${roleName}` must be a path literal, got `${builtins.typeOf cap.asset}`"
        else if cap ? instruction then
          throw "capability-field: the file kind `${cap.kind}` of the capability `${cap.name}` of the role `${roleName}` holds the field `instruction`"
        else
          let
            emitter = cap.emitter or "capability";
            root = if cap.kind == "skill" then "skills" else "commands";
          in
          if
            cap.home == "shipped"
            && emitter == "capability"
            && builtins.match ".*/assets/${root}/.*" (toString cap.asset) == null
          then
            throw "capability-asset: the shipped file capability `${cap.name}` of the role `${roleName}` points outside `assets/${root}/`"
          else if cap.home == "repo-local" && builtins.match ".*/assets/.*" (toString cap.asset) != null then
            throw "capability-asset: the repo-local file capability `${cap.name}` of the role `${roleName}` points inside the asset tree"
          else
            cap
      else if cap.kind == "mcp" then
        if cap ? asset then
          throw "capability-asset: the config kind `mcp` of the capability `${cap.name}` of the role `${roleName}` holds no `asset`"
        else if !(cap ? instruction) then
          throw "capability-instruction: the `mcp` capability `${cap.name}` of the role `${roleName}` needs the field `instruction`"
        else if !(builtins.isString cap.instruction) || cap.instruction == "" then
          throw "capability-instruction: the field `instruction` of the `mcp` capability `${cap.name}` of the role `${roleName}` must name a `skill` capability"
        else
          cap
      else if cap ? asset then
        throw "capability-asset: the config kind `${cap.kind}` of the capability `${cap.name}` of the role `${roleName}` holds no `asset`"
      else if cap ? instruction then
        throw "capability-field: the config kind `${cap.kind}` of the capability `${cap.name}` of the role `${roleName}` holds the field `instruction`"
      else if cap.home == "shipped" && !(hasCapabilityValue cap.kind cap.name) then
        throw "capability-value: the shipped config capability `${cap.name}` of the role `${roleName}` has no entry `capabilityValues.${cap.kind}.${cap.name}`"
      else
        cap;

  # Validate the capability list of one role and the bundle link of each
  # `mcp` capability (spec-capability-kinds invariant 9). The instruction
  # skill is a `skill` capability of the same role with the home `shipped`
  # and the same value of `when`. Returns the validated list.
  validateCapabilities =
    roleName: caps:
    if !(builtins.isList caps) then
      throw "capability-list: the field `capabilities` of the role `${roleName}` must be a list"
    else
      let
        validated = builtins.map (validateCapability roleName) caps;
        link =
          cap:
          if cap.kind != "mcp" then
            cap
          else
            let
              target = builtins.filter (c: c.kind == "skill" && c.name == cap.instruction) validated;
            in
            if target == [ ] then
              throw "capability-instruction: the `mcp` capability `${cap.name}` of the role `${roleName}` names no `skill` capability `${cap.instruction}` of the same role"
            else if (builtins.head target).home != "shipped" then
              throw "capability-instruction: the instruction skill `${cap.instruction}` of the `mcp` capability `${cap.name}` of the role `${roleName}` must hold the home `shipped`"
            else if ((builtins.head target).when or "always") != (cap.when or "always") then
              throw "capability-instruction: the `mcp` capability `${cap.name}` and its instruction skill `${cap.instruction}` of the role `${roleName}` must hold the same value of `when`"
            else
              cap;
      in
      builtins.map link validated;

  # The role-contract table (spec-role-permissions, adr-permission-source).
  # One entry for each known rendered role name. Each entry holds the two
  # axes as data: the ownership path patterns, the capability set
  # (spec-capability-kinds), the governance rules, and the shell rules of
  # the role. The table is a lookup only: the derive
  # function writes the rule order as a list literal, because
  # `builtins.attrNames` sorts the names (RC01-C2).
  roleContracts = {
    artifact-master = {
      ownership = [ ];
      research = "deny";
      capabilities = validateCapabilities "artifact-master" [
        {
          kind = "skill";
          name = "artifact-master";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/artifact-master/SKILL.md;
        }
        {
          kind = "skill";
          name = "expert-role";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/expert-role/SKILL.md;
        }
        {
          kind = "skill";
          name = "coverage-audit";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/coverage-audit/SKILL.md;
        }
        {
          kind = "command";
          name = "plan-pn";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/plan-pn.md;
        }
        {
          kind = "command";
          name = "interview";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/interview.md;
        }
        {
          kind = "command";
          name = "coverage-audit";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/coverage-audit.md;
        }
        {
          kind = "reference";
          name = "opencode-v2";
          home = "shipped";
          when = "always";
        }
        {
          kind = "model";
          name = "artifact-master";
          home = "repo-local";
          when = "always";
        }
        {
          kind = "worktree";
          name = "phase4";
          home = "shipped";
          when = "always";
        }
      ];
      governance = {
        subagent = "allow";
        question = "allow";
      };
      shell = {
        broad = "ask";
        specific = [
          {
            resource = "git status *";
            effect = "allow";
          }
          {
            resource = "git diff *";
            effect = "allow";
          }
          {
            resource = "git log *";
            effect = "allow";
          }
          {
            resource = "git show *";
            effect = "allow";
          }
          {
            resource = "git add *";
            effect = "allow";
          }
          {
            resource = "git commit *";
            effect = "allow";
          }
          {
            resource = "git switch *";
            effect = "allow";
          }
          {
            resource = "git branch *";
            effect = "allow";
          }
          {
            resource = "git checkout -b *";
            effect = "allow";
          }
          {
            resource = "git push *";
            effect = "deny";
          }
          {
            resource = "sh .opencode/scripts/coverage-audit.sh *";
            effect = "allow";
          }
          {
            resource = "find *";
            effect = "allow";
          }
          {
            resource = "grep *";
            effect = "allow";
          }
          {
            resource = "head *";
            effect = "allow";
          }
          {
            resource = "tail *";
            effect = "allow";
          }
          {
            resource = "cat *";
            effect = "allow";
          }
          {
            resource = "ls *";
            effect = "allow";
          }
          {
            resource = "echo *";
            effect = "allow";
          }
          {
            resource = "dirname *";
            effect = "allow";
          }
          {
            resource = "basename *";
            effect = "allow";
          }
          {
            resource = "sort *";
            effect = "allow";
          }
          {
            resource = "uniq *";
            effect = "allow";
          }
          {
            resource = "wc *";
            effect = "allow";
          }
          {
            resource = "diff *";
            effect = "allow";
          }
          {
            resource = "tr *";
            effect = "allow";
          }
          {
            resource = "readlink *";
            effect = "allow";
          }
          {
            resource = "printf *";
            effect = "allow";
          }
          {
            resource = "cut *";
            effect = "allow";
          }
          {
            resource = ": *";
            effect = "allow";
          }
        ];
      };
    };
    requirement-expert = {
      ownership = [
        {
          resource = "docs/artifact/*/changes/*/README.md";
          effect = "allow";
        }
        {
          resource = "docs/artifact/*/changes/*/requirements/*";
          effect = "allow";
        }
        {
          resource = "docs/artifact/README.md";
          effect = "allow";
        }
        {
          resource = "docs/domain/*";
          effect = "allow";
        }
      ];
      research = "allow";
      capabilities = validateCapabilities "requirement-expert" [
        {
          kind = "skill";
          name = "asd-ste-100";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/asd-ste-100/SKILL.md;
        }
        {
          kind = "skill";
          name = "ddd-review";
          home = "shipped";
          when = "ddd";
          emitter = "design";
          asset = ../assets/design/ddd/skill/SKILL.md;
        }
        {
          kind = "command";
          name = "interview";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/interview.md;
        }
        {
          kind = "model";
          name = "requirement-expert";
          home = "repo-local";
          when = "always";
        }
      ];
      governance = {
        subagent = "deny";
        question = "deny";
      };
      shell = {
        broad = "deny";
        specific = [ ];
      };
    };
    solution-expert = {
      ownership = [
        {
          resource = "docs/artifact/*/changes/*/specifications/*";
          effect = "allow";
        }
        {
          resource = "docs/artifact/*/changes/*/decisions/*";
          effect = "allow";
        }
        {
          resource = "docs/artifact/*/changes/*/tasks/*";
          effect = "allow";
        }
        {
          resource = "docs/domain/*";
          effect = "allow";
        }
      ];
      research = "allow";
      capabilities = validateCapabilities "solution-expert" [
        {
          kind = "skill";
          name = "asd-ste-100";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/asd-ste-100/SKILL.md;
        }
        {
          kind = "skill";
          name = "ddd-review";
          home = "shipped";
          when = "ddd";
          emitter = "design";
          asset = ../assets/design/ddd/skill/SKILL.md;
        }
        {
          kind = "skill";
          name = "context7-mcp";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/context7-mcp/SKILL.md;
        }
        {
          kind = "skill";
          name = "codegraph";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/codegraph/SKILL.md;
        }
        {
          kind = "command";
          name = "interview";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/interview.md;
        }
        {
          kind = "command";
          name = "contract-review";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/contract-review.md;
        }
        {
          kind = "mcp";
          name = "context7";
          home = "shipped";
          when = "always";
          instruction = "context7-mcp";
        }
        {
          kind = "mcp";
          name = "codegraph";
          home = "shipped";
          when = "always";
          instruction = "codegraph";
        }
        {
          kind = "reference";
          name = "opencode-v2";
          home = "shipped";
          when = "always";
        }
        {
          kind = "model";
          name = "solution-expert";
          home = "repo-local";
          when = "always";
        }
      ];
      governance = {
        subagent = "deny";
        question = "deny";
      };
      shell = {
        broad = "deny";
        specific = [ ];
      };
    };
    artifact-release-expert = {
      ownership = [
        {
          resource = "docs/artifact/*/versions/*";
          effect = "allow";
        }
        {
          resource = "docs/artifact/*/README.md";
          effect = "allow";
        }
        {
          resource = "docs/artifact/*/changes/change-*";
          effect = "allow";
        }
        {
          resource = "docs/artifact/*/changes/*/README.md";
          effect = "deny";
        }
        {
          resource = "docs/artifact/*/changes/*/requirements/*";
          effect = "deny";
        }
        {
          resource = "docs/artifact/*/changes/*/specifications/*";
          effect = "deny";
        }
        {
          resource = "docs/artifact/*/changes/*/decisions/*";
          effect = "deny";
        }
        {
          resource = "docs/artifact/*/changes/*/tasks/*";
          effect = "deny";
        }
        {
          resource = "docs/artifact/*/changes/*/design/*";
          effect = "deny";
        }
      ];
      research = "allow";
      capabilities = validateCapabilities "artifact-release-expert" [
        {
          kind = "skill";
          name = "asd-ste-100";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/asd-ste-100/SKILL.md;
        }
        {
          kind = "skill";
          name = "artifact-cleanup";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/artifact-cleanup/SKILL.md;
        }
        {
          kind = "command";
          name = "release";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/release.md;
        }
        {
          kind = "command";
          name = "artifact-cleanup";
          home = "shipped";
          when = "always";
          asset = ../assets/commands/artifact-cleanup.md;
        }
        {
          kind = "model";
          name = "artifact-release-expert";
          home = "repo-local";
          when = "always";
        }
      ];
      governance = {
        subagent = "deny";
        question = "deny";
      };
      shell = {
        broad = "deny";
        specific = [
          {
            resource = "cp *";
            effect = "allow";
          }
          {
            resource = "mkdir -p *";
            effect = "allow";
          }
          {
            resource = "rm -rf docs/artifact/*/versions/*";
            effect = "allow";
          }
          {
            resource = "rm -rf docs/artifact/*/changes/change-*";
            effect = "allow";
          }
          {
            resource = "sh .opencode/scripts/artifact-cleanup.sh *";
            effect = "allow";
          }
        ];
      };
    };
    factory-expert = {
      ownership = [
        {
          resource = "services/factory/*";
          effect = "allow";
        }
        {
          resource = "docs/wiki/documentation/*";
          effect = "allow";
        }
        {
          resource = ".agents/skills/expert-role/*";
          effect = "allow";
        }
        {
          resource = "utils/agent/role/factory-expert/ROLE.md";
          effect = "allow";
        }
      ];
      research = "allow";
      capabilities = validateCapabilities "factory-expert" [
        {
          kind = "skill";
          name = "asd-ste-100";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/asd-ste-100/SKILL.md;
        }
        {
          kind = "skill";
          name = "context7-mcp";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/context7-mcp/SKILL.md;
        }
        {
          kind = "skill";
          name = "codegraph";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/codegraph/SKILL.md;
        }
        {
          kind = "mcp";
          name = "context7";
          home = "shipped";
          when = "always";
          instruction = "context7-mcp";
        }
        {
          kind = "mcp";
          name = "codegraph";
          home = "shipped";
          when = "always";
          instruction = "codegraph";
        }
        {
          kind = "reference";
          name = "opencode-v2";
          home = "shipped";
          when = "always";
        }
        {
          kind = "model";
          name = "factory-expert";
          home = "repo-local";
          when = "always";
        }
      ];
      governance = {
        subagent = "deny";
        question = "deny";
      };
      shell = {
        broad = "ask";
        specific = [
          {
            resource = "nix flake check *";
            effect = "allow";
          }
          {
            resource = "nix build *";
            effect = "allow";
          }
          {
            resource = "nix eval *";
            effect = "allow";
          }
          {
            resource = "git status *";
            effect = "allow";
          }
          {
            resource = "git diff *";
            effect = "allow";
          }
          {
            resource = "git log *";
            effect = "allow";
          }
          {
            resource = "git show *";
            effect = "allow";
          }
        ];
      };
    };
    designer-expert = {
      ownership = [
        {
          resource = "docs/artifact/*/changes/*/design/*";
          effect = "allow";
        }
      ];
      research = "allow";
      capabilities = validateCapabilities "designer-expert" [
        {
          kind = "skill";
          name = "asd-ste-100";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/asd-ste-100/SKILL.md;
        }
        {
          kind = "mcp";
          name = "figma";
          home = "shipped";
          when = "design-tool";
          instruction = "figma";
        }
        {
          kind = "skill";
          name = "figma";
          home = "shipped";
          when = "design-tool";
          asset = ../assets/skills/figma/SKILL.md;
        }
        {
          kind = "mcp";
          name = "pencil";
          home = "shipped";
          when = "design-tool";
          instruction = "pencil";
        }
        {
          kind = "skill";
          name = "pencil";
          home = "shipped";
          when = "design-tool";
          asset = ../assets/skills/pencil/SKILL.md;
        }
        {
          kind = "model";
          name = "designer-expert";
          home = "repo-local";
          when = "always";
        }
      ];
      governance = {
        subagent = "deny";
        question = "deny";
      };
      shell = {
        broad = "deny";
        specific = [ ];
      };
    };
    repository-expert = {
      ownership = [
        {
          resource = "README.md";
          effect = "allow";
        }
        {
          resource = "factory.nix";
          effect = "allow";
        }
        {
          resource = ".gitignore";
          effect = "allow";
        }
        {
          resource = "AGENTS.md";
          effect = "allow";
        }
        {
          resource = "devenv.nix";
          effect = "allow";
        }
        {
          resource = "flake.nix";
          effect = "allow";
        }
        {
          resource = ".agents/skills/*";
          effect = "allow";
        }
        {
          resource = ".opencode/commands/*";
          effect = "allow";
        }
        {
          resource = ".opencode/agents/*";
          effect = "allow";
        }
        {
          resource = "docs/wiki/documentation/artifact-driven/templates/*";
          effect = "allow";
        }
        {
          resource = "surface.tsv";
          effect = "allow";
        }
        {
          resource = "factory.config.yaml";
          effect = "allow";
        }
        {
          resource = ".opencode/opencode.jsonc";
          effect = "allow";
        }
        {
          resource = ".opencode/scripts/*";
          effect = "allow";
        }
        {
          resource = "docs/wiki/README.md";
          effect = "allow";
        }
        {
          resource = "docs/wiki/overview/*";
          effect = "allow";
        }
        {
          resource = "docs/wiki/repo-arch/consumer-guide.md";
          effect = "allow";
        }
        {
          resource = "docs/wiki/development/*";
          effect = "allow";
        }
      ];
      research = "allow";
      capabilities = validateCapabilities "repository-expert" [
        {
          kind = "skill";
          name = "asd-ste-100";
          home = "shipped";
          when = "always";
          asset = ../assets/skills/asd-ste-100/SKILL.md;
        }
      ];
      governance = {
        subagent = "deny";
        question = "deny";
      };
      shell = {
        broad = "ask";
        specific = [
          {
            resource = "nix flake check *";
            effect = "allow";
          }
          {
            resource = "nix build *";
            effect = "allow";
          }
          {
            resource = "nix eval *";
            effect = "allow";
          }
          {
            resource = "git status *";
            effect = "allow";
          }
          {
            resource = "git diff *";
            effect = "allow";
          }
          {
            resource = "git log *";
            effect = "allow";
          }
          {
            resource = "git show *";
            effect = "allow";
          }
        ];
      };
    };
  };

  # The restrictive default of a rendered role name outside the table
  # (spec-role-permissions, "The role names and the default"): the ownership
  # scope `none`, the local reads, the external research deny, the skill `*`
  # rule with the effect `ask`, the governance deny, and the broad shell
  # deny.
  defaultRoleContract = {
    ownership = [ ];
    research = "deny";
    capabilities = [ ];
    governance = {
      subagent = "deny";
      question = "deny";
    };
    shell = {
      broad = "deny";
      specific = [ ];
    };
  };

  # Derived ordered permission array of one rendered role name
  # (spec-role-permissions, "The render order"). The order is a list
  # literal: the broad `edit` deny, the ownership allows and the specific
  # ownership deny, the local reads, the external research, the skill set,
  # the governance, the broad `shell` rule, and the specific shell rules.
  # The table gives the data of each rule; it is not the source of the order
  # (RC01-C2). A rendered role name outside the table receives the
  # restrictive default. The skill allow rules hold the unconditional
  # version 3.0.0 chain and the active instruction skill of each tool bundle,
  # in the order of the capability list (C-CL33, C-CL34). The design tool
  # arrives as an input (C-FCL-06-02). A `design-tool` instruction skill is
  # active only when the design tool equals its name; the chain maps
  # unconditionally (C-FCL-06-05).
  permissionRulesFor =
    roleName: tool:
    let
      c =
        if builtins.hasAttr roleName roleContracts then roleContracts.${roleName} else defaultRoleContract;
      skillActive =
        cap:
        let
          when = cap.when or "always";
        in
        when == "always" || (when == "design-tool" && cap.name == tool);
      # The allow rule of one `skill` capability (spec-role-permissions). The
      # legacy chain maps unconditionally. Every other active skill capability
      # adds its rule, so a standalone instruction skill grants its load
      # (spec-coverage-bundle C-CA23, C-FCA-06-02).
      skillAllowed =
        cap:
        builtins.elem cap.name legacySkillChain
        || skillActive cap;
      skillAllows = builtins.filter (cap: cap.kind == "skill" && skillAllowed cap) c.capabilities;
    in
    [ { action = "edit"; resource = "*"; effect = "deny"; } ]
    ++ builtins.map (p: { action = "edit"; inherit (p) resource effect; }) c.ownership
    ++ [
      {
        action = "read";
        resource = "*";
        effect = "allow";
      }
      {
        action = "glob";
        resource = "*";
        effect = "allow";
      }
      {
        action = "grep";
        resource = "*";
        effect = "allow";
      }
    ]
    ++ builtins.map (a: {
      action = a;
      resource = "*";
      effect = c.research;
    }) [
      "webfetch"
      "websearch"
    ]
    ++ [
      {
        action = "skill";
        resource = "*";
        effect = "ask";
      }
    ]
    ++ builtins.map (cap: {
      action = "skill";
      resource = cap.name;
      effect = "allow";
    }) skillAllows
    ++ [
      {
        action = "subagent";
        resource = "*";
        effect = c.governance.subagent;
      }
      {
        action = "question";
        resource = "*";
        effect = c.governance.question;
      }
    ]
    ++ [
      {
        action = "shell";
        resource = "*";
        effect = c.shell.broad;
      }
    ]
    ++ builtins.map (s: { action = "shell"; inherit (s) resource effect; }) c.shell.specific;

  # The shipped config-key entries of the rendered role set
  # (spec-harness-merge C-CL18, spec-capability-ship C-CL07). One entry per
  # shipped config capability: `references.<name>`, `agents.<role>.model`,
  # and `worktree.directory`. A repo-local capability adds no entry. Two
  # entries with the same path collapse to one when the value agrees; two
  # different values at one path fail evaluation (C-CL13).
  configKeyEntries =
    roleNames:
    let
      capsOf =
        r: if builtins.hasAttr r roleContracts then roleContracts.${r}.capabilities else [ ];
      perRole = builtins.concatLists (
        builtins.map (
          r:
          builtins.map (cap: {
            path =
              if cap.kind == "reference" then
                [
                  "references"
                  cap.name
                ]
              else if cap.kind == "worktree" then
                [
                  "worktree"
                  "directory"
                ]
              else
                [
                  "agents"
                  r
                  "model"
                ];
            value = capabilityValues.${cap.kind}.${cap.name};
          }) (builtins.filter (cap: builtins.elem cap.kind configKinds && cap.home == "shipped") (capsOf r))
        ) roleNames
      );
    in
    dedupeConfigEntries perRole;

  dedupeConfigEntries =
    entries:
    let
      paths = builtins.foldl' (
        acc: e: if builtins.elem e.path acc then acc else acc ++ [ e.path ]
      ) [ ] entries;
      pick =
        path:
        let
          group = builtins.filter (e: e.path == path) entries;
          first = builtins.head group;
          conflict = builtins.filter (e: e.value != first.value) (builtins.tail group);
        in
        if conflict == [ ] then
          first
        else
          throw "capability-duplicate: the config key path `${showPath path}` receives two capabilities with different values";
    in
    builtins.map pick paths;

  # Managed opencode settings (spec-harness-merge, the managed keys table).
  # Each rendered role name receives the derived ordered permission array of
  # spec-role-permissions in the managed key `agents.<role>.permissions`
  # (RC01-C1). The key path and the trace path use the rendered role name
  # (RC01-C3). The shipped config keys of the capability layer join the same
  # group (C-CL18). The design tool reaches the derive (C-FCL-06-02). The
  # argument is the rendered-role list, or the group `{ roleNames; tool; }`.
  managedOpencodeSettings =
    args:
    let
      roleNames = if builtins.isList args then args else args.roleNames;
      tool = if builtins.isAttrs args then args.tool or "unset" else "unset";
      permissions = builtins.listToAttrs (
        builtins.map (r: {
          name = r;
          value = {
            permissions = permissionRulesFor r tool;
          };
        }) roleNames
      );
    in
    builtins.foldl' (acc: e: setPath acc e.path e.value) { agents = permissions; } (
      configKeyEntries roleNames
    );

  # Managed key paths of the rendered opencode file as attribute paths. Each
  # role path is a rendered path in the file `agents.<role>.permissions`;
  # each shipped config kind adds its rendered key path (spec-harness-merge,
  # C-CL18).
  managedOpencodePathLists =
    roleNames:
    builtins.map (r: [
      "agents"
      r
      "permissions"
    ]) roleNames
    ++ builtins.map (e: e.path) (configKeyEntries roleNames);

  showPath = path: builtins.concatStringsSep "." path;

  hasPath =
    attrs: path:
    if path == [ ] then
      true
    else if !(builtins.isAttrs attrs) then
      false
    else if !(builtins.hasAttr (builtins.head path) attrs) then
      false
    else
      hasPath attrs.${builtins.head path} (builtins.tail path);

  setPath =
    attrs: path: value:
    let
      base = if builtins.isAttrs attrs then attrs else { };
      key = builtins.head path;
      rest = builtins.tail path;
    in
    if rest == [ ] then
      base // { ${key} = value; }
    else
      base
      // {
        ${key} = setPath (if builtins.hasAttr key base then base.${key} else { }) rest value;
      };

  getPath = attrs: path: builtins.foldl' (a: k: a.${k}) attrs path;

  # Canonical MCP entries of the managed layer (spec-mcp-dialect). The
  # factory owns the `command`, `args`, and `env` values of each entry.
  # `enabled` is user-wins with the default `false`.
  canonicalMcp = {
    figma = {
      command = "npx";
      args = [
        "-y"
        "figma-ui-mcp"
      ];
      env = {
        FIGMA_UI_MCP_TARGET = "Figma Desktop";
      };
    };
    pencil = {
      command = "pen-mcp-server";
      args = [
        "--app"
        "desktop"
      ];
      env = { };
    };
    context7 = {
      command = "npx";
      args = [
        "-y"
        "@upstash/context7-mcp"
      ];
      env = { };
    };
    codegraph = {
      command = "codegraph";
      args = [
        "serve"
        "--mcp"
      ];
      env = { };
    };
  };

  hasField = attrs: field: attrs != null && builtins.isAttrs attrs && builtins.hasAttr field attrs;

  # Merge one MCP entry per leaf field (C-08, spec-mcp-dialect, the author
  # environment path). A canonical entry keeps the canonical `command` and
  # `args` as whole fields and the canonical keys of `env` per key; each
  # ignored project or local value gives one log line. An author `env` key
  # that the canonical entry does not set joins the merged `env` (local over
  # project). `enabled` takes the value of the last layer that sets it. A
  # user entry takes the last layer that sets each field. proj and loc are
  # validated entry sets or null when the layer holds no entry of this name.
  # selected is true when the tool feed selects this entry (C-14): the
  # default of `enabled` is then true, else false. The feed changes the entry
  # set and the default of `enabled` only.
  mergeMcpEntry =
    name: proj: loc: selected:
    let
      canonical = if builtins.hasAttr name canonicalMcp then canonicalMcp.${name} else null;
      pick =
        field: dflt:
        if hasField loc field then
          loc.${field}
        else if hasField proj field then
          proj.${field}
        else
          dflt;
      managedFieldTraces =
        field:
        builtins.filter (t: t != null) [
          (if hasField proj field then "managed-wins: mcp.${name}.${field} from project" else null)
          (if hasField loc field then "managed-wins: mcp.${name}.${field} from local" else null)
        ];
      # The canonical key set of the `env` of this entry, computed once at
      # the entry name (spec-harness-merge managed keys 12, FAM-01-C3).
      canonicalEnvKeys = builtins.attrNames canonical.env;
      layerEnvKeys =
        layer:
        if hasField layer "env" && builtins.isAttrs layer.env then
          builtins.attrNames layer.env
        else
          [ ];
      layerSetsEnvKey =
        layer: key:
        hasField layer "env" && builtins.isAttrs layer.env && builtins.hasAttr key layer.env;
      # One trace line for each canonical `env` key that a raw layer entry
      # sets (spec-harness-merge managed keys 13, FAM-01-C10). The line names
      # the ignored key: `managed-wins: mcp.<name>.env.<KEY> from <layer>`.
      envKeyTraces =
        key:
        builtins.filter (t: t != null) [
          (
            if layerSetsEnvKey proj key then
              "managed-wins: mcp.${name}.env.${key} from project"
            else
              null
          )
          (
            if layerSetsEnvKey loc key then
              "managed-wins: mcp.${name}.env.${key} from local"
            else
              null
          )
        ];
      # The author environment keys: the union of the project and local `env`
      # keys, minus the canonical keys. A key that only the project layer sets
      # takes the project value; a key that the local layer sets takes the
      # local value (spec-mcp-dialect author environment path 6 and 7).
      projectEnvKeys = layerEnvKeys proj;
      authorEnvKeys = builtins.filter (k: !(builtins.elem k canonicalEnvKeys)) (
        projectEnvKeys ++ builtins.filter (k: !(builtins.elem k projectEnvKeys)) (layerEnvKeys loc)
      );
      authorEnv = builtins.listToAttrs (
        builtins.map (k: {
          name = k;
          value = if layerSetsEnvKey loc k then loc.env.${k} else proj.env.${k};
        }) authorEnvKeys
      );
    in
    if canonical != null then
      {
        entry = {
          command = canonical.command;
          args = canonical.args;
          env = canonical.env // authorEnv;
          enabled = pick "enabled" (if selected then true else false);
        };
        traces =
          builtins.concatLists (
            builtins.map managedFieldTraces [
              "command"
              "args"
            ]
          )
          ++ builtins.concatLists (builtins.map envKeyTraces canonicalEnvKeys);
      }
    else
      {
        entry = {
          command = pick "command" null;
          args = pick "args" [ ];
          env = pick "env" { };
          enabled = pick "enabled" true;
        };
        traces = [ ];
      };

  # Merge the MCP source of the project and local layers with the tool
  # feed (C-14, spec-designer-scope). Returns the merged entries with
  # defaults applied and the managed-wins trace lines. The merged entry set
  # holds the canonical entry of the selected tool with the default
  # `enabled = true`, also when no layer declares the entry. A canonical
  # entry that the tool does not select is present only when the project
  # layer or the local layer declares it, with the default
  # `enabled = false`. The feed adds no other entry.
  mergeMcp =
    projectMcp: localMcp: tool:
    let
      p = if projectMcp == null then { } else projectMcp;
      l = if localMcp == null then { } else localMcp;
      declared =
        builtins.attrNames p ++ builtins.filter (n: !(builtins.hasAttr n p)) (builtins.attrNames l);
      selected = if builtins.hasAttr tool canonicalMcp then tool else null;
      names =
        declared ++ (if selected != null && !(builtins.elem selected declared) then [ selected ] else [ ]);
      per =
        n:
        mergeMcpEntry n (if builtins.hasAttr n p then p.${n} else null) (
          if builtins.hasAttr n l then l.${n} else null
        ) (selected != null && n == selected);
    in
    {
      entries = builtins.listToAttrs (
        builtins.map (n: {
          name = n;
          value = (per n).entry;
        }) names
      );
      traces = builtins.concatLists (builtins.map (n: (per n).traces) names);
    };

  # One MCP source rendered into the opencode version 2 dialect
  # (spec-mcp-dialect, the dialect mapping table): `command` and `args`
  # join into the `command` array with `type = "local"`, `env` renders as
  # `environment`, and `enabled` renders as the inverse `disabled`, always
  # written. The rendered entry name is the source name.
  mcpDialectEntry = name: entry: {
    command = [ entry.command ] ++ entry.args;
    type = "local";
    environment = entry.env;
    disabled = !entry.enabled;
  };
  # The built-in declaration of the designer-expert role (C-18,
  # spec-designer-role). The factory adds it to the role set after the
  # validation of the project layer and the local layer. The source is the
  # role source `assets/roles/designer-expert/ROLE.md`.
  designerBuiltIn = {
    description = "The role owns the Design artifact and the flow, the layout, and the interaction of the product. Use for writing the Design artifact of a change.";
    source = ../assets/roles/designer-expert/ROLE.md;
  };

  # Deep user-wins merge of two layers. Attribute sets recurse per leaf key;
  # any other value takes the second (later) layer.
  deepUserWins =
    a: b:
    if builtins.isAttrs a && builtins.isAttrs b then
      let
        shared = builtins.filter (k: builtins.hasAttr k b) (builtins.attrNames a);
        merged = builtins.listToAttrs (
          builtins.map (k: {
            name = k;
            value = deepUserWins a.${k} b.${k};
          }) shared
        );
      in
      a // b // merged
    else
      b;

  # Merge the project and local layers with the managed layer in the order
  # managed, then project, then local. project and local are validated
  # agents groups (see modules/orchestration.nix); a layer that holds no
  # key leaves the earlier layer standing. `uses` is presence-wins: an
  # explicit local `uses` (even `[ ]`) wins over the project value, and an
  # absent local key keeps the project value. An empty `uses` list selects
  # no harness. roleNames are the
  # rendered content experts used for the managed permission table.
  mergeAgents =
    {
      project,
      local ? { },
      roleNames ? [ ],
      tool ? "unset",
      ux ? false,
    }:
    let
      p = project;
      l = local;
      mergedUses = if l ? uses then l.uses else (p.uses or [ ]);
      selected = h: builtins.elem h mergedUses;
      mcpMerged = mergeMcp (p.mcp or null) (l.mcp or null) tool;
      mergedMcp = mcpMerged.entries;
      mcpTraces = if mergedUses == [ ] then [ ] else mcpMerged.traces;
      mergedUserRoles = deepUserWins (p.roles or { }) (l.roles or { });
      # The built-in declaration of the designer-expert role joins the role
      # set after the validation of the project layer and the local layer
      # (C-18): the name is `designer-expert` and the source is the role
      # source. The built-in declaration passes the reserved-name rule, and
      # no merged user declaration of the name exists: both layers reject
      # the name in evalAgents. When the ux flag is false, the role set
      # holds no designer-expert declaration.
      mergedRoles =
        if ux then mergedUserRoles // { designer-expert = designerBuiltIn; } else mergedUserRoles;
      mergedHarness = h: deepUserWins (p.${h} or { }) (l.${h} or { });
      baseOpencode = mergedHarness "opencode";
      managed = managedOpencodeSettings { inherit roleNames tool; };
      managedPaths = managedOpencodePathLists roleNames;
      withManaged = builtins.foldl' (
        acc: path: setPath acc path (getPath managed path)
      ) baseOpencode managedPaths;
      opencodeTraces =
        if selected "opencode" then
          builtins.concatLists (
            builtins.map (
              path:
              builtins.filter (t: t != null) [
                (if hasPath (p.opencode or { }) path then "managed-wins: ${showPath path} from project" else null)
                (if hasPath (l.opencode or { }) path then "managed-wins: ${showPath path} from local" else null)
              ]
            ) managedPaths
          )
        else
          [ ];
      force = builtins.map (msg: builtins.trace msg true) (opencodeTraces ++ mcpTraces);
      result = {
        uses = mergedUses;
        mcp = mergedMcp;
        roles = mergedRoles;
        opencode = withManaged;
      };
    in
    builtins.deepSeq force result;

  # Render the merged opencode settings in one pass into the one document
  # `.opencode/opencode.jsonc`. An unselected harness receives no file and
  # no entry. Each merged entry renders with `disabled = !enabled`, so a
  # disabled entry stays configured without a connection; with no entry
  # the opencode file holds no `mcp.servers` group. Returns the file
  # declarations and the rendered-source list of the run (C-03). Each file
  # has the copy mode `managed`.
  renderSelected =
    {
      merged,
      uses,
    }:
    let
      select = h: builtins.elem h uses;
      entryNames = builtins.attrNames (merged.mcp or { });
      dialectGroup = builtins.listToAttrs (
        builtins.map (n: {
          name = n;
          value = mcpDialectEntry n merged.mcp.${n};
        }) entryNames
      );
      opencodeDoc =
        (merged.opencode or { })
        // (
          if entryNames == [ ] then
            { }
          else
            {
              mcp = {
                servers = dialectGroup;
              };
            }
        );
      opencodeSource = builtins.toFile "opencode.jsonc" (builtins.toJSON opencodeDoc);
      decls = (
        if select "opencode" then
          [
            {
              rel = ".opencode/opencode.jsonc";
              source = opencodeSource;
              copyMode = "managed";
            }
          ]
        else
          [ ]
      );
    in
    {
      fileDecls = decls;
      renderedSources = builtins.map (d: d.source) decls;
    };

  # Render the shipped file capabilities of the enabled rendered-role set
  # (spec-capability-kinds interface 10, spec-capability-ship interface 6 to
  # 9, C-CL03, C-CL05, C-CL09, C-CL29). The function skips a capability with
  # the emitter `design`, because the design module owns that emit. An
  # inactive capability emits no file. The instruction skill of an active
  # `mcp` bundle is a `skill` capability, so the `skill` branch emits its
  # file once; the field `instruction` is a validation link only. Two
  # capabilities with the same emitted path collapse to one entry when the
  # asset agrees; two different assets at one path fail evaluation
  # (C-CL13). Every file routes through the rendered-source list. Returns
  # the file declarations and the rendered-source list of the run.
  capabilitySources =
    { roleNames, tool ? "unset" }:
    let
      capsOf =
        r: if builtins.hasAttr r roleContracts then roleContracts.${r}.capabilities else [ ];
      active =
        cap:
        let
          when = cap.when or "always";
        in
        when == "always" || (when == "design-tool" && cap.name == tool);
      emit =
        cap:
        cap.kind != "mcp"
        && builtins.elem cap.kind fileKinds
        && cap.home == "shipped"
        && (cap.emitter or "capability") == "capability"
        && active cap;
      entries = builtins.concatLists (
        builtins.map (
          r:
          builtins.map (
            cap:
            let
              rel =
                if cap.kind == "skill" then
                  ".agents/skills/${cap.name}/SKILL.md"
                else
                  ".opencode/commands/${cap.name}.md";
              source = builtins.toFile (builtins.baseNameOf (toString cap.asset)) (
                builtins.readFile cap.asset
              );
            in
            {
              inherit rel source;
              asset = cap.asset;
              copyMode = "managed";
            }
          ) (builtins.filter emit (capsOf r))
        ) roleNames
      );
      deduped = dedupeFileEntries entries;
    in
    {
      fileDecls = builtins.map (e: {
        inherit (e) rel source copyMode;
      }) deduped;
      renderedSources = builtins.map (e: e.source) deduped;
    };

  dedupeFileEntries =
    entries:
    let
      rels = builtins.foldl' (
        acc: e: if builtins.elem e.rel acc then acc else acc ++ [ e.rel ]
      ) [ ] entries;
      pick =
        rel:
        let
          group = builtins.filter (e: e.rel == rel) entries;
          first = builtins.head group;
          conflict = builtins.filter (e: toString e.asset != toString first.asset) (builtins.tail group);
        in
        if conflict == [ ] then
          first
        else
          throw "capability-duplicate: the emitted path `${rel}` receives two capabilities with different bytes";
    in
    builtins.map pick rels;
in
{
  inherit
    harnessNames
    upperToLower
    lowerFirstChar
    isAsciiLetter
    hasExtraPrefix
    keyRest
    firstChar
    renderedKeyName
    resolveExtraKey
    resolveHarnessGroup
    emptyAgents
    canonicalMcp
    designerBuiltIn
    mergeMcpEntry
    mergeMcp
    mcpDialectEntry
    optionKinds
    capabilityValues
    legacySkillChain
    roleContracts
    defaultRoleContract
    permissionRulesFor
    managedOpencodeSettings
    managedOpencodePathLists
    capabilitySources
    configKeyEntries
    dedupeConfigEntries
    dedupeFileEntries
    hasPath
    setPath
    getPath
    deepUserWins
    mergeAgents
    renderSelected
    ;
}
