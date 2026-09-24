# services/factory/modules/delivery.nix
# Facade groups `factory.project.ci`, `factory.project.site`,
# `factory.project.publish`, `factory.project.notify`, and the key
# `factory.project.preset` of the delivery change. Holds the option table
# `deliveryOptions` and the validation of the four groups and the key.
# Pure Nix with no nixpkgs dependency, in the style of modules/design.nix.
let
  ciLib = import ../lib/ci.nix;

  ciUseValues = [
    "unset"
    "github-actions"
    "azure-pipelines"
  ];

  publishTargetValues = [
    "github-pages"
    "azure-static-web-app"
  ];

  deployToolValues = [
    "official-task"
    "swa-cli"
  ];

  notifyChannelValues = [
    "google-chat"
    "slack"
    "telegram"
  ];

  presetValues = [
    "minimal"
    "docs-only"
    "full"
  ];

  ciKnownKeys = [
    "use"
    "folder"
    "watchPaths"
    "build"
  ];

  buildHookKeys = [
    "beforeNodeSetup"
    "beforeSiteBuild"
    "afterSiteBuild"
  ];

  siteKnownKeys = [
    "enable"
    "title"
    "url"
    "baseUrl"
    "staticDirectories"
  ];

  publishKnownKeys = [
    "target"
    "deployTool"
  ];

  notifyKnownKeys = [
    "uses"
    "google-chat"
    "slack"
    "telegram"
  ];

  deliveryOptions = {
    ci = {
      use = {
        type = "enum unset github-actions azure-pipelines";
        default = "unset";
        description = "CI provider; unset emits no CI file (spec-ci-options).";
      };
      folder = {
        type = "relative path";
        default = "azure-pipelines";
        description = "Folder of the azure-pipelines file (spec-ci-options).";
      };
      watchPaths = {
        type = "list of strings";
        default = [ ];
        description = "Extra trigger paths after the factory paths (spec-ci-options).";
      };
      build = {
        beforeNodeSetup = {
          type = "list of steps";
          default = [ ];
          description = "Typed steps before the Node.js setup (spec-ci-options).";
        };
        beforeSiteBuild = {
          type = "list of steps";
          default = [ ];
          description = "Typed steps before the site build (spec-ci-options).";
        };
        afterSiteBuild = {
          type = "list of steps";
          default = [ ];
          description = "Typed steps after the site build (spec-ci-options).";
        };
      };
    };
    site = {
      enable = {
        type = "bool";
        default = false;
        description = "Gate of the site; false emits no site file (spec-site-render).";
      };
      title = {
        type = "string";
        default = "Documentation";
        description = "Site title (spec-site-render).";
      };
      url = {
        type = "string";
        default = "";
        description = "Site url (spec-site-render).";
      };
      baseUrl = {
        type = "string";
        default = "/";
        description = "Site base url (spec-site-render).";
      };
      staticDirectories = {
        type = "list of relative paths";
        default = [ ];
        description = "Static asset directories (spec-site-render).";
      };
    };
    publish = {
      target = {
        type = "enum github-pages azure-static-web-app";
        default = "github-pages";
        description = "Publish target of the site (spec-publish).";
      };
      deployTool = {
        type = "enum official-task swa-cli";
        default = "official-task";
        description = "Deploy tool of the Static Web App flow (spec-publish).";
      };
    };
    notify = {
      uses = {
        type = "list of google-chat slack telegram";
        default = [ ];
        description = "Selected notifier channels in order (spec-notify-fanout).";
      };
      google-chat = {
        secret = {
          type = "secret name";
          default = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
          description = "Secret name of the Google Chat webhook (spec-notify-fanout).";
        };
      };
      slack = {
        secret = {
          type = "secret name";
          default = "NOTIFY_SLACK_WEBHOOK";
          description = "Secret name of the Slack webhook (spec-notify-fanout).";
        };
      };
      telegram = {
        secret = {
          type = "secret name";
          default = "NOTIFY_TELEGRAM_TOKEN";
          description = "Secret name of the Telegram bot token (spec-notify-fanout).";
        };
        chatId = {
          type = "string";
          default = "";
          description = "Telegram chat ID (spec-notify-fanout).";
        };
      };
    };
    preset = {
      type = "enum minimal docs-only full";
      description = "Named preset bundle; absent gives no bundle (spec-presets).";
    };
  };

  show = v: if builtins.isString v then "`${v}`" else builtins.toJSON v;

  isNonEmptyString = v: builtins.isString v && v != "";

  # Relative POSIX path: non-empty, no leading slash, no empty/./.. segment,
  # no backslash. Used for site.staticDirectories entries; the folder rule of
  # task-ci-render reuses the same predicate.
  isRelativePath =
    v:
    if !(builtins.isString v) || v == "" then
      false
    else if builtins.substring 0 1 v == "/" then
      false
    else if builtins.match ".*\\\\.*" v != null then
      false
    else
      let
        len = builtins.stringLength v;
        # Split on "/" without builtins.split (keep pure, no regex edge).
        splitParts =
          s:
          let
            findSlash =
              i:
              if i >= builtins.stringLength s then
                null
              else if builtins.substring i 1 s == "/" then
                i
              else
                findSlash (i + 1);
            idx = findSlash 0;
          in
          if s == "" then
            [ "" ]
          else if idx == null then
            [ s ]
          else
            [ (builtins.substring 0 idx s) ]
            ++ splitParts (builtins.substring (idx + 1) (builtins.stringLength s - idx - 1) s);
        parts = splitParts v;
      in
      !(builtins.elem "" parts) && !(builtins.elem "." parts) && !(builtins.elem ".." parts) && len > 0;

  # Validate one site group value and return the dense validated group.
  evalSite =
    value:
    if value == null then
      {
        enable = false;
        title = "Documentation";
        url = "";
        baseUrl = "/";
        staticDirectories = [ ];
      }
    else if !(builtins.isAttrs value) then
      throw "site-type: the group `site` below the root `factory.project` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k siteKnownKeys)) keys;
      in
      if outside != [ ] then
        throw "site-key: the key `${builtins.head outside}` of the group `site` is outside the value set enable, title, url, baseUrl, staticDirectories"
      else
        let
          enable = if value ? enable then value.enable else false;
          title = if value ? title then value.title else "Documentation";
          url = if value ? url then value.url else "";
          baseUrl = if value ? baseUrl then value.baseUrl else "/";
          staticDirectories = if value ? staticDirectories then value.staticDirectories else [ ];
          badStatic = builtins.filter (e: !isRelativePath e) (
            if builtins.isList staticDirectories then staticDirectories else [ "non-list" ]
          );
        in
        if !(builtins.isBool enable) then
          throw "site-enable: the key `enable` of the group `site` must be a bool, got ${show enable}"
        else if !(builtins.isString title) then
          throw "site-title: the key `title` of the group `site` must be a string, got ${show title}"
        else if !(builtins.isString url) then
          throw "site-url: the key `url` of the group `site` must be a string, got ${show url}"
        else if !(builtins.isString baseUrl) then
          throw "site-baseUrl: the key `baseUrl` of the group `site` must be a string, got ${show baseUrl}"
        else if !(builtins.isList staticDirectories) then
          throw "site-staticDirectories: the key `staticDirectories` of the group `site` must be a list of non-empty relative POSIX paths, got ${show staticDirectories}"
        else if badStatic != [ ] then
          throw "site-staticDirectories: the entry ${show (builtins.head badStatic)} of the key `staticDirectories` of the group `site` must be a non-empty relative POSIX path"
        else
          {
            inherit
              enable
              title
              url
              baseUrl
              staticDirectories
              ;
          };

  # Validate one ci group value and return the dense validated group.
  evalCi =
    value:
    if value == null then
      {
        use = "unset";
        folder = "azure-pipelines";
        watchPaths = [ ];
        build = {
          beforeNodeSetup = [ ];
          beforeSiteBuild = [ ];
          afterSiteBuild = [ ];
        };
      }
    else if !(builtins.isAttrs value) then
      throw "ci-type: the group `ci` below the root `factory.project` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k ciKnownKeys)) keys;
      in
      if outside != [ ] then
        throw "ci-key: the key `${builtins.head outside}` of the group `ci` is outside the value set use, folder, watchPaths, build"
      else
        let
          use = if value ? use then value.use else "unset";
          folder = if value ? folder then value.folder else "azure-pipelines";
          watchPaths = if value ? watchPaths then value.watchPaths else [ ];
          build = if value ? build then value.build else { };
          watchBad = builtins.filter (e: !(isNonEmptyString e)) (
            if builtins.isList watchPaths then watchPaths else [ 0 ]
          );
        in
        if !(builtins.isString use) || !(builtins.elem use ciUseValues) then
          throw "ci-use: the key `use` of the group `ci` must be one of unset, github-actions, azure-pipelines, got ${show use}"
        else if !isRelativePath folder then
          throw "ci-folder: the key `folder` of the group `ci` must be a non-empty relative POSIX path with no empty, `.`, or `..` segment and no backslash, got ${show folder}"
        else if !(builtins.isList watchPaths) then
          throw "ci-watchPaths: the key `watchPaths` of the group `ci` must be a list of non-empty strings, got ${show watchPaths}"
        else if watchBad != [ ] then
          throw "ci-watchPaths: the entry ${show (builtins.head watchBad)} of the key `watchPaths` of the group `ci` must be a non-empty string"
        else if !(builtins.isAttrs build) then
          throw "ci-build: the key `build` of the group `ci` must be an attribute set, got `${builtins.typeOf build}`"
        else
          let
            bkeys = builtins.attrNames build;
            boutside = builtins.filter (k: !(builtins.elem k buildHookKeys)) bkeys;
          in
          if boutside != [ ] then
            throw "ci-build-key: the key `${builtins.head boutside}` of the group `ci.build` is outside the value set beforeNodeSetup, beforeSiteBuild, afterSiteBuild"
          else
            let
              beforeNodeSetup = if build ? beforeNodeSetup then build.beforeNodeSetup else [ ];
              beforeSiteBuild = if build ? beforeSiteBuild then build.beforeSiteBuild else [ ];
              afterSiteBuild = if build ? afterSiteBuild then build.afterSiteBuild else [ ];
            in
            if !(builtins.isList beforeNodeSetup) then
              throw "ci-build-beforeNodeSetup: the hook `beforeNodeSetup` of the group `ci.build` must be a list, got ${show beforeNodeSetup}"
            else if !(builtins.isList beforeSiteBuild) then
              throw "ci-build-beforeSiteBuild: the hook `beforeSiteBuild` of the group `ci.build` must be a list, got ${show beforeSiteBuild}"
            else if !(builtins.isList afterSiteBuild) then
              throw "ci-build-afterSiteBuild: the hook `afterSiteBuild` of the group `ci.build` must be a list, got ${show afterSiteBuild}"
            else
              let
                checked = builtins.map ciLib.assertStep (beforeNodeSetup ++ beforeSiteBuild ++ afterSiteBuild);
              in
              builtins.deepSeq checked {
                inherit use folder watchPaths;
                build = {
                  inherit
                    beforeNodeSetup
                    beforeSiteBuild
                    afterSiteBuild
                    ;
                };
              };

  # Validate one publish group value and return the dense validated group.
  evalPublish =
    value:
    if value == null then
      {
        target = "github-pages";
        deployTool = "official-task";
      }
    else if !(builtins.isAttrs value) then
      throw "publish-type: the group `publish` below the root `factory.project` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k publishKnownKeys)) keys;
      in
      if outside != [ ] then
        throw "publish-key: the key `${builtins.head outside}` of the group `publish` is outside the value set target, deployTool"
      else
        let
          target = if value ? target then value.target else "github-pages";
          deployTool = if value ? deployTool then value.deployTool else "official-task";
        in
        if !(builtins.isString target) || !(builtins.elem target publishTargetValues) then
          throw "publish-target: the key `target` of the group `publish` must be one of github-pages, azure-static-web-app, got ${show target}"
        else if !(builtins.isString deployTool) || !(builtins.elem deployTool deployToolValues) then
          throw "publish-deployTool: the key `deployTool` of the group `publish` must be one of official-task, swa-cli, got ${show deployTool}"
        else
          {
            inherit target deployTool;
          };

  # Validate one notify channel subgroup with exactly one required key set.
  evalNotifyChannel =
    channel: allowedKeys: value:
    if !(builtins.isAttrs value) then
      throw "notify-${channel}-type: the group `${channel}` of the group `notify` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k allowedKeys)) keys;
      in
      if outside != [ ] then
        throw "notify-key: the key `${builtins.head outside}` of the group `notify.${channel}` is outside the value set ${builtins.concatStringsSep ", " allowedKeys}"
      else
        value;

  # Validate one notify group value and return the dense validated group.
  evalNotify =
    value:
    if value == null then
      {
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
      }
    else if !(builtins.isAttrs value) then
      throw "notify-type: the group `notify` below the root `factory.project` must be an attribute set, got `${builtins.typeOf value}`"
    else
      let
        keys = builtins.attrNames value;
        outside = builtins.filter (k: !(builtins.elem k notifyKnownKeys)) keys;
      in
      if outside != [ ] then
        throw "notify-key: the key `${builtins.head outside}` of the group `notify` is outside the value set uses, google-chat, slack, telegram"
      else
        let
          uses = if value ? uses then value.uses else [ ];
          badUses = builtins.filter (e: !(builtins.isString e) || !(builtins.elem e notifyChannelValues)) (
            if builtins.isList uses then uses else [ 0 ]
          );
          uniq = builtins.foldl' (acc: n: if builtins.elem n acc then acc else acc ++ [ n ]) [ ] (
            if builtins.isList uses then uses else [ ]
          );
          gcRaw =
            if value ? google-chat then value.google-chat else { secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK"; };
          slRaw = if value ? slack then value.slack else { secret = "NOTIFY_SLACK_WEBHOOK"; };
          tgRaw =
            if value ? telegram then
              value.telegram
            else
              {
                secret = "NOTIFY_TELEGRAM_TOKEN";
                chatId = "";
              };
          gc = evalNotifyChannel "google-chat" [ "secret" ] gcRaw;
          sl = evalNotifyChannel "slack" [ "secret" ] slRaw;
          tg = evalNotifyChannel "telegram" [
            "secret"
            "chatId"
          ] tgRaw;
          gcSecret = if gc ? secret then gc.secret else "NOTIFY_GOOGLE_CHAT_WEBHOOK";
          slSecret = if sl ? secret then sl.secret else "NOTIFY_SLACK_WEBHOOK";
          tgSecret = if tg ? secret then tg.secret else "NOTIFY_TELEGRAM_TOKEN";
          tgChatId = if tg ? chatId then tg.chatId else "";
          isSecretName = s: builtins.isString s && builtins.match "[A-Za-z_][A-Z0-9_]*" s != null;
        in
        if !(builtins.isList uses) then
          throw "notify-uses: the key `uses` of the group `notify` must be an ordered list of google-chat, slack, telegram, got ${show uses}"
        else if badUses != [ ] then
          throw "notify-uses: the entry ${show (builtins.head badUses)} of `uses` must be one of google-chat, slack, telegram"
        else if builtins.length uniq != builtins.length uses then
          throw "notify-uses-duplicate: the key `uses` of the group `notify` holds a duplicate entry"
        else if !isSecretName gcSecret then
          throw "notify-secret: the key `secret` of the group `notify.google-chat` must be a name matching `^[A-Za-z_][A-Z0-9_]*$`, got ${show gcSecret}"
        else if !isSecretName slSecret then
          throw "notify-secret: the key `secret` of the group `notify.slack` must be a name matching `^[A-Za-z_][A-Z0-9_]*$`, got ${show slSecret}"
        else if !isSecretName tgSecret then
          throw "notify-secret: the key `secret` of the group `notify.telegram` must be a name matching `^[A-Za-z_][A-Z0-9_]*$`, got ${show tgSecret}"
        else if !(builtins.isString tgChatId) then
          throw "notify-chatId: the key `chatId` of the group `notify.telegram` must be a string, got ${show tgChatId}"
        else if builtins.elem "telegram" uses && tgChatId == "" then
          throw "notify-chatId: the selected channel `telegram` needs a non-empty `chatId`"
        else
          {
            uses = uses;
            google-chat = {
              secret = gcSecret;
            };
            slack = {
              secret = slSecret;
            };
            telegram = {
              secret = tgSecret;
              chatId = tgChatId;
            };
          };

  # Validate the preset key. Absent (null) gives null: no bundle.
  evalPreset =
    value:
    if value == null then
      null
    else if !(builtins.isString value) || !(builtins.elem value presetValues) then
      throw "preset-value: the key `preset` below the root `factory.project` must be one of minimal, docs-only, full, got ${show value}"
    else
      value;

  # One assertion entry per invariant of the seed-check fixture. Each
  # message names the item. Takes the evaluated settings and the
  # modeled-key list.
  deliveryAssertions =
    settings: modeledKeys:
    let
      ci = settings.ci or null;
      ciKeys = if builtins.isAttrs ci then builtins.attrNames ci else [ ];
      site = settings.site or null;
      siteKeys = if builtins.isAttrs site then builtins.attrNames site else [ ];
      publish = settings.publish or null;
      publishKeys = if builtins.isAttrs publish then builtins.attrNames publish else [ ];
      notify = settings.notify or null;
      notifyKeys = if builtins.isAttrs notify then builtins.attrNames notify else [ ];
      preset = if settings ? preset then settings.preset else "absent";
    in
    [
      {
        name = "ci-keys";
        assertion = builtins.sort builtins.lessThan ciKeys == builtins.sort builtins.lessThan ciKnownKeys;
        message = "ci-keys: the group `ci` must hold exactly the keys `use`, `folder`, `watchPaths`, `build`, got ${builtins.toJSON ciKeys}";
      }
      {
        name = "ci-use";
        assertion = builtins.isAttrs ci && builtins.elem (ci.use or "other") ciUseValues;
        message = "ci-use: the key `use` of the group `ci` must be one of unset, github-actions, azure-pipelines, got ${
          show (if builtins.isAttrs ci && ci ? use then ci.use else null)
        }";
      }
      {
        name = "ci-folder";
        assertion = builtins.isAttrs ci && isRelativePath (ci.folder or null);
        message = "ci-folder: the key `folder` of the group `ci` must be a non-empty relative POSIX path with no empty, `.`, or `..` segment and no backslash";
      }
      {
        name = "ci-build-hooks";
        assertion =
          builtins.isAttrs ci
          && builtins.isAttrs (ci.build or null)
          && builtins.isList ((ci.build or { }).beforeNodeSetup or null)
          && builtins.isList ((ci.build or { }).beforeSiteBuild or null)
          && builtins.isList ((ci.build or { }).afterSiteBuild or null);
        message = "ci-build-hooks: the hooks `beforeNodeSetup`, `beforeSiteBuild`, and `afterSiteBuild` of the group `ci.build` must be lists";
      }
      {
        name = "site-keys";
        assertion =
          builtins.sort builtins.lessThan siteKeys == builtins.sort builtins.lessThan siteKnownKeys;
        message = "site-keys: the group `site` must hold exactly the keys `enable`, `title`, `url`, `baseUrl`, `staticDirectories`, got ${builtins.toJSON siteKeys}";
      }
      {
        name = "site-enable";
        assertion = builtins.isAttrs site && builtins.isBool (site.enable or null);
        message = "site-enable: the key `enable` of the group `site` must be a bool";
      }
      {
        name = "publish-keys";
        assertion =
          builtins.sort builtins.lessThan publishKeys == builtins.sort builtins.lessThan publishKnownKeys;
        message = "publish-keys: the group `publish` must hold exactly the keys `target`, `deployTool`, got ${builtins.toJSON publishKeys}";
      }
      {
        name = "publish-target";
        assertion =
          builtins.isAttrs publish && builtins.elem (publish.target or "other") publishTargetValues;
        message = "publish-target: the key `target` of the group `publish` must be one of github-pages, azure-static-web-app";
      }
      {
        name = "publish-deployTool";
        assertion =
          builtins.isAttrs publish && builtins.elem (publish.deployTool or "other") deployToolValues;
        message = "publish-deployTool: the key `deployTool` of the group `publish` must be one of official-task, swa-cli";
      }
      {
        name = "notify-keys";
        assertion =
          builtins.sort builtins.lessThan notifyKeys == builtins.sort builtins.lessThan notifyKnownKeys;
        message = "notify-keys: the group `notify` must hold exactly the keys `uses`, `google-chat`, `slack`, `telegram`, got ${builtins.toJSON notifyKeys}";
      }
      {
        name = "notify-uses";
        assertion =
          builtins.isAttrs notify
          && builtins.isList (notify.uses or null)
          && builtins.all (e: builtins.elem e notifyChannelValues) (notify.uses or [ "other" ])
          &&
            builtins.length (
              builtins.foldl' (acc: n: if builtins.elem n acc then acc else acc ++ [ n ]) [ ] (notify.uses or [ ])
            ) == builtins.length (notify.uses or [ ]);
        message = "notify-uses-duplicate: the key `uses` of the group `notify` must hold distinct entries of google-chat, slack, telegram";
      }
      {
        name = "notify-secret";
        assertion =
          builtins.isAttrs notify
          && builtins.all (s: builtins.isString s && builtins.match "[A-Za-z_][A-Z0-9_]*" s != null) [
            ((notify.google-chat or { }).secret or "")
            ((notify.slack or { }).secret or "")
            ((notify.telegram or { }).secret or "")
          ];
        message = "notify-secret: each `secret` of the group `notify` must be a name matching `^[A-Za-z_][A-Z0-9_]*$`";
      }
      {
        name = "notify-chatId";
        assertion =
          builtins.isAttrs notify
          && (
            !(builtins.elem "telegram" (notify.uses or [ ]))
            || (
              ((notify.telegram or { }).chatId or "") != ""
              && builtins.isString ((notify.telegram or { }).chatId or null)
            )
          );
        message = "notify-chatId: the selected channel `telegram` needs a non-empty `chatId`";
      }
      {
        name = "preset-value";
        assertion = preset == null || builtins.elem preset presetValues;
        message = "preset-value: the key `preset` must be one of minimal, docs-only, full";
      }
      {
        name = "delivery-modeled";
        assertion =
          builtins.elem "ci" modeledKeys
          && builtins.elem "site" modeledKeys
          && builtins.elem "publish" modeledKeys
          && builtins.elem "notify" modeledKeys
          && builtins.elem "preset" modeledKeys;
        message = "delivery-modeled: the modeled-key list must hold `ci`, `site`, `publish`, `notify`, and `preset`, got ${builtins.toJSON modeledKeys}";
      }
    ];

  # Delivery files of the run: the site files, the CI file, and the
  # notifier file. Takes the evaluated settings and the repository root.
  # Each entry joins the plan as an extraFiles entry with a rendered
  # source of the run.
  deliveryFiles =
    settings: repoRoot:
    let
      siteLib = import ../lib/site.nix;
      notifyLib = import ../lib/notify.nix;
      siteOut = siteLib.siteFiles settings repoRoot;
      ciOut = ciLib.ciFiles settings;
      notifyOut = notifyLib.notifyFiles settings;
    in
    {
      extraFiles = siteOut.extraFiles ++ ciOut.extraFiles ++ notifyOut.extraFiles;
      renderedSources = siteOut.renderedSources ++ ciOut.renderedSources ++ notifyOut.renderedSources;
    };
in
{
  inherit
    ciUseValues
    publishTargetValues
    deployToolValues
    notifyChannelValues
    presetValues
    ciKnownKeys
    buildHookKeys
    siteKnownKeys
    publishKnownKeys
    notifyKnownKeys
    deliveryOptions
    isRelativePath
    evalSite
    evalCi
    evalPublish
    evalNotify
    evalPreset
    deliveryAssertions
    deliveryFiles
    ;
}
