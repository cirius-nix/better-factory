# adr-cleanup-script-shape: The shape of the cleanup script

**Relates to:** spec-cleanup-bundle, spec-artifact-cleanup
**Context:** context-factory

## Context

The artifact cleanup computes a plan for the version folders and the change folders of one
feature. The requirement req-cleanup-bundle fixes one bundle: the command, the instruction skill,
and the script. The change must select the shape of the script. The change can keep one script or
two. The change can name the two folder kinds with two subcommands or with one flag. The shape
fixes the shell allow rule of the release role and the command body.

The precedent is the coverage-audit bundle. That bundle holds one script
`.opencode/scripts/coverage-audit.sh` and one shell allow rule
`sh .opencode/scripts/coverage-audit.sh *`.

## Options

1. One script with the two subcommands `versions` and `changes`. A run names one subcommand. A run
   with no subcommand covers both kinds. Pro: the one-bundle/one-script precedent holds. Pro: one
   shell allow rule covers each run. Pro: the command body names the subcommand, so the run kind
   is explicit. Con: the script reads a subcommand argument.
2. One script with the flag `--kind versions|changes|all`. Pro: one script. Pro: one shell allow
   rule. Con: the flag form differs from the coverage-audit precedent. Con: the flag spans the
   same value set as two subcommands.
3. Two scripts, one for the version folders and one for the change folders. Pro: each script
   holds one kind only. Con: two scripts break the one-bundle/one-script precedent. Con: the
   release role needs two shell allow rules. Con: the factory holds two cleanup scripts.

## Decision

Option 1 is selected. The cleanup ships one script, `artifact-cleanup.sh`, with the two
subcommands `versions` and `changes`. A run with no subcommand covers both kinds. The shell allow
rule is one: `sh .opencode/scripts/artifact-cleanup.sh *`. The command body names the subcommand.

The reason: the two subcommands match the one-bundle/one-script precedent of the coverage audit
and keep one shell allow rule. The value set is the same as option 2, and the subcommand form is
the common shell shape of the house. Option 3 doubles the script and the grant for no gain.

The option `--kind versions|changes|all` (option 2) and the two separate scripts (option 3) are
rejected. The selected option is the final shape of the cleanup bundle.

## Consequences

Easier: one script and one grant; the command body names the run kind; the plan of the two kinds
comes from one algorithm.

Harder: the script reads a subcommand argument and rejects an unknown value. The command body
holds one line per subcommand.
