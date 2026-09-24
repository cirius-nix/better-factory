# services/factory/lib/site.nix
# Site library (spec-site-render). Holds the emitted-files table, the
# function featureOrder with the argument repoRoot, and the function
# siteFiles with the arguments settings and repoRoot. Pure Nix with no
# nixpkgs dependency. The feature order derives from the feature index of
# the repository under generation; the factory holds no hand list.
let
  # The emitted-files table of spec-site-render. Each entry holds the
  # emitted path, the content source under assets/delivery/site/, and the
  # copy mode. The file site.json is not an asset; the module renders it.
  # The factory emits no package-lock.json; the emitted repository
  # generates the lock file with `npm install` (spec-ci-options).
  emittedSiteFiles = [
    {
      rel = "apps/documentation/package.json";
      asset = ../assets/delivery/site/package.json;
      copyMode = "managed";
    }
    {
      rel = "apps/documentation/docusaurus.config.js";
      asset = ../assets/delivery/site/docusaurus.config.js;
      copyMode = "managed";
    }
    {
      rel = "apps/documentation/sidebars.js";
      asset = ../assets/delivery/site/sidebars.js;
      copyMode = "managed";
    }
    {
      rel = "apps/documentation/.gitignore";
      asset = ../assets/delivery/site/.gitignore;
      copyMode = "managed";
    }
    {
      rel = "apps/documentation/src/css/custom.css";
      asset = ../assets/delivery/site/src/css/custom.css;
      copyMode = "seed";
    }
    {
      rel = "apps/documentation/README.md";
      asset = ../assets/delivery/site/README.md;
      copyMode = "seed";
    }
  ];

  splitLines =
    s:
    let
      findNl =
        i:
        if i >= builtins.stringLength s then
          null
        else if builtins.substring i 1 s == "\n" then
          i
        else
          findNl (i + 1);
      idx = findNl 0;
    in
    if s == "" then
      [ ]
    else if idx == null then
      [ s ]
    else
      [ (builtins.substring 0 idx s) ]
      ++ splitLines (builtins.substring (idx + 1) (builtins.stringLength s - idx - 1) s);

  startsWith = prefix: s: builtins.substring 0 (builtins.stringLength prefix) s == prefix;

  trimCarriage =
    s:
    if s == "" then
      s
    else if builtins.substring (builtins.stringLength s - 1) 1 s == "\r" then
      builtins.substring 0 (builtins.stringLength s - 1) s
    else
      s;

  # Rows of the ## Features table in order: lines after the ## Features
  # heading that start with |. The header row and the separator row carry
  # no feat- name and drop out of the name match.
  indexRows =
    text:
    let
      lines = builtins.map trimCarriage (splitLines text);
      afterHeading = builtins.tail (
        let
          find =
            xs:
            if xs == [ ] then
              [ ]
            else if startsWith "## Features" (builtins.head xs) then
              xs
            else
              find (builtins.tail xs);
        in
        find lines
      );
      pipeLines = builtins.filter (l: startsWith "|" l) afterHeading;
      nameOf = l: builtins.match ".*(feat-[A-Za-z0-9-]+).*" l;
      names = builtins.filter (n: n != null) (
        builtins.map (
          l:
          let
            m = nameOf l;
          in
          if m == null then null else builtins.head m
        ) pipeLines
      );
      dedup = builtins.foldl' (acc: n: if builtins.elem n acc then acc else acc ++ [ n ]) [ ] names;
    in
    if lines == [ ] then [ ] else dedup;

  # The derived feature order of one repository root (adr-derived-feature-order):
  # the row order of the feature index, then each unlisted feature folder in
  # alphabetical order. An absent index gives the alphabetical order.
  featureOrder =
    repoRoot:
    let
      indexPath = repoRoot + "/docs/artifact/README.md";
      artDir = repoRoot + "/docs/artifact";
      hasIndex = builtins.pathExists indexPath;
      hasDir = builtins.pathExists artDir;
      listed = if !hasIndex then [ ] else indexRows (builtins.readFile indexPath);
      entries = if !hasDir then { } else builtins.readDir artDir;
      folders = builtins.sort builtins.lessThan (
        builtins.filter (n: entries.${n} == "directory" && startsWith "feat-" n) (
          builtins.attrNames entries
        )
      );
      unlisted = builtins.filter (n: !(builtins.elem n listed)) folders;
    in
    listed ++ unlisted;

  # The site files of the run. When settings.site.enable is true, each
  # asset file of the table joins the plan as an extraFiles entry whose
  # source is a builtins.toFile store path of the run, and site.json joins
  # as the rendered JSON store path. The same store paths join the
  # rendered-source list. A direct path under assets/delivery/ is never the
  # source of a plan entry. When enable is false, the plan holds no file.
  siteFiles =
    settings: repoRoot:
    let
      site = settings.site or { enable = false; };
    in
    if (site.enable or false) != true then
      {
        extraFiles = [ ];
        renderedSources = [ ];
      }
    else
      let
        order = featureOrder repoRoot;
        siteValue = {
          title = site.title or "Documentation";
          url = site.url or "";
          baseUrl = site.baseUrl or "/";
          staticDirectories = site.staticDirectories or [ ];
          featureOrder = order;
        };
        jsonSource = builtins.toFile "site.json" (builtins.toJSON siteValue);
        assetEntries = builtins.map (
          f:
          let
            source = builtins.toFile "site-file" (builtins.readFile f.asset);
          in
          {
            rel = f.rel;
            inherit source;
            copyMode = f.copyMode;
          }
        ) emittedSiteFiles;
        jsonEntry = {
          rel = "apps/documentation/site.json";
          source = jsonSource;
          copyMode = "managed";
        };
        entries = assetEntries ++ [ jsonEntry ];
      in
      {
        extraFiles = entries;
        renderedSources = builtins.map (e: e.source) entries;
      };
in
{
  inherit
    emittedSiteFiles
    featureOrder
    siteFiles
    ;
}
