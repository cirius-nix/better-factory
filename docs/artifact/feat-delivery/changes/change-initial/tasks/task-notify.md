# task-notify: The notifier library, the script, and the deploy fan-out

**Plan:** [Implementation plan](README.md)
**Covers:** req-notifier, spec-notify-fanout
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-delivery-facade](task-delivery-facade.md),
[task-site-lib](task-site-lib.md), [task-ci-render](task-ci-render.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Ship the one notifier script with the injectable transport, the notifier library, and the
notification step of the CI file.

## Steps

1. Write `assets/delivery/notify.py` with the one message contract of spec-notify-fanout. The
   message holds the repository, the deployment URL, the source ref and the first seven
   characters of the commit, and the run URL. The message stays at or below 3,500 characters.
   The payload is UTF-8 JSON. The channels `google-chat` and `slack` receive `{"text": "..."}`.
   The channel `telegram` receives `{"chat_id": "...", "text": "..."}` at the Bot API method
   `sendMessage`.
2. Read the environment inputs of the table of spec-notify-fanout and no other environment
   value. The script reads the JSON list `NOTIFY_USES` and the inputs of each selected channel.
3. Send the message to each selected channel in the list order. Treat each HTTP 2xx response as
   success. Retry a network error, HTTP 429, and an HTTP 5xx response. Make at most three
   attempts with one-second and two-second delays. Do not retry another HTTP 4xx response. Try
   each selected channel and then fail when one or more channels fail. The exit code is
   non-zero after the last failure.
4. Print no webhook URL, no bot token, and no response body. Report the channel name and the
   response status only. Send no message for an event other than the deploy event. Hold no
   second message.
5. Take the HTTP transport and the sleep function as function parameters (C-35). The defaults
   are the real transport and the real sleep. The script holds no other transport call and no
   other sleep call. The path is `scripts/notify.py` on both providers
   (C-26, adr-notifier-file).
6. Add the secret-name rule and the Telegram chat-ID rule to the group validation of
   `modules/delivery.nix` (spec-notify-fanout). A `secret` value is a name matching
   `^[A-Za-z_][A-Z0-9_]*$`. A value of another shape, for example a webhook URL, fails
   evaluation. A selected `telegram` channel needs a non-empty `chatId`. Add one assertion for
   each rule with a message that names the item.
7. Create `lib/notify.nix`. The library holds the function `notifyFiles` with the argument
   `settings` and the function `notifyStep` with the provider and the settings. `notifyFiles`
   returns the `extraFiles` entries and the rendered-source list of the run. The gate is the
   value `uses` not equal to `[ ]` (C-39). The `source` of the entry is a `builtins.toFile`
   store path of the script content. The copy mode is `managed`. The same store path joins the
   rendered-source list (C-33). When `uses` is `[ ]`, the plan holds no notifier file.
8. Write the notification step in `lib/notify.nix` for both providers. The step runs
   `python3 scripts/notify.py`. Map each CI value onto one notifier input with the table of
   spec-notify-fanout (C-27). Write the input of a channel only when the channel is selected.
   On GitHub Actions a secret reads `${{ secrets.<name> }}`. On Azure Pipelines a secret reads
   `$(<name>)`.
9. Add the notification step to the two renderers of `lib/ci.nix` after the build steps. The
   publish step of task-publish comes before the notification step. The notification step runs
   in the job of the deploy step. A failed deploy step stops the notification step. On GitHub
   Actions the deploy job holds the permission `contents: read`, and the notification step
   follows a checkout step with `persist-credentials: false`. On Azure Pipelines the
   notification step is a script step after the deploy step. Add no notification step when
   `uses` is `[ ]`.
10. Add the notifier files to the function `deliveryFiles` of `modules/delivery.nix`.
11. Write the stub test `assets/delivery/tests/test_notify.py`. The test injects a stub
    transport and a stub sleep and imports the script. The test proves each item of the check
    list of spec-notify-fanout. A failed item exits with a non-zero code and names the item.
12. Advance `modules/seed-check.nix`: run the test with the `python3` interpreter of `pkgs` in
    the derivation after the seed-check script. Pass the script path and the test path to the
    interpreter. The result file stays exactly five lines. Add the fixture assertion that the
    `uses = [ ]` fixture holds no notifier file, and the fixture assertion that the notifier
    file joins the plan with a rendered source and the copy mode `managed`.

## Checks

- Run the stub test. The payload of each channel is correct, and each selected channel
  receives the same message text.
- Run the stub test with one failing channel. The other channels receive the message, and the
  script exits non-zero.
- Run the stub test with a retryable response. The transport sees three attempts and the sleep
  sees the delays one second and two seconds.
- Run the stub test with a non-retryable HTTP 4xx response. The transport sees one attempt.
- Run the stub test with a secret value in the environment. The standard output and the
  standard error hold no secret value.
- Run the stub test in the no-network sandbox. The test needs no network access.
- Evaluate a `notify` fixture with a secret value outside the name pattern and a fixture with
  the selected channel `telegram` and no `chatId`. Each evaluation fails.
- Build the plan of the `uses = [ ]` fixture. It holds no notifier file.
- Build the plan of the `uses = [ "slack" ]` fixture. It holds `scripts/notify.py` with the
  copy mode `managed` and a rendered source.
- Build the plan of a notifier fixture with an `extraFiles` entry whose source is a direct path
  under `assets/delivery/`. The file-plan check rejects it.
- Read the notification step of each provider render. The step runs `python3 scripts/notify.py`
  and holds the input of each selected channel only.
- Read the render of a fixture with `uses = [ ]`. It holds no notification step.
- Run the seed check of both archs. Both are green with exactly five result lines.

## Done criteria

- The group validation holds the secret-name rule and the Telegram chat-ID rule.
- The script sends the one message to each selected channel and holds no second message.
- The script takes the transport and the sleep function as parameters, and the test injects
  both (C-35).
- The notifier file joins the plan at `scripts/notify.py` as a rendered managed file
  (C-26, C-33).
- The notification step follows the deploy step and holds the environment mapping of
  spec-notify-fanout (C-27).
- The stub test passes in the no-network sandbox.
