# services/factory/modules/artifact-cleanup.nix
# The artifact cleanup script (spec-cleanup-bundle, C-FAC-01-04, C-FAC-01-10).
# The script is not one of the seven capability kinds. It joins the plan as an
# `extraFiles` entry whose source is a `builtins.toFile` render in the
# `renderedSources` list of the run. The directory `assets/scripts/` is a raw
# asset root, so `checkSourceAllowed` rejects a raw path under it. The module
# reads the asset with `builtins.readFile`; it imports no asset path. The
# render is pure Nix.
let
  scriptSource = builtins.toFile "artifact-cleanup.sh" (
    builtins.readFile ../assets/scripts/artifact-cleanup.sh
  );
in
{
  inherit scriptSource;
  extraFiles = [
    {
      rel = ".opencode/scripts/artifact-cleanup.sh";
      source = scriptSource;
      copyMode = "managed";
    }
  ];
  renderedSources = [ scriptSource ];
}
