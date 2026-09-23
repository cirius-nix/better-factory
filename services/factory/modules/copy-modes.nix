# services/factory/modules/copy-modes.nix
# Copy modes and the manifest (spec-copymode).
# files is an attribute set of declarations. Each key is a repository-relative
# path in quotes. Each declaration is a submodule with the fields source and
# copyMode. copyMode is optional; the default is seed. The value set is
# exactly seed, managed, and template.
let
  filePlan = import ./file-plan.nix;

  manifestText =
    files:
    let
      rels = builtins.sort builtins.lessThan (builtins.attrNames files);
      line = rel: "${files.${rel}.copyMode}\t${rel}\t${toString files.${rel}.source}";
    in
    builtins.concatStringsSep "\n" (builtins.map line rels) + "\n";
in
{
  inherit (filePlan) validModes mkFileDecl;
  inherit manifestText;
}
