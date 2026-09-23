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
  toml = import ./toml.nix;

  harnessNames = [
    "opencode"
    "claude"
    "codex"
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
    claude = { };
    codex = { };
  };

  # Managed opencode settings (spec-harness-merge, the managed keys table).
  # roleNames are the rendered content experts: `artifact-master` keeps
  # `permission.task = "allow"`; each other role keeps `"deny"`. An absent
  # permission is not a deny, so each rendered role holds an explicit value.
  managedOpencodeSettings = roleNames: {
    subagent_depth = 1;
    agent = builtins.listToAttrs (
      builtins.map (r: {
        name = r;
        value = {
          permission = {
            task = if r == "artifact-master" then "allow" else "deny";
          };
        };
      }) roleNames
    );
  };

  # Managed key paths of the rendered opencode file as attribute paths. Each
  # path is a path in the rendered file (spec-harness-merge).
  managedOpencodePathLists =
    roleNames:
    [ [ "subagent_depth" ] ]
    ++ builtins.map (r: [
      "agent"
      r
      "permission"
      "task"
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
  # entry of this name.
  mergeMcpEntry =
    name: proj: loc:
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
          enabled = pick "enabled" false;
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

  # Merge the MCP source of the project and local layers. Returns the merged
  # entries with defaults applied and the managed-wins trace lines.
  mergeMcp =
    projectMcp: localMcp:
    let
      p = if projectMcp == null then { } else projectMcp;
      l = if localMcp == null then { } else localMcp;
      names = builtins.attrNames p ++ builtins.filter (n: !(builtins.hasAttr n p)) (builtins.attrNames l);
      per =
        n:
        mergeMcpEntry n (if builtins.hasAttr n p then p.${n} else null) (
          if builtins.hasAttr n l then l.${n} else null
        );
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

  # One MCP source rendered into the dialect of one harness
  # (spec-mcp-dialect, the dialect mapping table). The rendered entry name
  # is the source name.
  mcpDialectEntry = name: entry: {
    opencode = {
      command = [ entry.command ] ++ entry.args;
      type = "local";
      environment = entry.env;
      enabled = entry.enabled;
    };
    claude = {
      command = entry.command;
      args = entry.args;
      env = entry.env;
    };
    codex = {
      command = entry.command;
      args = entry.args;
      env = entry.env;
    };
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
    }:
    let
      p = project;
      l = local;
      mergedUses = if l ? uses then l.uses else (p.uses or [ ]);
      selected = h: builtins.elem h mergedUses;
      mcpMerged = mergeMcp (p.mcp or null) (l.mcp or null);
      mergedMcp = mcpMerged.entries;
      mcpTraces = if mergedUses == [ ] then [ ] else mcpMerged.traces;
      mergedRoles = deepUserWins (p.roles or { }) (l.roles or { });
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
        claude = mergedHarness "claude";
        codex = mergedHarness "codex";
      };
    in
    builtins.deepSeq force result;

  # Compose `.codex/config.toml` in one pass from the merged codex keys,
  # the `agents` fragment of the role render, and the `mcp_servers` group.
  # The composition reads no rendered file back (C-09). A group with no
  # entries is absent from the document. The one TOML renderer serves this
  # file and each codex role file.
  composeCodexConfig =
    {
      codexKeys,
      agentsFragment ? { },
      mcpServers ? { },
    }:
    let
      doc = deepUserWins codexKeys (
        (if agentsFragment == { } then { } else { agents = agentsFragment; })
        // (if mcpServers == { } then { } else { mcp_servers = mcpServers; })
      );
    in
    toml.renderToml doc;

  # Render the merged settings of each selected harness. An unselected
  # harness receives no file and no entry. An entry renders only when
  # `enabled = true`; with no enabled entry the files hold no dialect group.
  # Returns the file declarations and the rendered-source list of the run
  # (C-03). Each file has the copy mode `managed`. agentsFragment is the
  # codex `agents` fragment of the role render (task-role-render adds it).
  renderSelected =
    {
      merged,
      uses,
      agentsFragment ? { },
    }:
    let
      select = h: builtins.elem h uses;
      enabledNames = builtins.filter (n: merged.mcp.${n}.enabled) (
        builtins.attrNames (merged.mcp or { })
      );
      dialectGroup =
        h:
        builtins.listToAttrs (
          builtins.map (n: {
            name = n;
            value = (mcpDialectEntry n merged.mcp.${n}).${h};
          }) enabledNames
        );
      opencodeDoc =
        (merged.opencode or { })
        // (if enabledNames == [ ] then { } else { mcp = dialectGroup "opencode"; });
      claudeDoc = merged.claude or { };
      mcpJsonDoc = if enabledNames == [ ] then { } else { mcpServers = dialectGroup "claude"; };
      codexDoc = composeCodexConfig {
        codexKeys = merged.codex or { };
        inherit agentsFragment;
        mcpServers = dialectGroup "codex";
      };
      opencodeSource = builtins.toFile "opencode.jsonc" (builtins.toJSON opencodeDoc);
      claudeSource = builtins.toFile "settings.json" (builtins.toJSON claudeDoc);
      mcpJsonSource = builtins.toFile "mcp.json" (builtins.toJSON mcpJsonDoc);
      codexSource = builtins.toFile "config.toml" codexDoc;
      decls =
        (
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
        )
        ++ (
          if select "claude" then
            [
              {
                rel = ".claude/settings.json";
                source = claudeSource;
                copyMode = "managed";
              }
              {
                rel = ".mcp.json";
                source = mcpJsonSource;
                copyMode = "managed";
              }
            ]
          else
            [ ]
        )
        ++ (
          if select "codex" then
            [
              {
                rel = ".codex/config.toml";
                source = codexSource;
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
    mergeMcpEntry
    mergeMcp
    mcpDialectEntry
    composeCodexConfig
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
