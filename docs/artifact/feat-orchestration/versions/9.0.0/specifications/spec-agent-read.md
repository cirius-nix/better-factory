# spec-agent-read: The read of the agent set

**Master:** [Specifications](README.md)
**Covers:** req-coverage-audit
**Context:** context-factory
**Aggregate:** agg-repository-blueprint

## Contract

### Interface

1. The scan takes the project root as its input. The scan reads the agent set of the project under
   scan.
2. The scan reads the configuration documents of the project in the merge order of opencode
   version 2.
3. The merge order is the global document, then the direct `opencode.json(c)` documents from the
   farthest ancestor directory to the closest, then the `.opencode/opencode.json(c)` documents in
   the same order.
4. A `.opencode` document overrides a direct document at the same precedence step. A document of a
   closer directory overrides a document of a farther directory.
5. The scan reads the `agents` group of each document. The group merges per leaf. A later scalar
   replaces an earlier scalar. A permission array appends.
6. The scan reads each file `.opencode/agents/<id>.md`. The frontmatter of the file holds the
   `permissions` array of the agent.
7. The file form is the last definition of one id. The `permissions` array of the file form appends
   after the rules of the configuration form of the same id.
8. The effective rule list of one id is a sequential concatenation, in order: the global
   `permissions` rules of each document, the `agents.<id>.permissions` rules of each document, and
   the `permissions` rules of the file form.
9. The scan reads each agent id that a document or a file holds. The scan holds no hand list of
   agent ids. The read thus includes every agent that the user defines.
10. The write scope of an agent is the set of surface entries where the last matching `edit` rule
    of the effective list has the effect `allow` (spec-coverage-scan).

### Events

1. The read emits no event of its own. The event `Coverage scanned` covers the read and the
   comparison (spec-coverage-scan).

### Data model

The ordered document list of a project under scan. A document that does not exist is skipped.

| Step | Document | Note |
| --- | --- | --- |
| 1 | `~/.config/opencode/opencode.json(c)` | The global document. The lowest precedence. The document is outside the project and version control. |
| 2 | `<directory>/opencode.json(c)` | The direct documents, from the farthest ancestor directory to the project root. |
| 3 | `<directory>/.opencode/opencode.json(c)` | The `.opencode` documents, in the same order. Each `.opencode` document overrides each direct document. |
| 4 | `.opencode/agents/<id>.md` | The file form. The last definition of one id. |

The two definition forms of one agent:

| Form | Source | Field |
| --- | --- | --- |
| configuration | `agents.<id>` of a configuration document | `permissions` is an ordered array of rules. |
| file | The frontmatter of `.opencode/agents/<id>.md` | `permissions` is an ordered array of rules. |

One permission rule:

```jsonc
{ "action": "edit", "resource": "docs/domain/*", "effect": "allow" }
```

| Field | Value |
| --- | --- |
| `action` | One action, for example `edit`, `read`, `shell`, or `skill`. |
| `resource` | The path, the command, the skill ID, or the agent ID. The wildcard `*` matches zero or more characters, including `/`. |
| `effect` | `allow`, `deny`, or `ask`. |

The effective rule list of one id, in order:

1. The global `permissions` rules of each document in merge order.
2. The `agents.<id>.permissions` rules of each document in merge order.
3. The `permissions` rules of the file form.

The scan keeps the `edit` rules of the list in order. The scan applies the last matching rule.

### The parse

1. The parse of the configuration documents and of the YAML frontmatter lives in the shell script
   `assets/scripts/coverage-audit.sh`. The seed check does not parse an agent document.
2. The script uses the portable declared tool set: POSIX `sh`, `awk`, `sed`, `grep`, and `sort`. The
   script uses no `jq` and no `yq`.
3. The script normalizes a JSONC document before the parse. The normalize step strips the `//` line
   comments and the `/* */` block comments that sit outside a string literal. A `//` or a `/*`
   inside a string literal stays.
4. The normalize step removes a trailing comma before a closing bracket when the comma sits outside
   a string literal.
5. The script reads the frontmatter of a markdown agent file as the block between the first `---`
   line and the next `---` line. The script reads the `permissions` list of the block.
