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
  ];

  harnessFields = [
    "opencode"
  ];

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
  # and each harness group to the empty set. The structural header keys
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
              {
                enable = if decl ? enable then decl.enable else true;
                inherit name;
                description = decl.description;
                source = decl.source;
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
