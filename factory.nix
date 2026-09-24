{
  factory.project = {
    arch = "multiple";
    advanced = { };
    secrets = [ ];
    agents = {
      uses = [ "opencode" ];
      mcp = { };
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
      url = "";
      baseUrl = "/";
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
