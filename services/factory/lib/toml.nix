# services/factory/lib/toml.nix
# One pinned TOML renderer for the codex files (spec-mcp-dialect, C-07).
# The codex config and each codex role file use this renderer. The component
# holds no second TOML renderer.
#
# Rules: a string scalar is JSON-encoded (a JSON string is a TOML basic
# string); an integer, a float, and a boolean render as TOML literals; a
# list of scalars renders inline; a nested attribute set renders as a table
# header on its own line; a table writes its scalar keys before its
# sub-tables; a null, a function, and a list of tables fail evaluation; the
# same input gives the same bytes on each run (attribute names sort).
let
  isScalar = v: builtins.isString v || builtins.isInt v || builtins.isFloat v || builtins.isBool v;

  isValueList = v: builtins.isList v;

  isTable = v: builtins.isAttrs v;

  renderScalar =
    v:
    if builtins.isString v then
      builtins.toJSON v
    else if builtins.isInt v then
      builtins.toString v
    else if builtins.isFloat v then
      builtins.toString v
    else if builtins.isBool v then
      (if v then "true" else "false")
    else
      throw "toml renderer: unsupported scalar of type `${builtins.typeOf v}`";

  renderList =
    items:
    if items == [ ] then
      "[ ]"
    else if builtins.all isScalar items then
      "[ ${builtins.concatStringsSep ", " (builtins.map renderScalar items)} ]"
    else
      throw "toml renderer: a list holds scalars only; a list of tables fails evaluation";

  bareKey = k: builtins.match "[A-Za-z0-9_-]+" k != null;

  keySegment = k: if bareKey k then k else builtins.toJSON k;

  showHeader = path: "[${builtins.concatStringsSep "." (builtins.map keySegment path)}]";

  renderTableLines =
    path: attrs:
    let
      keys = builtins.attrNames attrs;
      scalarKeys = builtins.filter (k: isScalar attrs.${k} || isValueList attrs.${k}) keys;
      tableKeys = builtins.filter (k: isTable attrs.${k}) keys;
      known = scalarKeys ++ tableKeys;
      bad = builtins.filter (k: !(builtins.elem k known)) keys;
    in
    if bad != [ ] then
      throw "toml renderer: unsupported value for key `${builtins.head bad}`"
    else
      let
        header = if path == [ ] then [ ] else [ (showHeader path) ];
        scalarLines = builtins.map (
          k:
          if isValueList attrs.${k} then
            "${keySegment k} = ${renderList attrs.${k}}"
          else
            "${keySegment k} = ${renderScalar attrs.${k}}"
        ) scalarKeys;
        subLists = builtins.map (k: renderTableLines (path ++ [ k ]) attrs.${k}) tableKeys;
        joined = builtins.foldl' (acc: l: if acc == [ ] then l else acc ++ [ "" ] ++ l) [ ] subLists;
        lead = header ++ scalarLines;
      in
      lead ++ (if joined == [ ] then [ ] else (if lead == [ ] then joined else [ "" ] ++ joined));

  renderToml =
    attrs:
    if !(builtins.isAttrs attrs) then
      throw "toml renderer: the document must be an attribute set, got `${builtins.typeOf attrs}`"
    else
      builtins.concatStringsSep "\n" (renderTableLines [ ] attrs) + "\n";
in
{
  inherit renderToml;
}
