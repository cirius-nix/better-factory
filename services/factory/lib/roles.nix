# services/factory/lib/roles.nix
# Role render of one role source for the opencode harness
# (spec-role-render). Pure Nix with no nixpkgs dependency. Uses lib/yaml.nix
# for the markdown frontmatter.
let
  yaml = import ./yaml.nix;

  namePattern = "[A-Za-z0-9._-]+";

  # Role names reserved to the factory (C-18, spec-designer-role). A
  # declaration of a reserved name in the project layer or in the local
  # layer fails evaluation with a message that names the reserved name.
  # The factory adds the built-in declaration after the layer validation,
  # so the built-in declaration passes and no merged user declaration of
  # the name exists.
  reservedRoleNames = [
    "designer-expert"
  ];

  roleFields = [
    "enable"
    "name"
    "description"
    "source"
    "harness"
    "ownership"
    "capabilities"
  ];

  # The declared skill vocabulary (spec-declared-skill, adr-declared-skill-shape).
  # The kind `skill` is the only accepted kind in this change. A declared
  # skill holds the home `shipped` or `repo-local`.
  capabilityKindValues = [ "skill" ];

  capabilityHomeValues = [
    "shipped"
    "repo-local"
  ];

  capabilityFields = [
    "kind"
    "name"
    "home"
  ];

  harnessFields = [
    "opencode"
  ];

  ownershipEffectValues = [
    "allow"
    "deny"
    "ask"
  ];

  # The escape rule of one ownership pattern (spec-local-role-ownership,
  # C-LRO-03). The pattern MUST NOT start with `/`, MUST NOT start with
  # `~`, MUST NOT be empty, and MUST NOT hold a path segment that equals
  # `..`. The rule is syntactic, because the derive reads no project root.
  ownershipPatternOk =
    p:
    builtins.isString p
    && p != ""
    && builtins.substring 0 1 p != "/"
    && builtins.substring 0 1 p != "~"
    && !(builtins.elem ".." (builtins.filter builtins.isString (builtins.split "/" p)));

  # Normalize one ownership entry to the shape `{ resource; effect; }`
  # (spec-local-role-ownership, C-LRO-02). A plain string entry `s` means
  # `{ resource = s; effect = "allow"; }`. An attribute-set entry holds the
  # required field `resource` and the optional field `effect`. Each failure
  # gives the named message of the field.
  normalizeOwnershipEntry =
    roleName: entry:
    if builtins.isString entry then
      if entry == "" then
        throw "role-ownership-entry: an ownership entry of the role `${roleName}` needs a non-empty string `resource`"
      else
        {
          resource = entry;
          effect = "allow";
        }
    else if builtins.isAttrs entry then
      let
        unknown = builtins.filter (
          f:
          !(builtins.elem f [
            "resource"
            "effect"
          ])
        ) (builtins.attrNames entry);
      in
      if unknown != [ ] then
        throw "role-ownership-field: an ownership entry of the role `${roleName}` holds the unknown field `${builtins.head unknown}`"
      else if !(entry ? resource) || !(builtins.isString entry.resource) || entry.resource == "" then
        throw "role-ownership-entry: an ownership entry of the role `${roleName}` needs a non-empty string `resource`"
      else if (entry ? effect) && !(builtins.elem entry.effect ownershipEffectValues) then
        throw "role-ownership-effect: the `effect` of an ownership entry of the role `${roleName}` must be allow, deny, or ask"
      else
        {
          resource = entry.resource;
          effect = if entry ? effect then entry.effect else "allow";
        }
    else
      throw "role-ownership-entry: an ownership entry of the role `${roleName}` must be a string or an attribute set, got `${builtins.typeOf entry}`";

  # Validate one ownership value and normalize each entry (C-LRO-02,
  # C-LRO-03). The value MUST be a list. Each normalized entry reaches the
  # escape rule. A failing pattern gives the named message
  # `role-ownership-escape`.
  normalizeOwnership =
    roleName: value:
    if !(builtins.isList value) then
      throw "role-ownership-type: the `ownership` of the role `${roleName}` must be a list, got `${builtins.typeOf value}`"
    else
      let
        normalize =
          e:
          if ownershipPatternOk e.resource then
            e
          else
            throw "role-ownership-escape: the ownership path `${e.resource}` of the role `${roleName}` escapes the project root";
      in
      builtins.map (e: normalize (normalizeOwnershipEntry roleName e)) value;

  # Normalize one declared capability entry to the shape
  # `{ kind; name; home; }` (spec-declared-skill interface 2 and 3). The
  # entry holds exactly the fields `kind`, `name`, and `home`. The only
  # accepted kind is `skill`. The name is one path segment matching
  # `[A-Za-z0-9._-]+`, except `.` and `..`. The home is `shipped` or
  # `repo-local`. No `asset`, `source`, `when`, or emitted-path field is
  # accepted. Each failure gives the named `role-capability-*` message.
  normalizeCapabilityEntry =
    roleName: entry:
    if !(builtins.isAttrs entry) then
      throw "role-capability-entry: a declared capability of the role `${roleName}` must be an attribute set, got `${builtins.typeOf entry}`"
    else
      let
        unknown = builtins.filter (f: !(builtins.elem f capabilityFields)) (
          builtins.attrNames entry
        );
        missing = builtins.filter (f: !(builtins.hasAttr f entry)) capabilityFields;
      in
      if unknown != [ ] then
        throw "role-capability-field: a declared capability of the role `${roleName}` holds the unknown field `${builtins.head unknown}`"
      else if missing != [ ] then
        throw "role-capability-entry: a declared capability of the role `${roleName}` misses the field `${builtins.head missing}`"
      else if !(builtins.isString entry.kind) || !(builtins.elem entry.kind capabilityKindValues) then
        throw "role-capability-kind: a declared capability of the role `${roleName}` holds the kind `${builtins.toJSON entry.kind}`; want `skill`"
      else if
        !(builtins.isString entry.name)
        || builtins.match namePattern entry.name == null
        || entry.name == "."
        || entry.name == ".."
      then
        throw "role-capability-name: a declared capability of the role `${roleName}` holds the name `${builtins.toJSON entry.name}`; want one path segment matching [A-Za-z0-9._-]+, except `.` and `..`"
      else if !(builtins.isString entry.home) || !(builtins.elem entry.home capabilityHomeValues) then
        throw "role-capability-home: the declared capability `${entry.name}` of the role `${roleName}` holds the home `${builtins.toJSON entry.home}`; want `shipped` or `repo-local`"
      else
        {
          inherit (entry) kind name home;
        };

  # Validate one declared capability list (spec-declared-skill interface 1 to
  # 3). The value MUST be a list. Each entry reaches normalizeCapabilityEntry.
  normalizeCapabilities =
    roleName: value:
    if !(builtins.isList value) then
      throw "role-capability-type: the `capabilities` of the role `${roleName}` must be a list, got `${builtins.typeOf value}`"
    else
      builtins.map (normalizeCapabilityEntry roleName) value;

  isPathLike = v: builtins.typeOf v == "path" || builtins.isString v;

  # Validate one role declaration with explicit pure checks (C-11): the
  # exact field list, a non-empty string `description`, a `source` that
  # `builtins.pathExists` matches, a `name` that matches `[A-Za-z0-9._-]+`
  # and is not `.` or `..`, and the exact `harness` group. An unknown field
  # fails evaluation. A reserved name fails evaluation unless allowReserved
  # is true: the project layer and the local layer validate with
  # `checkRole`, so a user declaration of a reserved name fails; the role
  # render validates the merged set with allowReserved, so the
  # factory-injected built-in declaration passes. Returns the normalized
  # declaration: `enable` defaults to true, `name` to the attribute name,
  # `ownership` and `capabilities` to the empty list, and each harness group
  # to the empty set. The structural header keys
  # always win over a harness extra with the same name.
  checkRoleWith =
    {
      allowReserved ? false,
    }:
    attrName: decl:
    if !(builtins.isAttrs decl) then
      throw "role-type: the declaration `roles.${attrName}` must be an attribute set, got `${builtins.typeOf decl}`"
    else
      let
        unknown = builtins.filter (f: !(builtins.elem f roleFields)) (builtins.attrNames decl);
      in
      if unknown != [ ] then
        throw "role-field: the declaration `roles.${attrName}` holds the unknown field `${builtins.head unknown}`"
      else if (decl ? enable) && !(builtins.isBool decl.enable) then
        throw "role-enable: the `enable` of the declaration `roles.${attrName}` must be a bool"
      else if
        !(decl ? description) || !(builtins.isString decl.description) || decl.description == ""
      then
        throw "role-description: the declaration `roles.${attrName}` needs a non-empty string `description`"
      else if !(decl ? source) || !(isPathLike decl.source) || !(builtins.pathExists decl.source) then
        throw "role-source: the `source` of the declaration `roles.${attrName}` must exist; builtins.pathExists does not match it"
      else
        let
          name = if decl ? name then decl.name else attrName;
        in
        if
          !(builtins.isString name) || builtins.match namePattern name == null || name == "." || name == ".."
        then
          throw "role-name: the `name` of the declaration `roles.${attrName}` must match [A-Za-z0-9._-]+ and must not be `.` or `..`"
        else if !allowReserved && builtins.elem name reservedRoleNames then
          throw "role-reserved: the name `${name}` of the declaration `roles.${attrName}` is reserved to the factory"
        else if (decl ? harness) && !(builtins.isAttrs decl.harness) then
          throw "role-harness: the `harness` of the declaration `roles.${attrName}` must be an attribute set"
        else
          let
            hg = if decl ? harness then decl.harness else { };
            rejected = builtins.filter (
              h:
              builtins.elem h [
                "claude"
                "codex"
              ]
            ) (builtins.attrNames hg);
            hUnknown = builtins.filter (f: !(builtins.elem f harnessFields)) (builtins.attrNames hg);
          in
          if rejected != [ ] then
            throw "role-harness: the `harness.${builtins.head rejected}` group of the declaration `roles.${attrName}` is removed; the declaration holds `opencode` only"
          else if hUnknown != [ ] then
            throw "role-harness: the `harness` of the declaration `roles.${attrName}` holds the unknown field `${builtins.head hUnknown}`"
          else
            let
              present = builtins.filter (h: builtins.hasAttr h hg) harnessFields;
              bad = builtins.filter (h: !(builtins.isAttrs hg.${h})) present;
            in
            if bad != [ ] then
              throw "role-harness: the `harness.${builtins.head bad}` of the declaration `roles.${attrName}` must be an attribute set"
            else
              let
                ownership = if decl ? ownership then normalizeOwnership name decl.ownership else [ ];
                capabilities =
                  if decl ? capabilities then normalizeCapabilities name decl.capabilities else [ ];
              in
              {
                enable = if decl ? enable then decl.enable else true;
                inherit name;
                description = decl.description;
                source = decl.source;
                inherit ownership;
                inherit capabilities;
                harness = {
                  opencode = if builtins.hasAttr "opencode" hg then hg.opencode else { };
                };
              };

  checkRole = checkRoleWith { };

  # Trim trailing newline characters from rendered text.
  trimRight =
    s:
    let
      len = builtins.stringLength s;
    in
    if len == 0 then
      s
    else if builtins.substring (len - 1) 1 s == "\n" then
      trimRight (builtins.substring 0 (len - 1) s)
    else
      s;

  # Compose the rendered body: the role source, then the chapters of the
  # map of that role. The order is the DDD chapter first and the UX chapter
  # second. One blank line separates the parts. chapters is the chapter
  # list of one role.
  composeBody =
    sourceText: chapters:
    builtins.concatStringsSep "\n\n" ([ (trimRight sourceText) ] ++ builtins.map trimRight chapters)
    + "\n";

  # Render each enabled role declaration for the opencode harness. roles
  # maps the attribute name to its declaration; uses holds the selected
  # harnesses; chapterMap holds one chapter list per role name
  # (spec-design-option, C-13). The body of one role is the role source
  # plus the chapters of the map of that role. An absent role name gives
  # the empty list, so the body is the role source only. One blank line
  # separates the parts (spec-role-render of feat-orchestration 1.0.0).
  # An unselected harness receives no role file. Each file has
  # the copy mode `managed`. No task permission is held in a role
  # frontmatter. Returns the file declarations and the rendered-source
  # list. No second harness fragment exists.
  renderRoles =
    {
      roles,
      uses,
      chapterMap ? { },
    }:
    let
      given = if roles == null then { } else roles;
      checked = builtins.mapAttrs (checkRoleWith { allowReserved = true; }) given;
      enabled = builtins.filter (n: checked.${n}.enable) (builtins.attrNames checked);
      select = h: builtins.elem h uses;
      one =
        n:
        let
          decl = checked.${n};
          chapters = chapterMap.${decl.name} or [ ];
          body = composeBody (builtins.readFile decl.source) chapters;
          opencodeFront = yaml.renderYaml (decl.harness.opencode // { description = decl.description; });
          opencodeContent = "---\n${opencodeFront}---\n\n${body}";
        in
        {
          decl = decl;
          body = body;
          files = (
            if select "opencode" then
              [
                {
                  rel = ".opencode/agents/${decl.name}.md";
                  source = builtins.toFile "${decl.name}.md" opencodeContent;
                  copyMode = "managed";
                }
              ]
            else
              [ ]
          );
        };
      rendered = builtins.listToAttrs (
        builtins.map (n: {
          name = n;
          value = one n;
        }) enabled
      );
      fileDecls = builtins.concatLists (builtins.map (n: rendered.${n}.files) enabled);
      outcome = {
        inherit fileDecls;
        renderedSources = builtins.map (d: d.source) fileDecls;
      };
    in
    builtins.deepSeq (builtins.attrValues checked) outcome;
in
{
  inherit
    namePattern
    reservedRoleNames
    roleFields
    harnessFields
    checkRoleWith
    checkRole
    trimRight
    composeBody
    renderRoles
    ;
}
