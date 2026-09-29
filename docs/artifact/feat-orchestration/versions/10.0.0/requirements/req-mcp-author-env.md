# req-mcp-author-env: Author environment variable of a canonical MCP entry

**Master:** [Requirements](README.md)
**Context:** context-factory
**Priority:** Must

## Statement

The project must give each canonical MCP entry a declared author path for an environment
variable. A downstream author must pass a credential, for example `CONTEXT7_API_KEY`, to a
canonical MCP server without an edit of the managed `command` or the managed `args`.

The fields `command` and `args` of a canonical entry must stay factory-owned and immutable. Only
the field `env` must gain the author path.

The merge of the `env` of a canonical entry must work per key. The canonical key must stay
factory-owned. An author value at a canonical key must keep the canonical value and must write one
`managed-wins:` trace line. An author key that the canonical entry does not set must join the
rendered `environment`.

The value form must be permissive. An author environment value must be any string. A secret value
must stay out of the repository: the author must use the OpenCode `{env:NAME}` substitution, and
the value must come from the OpenCode process environment.

The change must stay inside the existing one MCP source `agents.mcp` and the existing local
dialect. The change must add no new field of the MCP source, no remote MCP dialect, no `url`, and
no `headers`.

## Acceptance criteria

- Given a canonical MCP entry, when the author declares an `env` value at a key that the canonical
  entry does not set, then the rendered `environment` of the entry holds that key and its value.
- Given a canonical MCP entry, when the author declares an `env` value at a canonical key, then the
  entry keeps the canonical value and writes one `managed-wins:` trace line for the ignored value.
- Given a canonical MCP entry, when the author declares a value for `command` or for `args`, then
  the entry keeps the canonical value and the author value changes no rendered field.
- Given an author environment value that is a plain string, when the factory renders the entry,
  then the value renders unchanged.
- Given an author environment value with the `{env:NAME}` form, when the factory renders the entry,
  then the entry holds the substitution text unchanged.
- Given the entry `context7`, when the author declares
  `env = { CONTEXT7_API_KEY = "{env:CONTEXT7_API_KEY}"; }`, then the rendered entry holds the
  `environment` key `CONTEXT7_API_KEY`, the canonical `command`, and the canonical `args`.
- Given the one MCP source, when the author reads it, then the source holds no new field, and the
  rendered entry holds no `type` value `remote`, no `url`, and no `headers`.

## Notes

- The rule of this requirement follows the approved option A of the phase-1 option interview: the
  author reuses the declared `env` of the canonical entry, the canonical key wins, and an author
  key that the canonical entry does not set joins the rendered `environment`. The value form is
  permissive.
- The exact merge implementation, the exact trace path, and the exact render shape belong to
  phase 2. The candidate trace path is `mcp.<name>.env.<KEY>` from the layer that sets the value.
- The immediate case is the canonical entry `context7` of the package `@upstash/context7-mcp`. The
  package documents the argument `--api-key <key>` and the environment variable
  `CONTEXT7_API_KEY`. Source: `https://www.npmjs.com/package/@upstash/context7-mcp`. The canonical
  `env` of the entry is `{ }`, so the immediate case has no key collision.
- The OpenCode version 2 reference documents the key `environment` as string variables that the
  server process adds to the inherited process environment. The `{env:NAME}` form is the
  documented environment substitution. A shell expression such as `$NAME` is not expanded in a
  JSON string. Source: `https://opencode.ai/v2/docs/mcp-servers`, read 2026-09-28.
- The factory repository holds no secret value. The value of the variable comes from the OpenCode
  process environment. The repository states the variable name only.

### Superseded statements

Phase 2 must update the statements below. The statements belong to the version 7.0.0
specifications.

- `spec-mcp-dialect`, resolved constraint C-08: "The MCP entries merge per leaf field. The
  canonical `command`, `args`, and `env` keep the canonical value with one log line for each
  ignored value; `enabled` is user-wins." The statement is superseded in part. The canonical
  `env` keeps the canonical value of each canonical key with one log line. An author key that the
  canonical entry does not set joins the rendered `environment`. The rule of `command`, `args`,
  and `enabled` stays.
- `spec-mcp-dialect`, the Description: "One MCP source holds each Model Context Protocol (MCP)
  entry once. ... The factory owns their `command`, `args`, and `env` values." The sentence about
  the owned `env` is superseded in part. The factory owns the canonical keys of `env`, and the
  author may add a key.
- `spec-mcp-dialect`, the dialect mapping table: the row `| env | environment |` stays true. The
  rendered `environment` is the join of the canonical keys and the author keys.
- `req-knowledge-access`: the statement and the acceptance must name the declared author path for
  `CONTEXT7_API_KEY` with the `{env:NAME}` substitution. The phase-1 change keeps the requirement
  text. Phase 2 adds the criterion to the specification `spec-mcp-knowledge`.
- `req-mcp-dialect`: the dialect statement stays true. Phase 2 confirms that the author path uses
  the existing `environment` key and adds no dialect key.
- `spec-mcp-knowledge`, resolved constraint RC02-C6: the statement stays true, because the change
  adds no field of the MCP source. Phase 2 restates it to name the author `env` path, so a reader
  knows that the author path is not a new field.
- The out-of-scope items of `req-knowledge-access`: the remote MCP dialect (`type = "remote"`,
  `url`, `headers`) stays out of scope.

### Out of scope

- The exact merge implementation, the exact trace path, and the exact render shape.
- A change to the canonical `command` and `args` and to the `managed-wins` rule of the two fields.
- A new field of the MCP source.
- A second MCP source, a new facade group, and a new facade layer.
- The remote MCP dialect (`type = "remote"`, `url`, `headers`).
- The mechanism that sets the value in the OpenCode process environment.
- The repository declaration of the value in `factory.nix` and the regeneration of
  `.opencode/opencode.jsonc`; they are a post-phase-5 follow-up.
- The specifications, the decisions, the tasks, and the code.