6. The parse is deterministic. The same bytes give the same rule list.

### Invariant

1. The scan reads the documents in the merge order of the table above. The precedence is a
   sequential concatenation: the global document, the direct documents from the farthest directory
   to the closest, the `.opencode` documents in the same order, then the file form last.
2. The scan reads the shipped agents and the agents that the user defines. The scan reads no hand
   list of agent ids.
3. The scan reads both definition forms of one agent.
4. The file form is the last definition of one id. The rule list of a file agent appends after the
   rules of the configuration form of the same id.
5. The last matching rule wins. A broad rule comes before a specific rule.
6. The write scope of an agent is the union of the `edit` allow rules that win the last match.
7. The scan reads the declared rules of the documents and the files only. The base default policy
   of opencode is a harness policy, not a declared rule, and never covers a path.
8. The read is deterministic. The same documents and the same files give the same agent set.
9. A file agent with no `permissions` field holds an empty rule list. The agent covers no surface
   entry through the file form.
10. The factory agent files hold no `permissions` frontmatter. The factory renders the permission
    set into `.opencode/opencode.jsonc`. An absent `permissions` field gives the empty list.
11. A nested file path becomes part of the agent id. The id is the path below
    `.opencode/agents/` without the `.md` suffix.
12. The normalize step changes no byte inside a string literal.

### The phase-4 precondition

1. The global document `~/.config/opencode/opencode.json(c)` is outside the project and outside
   version control. Its content can change between two runs.
2. The phase-4 clean run declares the global document absent, or pins its content. Either way the
   phase-4 result is reproducible.
3. The precondition applies to the factory repository run and to the consumer run (C-FCA-07-09).

## Description

The write scope of an agent is the `edit` rules of its permission list (req-coverage-audit). The
scan must read the shipped agents and the agents that the user defines. The scan must read both
definition forms of opencode version 2: the `agents.<id>.permissions` rules of the configuration
documents, and the frontmatter `permissions` of `.opencode/agents/<id>.md`.

The change adds the read. The scan reads the configuration documents in the merge order of the
harness. The order is the global document, then the direct documents from the farthest directory to
the closest, then the `.opencode` documents in the same order, then the file form last. The scan
reads the `agents` group of each document. The scan then reads each markdown agent file under
`.opencode/agents/`.

The scan holds no list of known agent ids. The scan reads each id that a document or a file holds.
So the read includes every agent that the user defines. A project-local role appears in the agent
set.

The rule lists append. A later scalar replaces an earlier scalar, and a permission array appends
(opencode version 2, `https://opencode.ai/v2/docs/agents`). The file form is the last definition of
one id (adr-agent-definition-read). The scan applies the last matching rule to the action `edit`.
The precedence is a sequential concatenation (C-FCA-02-05).

The parse lives in the shell script. The script uses the portable tool set of POSIX `sh`, `awk`,
`sed`, `grep`, and `sort` (C-FCA-02-03). The seed check holds no parse of an agent document
(C-FCA-02-02). The script strips the JSONC comments outside a string literal before the parse.

The scan reads the declared rules only. The opencode base default policy is `*/* = allow`. That
policy is a harness policy, not a declared rule. The coverage rule needs a declared owner per path,
so the base policy never covers a path. A shipped role holds an explicit `edit` deny rule and
explicit ownership allow rules (spec-role-permissions of change-capability-layer).

The factory agent files hold no `permissions` frontmatter. The factory writes the permission set
into the managed key `agents.<role>.permissions` of `.opencode/opencode.jsonc`. The scan reads that
document. An absent `permissions` field gives the empty list (C-FCA-02-06).

The global document is outside the project and version control. The phase-4 clean run declares it
absent or pins its content (C-FCA-02-04, C-FCA-07-09).

## Errors

- A project under scan with an unreadable configuration document fails the scan with the exit
  code `2`.
- A configuration document with invalid JSON or JSONC fails the scan with the exit code `2`.
- A permission rule without the three fields fails the scan with the exit code `2`.
- A file agent without the `permissions` field gives an empty rule list. The read does not fail.
- An agent id that two forms define holds one rule list. The file form rules follow the
  configuration form rules.
