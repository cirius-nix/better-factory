# spec-harness-merge: Three layers and declared skill delivery

**Master:** [Specifications](README.md)
**Covers:** req-harness-facade, req-capability-options, req-capability-ship, req-capability-bundle, req-local-role-ownership, req-mcp-author-env, req-chat-no-slop, req-skill-declaration
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

**Amends:** `versions/11.0.0/specifications/spec-harness-merge.md`. Its MCP and environment merge, native version 2 shape, managed keys, trace format, and file-plan restrictions remain in force.

## Contract

### Interface

1. The existing project and local role layers accept `roles.<name>.capabilities`. The local list replaces the project list at this user-wins leaf. Each layer uses `roles.checkRoleWith`.
2. `mergeAgents` builds the rendered-name declaration map and passes it to `permissionRulesFor` and `managedOpencodeSettings`. The entrypoint also gives the effective declarations to `capabilitySources`, with `filePlan.listTree` and the repository root as required by spec-capability-ship and spec-declared-skill.
3. `agents.<role>.permissions` remains one managed leaf. For a shipped role name, the table wins over a declaration of `capabilities`; the trace list has `managed-wins: roles.<name>.capabilities from <layer>` for each layer that declares it.
4. The seed check proves the full shipped skill file set, its bytes, the six updated permission arrays, the collision cases, and the declared skill at each home. Each proof is an evaluation-time assertion; the result file stays five lines.

### Events

`Harness merged` records the effective role and key set. `Capability shipped` records the emitted files. `Permission set rendered` records the ordered managed value.

### Data model

The expected shipped path set adds eight paths to `capabilityExpectedRels`:

```text
.agents/skills/asd-ste-100-chat-no-slop/SKILL.md
.agents/skills/asd-ste-100-chat-no-slop/references/eval.md
.agents/skills/asd-ste-100-chat-no-slop/references/examples-chat.md
.agents/skills/asd-ste-100-chat-no-slop/references/slop-patterns.md
.agents/skills/asd-ste-100/references/dictionary.md
.agents/skills/asd-ste-100/references/examples.md
.agents/skills/asd-ste-100/references/review-checklist.md
.agents/skills/asd-ste-100/references/writing-rules.md
```

The current expected paths, including the two `expert-role` references, stay. The fixture checks equality of the generated file set with the asset folder file set, not only membership of these eight paths. It checks `SKILL.md` and supporting-file bytes and checks that repeated roles emit each path once. A declared shipped fixture uses an asset under the factory root. A repo-local fixture uses an existing skill in a fixture repository root; a second fixture with a missing file fails evaluation. A kind other than `skill` fails with its kind in the error.

### Invariant

1. The managed permission key and the generated skill files derive from one effective role declaration.
2. A repo-local skill gives no file-plan entry. A shipped skill uses only a factory skill asset and a rendered source.
3. Each ignored shipped-role declaration writes one named trace line. An unshipped declared role does not write a `managed-wins` line for its permission path unless the author also tries to override that managed key.
4. No MCP key, other config key, copy mode, or generated file outside skill folders changes under this contract.
5. The seed-check result remains exactly five lines for each arch.

## Description

The entrypoint already holds `repoRoot`. The new presence check uses that value; it does not use the scratch output as the source of repo-local skills. The existing file-plan acceptance of rendered sources remains the sole path for shipped skill entries.

## Errors

- A missing repo-local file or shipped asset fails evaluation before a misleading grant reaches the rendered document.
- A shipped-role declaration that changes the managed permission key fails its fixture; its field is ignored with the named trace.
- A shipped file source not in `renderedSources` fails `checkSourceAllowed`.
- A missing new path, an extra unexpected path, or changed file bytes fails the seed check.

## Resolved constraints

| Constraint | Decision | Owner |
| --- | --- | --- |
| SC-01 | Pass the existing `filePlan.listTree` and the asset files to the capability render. | services/factory |
| SC-03 | Pass `repoRoot` through the entrypoint for the repo-local presence check. | services/factory |
| SC-04 | Update the fixed expected paths, compare full folders, and preserve the five-line result. | services/factory |
