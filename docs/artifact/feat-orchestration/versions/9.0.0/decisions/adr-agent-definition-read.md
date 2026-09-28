# adr-agent-definition-read: The read of the two agent definition forms

**Relates to:** spec-agent-read, spec-coverage-scan
**Context:** context-factory

## Context

The requirement req-coverage-audit asks the scan to read the shipped agents and the agents that the
user defines. OpenCode version 2 defines an agent under `agents.<id>` of a configuration document,
or in the markdown file `.opencode/agents/<id>.md`. The markdown frontmatter accepts the same
fields as a configuration entry, including the `permissions` array. The two forms can define the
same id. The scan needs one deterministic rule for the precedence, or the write scope of one id is
ambiguous. The configuration documents merge in a fixed order, and a permission array appends
across the documents. The review FCA-02 asks for the parse and the precedence. The change must
select the read.

## Options

1. The file form is the last definition of one id. Pro: the markdown file is the specific
   definition of the agent; one rule is easy to read; the read is deterministic. Con: a
   configuration entry of the same id loses to the file.
2. The configuration form is the last definition of one id. Pro: the rendered permission document
   is the merged result. Con: a user file agent loses to a stale configuration entry.
3. No precedence rule, and two entries for one id. Pro: no rule to remember. Con: the write scope
   of one id is ambiguous, so the scan is not deterministic and the coverage result is not reliable.

## Decision

Option 1. The scan reads the two definition forms. The file form
`.opencode/agents/<id>.md` is the last definition of one id. The permission rules append, so the
rules of the file form follow the rules of the configuration form of the same id.

The effective rule list of one id is the concatenation, in order, of the global `permissions` rules
of each document, the `agents.<id>.permissions` rules of each document, and the `permissions` rules
of the file form. The scan keeps the `edit` rules and applies the last matching rule.

The scan reads each agent id that a document or a file holds. The scan holds no hand list of agent
ids, so the read includes every agent that the user defines. The scan reads the declared rules
only; the opencode base default policy is a harness policy and covers no path.

The parse lives in the shell script `assets/scripts/coverage-audit.sh`. The script uses the portable
declared tool set: POSIX `sh`, `awk`, `sed`, `grep`, and `sort`. The script uses no `jq` and no
`yq`. The script strips the JSONC comments and a trailing comma outside a string literal before the
parse. The seed check holds no parse of an agent document.

The global document `~/.config/opencode/opencode.json(c)` is outside the project and version
control. The phase-4 clean run declares it absent or pins its content, so the result is
reproducible.

The factory agent files hold no `permissions` frontmatter; the factory renders the permission set
into `.opencode/opencode.jsonc`. An absent `permissions` field gives the empty list.

## Consequences

Easier: one precedence rule; the read includes every agent; the write scope of one id is
deterministic; the scan is the proof of the coverage; a project-local role removes its paths from
the report.

Harder: the scan holds a parser for JSON, JSONC, and the YAML frontmatter; a reader must know the
precedence rule; a configuration entry of an id that a file also defines does not decide the write
scope.
