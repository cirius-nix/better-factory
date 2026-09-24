# spec-presets: The preset key and the three bundles

**Master:** [Specifications](README.md)
**Covers:** req-presets
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Description

One optional key selects a named preset. The presets are `minimal`, `docs-only`, and `full`.
Each preset is one bundle. A bundle is a key-selection map: each entry names one key path below
`factory.project` and one selected value. The bundles live in the library `lib/presets.nix`.

A bundle changes the declared default of each key that it selects. An author value other than
the declared default wins over the bundle. The bundle adds no key outside the key set of F1
through F4.

The harness key set is opencode only (spec-harness-merge of
`feat-orchestration/change-opencode-v2`). The group `agents` holds the typed keys `uses`, `mcp`,
`roles`, and `opencode`. The `full` bundle holds no `agents.claude` key and no `agents.codex`
key.

The blueprint records the selected preset, the effective settings, and the emitted file set.

## Contract

### The preset key

```nix
factory.project.preset = "docs-only";  # "minimal" | "docs-only" | "full"; optional
```

1. `preset` is one of `minimal`, `docs-only`, and `full`. An absent value gives no bundle.
   Another value fails evaluation. The message names the three preset names.
2. The key is optional. A repository without the key behaves as a repository without a bundle.
3. The key joins the modeled-key list and the root option definitions of the facade root in the
   same change (C-30). `evalFactory` accepts the key and returns the selected bundle with the
   other settings.

### The bundle

1. A bundle is an attribute set. Each key is a key path below `factory.project`. Each value is
   the selected value of that key.
2. A bundle replaces the declared default of each key that it selects.
3. The factory applies the selected value of a key when the current value of the key equals the
   declared default of the key. A key with a value other than the declared default keeps that
   value.
4. The factory compares the value with the declared default. The factory cannot tell a
   hand-written value that equals the declared default from the default itself. Such a value
   takes the selected value.
5. A bundle holds no key of the F1 root (`arch`, `advanced`, `secrets`) and no `preset` key.
   The F1 root keys and the preset key stay author-owned.
6. A bundle cannot declare a role source. The key `agents.roles` selects the group with the
   empty value. A role declaration stays author-owned.

### The declared defaults

1. The declared default of each F2, F3, and F4 key comes from the option table of the module
   that declares the key. The factory holds one option table for each key group:

   | Key group | Option table | Module |
   | --- | --- | --- |
   | The F2 `agents` keys | `agentsOptions` | `modules/orchestration.nix` |
   | The F3 `design` keys and the key `ux` | `designOptions`, `uxOptions` | `modules/design.nix` |
   | The F4 keys `ci`, `site`, `publish`, and `notify` | `deliveryOptions` | `modules/delivery.nix` |

2. The library `lib/presets.nix` reads these tables for the comparison with the declared
   default. The factory holds no second copy of a declared default. The comparison code holds
   no inline default value.
3. A bundle holds no F1 root key and no `preset` key, so the comparison reads no F1 default and
   no `preset` default.

### The bundles

The bundle `minimal` holds no key. The repository holds the F1 root keys and no selected
feature key. The effective settings of the F2, F3, and F4 keys are their declared defaults. The
emitted file set holds the base files and the overlay files only. The minimal bundle is the
smallest key set that still builds.

The bundle `docs-only` holds each key of this table:

| Key path | Selected value |
| --- | --- |
| `ci.use` | `"github-actions"` |
| `ci.folder` | `"azure-pipelines"` |
| `ci.watchPaths` | `[ ]` |
| `ci.build.beforeNodeSetup` | `[ ]` |
| `ci.build.beforeSiteBuild` | `[ ]` |
| `ci.build.afterSiteBuild` | `[ ]` |
| `site.enable` | `true` |
| `site.title` | `"Documentation"` |
| `site.url` | `""` |
| `site.baseUrl` | `"/"` |
| `site.staticDirectories` | `[ ]` |
| `publish.target` | `"github-pages"` |
| `publish.deployTool` | `"official-task"` |
| `notify.uses` | `[ ]` |
| `notify.google-chat.secret` | `"NOTIFY_GOOGLE_CHAT_WEBHOOK"` |
| `notify.slack.secret` | `"NOTIFY_SLACK_WEBHOOK"` |
| `notify.telegram.secret` | `"NOTIFY_TELEGRAM_TOKEN"` |
| `notify.telegram.chatId` | `""` |

The docs-only bundle holds every F4 key except `preset`. It selects the delivery keys for the
docs site and no extra content. The emitted file set holds the site project, the CI file, and
the publish flow. It holds no role file, no design file, and no UX chapter.

The bundle `full` holds each key of the docs-only bundle and each key of this table:

| Key path | Selected value |
| --- | --- |
| `agents.uses` | `[ "opencode" ]` |
| `agents.mcp` | `{ }` |
| `agents.roles` | `{ }` |
| `agents.opencode` | `{ }` |
| `design.use` | `"ddd"` |
| `design.tool` | `"unset"` |
| `ux` | `true` |

