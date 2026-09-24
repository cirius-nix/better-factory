# services/factory/modules/orchestration.nix
# Facade group `factory.project.agents` (spec-harness-merge). Holds the
# option declarations and the validation of the group: the typed key `uses`,
# the typed groups `mcp` and `roles`, and the one harness group `opencode`.
# The merge itself lives in lib/harness.nix. Pure Nix with no nixpkgs
# dependency.
let
  harness = import ../lib/harness.nix;
  roles = import ../lib/roles.nix;

  harnessNames = harness.harnessNames;

  emptyAgents = harness.emptyAgents;

  knownKeys = [
    "uses"
    "mcp"
    "roles"
    "opencode"
  ];

  harnessGroups = [
    "opencode"
  ];

  agentsOptions = {
    uses = {
      type = "list of opencode";
      default = [ ];
      description = "Selected harnesses; the only entry is opencode.";
    };
    mcp = {
      type = "attrs of MCP entries";
      default = { };
      description = "One MCP source entry per key (spec-mcp-dialect).";
    };
    roles = {
      type = "attrs of role declarations";
      default = { };
      description = "One role declaration per key (spec-role-render).";
    };
    opencode = {
      type = "attrs of extra keys";
      default = { };
      description = "Extra opencode settings file keys; each key starts with `extra`.";
    };
  };

  show = v: if builtins.isString v then "`${v}`" else builtins.toJSON v;

  # One assertion entry per invariant of the task: the `uses` value, the
  # extra-key name rules, the harness group key rule, and the duplicate
  # rendered names. Each message names the item. The modeled-key list
  # invariant is enforced by checkModeledKeys in modules/facade.nix, which
  # fails when the modeled-key list and the root option definitions differ.
  agentsAssertions =
    value:
    let
      uses = value.uses or [ ];
      usesBad =
        if !(builtins.isList uses) then
          [ uses ]
        else
          builtins.filter (e: !(builtins.isString e) || !(builtins.elem e harnessNames)) uses;
      usesEntry = {
        name = "uses-value";
        assertion = usesBad == [ ];
        message =
          if !(builtins.isList uses) then
            "uses-value: the key `uses` of the group `agents` must be a list of harness names, got `${builtins.typeOf uses}`"
          else if usesBad == [ ] then
            "uses-value: an entry of `uses` is outside the value set opencode"
          else
            "uses-value: the entry ${show (builtins.head usesBad)} of `uses` must be opencode";
      };
      perKey =
        h: k:
        let
          rest = harness.keyRest k;
          first = harness.firstChar rest;
        in
        [
          {
            name = "harness-key";
            assertion = harness.hasExtraPrefix k;
            message = "harness-key: the key `${k}` of the harness group `${h}` must start with `extra`";
          }
          {
            name = "extra-key-rest";
            assertion = !(harness.hasExtraPrefix k) || rest != "";
            message = "extra-key-rest: the key `extra` of the harness group `${h}` has an empty rest; the rendered key name is absent";
          }
          {
            name = "extra-key-letter";
            assertion = !(harness.hasExtraPrefix k) || rest == "" || harness.isAsciiLetter first;
            message = "extra-key-letter: the key `${k}` of the harness group `${h}` starts the rendered name with `${first}`; want an ASCII letter A to Z or a to z";
          }
        ];
      perGroup =
        h:
        let
          g = value.${h} or { };
        in
        if !(builtins.isAttrs g) then
          [
            {
              name = "${h}-group-type";
              assertion = false;
              message = "harness-group: the harness group `${h}` must be an attribute set, got `${builtins.typeOf g}`";
            }
          ]
        else
          let
            keys = builtins.attrNames g;
            wellFormed =
              k:
              harness.hasExtraPrefix k
              && harness.keyRest k != ""
              && harness.isAsciiLetter (harness.firstChar (harness.keyRest k));
            rendered = builtins.map harness.renderedKeyName (builtins.filter wellFormed keys);
            uniq = builtins.foldl' (acc: n: if builtins.elem n acc then acc else acc ++ [ n ]) [ ] rendered;
          in
          builtins.concatLists (builtins.map (perKey h) keys)
          ++ [
            {
              name = "extra-key-duplicate";
              assertion = builtins.length uniq == builtins.length rendered;
              message = "extra-key-duplicate: two keys of the harness group `${h}` render the same key name";
            }
          ];
    in
    [ usesEntry ] ++ builtins.concatLists (builtins.map perGroup harnessGroups);

  # Validate one agents group value and return the sparse validated group:
  # absent keys stay absent so the merge keeps the "last layer that sets the
  # key" rule. Harness groups return with rendered key names. Throws the
  # naming message of the first failing invariant.
  evalAgents =
    value:
    if !(builtins.isAttrs value) then
      throw "agents-type: the group `agents` below the root `factory.project` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k knownKeys)) keys;
      in
      if outside != [ ] then
        throw "agents-key: the key `${builtins.head outside}` of the group `agents` is outside the typed keys uses, mcp, roles, opencode"
      else
        let
          failing = builtins.filter (a: !a.assertion) (agentsAssertions value);
        in
        if failing != [ ] then
          throw (builtins.head failing).message
        else if (value ? mcp) && !(builtins.isAttrs value.mcp) then
          throw "agents-type: the key `mcp` of the group `agents` must be an attribute set, got `${builtins.typeOf value.mcp}`"
        else if (value ? roles) && !(builtins.isAttrs value.roles) then
          throw "agents-type: the key `roles` of the group `agents` must be an attribute set, got `${builtins.typeOf value.roles}`"
        else
          let
            # The name `designer-expert` is reserved to the factory (C-18,
            # spec-designer-role). A declaration of the name in the project
            # layer or in the local layer fails evaluation with a message
            # that names the reserved name. Both layers validate here: the
            # project declaration through evalAgents and the local
            # declaration through readLocalAgents.
            roleNameOf =
              n:
              let
                d = value.roles.${n};
              in
              if builtins.isAttrs d && d ? name && builtins.isString d.name then d.name else n;
            reserved = builtins.filter (
              n: builtins.elem n roles.reservedRoleNames || builtins.elem (roleNameOf n) roles.reservedRoleNames
            ) (builtins.attrNames (value.roles or { }));
          in
          if reserved != [ ] then
            throw "role-reserved: the name `designer-expert` is reserved to the factory; declare no role with the name `designer-expert` in the project layer or the local layer"
          else
            let
              checkedMcp = builtins.mapAttrs checkMcpEntry (value.mcp or { });
              checkedRoles = builtins.mapAttrs roles.checkRole (value.roles or { });
              result =
                (if value ? uses then { uses = value.uses; } else { })
                // {
                  mcp = checkedMcp;
                  roles = checkedRoles;
                }
                // (if value ? opencode then { opencode = harness.resolveHarnessGroup value.opencode; } else { });
            in
            builtins.deepSeq (builtins.attrValues checkedMcp) (
              builtins.deepSeq (builtins.attrValues checkedRoles) result
            );

  # Validate one MCP entry of the group `factory.project.agents.mcp.<name>`
  # (spec-mcp-dialect). `command` is a required non-empty string, except for
  # a canonical entry where the managed layer provides it and the author
  # enables the entry with `enabled = true` only. `args` is a list of
  # strings, `env` an attribute set of strings, and `enabled` a bool. An
  # unknown field fails evaluation. Returns the sparse validated entry.
  checkMcpEntry =
    name: entry:
    let
      canonical = builtins.hasAttr name harness.canonicalMcp;
      allowed = [
        "command"
        "args"
        "env"
        "enabled"
      ];
      unknown =
        if !(builtins.isAttrs entry) then
          [ ]
        else
          builtins.filter (f: !(builtins.elem f allowed)) (builtins.attrNames entry);
      argsOk =
        !(entry ? args) || (builtins.isList entry.args && builtins.all builtins.isString entry.args);
      envOk =
        !(entry ? env)
        || (builtins.isAttrs entry.env && builtins.all builtins.isString (builtins.attrValues entry.env));
    in
    if !(builtins.isAttrs entry) then
      throw "mcp-entry: the entry `mcp.${name}` must be an attribute set, got `${builtins.typeOf entry}`"
    else if unknown != [ ] then
      throw "mcp-field: the entry `mcp.${name}` holds the unknown field `${builtins.head unknown}`"
    else if !(entry ? command) && !canonical then
      throw "mcp-command: the entry `mcp.${name}` has no `command`; a user entry needs a non-empty command string"
    else if (entry ? command) && (!(builtins.isString entry.command) || entry.command == "") then
      throw "mcp-command: the `command` of the entry `mcp.${name}` must be a non-empty string"
    else if !argsOk then
      throw "mcp-args: the `args` of the entry `mcp.${name}` must be a list of strings"
    else if !envOk then
      throw "mcp-env: the `env` of the entry `mcp.${name}` must be an attribute set of strings"
    else if (entry ? enabled) && !(builtins.isBool entry.enabled) then
      throw "mcp-enabled: the `enabled` of the entry `mcp.${name}` must be a bool"
    else
      entry;

  # Read the local layer from `devenv.local.nix` at the repository root
  # (C-06). The file is read only when `builtins.pathExists` matches. An
  # absent file or path gives an empty key-absent group (no key set), so the
  # merge keeps the project value. The local group holds the key space of
  # the project group. A bad typed value fails evaluation, and no `tryEval`
  # hides it. localFile is null or a path; null gives the empty key-absent
  # group without touching the filesystem.
  readLocalAgents =
    localFile:
    if localFile == null || !(builtins.pathExists localFile) then
      { }
    else
      let
        v = import localFile;
        g =
          if
            builtins.isAttrs v
            && v ? factory
            && builtins.isAttrs v.factory
            && v.factory ? local
            && builtins.isAttrs v.factory.local
            && v.factory.local ? agents
          then
            v.factory.local.agents
          else
            null;
      in
      if g == null then { } else evalAgents g;
in
{
  inherit
    harness
    roles
    harnessNames
    emptyAgents
    knownKeys
    harnessGroups
    agentsOptions
    agentsAssertions
    evalAgents
    checkMcpEntry
    readLocalAgents
    ;
}
