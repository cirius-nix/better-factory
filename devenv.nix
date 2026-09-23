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
      design.use = "ddd";
      agent = {
        harness = {
          uses = [
            "opencode"
          ];
          opencode.settings = {
            agent = {
              explore.model = "opencode-go/deepseek-v4.1-flash";
              plan.model = "opencode-go/muse-spark-1.3-contributor";
              build.model = "opencode-go/deepseek-v4.1-flash";
            };
          };
        };
        role.builder = {
          artifact-master.harness = {
            # sonnet-high or opus-medium
            opencode = {
              model = "opencode-go/muse-spark-1.3-contributor";
              variant = "medium";
            };
          };
          requirement-expert.harness = {
            opencode = {
              # sonnet or opus medium
              model = "opencode-go/muse-spark-1.3-contributor";
              variant = "medium";
            };
          };
          solution-expert.harness = {
            opencode = {
              model = "opencode-go/deepseek-v4.1-flash";
              variant = "max";
            };
          };
          artifact-release-expert = {
            harness.opencode = {
              mode = "subagent";
              model = "opencode-go/deepseek-v4.1-flash";
              variant = "high";
            };
          };
        };
        skill.builtins = {
          asd-ste-100.enable = true;
          asd-ste-100-chat-no-slop.enable = true;
        };
      };
    };
  };
}
