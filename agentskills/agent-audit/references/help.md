# Agent-audit help

## Purpose

Agent-audit evaluates the repository-root `AGENTS.md` and existing files it explicitly references at the first level. It checks whether the guidance is clear, useful to coding agents, and efficient to load. It reports findings and recommendations only; it never edits files.

The repository-root `AGENTS.md` is required. If it is missing, the audit reports the hard failure under Target and Preflight, then stops without the remaining report sections.

## Common checks

- **Paths:** File references are relative to the `AGENTS.md` directory, stay inside the repository root, and are not absolute paths or URLs. Project-structure directory paths are checked for valid syntax, containment, and existence; their contents are not evaluated.
- **Project overview:** The opening gives a concise, project-specific description.
- **Project structure and documentation entry points:** The structure section uses valid paths and points to relevant indexes or canonical entry documents for specifications, designs, architecture decisions, and test plans when allowed evidence establishes they exist. A single document or a collection without an index may use a canonical entry document; recommend an index for larger collections.
- **Working rules:** Basic project-specific rules are documented in `AGENTS.md` or in a first-level referenced file.
- **Size:** `AGENTS.md` has fewer than 250 physical lines, including blank lines and headings.
- **Design document:** `AGENTS.md` refers to the exact `DESIGN.md` filename. Recommend referencing it, standardizing existing design material to that name, or defining it when absent.
- **Technology stack and dependencies:** Referenced documentation or manifests contain concrete technology versions and package/library dependencies, rather than empty sections, TODOs, or placeholders. Manifests count only when `AGENTS.md` references them. A textual dependency list is acceptable; a Mermaid package diagram is recommended when no dependency diagram exists.
- **Relational database schema:** If allowed evidence establishes that the project uses a relational database, the guidance points to documentation of its schema, including tables, indexes, and views.
- **Agent role:** Root `AGENTS.md` does not assign an explicit persona or identity to the agent; ordinary task responsibilities and quality expectations are not role assignments.

Only explicit repository-relative file paths directly written in the root `AGENTS.md` count as first-level references. Existing referenced files are evaluated; directory contents and nested references are not. Do not search unreferenced files to determine whether conditional criteria apply; use only the allowed files as evidence, and mark a conditional criterion `not-applicable` if that evidence does not establish that it applies. Unresolved or invalid paths are warnings and make Path Rules `not-fulfilled` when they violate a path rule, but do not stop the audit.

## Report

The report has these sections, in order: **Target**, **Preflight**, **Criteria results**, **Reference path warnings**, and **Summary**. Each criterion is marked `fulfilled`, `not-fulfilled`, or `not-applicable`, with a rationale and repository-relative evidence paths and line numbers when available. The summary includes counts and up to five recommended fixes ranked by blockers and impact.

## Typical prompts

> Use agent-audit to audit the repository-root `AGENTS.md` and report the findings.

> Explain what agent-audit checks and show me examples of prompts I can use.

> Audit the root `AGENTS.md`. Include the evidence paths and prioritize the recommended fixes.

> The repository-root `AGENTS.md` is missing. Run agent-audit and report the preflight result.
