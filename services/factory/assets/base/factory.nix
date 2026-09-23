# Starter factory declaration (copy mode seed).
# Sets the root factory.project, the arch, and the three groups. The group
# `agents` selects no harness (spec-harness-merge point 7).
{
  factory.project = {
    arch = "single";
    advanced = {
    };
    secrets = [
      "GITHUB_TOKEN"
    ];
    agents = {
      uses = [ ];
      mcp = { };
      roles = { };
    };
    design = {
      use = "unset";
      tool = "unset";
    };
    ux = false;
  };
}
