# task-role-render: One role source for each selected harness

**Plan:** [Implementation plan](README.md)
**Covers:** req-role-pipeline, spec-role-render
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Depends on:** [task-mcp-toml](task-mcp-toml.md), [task-lib-moves](task-lib-moves.md).
**can-parallel:** No. The task touches the component `services/factory`, the context
`context-factory`, and the aggregate `agg-repository-blueprint`. Tasks that share a component,
a context, or an aggregate run in sequence.

## Goal

Render one role source per role for each selected harness, with the ordered chapter appends
and the codex agents index. Render the roles of the factory repository from its own
declaration.

## Steps

1. Create `lib/roles.nix`. The library renders each enabled role declaration for each selected
   harness.
2. Type the declaration fields exactly `enable` (bool, default `true`), `name` (string,
   default the attribute name), `description` (required string), `source` (required path), and
   `harness` with exactly `opencode`, `claude`, and `codex`. An unknown field fails evaluation
   (C-11).
3. Check each declaration with explicit pure checks: a non-empty `description`; a `source`
   that `builtins.pathExists` matches; a `name` that matches `[A-Za-z0-9._-]+`, is not `.`,
   and is not `..` (C-11).
4. Render the role files:
   - `.claude/agents/<name>.md`: YAML frontmatter with `name`, `description`, and the
     `harness.claude` fields, then the body.
   - `.opencode/agents/<name>.md`: YAML frontmatter with `description` and the
     `harness.opencode` fields, then the body.
   - `.codex/agents/<name>.toml`: the TOML keys `name`, `description`, and
     `developer_instructions` (the body), then the `harness.codex` keys.
   Use `lib/yaml.nix` for the two markdown frontmatters and `lib/toml.nix` for the codex
   files. Each file has the copy mode `managed`.
5. Render one file for each enabled role of each selected harness. An unselected harness
   receives no role file. Hold no task permission in a role frontmatter.
6. Return the codex `agents` fragment as data: one `agents.<name>` entry with `description`
   and `config_file = "agents/<name>.toml"` for each rendered role. The file plan composes
   `.codex/config.toml` in one pass from the merged codex keys, the `agents` fragment, and the
   `mcp_servers` group. No rendered file is read back (C-09).
7. Add the chapter hook: append each active chapter after the body with one blank line between
   the parts. The order is the DDD chapter first and the UX chapter second. The chapter list
   is empty at this version. The chapter content and the options that activate a chapter
   belong to feat-design (F3). The check passes one fixture chapter list to the render.
8. Write the body of each built-in role source at
   `services/factory/assets/roles/<name>/ROLE.md`: `artifact-master`, `requirement-expert`,
   `solution-expert`, and `artifact-release-expert`. Each body starts with the title line and
   holds no frontmatter and no header.
9. Write the required statements of spec-protocol in the bodies:
   - The coordinator body states the phase sequence, the routing table, the handoff fields,
     the commit boundary, and the mid-build gate.
   - The coordinator body states that the user selects it as the primary agent in opencode
     and that it is the only role that starts an expert.
   - Each expert body states the no-subagent rule and the return-to-the-coordinator rule.
10. Write the required statements of spec-release-gate in the bodies:
    - The release body states the copy-only steps and the no-status rule.
    - The solution body states the readiness items and the confirmation.
    - The coordinator body states that the phase 5 route starts after the readiness
      confirmation.
11. Declare the roles of the factory repository in `devenv.nix` under
    `factory.project.agents.roles` with the four built-in sources and the harness extras.
    Remove the legacy option path `factory.domain.agent`. Render the roles of the factory
    repository for each selected harness (spec-role-render).
12. Update the `expert-role` skill text and its references to the new declaration path, the
    source convention `utils/agent/role/<name>/ROLE.md`, and the new rendered-file check.
    Remove each reference to the legacy option path.
13. Add the check of the role render and of the rendered statements.

## Checks

- Render one fixture role with the three selected harnesses. Each selected harness holds one
  file with the mode `managed`.
- Render the fixture with one selected harness. Only that harness holds a file.
- Render a role with `enable = false`. No file appears.
- Evaluate a role without `description`, with an empty `description`, without `source`, with a
  missing source path, with the name `a/b`, and with the name `..`. Each fails evaluation.
- Evaluate an unknown declaration field. Evaluation fails.
- Render a fixture with the chapter list `["ddd" "ux"]`. The body is the source, then the DDD
  chapter, then the UX chapter, with one blank line between the parts.
- Render the four built-in roles. Each rendered body holds the statements of spec-protocol and
  spec-release-gate. A missing statement fails the check.
- Render one role for the codex harness. `.codex/config.toml` holds one `agents.<name>` entry
  with the description and `config_file`. The composition reads no rendered file back (C-09).
- Build the plan of one fixture declaration with one selected harness, one enabled MCP entry,
  and one enabled role. The plan holds the starter files, the rendered role file, and the
  rendered MCP file in one transaction.
- Render the roles of the factory repository. The legacy option path `factory.domain.agent`
  is absent.

## Done criteria

- The declaration checks are explicit and pure (C-11).
- Each selected harness receives its rendered role files; an unselected harness receives none.
- The codex agents index composes in one pass (C-09).
- The four built-in role bodies hold the protocol statements and the release-gate statements.
- The factory repository renders its own roles, and the legacy option path is absent.
