{
  factory.project = {
    arch = "multiple";
    advanced = { };
    secrets = [ ];
    agents = {
      uses = [ "opencode" ];
      mcp = {
        context7 = {
          enabled = true;
          env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; };
        };
        codegraph = {
          enabled = true;
        };
      };
      opencode.extraAgents = {
        artifact-master.model = "opencode-go/deepseek-v4.1-flash";
        requirement-expert.model = "opencode-go/mimo-v2.6-pro";
        solution-expert = {
          model = "openai/gpt-6-sol";
          variant = "high";
        };
        artifact-release-expert.model = "opencode-go/muse-spark-1.3-contributor";
      };
      roles = {
        factory-expert = {
          description = "Owns phase 4 implementation of the services/factory Nix component and returns feasibility constraints in phases 2 and 3. Use for factory component tasks, seed-check failures, role render changes, or entrypoint and file-plan work.";
          source = ./utils/agent/role/factory-expert/ROLE.md;
          harness.opencode.mode = "subagent";
        };
      };
    };
    design = {
      use = "ddd";
      tool = "unset";
    };
    ux = false;
    ci = {
      use = "github-actions";
      folder = ".github/workflows";
      watchPaths = [ ];
    };
    site = {
      enable = true;
      title = "Better Factory Documentation";
      url = "https://cirius-nix.github.io";
      baseUrl = "/better-factory/";
      staticDirectories = [ ];
    };
    publish = {
      target = "github-pages";
      deployTool = "official-task";
    };
    notify = {
      uses = [ ];
      google-chat = {
        secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      };
      slack = {
        secret = "NOTIFY_SLACK_WEBHOOK";
      };
      telegram = {
        secret = "NOTIFY_TELEGRAM_TOKEN";
        chatId = "";
      };
    };
  };
}
