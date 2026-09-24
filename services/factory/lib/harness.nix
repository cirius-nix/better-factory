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

  # Managed opencode settings (spec-harness-merge, the managed keys table).
  # roleNames are the rendered content experts: `artifact-master` keeps the
  # `permissions` rule with `effect = "allow"`; each other rendered content
  # expert keeps the same rule with `effect = "deny"`. An absent rule is not
  # a deny, so each rendered role holds an explicit rule.
  managedOpencodeSettings = roleNames: {
    agents = builtins.listToAttrs (
      builtins.map (r: {
        name = r;
        value = {
          permissions = [
            {
              action = "subagent";
              resource = "*";
              effect = if r == "artifact-master" then "allow" else "deny";
            }
          ];
        };
      }) roleNames
    );
  };

  # Managed key paths of the rendered opencode file as attribute paths. Each
  # path is a rendered path in the file `agents.<role>.permissions`
  # (spec-harness-merge).
  managedOpencodePathLists =
    roleNames:
    builtins.map (r: [
      "agents"
      r
      "permissions"
    ]) roleNames;

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
  };

  hasField = attrs: field: attrs != null && builtins.isAttrs attrs && builtins.hasAttr field attrs;

  # Merge one MCP entry per leaf field (C-08). A canonical entry keeps the
  # canonical `command`, `args`, and `env`; each ignored project or local
  # value gives one log line. `enabled` takes the value of the last layer
  # that sets it. A user entry takes the last layer that sets each field.
  # proj and loc are validated entry sets or null when the layer holds no
  # entry of this name. selected is true when the tool feed selects this
  # entry (C-14): the default of `enabled` is then true, else false. The
  # feed changes the entry set and the default of `enabled` only.
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
    in
    if canonical != null then
      {
        entry = {
          command = canonical.command;
          args = canonical.args;
          env = canonical.env;
          enabled = pick "enabled" (if selected then true else false);
        };
        traces = builtins.concatLists (
          builtins.map managedFieldTraces [
            "command"
            "args"
            "env"
          ]
        );
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
      managed = managedOpencodeSettings roleNames;
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
    managedOpencodeSettings
    managedOpencodePathLists
    hasPath
    setPath
    getPath
    deepUserWins
    mergeAgents
    renderSelected
    ;
}
