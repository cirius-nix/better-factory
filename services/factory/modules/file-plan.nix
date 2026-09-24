# services/factory/modules/file-plan.nix
# File plan of the factory (spec-arch-seed).
# Resolves the file set of one arch to one plan of file declarations:
# files."<path>" = { source; copyMode; }.
# The plan is the allowlist: each source is under assets/base/ or under
# assets/overlays/<selected arch>/. A source under the inactive overlay or
# outside these two trees fails the check.
let
  facade = import ./facade.nix;

  validModes = [
    "seed"
    "managed"
    "template"
  ];
  overlayNames = [
    "single"
    "multiple"
  ];

  hasPrefix = prefix: s: builtins.substring 0 (builtins.stringLength prefix) s == prefix;

  # Recursive listing of the regular files below a directory.
  # Returns repository-relative paths below the directory.
  listTree =
    dir: prefix:
    let
      entries = builtins.readDir dir;
      names = builtins.attrNames entries;
      walk =
        name:
        let
          kind = entries.${name};
          rel = if prefix == "" then name else "${prefix}/${name}";
        in
        if kind == "directory" then
          listTree (dir + "/${name}") rel
        else if kind == "regular" then
          [ rel ]
        else
          throw "file plan: entry `${rel}` has an unsupported type";
    in
    builtins.concatLists (builtins.map walk names);

  # One file declaration. copyMode is optional; the default is seed.
  mkFileDecl =
    {
      rel,
      source ? null,
      copyMode ? "seed",
    }:
    if source == null then
      throw "file plan: file `${rel}` has no `source`"
    else if !(builtins.elem copyMode validModes) then
      throw "file plan: copyMode `${copyMode}` of `${rel}` must be one of seed, managed, template"
    else
      { inherit source copyMode; };

  checkSourceAllowed =
    {
      arch,
      baseDir,
      overlayDir,
      renderedSources ? [ ],
      rel,
      source,
    }:
    let
      s = toString source;
      basePrefix = toString baseDir + "/";
      overlayPrefix = toString overlayDir + "/";
      rendered = builtins.map toString renderedSources;
    in
    if hasPrefix basePrefix s || hasPrefix overlayPrefix s || builtins.elem s rendered then
      true
    else
      throw "file plan: source of `${rel}` is neither an asset tree path under assets/base/ or assets/overlays/${arch}/ (base files, overlay files, extraFiles) nor a rendered path of the rendered-source list ${builtins.toJSON rendered} of the run";

  checkDuplication =
    {
      baseDir,
      overlayDir,
      rel,
    }:
    let
      baseContent = builtins.readFile (baseDir + "/${rel}");
      overlayContent = builtins.readFile (overlayDir + "/${rel}");
      baseHash = builtins.hashString "sha256" baseContent;
      overlayHash = builtins.hashString "sha256" overlayContent;
    in
    if baseHash == overlayHash then
      throw "file plan: base file and overlay file of `${rel}` have equal content hashes"
    else
      true;

  checkOverlayNames =
    factoryDir:
    let
      names = builtins.attrNames (builtins.readDir (factoryDir + "/assets/overlays"));
    in
    if builtins.sort builtins.lessThan names == builtins.sort builtins.lessThan overlayNames then
      true
    else
      throw "file plan: overlays hold ${builtins.toJSON names}, want ${builtins.toJSON overlayNames}";

  # The foundation mode map (spec-consumer-entry). One table read by the
  # seed check and by the entrypoint, so a mode cannot differ between the
  # factory examples and the consumer tree.
  foundationModes = {
    ".gitignore" = "managed";
    ".markdownlint.yaml" = "managed";
    "docs/wiki/repo-arch/single-repository.md" = "managed";
    "docs/wiki/repo-arch/multiple-repositories.md" = "managed";
    "e2e/README.md" = "managed";
    "factory.config.yaml" = "template";
  };

  # The file plan of one arch: base files plus exactly one overlay.
  # A path in the base and in the active overlay appears once; the overlay
  # file wins. modes maps a relative path to its copy mode (default seed).
  # extraFiles joins the plan in the same transaction: each entry holds
  # `rel`, `source`, and an optional `copyMode` (default managed). The
  # source of each entry is either an asset tree path or a rendered path of
  # renderedSources, the rendered-source list of the run. An entry of
  # neither kind fails the check, as does an arbitrary store path.
  planForArch =
    {
      arch,
      factoryDir,
      modes ? { },
      extraFiles ? [ ],
      renderedSources ? [ ],
    }:
    let
      _arch =
        if builtins.elem arch overlayNames then
          true
        else
          throw "arch-value: the key `arch` must be `single` or `multiple`, got `${arch}`";
      baseDir = factoryDir + "/assets/base";
      overlayDir = factoryDir + "/assets/overlays/${arch}";
      _names = checkOverlayNames factoryDir;
      baseRels = listTree baseDir "";
      overlayRels = listTree overlayDir "";
      shared = builtins.filter (rel: builtins.elem rel baseRels) overlayRels;
      _dups = builtins.map (rel: checkDuplication { inherit baseDir overlayDir rel; }) shared;
      baseOnly = builtins.filter (rel: !(builtins.elem rel overlayRels)) baseRels;
      allRels = baseOnly ++ overlayRels;
      modeOf = rel: if builtins.hasAttr rel modes then modes.${rel} else "seed";
      sourceOf =
        rel: if builtins.elem rel overlayRels then overlayDir + "/${rel}" else baseDir + "/${rel}";
      one =
        rel:
        let
          source = sourceOf rel;
          _allowed = checkSourceAllowed {
            inherit
              arch
              baseDir
              overlayDir
              rel
              source
              ;
          };
        in
        assert _allowed;
        {
          name = rel;
          value = mkFileDecl {
            inherit rel source;
            copyMode = modeOf rel;
          };
        };
      _extra = builtins.map (
        f:
        let
          _allowed = checkSourceAllowed {
            inherit
              arch
              baseDir
              overlayDir
              renderedSources
              ;
            inherit (f) rel source;
          };
        in
        assert _allowed;
        {
          name = f.rel;
          value = mkFileDecl {
            rel = f.rel;
            source = f.source;
            copyMode = f.copyMode or "managed";
          };
        }
      ) extraFiles;
    in
    assert _arch;
    assert _names;
    assert builtins.all (x: x) _dups;
    assert builtins.all (e: builtins.isAttrs e.value) _extra;
    {
      inherit arch;
      baseFiles = baseRels;
      overlayFiles = overlayRels;
      files = builtins.listToAttrs (builtins.map one allRels) // builtins.listToAttrs _extra;
    };
in
{
  inherit
    validModes
    overlayNames
    listTree
    mkFileDecl
    checkSourceAllowed
    checkDuplication
    checkOverlayNames
    planForArch
    foundationModes
    ;
}
