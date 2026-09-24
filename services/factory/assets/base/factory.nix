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
    ci = {
      use = "unset";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = {
        beforeNodeSetup = [ ];
        beforeSiteBuild = [ ];
        afterSiteBuild = [ ];
      };
    };
    site = {
      enable = false;
      title = "Documentation";
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
    preset = "minimal";
  };
}
