# services/factory/lib/notify.nix
# Notifier library (spec-notify-fanout). Holds the function notifyFiles
# with the argument settings and the function notifyStep with the provider
# and the settings. One script serves both CI providers at the
# provider-neutral path scripts/notify.py. Pure Nix with no nixpkgs
# dependency.
let
  scriptContent = builtins.readFile ../assets/delivery/notify.py;

  secretRef =
    provider: name:
    if provider == "github-actions" then "$" + "{{ secrets." + name + " }}" else "$(" + name + ")";

  # The environment mapping of spec-notify-fanout. Each CI value maps onto
  # one notifier input. The input of a channel is written only when the
  # channel is selected. On GitHub Actions a secret reads
  # ${{ secrets.<name> }}. On Azure Pipelines a secret reads $(<name>).
  notifyEnv =
    provider: settings:
    let
      notify = settings.notify or { };
      uses = notify.uses or [ ];
      site = settings.site or { };
      selected = channel: builtins.elem channel uses;
      gcSecret = (notify.google-chat or { }).secret or "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      slSecret = (notify.slack or { }).secret or "NOTIFY_SLACK_WEBHOOK";
      tgSecret = (notify.telegram or { }).secret or "NOTIFY_TELEGRAM_TOKEN";
      tgChatId = (notify.telegram or { }).chatId or "";
      siteUrl = site.url or "";
      target = (settings.publish or { }).target or "github-pages";
      deployUrl =
        if provider == "github-actions" && target == "github-pages" then
          "$" + "{{ steps.deployment.outputs.page_url }}"
        else
          siteUrl;
      repoRef =
        if provider == "github-actions" then
          "$" + "{{ github.repository }}"
        else
          "$(Build.Repository.Name)";
      refRef =
        if provider == "github-actions" then "$" + "{{ github.ref_name }}" else "$(Build.SourceBranchName)";
      shaRef =
        if provider == "github-actions" then "$" + "{{ github.sha }}" else "$(Build.SourceVersion)";
      runRef =
        if provider == "github-actions" then
          "$"
          + "{{ github.server_url }}/"
          + "$"
          + "{{ github.repository }}/actions/runs/"
          + "$"
          + "{{ github.run_id }}"
        else
          "$(System.TeamFoundationCollectionUri)$(System.TeamProject)/_build/results?buildId=$(Build.BuildId)";
    in
    {
      NOTIFY_USES = builtins.toJSON uses;
      NOTIFY_DEPLOYMENT_URL = deployUrl;
      NOTIFY_REPOSITORY = repoRef;
      NOTIFY_REF_NAME = refRef;
      NOTIFY_COMMIT_SHA = shaRef;
      NOTIFY_RUN_URL = runRef;
    }
    // (
      if selected "google-chat" then
        { NOTIFY_GOOGLE_CHAT_WEBHOOK = secretRef provider gcSecret; }
      else
        { }
    )
    // (if selected "slack" then { NOTIFY_SLACK_WEBHOOK = secretRef provider slSecret; } else { })
    // (
      if selected "telegram" then
        {
          NOTIFY_TELEGRAM_TOKEN = secretRef provider tgSecret;
          NOTIFY_TELEGRAM_CHAT_ID = tgChatId;
        }
      else
        { }
    );

  # The notification step of one provider in the typed step model
  # (spec-ci-options). The step runs python3 scripts/notify.py at the
  # repository root. Returns null when uses is [ ]; the renderers add no
  # notification step then.
  notifyStep =
    provider: settings:
    let
      uses = (settings.notify or { }).uses or [ ];
    in
    if uses == [ ] then
      null
    else
      {
        name = "Notify the team";
        run = "python3 scripts/notify.py";
        env = notifyEnv provider settings;
        workingDirectory = ".";
      };

  # The notifier file computation. The gate is the value uses not equal to
  # [ ]. The source of the entry is a builtins.toFile store path of the
  # script content. The copy mode is managed. The same store path joins the
  # rendered-source list. When uses is [ ], the plan holds no file.
  notifyFiles =
    settings:
    let
      uses = (settings.notify or { }).uses or [ ];
    in
    if uses == [ ] then
      {
        extraFiles = [ ];
        renderedSources = [ ];
      }
    else
      let
        source = builtins.toFile "notify.py" scriptContent;
      in
      {
        extraFiles = [
          {
            rel = "scripts/notify.py";
            inherit source;
            copyMode = "managed";
          }
        ];
        renderedSources = [ source ];
      };
in
{
  inherit
    notifyEnv
    notifyStep
    notifyFiles
    ;
}
