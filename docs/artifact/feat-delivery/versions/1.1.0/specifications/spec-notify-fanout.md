# spec-notify-fanout: The deploy notifier and the channels

**Master:** [Specifications](README.md)
**Covers:** req-notifier
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One notifier sends one deploy message to each selected channel. The channels are `google-chat`,
`slack`, and `telegram`. The notifier serves deploy messages only. No other event uses it. The
declaration holds secret names only; the values stay in `.env` or in the CI secrets.

The notifier file lives at one provider-neutral path. One script serves both CI providers. The
CI renderer adds the notification step after a successful deploy step (spec-ci-options).

The blueprint records the channels, the secret names, and the notifier file.

## Contract

### The option group

```nix
factory.project.notify = {
  uses = [ "google-chat" "slack" "telegram" ];  # ordered list; default [ ]
  google-chat.secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
  slack.secret = "NOTIFY_SLACK_WEBHOOK";
  telegram.secret = "NOTIFY_TELEGRAM_TOKEN";
  telegram.chatId = "123456789";
};
```

1. `uses` is an ordered list. Each entry is one of `google-chat`, `slack`, and `telegram`. An
   absent value gives `[ ]`. Another entry fails evaluation. A duplicate entry fails
   evaluation.
2. The group holds exactly the keys `uses`, `google-chat`, `slack`, and `telegram`. The groups
   `google-chat` and `slack` hold exactly the key `secret`. The group `telegram` holds exactly
   the keys `secret` and `chatId`. An unknown key fails evaluation.
3. Each `secret` value is a name. The name matches `^[A-Za-z_][A-Z0-9_]*$`. The name is not
   empty. A value of another shape, for example a webhook URL, fails evaluation.
4. `chatId` is a non-empty string when the channel `telegram` is selected. A missing or empty
   value fails evaluation when `telegram` is selected.
5. The group joins the modeled-key list and the root option definitions of the facade root in
   the same change (spec-presets, C-30). `evalFactory` accepts the group and returns it with
   the other settings.
6. The factory never reads and never writes a secret value. A Nix string is world-readable in
   the Nix store, so the declaration holds names only.

### The notifier file

1. The notifier file is one script at `scripts/notify.py`. One source lives at
   `assets/delivery/notify.py`. The factory emits one notifier file and no second notifier.
2. The factory emits the notifier file when `uses` is not `[ ]` (spec-presets, C-39). The
   factory emits no notifier file when `uses` is `[ ]`.
3. The notifier file joins the file plan as an `extraFiles` entry. The `source` of the entry is
   a `builtins.toFile` store path of the script content. The rendered-source list of the run
   holds the same store path (spec-site-render, C-21, C-33). The file-plan allowlist stays the
   base tree, the active overlay tree, and the rendered-source list. A direct path under
   `assets/delivery/` fails the file-plan check.
4. The copy mode of the notifier file is `managed` (spec-copymode of feat-foundation 1.0.0).
5. The notifier file takes the HTTP transport and the sleep function as function parameters.
   The script holds no other transport call and no other sleep call. The check injects a stub
   transport and a stub sleep through these parameters.

### The one message contract

The notifier sends one plain-text message to each selected channel:

```text
Documentation site deployed: owner/repository
URL: https://owner.github.io/repository/
Source: main @ 0123456
Run: https://github.com/owner/repository/actions/runs/123456
```

1. Each selected channel receives the same message. The message holds the repository, the
   deployment URL, the source ref and the commit, and the run URL.
2. The message uses the first seven characters of the commit SHA.
3. The message stays at or below 3,500 characters. A longer message fails the delivery.
4. The payload is UTF-8 JSON. The webhook channels `google-chat` and `slack` receive
   `{"text": "..."}`. The channel `telegram` receives `{"chat_id": "...", "text": "..."}` at
   the Bot API method `sendMessage`.
5. The notifier does not print a webhook URL, a bot token, or a response body. It reports the
   channel name and the response status only.
6. The notifier sends no message for an event other than the deploy event. The notifier holds
   no second message.

### The environment input

The CI renderer maps each CI value onto one notifier input:

