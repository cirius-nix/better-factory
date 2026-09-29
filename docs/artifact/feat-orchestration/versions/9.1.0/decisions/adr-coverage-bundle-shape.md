# adr-coverage-bundle-shape: The shape of the coverage scan bundle

**Relates to:** spec-coverage-bundle, spec-proposed-role, spec-coverage-scan
**Context:** context-factory

## Context

The requirement req-coverage-audit asks for a scan that ships with its instruction skill and its
command. A skill holds no permission list. The permission action `skill` with the skill ID decides
the load. The command is a markdown file at `.opencode/commands/<name>.md`, and its frontmatter
field `agent` selects the agent that runs the command. The capability model holds seven option
kinds: skill, command, MCP server, reference, plugin, model, and worktree. A scan script is not one
of the seven kinds. The reviews FCA-05 and FCA-06 ask for the script asset root, the command
render, the `agent` value, and the grants of the scan agent. The change must select the bundle
shape.

## Options

1. The bundle holds the script, the command, and the instruction skill. The script joins the plan
   as a managed extra file under a new asset root `services/factory/assets/scripts/`. The command
   and the instruction skill are shipped capability entries. The agent `artifact-master` runs the
   scan. Pro: the script is one asset with one emitted path; the command and the skill use the
   capability render; the coordinator is shipped to every generated project and presents the holes
   and the proposal to the user; the seven kinds stay closed. Con: the factory holds one asset root
   outside the capability kinds; the coordinator holds one new shell rule.
2. A new shipped role for the scan. Pro: one owner for the scan. Con: a new role needs a source
   asset, a permission table entry, a body, and a capability set; a second coordinator role
   conflicts with the one-coordinator rule.
3. The script inside the instruction skill folder. Pro: the script sits beside the skill that
   states how to call it. Con: the capability render emits the `SKILL.md` file only; an extra file
   inside the skill folder needs a change to the skill render.
4. The `factory-expert` runs the scan. Pro: the role owns the factory source. Con: the role is
   repo-local, so a generated project receives no scan agent.

## Decision

Option 1. The bundle holds three assets:

| Asset | Source | Emitted path | Copy mode |
| --- | --- | --- | --- |
| scan script | `services/factory/assets/scripts/coverage-audit.sh` | `.opencode/scripts/coverage-audit.sh` | `managed` |
| command | `services/factory/assets/commands/coverage-audit.md` | `.opencode/commands/coverage-audit.md` | `managed` |
| instruction skill | `services/factory/assets/skills/coverage-audit/SKILL.md` | `.agents/skills/coverage-audit/SKILL.md` | `managed` |

The command asset holds the frontmatter `agent: artifact-master`. The instruction skill holds the
sections `## When to use`, `## When not to use`, and `## How to call`.

The agent `artifact-master` runs the scan. It holds the local read tools, the `skill` allow rule
`coverage-audit`, and the shell rule `sh .opencode/scripts/coverage-audit.sh *`. The role holds no
`edit` allow rule, so the scan agent holds no write scope. Adding a capability to a shipped role is
allowed. The command needs no separate grant.

The directory `assets/scripts/` is a new raw asset root, and the file plan rejects a raw path under
it. The script joins the plan as an `extraFiles` entry whose source is a `builtins.toFile` render
in the `renderedSources` list. No module imports an asset path; the module reads the script asset
with `builtins.readFile`.

The script is not one of the seven option kinds. The seven kinds stay the closed vocabulary. Only
the command and the instruction skill use the capability render. The capability render does not
exist at version 4.0.0: the phase-4 order is the phase 4 of `change-capability-layer` first, then
the phase 4 of this change.

## Consequences

Easier: the script is one asset with one emitted path; the command and the instruction skill use the
capability render and the bundle rule of `change-capability-layer`; the coordinator presents the
holes and the proposal to the user and starts the `expert-role` skill; the seven kinds stay closed;
the script writes no content, so the coordinator holds no `edit` rule.

Harder: the factory holds the asset root `services/factory/assets/scripts/` outside the capability
kinds, and the file plan rejects a raw path under it, so the module makes a `builtins.toFile`
render; the coordinator holds one new shell rule and one new skill rule, and the permission fixture
advances; the capability render arrives only with the phase 4 of `change-capability-layer`, so the
phase 4 of this change depends on it; the factory repository must regenerate its own bundle, like
the regeneration of `.opencode/opencode.jsonc`.
