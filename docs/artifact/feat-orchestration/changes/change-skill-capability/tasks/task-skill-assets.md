# task-skill-assets: Add the complete skill assets

**Plan:** [Implementation plan](README.md)
**Covers:** req-capability-ship, req-chat-no-slop, spec-capability-ship, spec-capability-kinds
**Context:** context-factory
**Component:** services/factory
**Aggregate:** agg-repository-blueprint
**Owner:** factory-expert
**Depends on:** -

## Goal

Add the eight missing files to the factory skill asset tree without changing their source bytes.

## Files to change

- `services/factory/assets/skills/asd-ste-100/references/dictionary.md`
- `services/factory/assets/skills/asd-ste-100/references/examples.md`
- `services/factory/assets/skills/asd-ste-100/references/review-checklist.md`
- `services/factory/assets/skills/asd-ste-100/references/writing-rules.md`
- `services/factory/assets/skills/asd-ste-100-chat-no-slop/SKILL.md`
- `services/factory/assets/skills/asd-ste-100-chat-no-slop/references/eval.md`
- `services/factory/assets/skills/asd-ste-100-chat-no-slop/references/examples-chat.md`
- `services/factory/assets/skills/asd-ste-100-chat-no-slop/references/slop-patterns.md`

## Steps

1. Copy each file from its matching relative path under the tracked `.agents/skills/` tree. Preserve the bytes and the folder structure.
2. Leave the existing `asd-ste-100/SKILL.md` and `expert-role` asset folder in place.
3. Do not edit the tracked source tree. Its adoption belongs after phase 5.

## Check

- Compare each of the eight asset files byte-for-byte with its `.agents/skills/` counterpart.
- Confirm `asd-ste-100-chat-no-slop/SKILL.md` and all seven new reference files exist. The folder walker and the seed fixture prove their delivery in task-complete-skill-emit and task-skill-fixtures.
