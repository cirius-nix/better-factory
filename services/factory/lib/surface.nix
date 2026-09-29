# services/factory/lib/surface.nix
# The standard surface of a generated project (spec-coverage-surface). Pure
# Nix with no nixpkgs dependency. One entry holds the field `class`, the
# field `copyMode`, the field `scope`, and the field `pattern`. The scope is
# `model` or `conditional` (C-CA29). The repository classes name the shipped
# role `repository-expert` (spec-repository-role, C-CA30).
let
  # The copy-mode value set (C-FCA-01-04). The value `none` marks a class
  # that the factory does not copy. A class with the value `none` stays in
  # the declaration and never passes through `mkFileDecl`, because the class
  # holds no planned file.
  copyModes = [
    "seed"
    "managed"
    "template"
    "none"
  ];

  # The scope value set (C-CA29). A `model` class is an author path of every
  # project. A `conditional` class is an author path of a project only when
  # the class pattern matches a path of the project.
  scopes = [
    "model"
    "conditional"
  ];

  # The standard surface of a generated project (spec-coverage-surface, the
  # standard surface table). One entry holds one class and one path pattern.
  # The render `surfaceDeclaration` of modules/coverage.nix computes the
  # effective copy mode of each class from the effective file plan. A class
  # whose pattern matches no planned file keeps the table copy mode
  # (spec-coverage-surface interface 9). The conditional classes are the
  # `design` class, the five `component-*` classes (C-CA31), and the
  # `role-source` class (C-RS-02). The class `factory-config` holds the
  # planned file `factory.config.yaml` (C-CA30). The class `role-source`
  # holds no planned file: a project author writes a role source.
  standardSurface = [
    {
      class = "surface-declaration";
      pattern = "surface.tsv";
      copyMode = "managed";
      scope = "model";
    }
    {
      class = "repository-readme";
      pattern = "README.md";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "factory-declaration";
      pattern = "factory.nix";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "repository-ignore";
      pattern = ".gitignore";
      copyMode = "managed";
      scope = "model";
    }
    {
      class = "agent-guide";
      pattern = "AGENTS.md";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "dev-shell";
      pattern = "devenv.nix";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "dev-flake";
      pattern = "flake.nix";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "project-skill";
      pattern = ".agents/skills/*";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "project-command";
      pattern = ".opencode/commands/*";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "project-agent";
      pattern = ".opencode/agents/*";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "role-source";
      pattern = "utils/agent/role/*";
      copyMode = "none";
      scope = "conditional";
    }
    {
      class = "harness-config";
      pattern = ".opencode/opencode.jsonc";
      copyMode = "managed";
      scope = "model";
    }
    {
      class = "scan-script";
      pattern = ".opencode/scripts/*";
      copyMode = "managed";
      scope = "model";
    }
    {
      class = "factory-config";
      pattern = "factory.config.yaml";
      copyMode = "template";
      scope = "model";
    }
    {
      class = "artifact-template";
      pattern = "docs/wiki/documentation/artifact-driven/templates/*";
      copyMode = "managed";
      scope = "model";
    }
    {
      class = "artifact-index";
      pattern = "docs/artifact/README.md";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "artifact-change";
      pattern = "docs/artifact/*/changes/*/README.md";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "artifact-requirement";
      pattern = "docs/artifact/*/changes/*/requirements/*";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "artifact-specification";
      pattern = "docs/artifact/*/changes/*/specifications/*";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "artifact-decision";
      pattern = "docs/artifact/*/changes/*/decisions/*";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "artifact-task";
      pattern = "docs/artifact/*/changes/*/tasks/*";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "artifact-version";
      pattern = "docs/artifact/*/versions/*";
      copyMode = "none";
      scope = "model";
    }
    {
      class = "artifact-feature";
      pattern = "docs/artifact/*/README.md";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "domain";
      pattern = "docs/domain/*";
      copyMode = "seed";
      scope = "model";
    }
    {
      class = "design";
      pattern = "docs/artifact/*/changes/*/design/*";
      copyMode = "template";
      scope = "conditional";
    }
    {
      class = "component-app";
      pattern = "apps/*";
      copyMode = "none";
      scope = "conditional";
    }
    {
      class = "component-service";
      pattern = "services/*";
      copyMode = "none";
      scope = "conditional";
    }
    {
      class = "component-library";
      pattern = "libs/*";
      copyMode = "none";
      scope = "conditional";
    }
    {
      class = "component-deployment";
      pattern = "deployment/*";
      copyMode = "none";
      scope = "conditional";
    }
    {
      class = "component-e2e";
      pattern = "e2e/*";
      copyMode = "none";
      scope = "conditional";
    }
  ];
in
{
  inherit
    copyModes
    scopes
    standardSurface
    ;
}
