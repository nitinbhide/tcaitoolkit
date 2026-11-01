# Agent-audit skill clarifications

These clarifications record the agreed behavior for the agent-audit skill.

## Audit scope and applicability

- Audit only the repository-root `AGENTS.md` and files it explicitly references at the first level.
- Do not search or scan unreferenced files to discover project characteristics or determine whether conditional criteria apply.
- Use only the allowed files as evidence for applicability. If that evidence does not establish that a conditional check applies, mark it `not-applicable`.
- Evaluate referenced files, but do not follow references inside them.
- A referenced manifest can provide stack or dependency evidence only when `AGENTS.md` explicitly references it.

## Paths and document entry points

- Validate directory paths in the project structure for relative syntax, containment within the repository root, and existence. Do not evaluate directory contents or recurse into them.
- Report unresolved or invalid file references as warnings and mark `Path Rules` `not-fulfilled` when a path violates a path rule. Continue the audit; these warnings are not hard failures.
- Require the exact `DESIGN.md` filename. Recommend:
  - Referencing `DESIGN.md` from `AGENTS.md` if it exists but is not referenced.
  - Standardizing or renaming existing design material to `DESIGN.md` if it uses another filename.
  - Defining `DESIGN.md` if no design document exists.
- For other document sets, a direct link to the canonical entry document is acceptable when there is only one document or no index. Recommend an index for larger collections.

## Criteria and report

- Count all physical lines in the repository-root `AGENTS.md`, including blank lines and headings. A count of 250 or more is `not-fulfilled`.
- Treat explicit persona or identity assignments to the AI agent as role violations. Ordinary task responsibilities and quality expectations are not role assignments.
- Cite evidence with repository-relative paths and line numbers when available; use a path without line numbers when exact locations cannot be determined.
- Rank up to five recommended fixes by blockers and impact, prioritizing shared/root causes over isolated cleanup.
- If repository-root `AGENTS.md` is missing, report the target and preflight hard failure, then stop without the remaining report sections.

## No-edit policy

- Agent-audit is recommendation-only and never edits `AGENTS.md` or other files.