The full bundle holds every F2, F3, and F4 key except `preset`. The group `agents` holds the
modeled keys `uses`, `mcp`, `roles`, and `opencode` only. The bundle holds no `agents.claude`
key and no `agents.codex` key. It is the full key set of F1 through F4. The emitted file set
holds the opencode harness files, the designer-expert role, the design files, the UX chapter,
the site project, the CI file, and the publish flow.

### The dead-key check

1. The factory resolves each key path of each bundle against the modeled key set of F1 through
   F4.
2. A bundle key path outside the modeled key set fails evaluation. The message names the preset
   and the key path.
3. The full bundle holds every modeled key of F2, F3, and F4 except `preset`. The docs-only
   bundle holds every modeled key of F4 except `preset`. The minimal bundle holds no key.
4. A bundle key path that the modeled-key list does not hold is a dead key. A dead key fails
   evaluation. The check keeps the bundle maps and the modeled key set in agreement.
5. The modeled key set of the opencode-only version holds no `agents.claude` key and no
   `agents.codex` key. A bundle key path `agents.claude` or `agents.codex` is a dead key and
   fails evaluation.

### The application order

1. The factory applies the selected bundle before it computes the file plan.
2. The effective settings (after the bundle) supply each gate and each emitted file set: the
   site files, the CI file, the publish flow, the notifier file, the design files, the role
   files, and the MCP files.
3. A gate reads the effective value of its key. The site gate, the CI gate, and the notifier
   gate follow the effective settings.
4. The CI file follows the site gate (spec-ci-options, C-39). The notifier file and the
   notification step follow the notifier gate (spec-notify-fanout, C-39). A failed deploy step
   stops the notification step.

### The starter and the fixture

The starter declaration of each arch holds the key `preset` with the value `"minimal"` and the
four F4 groups with their declared off values:

```nix
{
  factory.project = {
    arch = "single";              # or "multiple" in the multiple overlay
    advanced = { };
    secrets = [ "GITHUB_TOKEN" ];
    agents = { uses = [ ]; mcp = { }; roles = { }; };
    design = { use = "unset"; tool = "unset"; };
    ux = false;
    ci = {
      use = "unset";
      folder = "azure-pipelines";
      watchPaths = [ ];
      build = { beforeNodeSetup = [ ]; beforeSiteBuild = [ ]; afterSiteBuild = [ ]; };
    };
    site = {
      enable = false;
      title = "Documentation";
      url = "";
      baseUrl = "/";
      staticDirectories = [ ];
    };
    publish = { target = "github-pages"; deployTool = "official-task"; };
    notify = {
      uses = [ ];
      google-chat.secret = "NOTIFY_GOOGLE_CHAT_WEBHOOK";
      slack.secret = "NOTIFY_SLACK_WEBHOOK";
      telegram.secret = "NOTIFY_TELEGRAM_TOKEN";
      telegram.chatId = "";
    };
    preset = "minimal";
  };
}
```

1. The starter declaration of each arch, the modeled-key list, the root option definitions,
   `evalFactory`, and the seed-check fixture advance in the same change as the F4 groups. The
   seed check stays green for both archs.
2. The seed-check fixture evaluates the starter declaration of each arch. It proves that the
   modeled-key list holds the keys `ci`, `site`, `publish`, `notify`, and `preset`, and that
   the starter selects the minimal bundle.
3. The starter holds each F4 gate with its declared off value: `ci.use = "unset"`,
   `site.enable = false`, and `notify.uses = [ ]`. The other F4 keys keep their declared
   defaults.

### The check

The preset check renders one fixture for each preset and one fixture without a bundle. It
proves:

- the minimal fixture holds the base files and the overlay files only;
- the docs-only fixture holds the site project, the CI file, and the publish flow, and it holds
  no role file, no design file, and no UX chapter;
- the full fixture holds the opencode harness files, the designer-expert role, the design files,
  the UX chapter, the site project, the CI file, and the publish flow;
- the full fixture holds no `.claude/` file, no `.mcp.json` file, and no `.codex/` file;
- the fixture without a bundle holds the declared defaults;
- an author value other than the declared default wins over a bundle value;
- a bundle value replaces a key with the declared default;
- the comparison reads the declared-default table of each module, and the factory holds no
  second copy of a declared default;
- the plan of each preset fixture holds the files of the effective settings, not the files of
  the declared values;
- each bundle key path resolves against the modeled key set of F1 through F4;
- the full bundle holds every F2, F3, and F4 key except `preset`;
- the full bundle holds the key `agents.uses = [ "opencode" ]` and holds no `agents.claude` key
  and no `agents.codex` key;
- the docs-only bundle holds every F4 key except `preset`;
- the minimal bundle holds no key;
- the starter declaration of each arch holds the key `preset = "minimal"` and the F4 off
  values, and the seed check is green for both archs.

## Errors