- A scan that reads a hand list of agent ids fails the check.
- A scan that drops an agent that the user defines fails the check.
- A scan that reads only one definition form fails the check.
- A scan that reads the opencode base default policy as a declared rule fails the rule. The base
  policy covers no path.
- A parse that drops a `//` inside a string literal fails the check.
- A seed check that parses an agent document fails the rule.

## Resolved constraints

| Constraint | Final decision | Owner |
| --- | --- | --- |
| C-CA06 | The scan reads the configuration documents in the merge order: the global document, then the direct documents from the farthest ancestor directory to the closest, then the `.opencode` documents in the same order. Each `.opencode` document overrides each direct document. | services/factory |
| C-CA07 | The scan reads the two definition forms: the `agents.<id>.permissions` rules of the configuration documents and the frontmatter `permissions` of `.opencode/agents/<id>.md`. The file form is the last definition of one id. | services/factory |
| C-CA08 | The effective rule list of one id appends the global rules, the configuration agent rules, and the file rules in that order. The scan applies the last matching `edit` rule. | services/factory |
| C-CA09 | The scan reads each agent id that a document or a file holds. The scan holds no hand list. The read includes every agent that the user defines. | services/factory |
| C-CA10 | The scan reads the declared rules only. The opencode base default policy is a harness policy and covers no path. | services/factory |
| C-FCA-02-01 | The scan holds a deterministic parse of JSON, of JSONC, and of the YAML frontmatter. The parse normalizes a document to the rule array of each agent (adr-agent-definition-read). | services/factory |
| C-FCA-02-02 | The JSONC parse and the YAML frontmatter parse live in the shell script `assets/scripts/coverage-audit.sh`. The seed check holds no parse of an agent document. | services/factory |
| C-FCA-02-03 | The script uses the portable declared tool set: POSIX `sh`, `awk`, `sed`, `grep`, and `sort`. The script uses no `jq` and no `yq`. The normalize step strips the JSONC comments outside a string literal. | services/factory |
| C-FCA-02-04 | The global document is outside the project and version control. The phase-4 clean run declares it absent or pins its content, so the run is reproducible. | services/factory |
| C-FCA-02-05 | The precedence is a sequential concatenation: the global document, the direct documents from the farthest directory to the closest, the `.opencode` documents in the same order, then the file form last. | services/factory |
| C-FCA-02-06 | The factory agent files hold no `permissions` frontmatter. The factory renders the permission set into `.opencode/opencode.jsonc`. An absent field gives the empty list. | services/factory |
| C-FCA-07-09 | The global-config precondition applies to the factory repository run and to the consumer run. | services/factory |

## Notes

- The merge order is confirmed from the opencode version 2 documentation, read 2026-09-25: the
  global document, then the direct documents from the farthest directory to the closest, then the
  `.opencode` documents in the same order; every `.opencode` document overrides every direct
  document. Source: `https://opencode.ai/v2/docs/config`.
- The agent merge is confirmed: agent definitions merge in configuration order; a later scalar
  replaces an earlier scalar; a permission array appends; the global rules come before the agent
  rules. Source: `https://opencode.ai/v2/docs/agents`.
- The last-match rule and the wildcard are confirmed: the last matching rule wins; `*` matches zero
  or more characters, including `/`; no matching rule gives `ask`. Source:
  `https://opencode.ai/v2/docs/permissions`.
- The file form holds the same fields as a configuration entry. Source:
  `https://opencode.ai/v2/docs/agents`.
- The rendered permission file of a generated project is `.opencode/opencode.jsonc`. That file is
  one configuration document of the project. The scan reads it in the merge order with the other
  configuration documents. So the scan reads the rendered permission file of the project
  (req-coverage-audit) and the ancestors of the file.
- The exact parser code belongs to phase 4. The contract fixes the tool set, the normalize rule, the
  input, and the result.
- Open item for finalization: the exact precedence of the file form against the configuration form.
  The change selects the file form as the last definition of one id (adr-agent-definition-read).
