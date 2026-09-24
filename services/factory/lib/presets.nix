# services/factory/lib/presets.nix
# Preset library (spec-presets). Holds the value set minimal, docs-only,
# and full, the three bundle maps, the dead-key check, and the function
# applyPreset with the arguments preset, project, and tables. A bundle
# replaces the value of each selected key when the current value equals
# the table value of the key. An author value other than the table value
# wins. The tables come from the option tables of the modules; this
# library holds no copy of a table value and no inline value.
let
  presetNames = [
    "minimal"
    "docs-only"
    "full"
  ];

  # The three bundle maps. Each key is a key path below factory.project
  # in dotted form. Each value is the selected value of that key. The
  # minimal bundle holds no key. The docs-only bundle holds every leaf
  # key of the delivery tables. The full bundle holds every leaf key of
  # the agents, design, and delivery tables.
  bundles = {
    minimal = { };
    docs-only = {
      "ci.use" = "github-actions";
      "ci.folder" = "azure-pipelines";
      "ci.watchPaths" = [ ];
      "ci.build.beforeNodeSetup" = [ ];
      "ci.build.beforeSiteBuild" = [ ];
      "ci.build.afterSiteBuild" = [ ];
      "site.enable" = true;
      "site.title" = "Documentation";
      "site.url" = "";
      "site.baseUrl" = "/";
      "site.staticDirectories" = [ ];
      "publish.target" = "github-pages";
      "publish.deployTool" = "official-task";
      "notify.uses" = [ ];
      "notify.google-chat.secret" = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      "notify.slack.secret" = "NOTIFY_SLACK_WEBHOOK";
      "notify.telegram.secret" = "NOTIFY_TELEGRAM_TOKEN";
      "notify.telegram.chatId" = "";
    };
    full = {
      "ci.use" = "github-actions";
      "ci.folder" = "azure-pipelines";
      "ci.watchPaths" = [ ];
      "ci.build.beforeNodeSetup" = [ ];
      "ci.build.beforeSiteBuild" = [ ];
      "ci.build.afterSiteBuild" = [ ];
      "site.enable" = true;
      "site.title" = "Documentation";
      "site.url" = "";
      "site.baseUrl" = "/";
      "site.staticDirectories" = [ ];
      "publish.target" = "github-pages";
      "publish.deployTool" = "official-task";
      "notify.uses" = [ ];
      "notify.google-chat.secret" = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      "notify.slack.secret" = "NOTIFY_SLACK_WEBHOOK";
      "notify.telegram.secret" = "NOTIFY_TELEGRAM_TOKEN";
      "notify.telegram.chatId" = "";
      "agents.uses" = [
        "opencode"
      ];
      "agents.mcp" = {
        context7 = { };
      };
      "agents.roles" = { };
      "agents.opencode" = { };
      "design.use" = "ddd";
      "design.tool" = "unset";
      "ux" = true;
    };
  };

  splitDots =
    s:
    let
      findDot =
        i:
        if i >= builtins.stringLength s then
          null
        else if builtins.substring i 1 s == "." then
          i
        else
          findDot (i + 1);
      idx = findDot 0;
    in
    if idx == null then
      [ s ]
    else
      [ (builtins.substring 0 idx s) ]
      ++ splitDots (builtins.substring (idx + 1) (builtins.stringLength s - idx - 1) s);

  getPath =
    attrs: path:
    if path == [ ] then
      attrs
    else if !(builtins.isAttrs attrs) || !(builtins.hasAttr (builtins.head path) attrs) then
      null
    else
      getPath attrs.${builtins.head path} (builtins.tail path);

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
  # The leaf table of the modules: each dotted key path below
  # factory.project maps to the table value of the key. The table value
  # is the `default` entry of the option table of the module that
  # declares the key. Group nodes hold no table value. The preset key
  # holds no table value, so no bundle resolves it.
  leafTable =
    tables:
    let
      walk =
        prefix: node:
        builtins.foldl' (
          acc: k:
          let
            entry = node.${k};
            dotted = if prefix == "" then k else prefix + "." + k;
          in
          if builtins.isAttrs entry && entry ? default then
            acc // { ${dotted} = entry.default; }
          else if builtins.isAttrs entry then
            acc // walk dotted entry
          else
            acc
        ) { } (builtins.attrNames node);
      agentsLeaves = walk "agents" tables.agents;
      designLeaves = walk "design" tables.design;
      uxLeaves = walk "" {
        ux = tables.ux;
      };
      deliveryLeaves = walk "" tables.delivery;
    in
    agentsLeaves // designLeaves // uxLeaves // deliveryLeaves;
  # The dead-key check. Each key path of each bundle resolves against the
  # leaf table. A path without a table value fails evaluation with a
  # message that names the preset and the key path.
  checkBundles =
    tables:
    let
      leaves = leafTable tables;
      per =
        preset:
        builtins.map (key: {
          inherit preset key;
          ok = builtins.hasAttr key leaves;
        }) (builtins.attrNames bundles.${preset});
      bad = builtins.filter (e: !e.ok) (builtins.concatLists (builtins.map per presetNames));
    in
    if bad == [ ] then
      true
    else
      throw "preset-dead-key: the bundle `${(builtins.head bad).preset}` holds the key path `${(builtins.head bad).key}` outside the modeled key set";

  # Apply the selected bundle to the project value. For each key path of
  # the bundle, read the table value of the key and apply the bundle
  # value when the current value of the key equals the table value. A key
  # with a value other than the table value keeps that value. An absent
  # value equals the table value, so it takes the bundle value. An absent
  # preset gives the project unchanged.
  applyPreset =
    {
      preset,
      project,
      tables,
    }:
    let
      _dead = checkBundles tables;
    in
    assert _dead;
    if preset == null then
      project
    else
      let
        leaves = leafTable tables;
        bundle =
          bundles.${preset}
            or (throw "preset-value: the key `preset` below the root `factory.project` must be one of minimal, docs-only, full, got `${preset}`");
        keys = builtins.attrNames bundle;
        step =
          acc: key:
          let
            tableValue = leaves.${key};
            current = getPath acc (splitDots key);
            atTable = current == null || current == tableValue;
          in
          if atTable then setPath acc (splitDots key) bundle.${key} else acc;
      in
      builtins.foldl' step project keys;
in
{
  inherit
    presetNames
    bundles
    leafTable
    checkBundles
    applyPreset
    ;
}
