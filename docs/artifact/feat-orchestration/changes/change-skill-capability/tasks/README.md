# Implementation plan: orchestration

**Change:** [skill-capability](../../../changes/change-skill-capability/README.md)

## Order of work

| Step | Task | Depends on |
| --- | --- | --- |
| 1 | [task-skill-assets](task-skill-assets.md) | - |
| 2 | [task-declared-skill-builder](task-declared-skill-builder.md) | task-skill-assets |
| 3 | [task-complete-skill-emit](task-complete-skill-emit.md) | task-skill-assets, task-declared-skill-builder |
| 4 | [task-shipped-skill-roles](task-shipped-skill-roles.md) | task-complete-skill-emit |
| 5 | [task-declared-skill-flow](task-declared-skill-flow.md) | task-declared-skill-builder, task-complete-skill-emit, task-shipped-skill-roles |
| 6 | [task-role-builder-reference](task-role-builder-reference.md) | task-declared-skill-flow |
| 7 | [task-skill-fixtures](task-skill-fixtures.md) | task-shipped-skill-roles, task-declared-skill-flow, task-role-builder-reference |

All tasks touch `context-factory` and its aggregate `agg-repository-blueprint`. Run them in table order; do not parallelize changes to this context. The phase 4 executor is `factory-expert`. The builder sets the declaration shape before the file and permission renders read it. The assets exist before the folder walker reads them. Add the shipped role entries before the independent fixture expects six new grants. Complete the flow and the reference before the final seed proof.

## Coverage

| Requirement | Specifications | Tasks |
| --- | --- | --- |
| req-capability-ship | spec-capability-ship, spec-capability-kinds, spec-role-builder-reference, spec-harness-merge | task-skill-assets, task-complete-skill-emit, task-skill-fixtures |
| req-chat-no-slop | spec-capability-kinds, spec-role-render, spec-role-permissions, spec-capability-ship, spec-harness-merge | task-skill-assets, task-shipped-skill-roles, task-skill-fixtures |
| req-skill-declaration | spec-declared-skill, spec-role-render, spec-role-permissions, spec-local-role-ownership, spec-harness-merge, spec-role-builder-reference, spec-capability-ship | task-declared-skill-builder, task-complete-skill-emit, task-declared-skill-flow, task-role-builder-reference, task-skill-fixtures |
| req-local-role-ownership | spec-local-role-ownership, spec-declared-skill, spec-role-permissions, spec-role-render, spec-harness-merge | task-declared-skill-builder, task-declared-skill-flow, task-skill-fixtures |

Every changed specification has a task. The six decisions constrain the named tasks: `adr-skill-folder-walk` and `adr-declared-skill-root` constrain task-complete-skill-emit; `adr-declared-skill-shape` constrains task-declared-skill-builder; `adr-declared-skill-order`, `adr-declared-skill-collision`, and `adr-repo-local-skill-presence` constrain task-declared-skill-flow and task-skill-fixtures.

## Constraints

- `lib/harness.nix` must not import `modules/file-plan.nix`. Inject the existing `filePlan.listTree` into `capabilitySources` at the entrypoint and seed-check call sites. Remove the hardcoded `skillReferences` branch.
- Keep the `ddd-review` design-module emitter and existing non-skill capability render. Do not change the `copy-step.sh` per-file copy rule or delete stale files.
- Keep shipped ownership, the `skill * ask` rule, the existing table rule order, the managed permission key, and the five-line seed-check result.
- Include the repo-local `utils/agent/role/factory-expert/ROLE.md` in step 4. The optional `factoryExpertBody` input of the self check proves its body/table agreement; an ordinary factory example alone cannot prove that body.
- The eight new asset files are byte-equal copies of their tracked `.agents/skills/` counterparts. The phase 4 implementation does not hand-edit those tracked source files.
- The example flakes `services/factory/examples/{single,multiple,consumer,self,coverage-fixture}/flake.lock` lock the factory by path. **This change needs lock updates** when factory-source changes alter the locked path. Update all five locks against the new factory source in step 7 and include any changed locks in the phase 4 code commit. A stale lock must not stand in for a passing check.
- Run `nix flake check ./services/factory/examples/single` and `nix flake check ./services/factory/examples/multiple`. Run the self-host `factory-parity` check with the `factory-expert` body input. Also run the applicable `consumer`, `self`, and `coverage-fixture` checks after lock updates. Do not report an unchecked example as green.
- Do not edit `AGENTS.md`, a version folder, or another bounded context.

## Adoption after the change

The factory repository is its own consumer. The tracked `.opencode/agents/*.md` and `.agents/skills/**` paths are adopted rendered output. **Do not regenerate or commit these paths in the phase 4 implementation commit.** After phase 5, regenerate and adopt them in a separate commit with the message `chore(opencode): adopt the skill-capability change`, as the change README requires. The phase 4 body edit at `utils/agent/role/factory-expert/ROLE.md` is source work, not adoption. No adoption task belongs to this change's phase 4 commit.

## Definition of done

- Each task's check passes and all four changed requirements meet their acceptance criteria.
- Every active shipped skill emits the complete folder with `managed` files and matching asset bytes. The eight new paths appear in the generated tree; `expert-role` references still arrive.
- The six roles hold both STE skills and allow both; `artifact-master` holds neither. The six shipped role bodies, including the repo-local `factory-expert` source, agree with the table.
- A declared skill at either home has one effective allow rule. A missing repo-local file, an unsupported kind, and a conflicting source fail evaluation. No declared skill adds a write rule.
- The seed-check result stays exactly five lines. The single and multiple flake checks and `factory-parity` pass with current locks.
