{ pkgs, ... }: {
  packages = with pkgs; [
    go-task
    codegraph
  ];
  git-hooks = {
    package = pkgs.prek;
    hooks.convco = {
      enable = true;
      entry = "sh -c 'convco check --from-stdin < \"$1\"' convco-hook";
    };
    hooks.markdownlint = {
      enable = true;
      entry = "markdownlint --config .markdownlint.yaml";
      excludes = [
        "^docs/.*/templates/"
        "^CLAUDE\\.md$"
        "^\\.(agents|claude|codex|opencode)/"
      ];
    };
    hooks.ripsecrets = {
      enable = true;
      entry = "ripsecrets --strict-ignore";
    };
    hooks.gitleaks = {
      enable = true;
      name = "gitleaks";
      description = "Scan the staged diff for secrets with gitleaks";
      package = pkgs.gitleaks;
      entry = "gitleaks git --pre-commit --staged --redact --no-banner --verbose";
      pass_filenames = false;
    };
  };
}
