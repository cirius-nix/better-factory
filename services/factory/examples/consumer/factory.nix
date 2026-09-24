# Consumer declaration (copy mode seed).
# Owned settings of the consumer example (spec-consumer-entry). Each key
# differs from the fixture starter services/factory/assets/base/factory.nix
# except arch: the starter selects no harness, leaves CI unset, disables
# the site, holds the title Documentation, and uses the minimal preset.
{
  factory.project = {
    arch = "single";
    advanced = {
      owner = "acme";
    };
    secrets = [
      "ACME_DEPLOY_TOKEN"
    ];
    agents = {
      uses = [ "opencode" ];
      mcp = { };
      roles = { };
    };
    design = {
      use = "ddd";
      tool = "unset";
    };
    ux = true;
    ci = {
      use = "github-actions";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = {
        beforeNodeSetup = [ ];
        beforeSiteBuild = [ ];
        afterSiteBuild = [ ];
      };
    };
    site = {
      enable = true;
      title = "Acme Factory";
      url = "";
      baseUrl = "/";
      staticDirectories = [ ];
    };
    publish = {
      target = "azure-static-web-app";
      deployTool = "swa-cli";
    };
    notify = {
      uses = [ "slack" ];
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
    preset = "docs-only";
  };
}
