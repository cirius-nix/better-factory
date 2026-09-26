---
description: Audit the write coverage of the project surface.
agent: artifact-master
---

Audit the write coverage of the project surface.

1. Run `sh .opencode/scripts/coverage-audit.sh .` from the project root. The scan grant
   `sh .opencode/scripts/coverage-audit.sh *` covers the run.
2. Read the report. The report names each author path with no owner.
3. Present the report rows and the proposal to the user.
4. If the report holds a proposal, offer the `expert-role` skill to the user.
