# services/factory/modules/yaml-renderer.nix
# One pinned line-based YAML renderer (spec-copymode).
# A scalar is JSON-encoded. YAML accepts JSON scalars. A nested attribute set
# and a list indent by two spaces. A key outside [A-Za-z0-9_-]+ is
# JSON-quoted. Empty containers render inline. The same input gives the same
# bytes on each run. Unsupported values (functions) fail evaluation.
let
  isScalar =
    v: builtins.isString v || builtins.isInt v || builtins.isFloat v || builtins.isBool v || v == null;

  keyText = k: if builtins.match "[A-Za-z0-9_-]+" k != null then k else builtins.toJSON k;

  indent = level: builtins.concatStringsSep "" (builtins.genList (_: "  ") level);

  renderMap =
    level: attrs:
    builtins.concatLists (
      builtins.map (
        k:
        let
          v = attrs.${k};
          head = "${indent level}${keyText k}:";
        in
        if isScalar v then
          [ "${head} ${builtins.toJSON v}" ]
        else if builtins.isAttrs v && v != { } then
          [ head ] ++ renderMap (level + 1) v
        else if builtins.isList v && v != [ ] then
          [ head ] ++ renderList (level + 1) v
        else if builtins.isAttrs v || builtins.isList v then
          [ "${head} ${builtins.toJSON v}" ]
        else
          throw "yaml renderer: unsupported value for key `${k}`"
      ) (builtins.attrNames attrs)
    );

  renderList =
    level: items:
    builtins.concatLists (
      builtins.map (
        x:
        if isScalar x then
          [ "${indent level}- ${builtins.toJSON x}" ]
        else if builtins.isAttrs x && x != { } then
          [ "${indent level}-" ] ++ renderMap (level + 1) x
        else if builtins.isList x && x != [ ] then
          [ "${indent level}-" ] ++ renderList (level + 1) x
        else if builtins.isAttrs x || builtins.isList x then
          [ "${indent level}- ${builtins.toJSON x}" ]
        else
          throw "yaml renderer: unsupported list item"
      ) items
    );

  renderYaml = attrs: builtins.concatStringsSep "\n" (renderMap 0 attrs) + "\n";
in
{
  inherit renderYaml;
}