| Input | Meaning | GitHub Actions source | Azure Pipelines source |
| --- | --- | --- | --- |
| `NOTIFY_USES` | The JSON list of the selected channels. | The rendered list. | The rendered list. |
| `NOTIFY_GOOGLE_CHAT_WEBHOOK` | The Google Chat webhook. | `${{ secrets.<name> }}` | `$(<name>)` |
| `NOTIFY_SLACK_WEBHOOK` | The Slack webhook. | `${{ secrets.<name> }}` | `$(<name>)` |
| `NOTIFY_TELEGRAM_TOKEN` | The Telegram bot token. | `${{ secrets.<name> }}` | `$(<name>)` |
| `NOTIFY_TELEGRAM_CHAT_ID` | The Telegram chat ID. | The configured value. | The configured value. |
| `NOTIFY_DEPLOYMENT_URL` | The deployed site URL. | The deploy step output or the site URL. | The deploy step output or the site URL. |
| `NOTIFY_REPOSITORY` | The repository name. | `${{ github.repository }}` | `$(Build.Repository.Name)` |
| `NOTIFY_REF_NAME` | The source branch name. | `${{ github.ref_name }}` | `$(Build.SourceBranchName)` |
| `NOTIFY_COMMIT_SHA` | The commit SHA. | `${{ github.sha }}` | `$(Build.SourceVersion)` |
| `NOTIFY_RUN_URL` | The run URL. | `${{ github.server_url }}/${{ github.repository }}/actions/runs/${{ github.run_id }}` | The build results URL. |

1. Each secret name maps one to one onto a CI secret of the same name. On GitHub Actions the
   name is a repository secret. On Azure Pipelines the name is a secret variable of the same
   name.
2. The renderer writes the input of a channel only when the channel is selected.
3. The notifier reads no other environment value.

### The deploy trigger

1. The notification step follows a successful deploy step. The deploy step belongs to the
   selected publish target (spec-publish).
2. The notification step runs in the job of the deploy step. A failed deploy step stops the
   notification step.
3. On GitHub Actions the deploy job holds the permission `contents: read`. The notification
   step follows a checkout step with `persist-credentials: false`.
4. On Azure Pipelines the notification step is a script step after the deploy step.
5. The step runs `python3 scripts/notify.py`.
6. The factory adds no notification step when `uses` is `[ ]`.

### The delivery contract

1. The notifier treats each HTTP 2xx response as success.
2. The notifier retries a network error, HTTP 429, and an HTTP 5xx response. It makes at most
   three attempts with one-second and two-second delays. It does not retry another HTTP 4xx
   response.
3. The notifier tries each selected channel and then fails when one or more channels fail. The
   exit code is non-zero after the last failure.
4. The deploy keeps the site. A workflow rerun can send a duplicate message.

### The check

The notifier check runs the script with the `python3` interpreter of `pkgs` in the no-network
sandbox of the seed check. The check injects a stub transport and a stub sleep. It proves:

- the payload of each channel;
- the same message text for each selected channel;
- the fan-out order and the failure result when one channel fails;
- the retry count and the delay for a retryable response;
- no retry for a non-retryable HTTP 4xx response;
- no secret value in the standard output and the standard error;
- no network access during the check;
- the secret-name validation and the Telegram chat-ID rule of the option group;
- the `uses = [ ]` fixture holds no notifier file.

## Errors

- A `uses` entry outside the three channels fails evaluation.
- A duplicate `uses` entry fails evaluation.
- A secret value outside the name pattern fails evaluation.
- A selected `telegram` channel without a chat ID fails evaluation.
- An unknown key of the group fails evaluation.
- A notifier file when `uses` is `[ ]` fails the check.
- A missing notifier file when `uses` is not `[ ]` fails the check.
- A message above 3,500 characters fails the delivery.
- A channel outside the selected list that receives a message fails the check.
- A secret value in the standard output or the standard error fails the check.
- A check run that needs network access fails the check.
- A direct `source` under `assets/delivery/` for the notifier file fails the file-plan check.
- A retry of a non-retryable HTTP 4xx response fails the check.
- A failed channel without a non-zero exit code fails the check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-26 | The notifier file lives at the provider-neutral path `scripts/notify.py`. One script serves both CI providers. The path does not sit below `.github/`, so the path stays correct for the azure-pipelines provider. The factory emits one notifier file and no duplicated notification tree. | services/factory |
| C-27 | One message serves each channel. The CI renderer maps each CI value onto one notifier input and adds the notification step only after a successful deploy step. Each secret name maps one to one onto a CI secret of the same name. | services/factory |
| C-35 | The notifier file takes the HTTP transport and the sleep function as function parameters. The check injects a stub transport and a stub sleep and runs the script with the `python3` interpreter of `pkgs` in the no-network sandbox of the seed check. The check proves that no secret value reaches the standard output or the standard error. | services/factory |
