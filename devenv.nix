{ pkgs, ... }: {
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
  factory = {
    domain = {
      documentation.use = "artifact-driven";
      repo-arch.use = "multiple";
    };
    project = {
      design = {
        use = "ddd";
        tool = "unset";
      };
      agents = {
        uses = [
          "opencode"
        ];
        roles = {
          artifact-master = {
            description = "Coordinate one artifact-driven change phase by phase with Plan-Pn then Build-Pn. Own coordination only and start each phase owner. Use for coordinating a change, planning then building a phase, or running the next artifact phase.";
            source = ./services/factory/assets/roles/artifact-master/ROLE.md;
            harness.opencode = {
              model = "opencode-go/muse-spark-1.3-contributor";
              variant = "medium";
            };
          };
          requirement-expert = {
            description = "Write the requirements of a change in phase 1. Own the requirements content only. Use for writing requirements of a change.";
            source = ./services/factory/assets/roles/requirement-expert/ROLE.md;
            harness.opencode = {
              model = "opencode-go/muse-spark-1.3-contributor";
              variant = "medium";
            };
          };
          solution-expert = {
            description = "Write the specifications, decisions, tasks, and readiness confirmation of a change in phases 2 and 3. Use for writing specifications, plans, or readiness checks of a change.";
            source = ./services/factory/assets/roles/solution-expert/ROLE.md;
            harness.opencode = {
              model = "opencode-go/deepseek-v4.1-flash";
              variant = "max";
            };
          };
          artifact-release-expert = {
            description = "Make the copy-only release of a change in phase 5 after the readiness confirmation. Use for releasing a version of a change.";
            source = ./services/factory/assets/roles/artifact-release-expert/ROLE.md;
            harness.opencode = {
              mode = "subagent";
              model = "opencode-go/deepseek-v4.1-flash";
              variant = "high";
            };
          };
        };
      };
    };
  };
}