- A `preset` value outside the three preset names fails evaluation.
- A bundle key path outside the modeled key set of F1 through F4 fails evaluation.
- A bundle key path `agents.claude` or `agents.codex` fails evaluation, because the modeled key
  set of the opencode-only version holds no such key.
- A bundle key of the F1 root or a `preset` key in a bundle fails the check.
- A bundle key that the modeled-key list does not hold fails the check.
- An author value other than the declared default that a bundle replaces fails the check.
- A key with the declared default that keeps the declared default fails the check.
- A full bundle without a modeled key of F2, F3, or F4 fails the check.
- A docs-only bundle without a modeled key of F4 fails the check.
- A minimal bundle with a key fails the check.
- A declared default written a second time outside its option table fails the check.
- A plan computed from a declared value instead of the effective value fails the check.
- A starter declaration without the key `preset` fails the seed check.
- A starter declaration without the F4 off values fails the seed check.
- A modeled-key list without the keys `ci`, `site`, `publish`, `notify`, or `preset` fails the
  check.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-29 | A bundle replaces the declared default of each key that it selects. The factory applies a bundle value to a key when the current value equals the declared default. An author value other than the declared default wins over the bundle. A bundle holds no F1 root key and no `preset` key. | services/factory |
| C-30 | The keys `ci`, `site`, `publish`, `notify`, and `preset` join the modeled-key list, the root option definitions, and `evalFactory` in one change. The two starter declarations (`assets/base/factory.nix` and `assets/overlays/multiple/factory.nix`) and the seed-check fixture advance in the same change. The starter holds the key `preset = "minimal"`. | services/factory |
| C-31 | The declared default of each F2, F3, and F4 key comes from the option table of the module that declares the key: `agentsOptions` (`modules/orchestration.nix`), `designOptions` and `uxOptions` (`modules/design.nix`), and `deliveryOptions` (`modules/delivery.nix`). The library `lib/presets.nix` reads these tables for the comparison. The factory holds no second copy of a declared default and no scattered inline default. | services/factory |
| C-38 | The starter declarations of both archs, the modeled-key list, the root option definitions, `evalFactory`, and the seed-check fixture advance in the same change. The starter holds the key `preset = "minimal"` and the F4 off values `ci.use = "unset"`, `site.enable = false`, and `notify.uses = [ ]`. The seed check is green for both archs. | services/factory |
| C-39 | The factory applies the selected bundle before it computes the file plan. The effective settings feed each gate and each emitted file set. The CI file follows the site gate (spec-ci-options), and the notifier file and the notification step follow the notifier gate (spec-notify-fanout). A failed deploy step stops the notification step. | services/factory |
| C-F10 | The modeled key set of the opencode-only version holds the group `agents` with the keys `uses`, `mcp`, `roles`, and `opencode` only. The `full` bundle drops the keys `agents.claude` and `agents.codex` and holds the key `agents.uses = [ "opencode" ]`. The dead-key check fails a bundle with a removed key. The bundle edit co-lands in the parent change-opencode-v2 phase 4 commit, atomic with the leaf removal (adr-bundle-landing). | feat-delivery, change-opencode-v2 |
| FC-01 | The reduced `full` bundle (25 keys) passes the `checkBundles` subset under the version 1 leaves, but the `preset-dead-key` coverage equality reads 25 != 27 until the parent change removes the claude and codex leaves. The bundle edit and the leaf removal land in one commit. A bundle-only landing on the version 1 code as green does not occur. | feat-delivery, change-opencode-v2 |
| FC-02 | `checkBundles` and `applyPreset` keep their semantics. The code edit holds no edge beyond the bundle maps. The check resolves each bundle key against the leaf table and throws `preset-dead-key` with the preset and the key path. The factory holds no second copy of a declared default. | services/factory |
| FC-03 | The harness and designer claude and codex fixtures stay parent-owned (task-seed-advance). The preset full-fixture absence items (`.claude/`, `.mcp.json`, `.codex/`) are part of this specification and hold under the version 1 code when the effective `uses` holds `opencode` only. The code that carries the bundle edit and the preset absence items lands in the parent change-opencode-v2 phase 4 commit. This change holds no fixture code. | change-opencode-v2, feat-delivery |

## Notes

- The parent change `feat-orchestration/change-opencode-v2` fixes the harness key set to
  opencode only. It names the feat-delivery statements of version 1.0.0 as superseded: the
  `full` bundle row `agents.uses = [ "opencode" "claude" "codex" ]` and the rows
  `agents.claude = { }` and `agents.codex = { }` (spec-harness-merge, C-F10). This
  specification replaces the statements.
- The `full` bundle edit and the parent leaf removal land in one commit of the parent
  change-opencode-v2 phase 4 (adr-bundle-landing). A bundle-only landing on the version 1 code
  is not green: the `preset-dead-key` coverage equality reads 25 != 27 until the leaf removal.
  The seed check stays green in the co-landed commit.
- The key `agents.opencode` stays in the full bundle, because the key is a modeled key of the
  group `agents`.
