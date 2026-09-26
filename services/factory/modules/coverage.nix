# services/factory/modules/coverage.nix
# The surface declaration of a generated project (spec-coverage-surface).
# The module imports the pure library lib/surface.nix. No module imports an
# asset path; the render is pure Nix. The declaration joins the plan as an
# `extraFiles` entry whose source is a `builtins.toFile` render in the
# `renderedSources` list of the run (C-FCA-01-02, C-FCA-01-06).
let
  surface = import ../lib/surface.nix;

  chars = s: builtins.genList (i: builtins.substring i 1 s) (builtins.stringLength s);

  escapeChar =
    c:
    if builtins.elem c [ "." "+" "?" "(" ")" "[" "]" "{" "}" "|" "^" "$" "\\" ] then
      "\\${c}"
    else
      c;

  escapeRegex = s: builtins.concatStringsSep "" (builtins.map escapeChar (chars s));

  # The glob match of one path pattern and one path (spec-coverage-scan, the
  # coverage relation). The wildcard `*` matches zero or more characters,
  # including `/`. The relation is deterministic.
  globMatch =
    pattern: text:
    builtins.match ("^" + builtins.replaceStrings [ "*" ] [ ".*" ] (escapeRegex pattern) + "$") text
    != null;

  # The effective copy mode of one standard class (spec-coverage-surface
  # interface 6, C-FCA-01-04). The render reads the effective file plan. An
  # exact planned path gives the plan copy mode. Otherwise the first planned
  # path that the pattern matches gives the plan copy mode. A class with no
  # planned file keeps the table value. The value `none` never passes
  # through `mkFileDecl`, because the class holds no planned file.
  effectiveCopyMode =
    plan: entry:
    let
      files = plan.files;
      matching = builtins.filter (rel: globMatch entry.pattern rel) (builtins.attrNames files);
    in
    if builtins.hasAttr entry.pattern files then
      files.${entry.pattern}.copyMode
    else if matching != [ ] then
      files.${builtins.head matching}.copyMode
    else
      entry.copyMode;

  oneLine =
    plan: entry:
    "${entry.class}\t${effectiveCopyMode plan entry}\t${entry.scope}\t${entry.pattern}";

  # The declaration text: one line per standard class of the table,
  # including a class whose pattern matches no planned file. One line holds
  # the class, the effective copy mode, the scope, and the pattern,
  # separated by a tab (spec-coverage-surface interface 3 and 9). A line
  # that starts with `#` is a comment.
  declarationText =
    plan:
    builtins.concatStringsSep "\n" (builtins.map (oneLine plan) surface.standardSurface) + "\n";

  # The render returns the `extraFiles` entry and the rendered-source list of
  # the run. The source is a `builtins.toFile` render, so a raw path under
  # `assets/` is rejected by `checkSourceAllowed` (C-FCA-01-02). The copy
  # mode of the entry is `managed`.
  surfaceDeclaration =
    plan:
    let
      text = declarationText plan;
      source = builtins.toFile "surface.tsv" text;
    in
    {
      inherit text;
      extraFiles = [
        {
          rel = "surface.tsv";
          inherit source;
          copyMode = "managed";
        }
      ];
      renderedSources = [ source ];
    };

  # The coverage scan script (spec-coverage-bundle, C-FCA-05-02). The script is
  # not a capability kind. It joins the plan as an extra file whose source is a
  # `builtins.toFile` render in the `renderedSources` list of the run. The
  # directory `assets/scripts/` is a raw asset root, so `checkSourceAllowed`
  # rejects a raw path under it.
  scriptSource = builtins.toFile "coverage-audit.sh" (
    builtins.readFile ../assets/scripts/coverage-audit.sh
  );

  scriptFiles = {
    extraFiles = [
      {
        rel = ".opencode/scripts/coverage-audit.sh";
        source = scriptSource;
        copyMode = "managed";
      }
    ];
    renderedSources = [ scriptSource ];
  };
in
{
  inherit
    globMatch
    effectiveCopyMode
    declarationText
    surfaceDeclaration
    scriptSource
    scriptFiles
    ;
}
