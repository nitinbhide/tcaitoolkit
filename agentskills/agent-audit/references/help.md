# Agent-audit help

## Purpose

Agent-audit evaluates the repository-root `AGENTS.md` and any existing files it explicitly references at the first level. It checks whether the guidance is clear, useful to coding agents, and efficient to load. It reports findings and recommended fixes; it does not modify files unless you separately ask for changes.

The repository-root `AGENTS.md` is required. If it is missing, the audit stops and reports that hard failure. **This skill does not generate or modify `AGENTS.md` file.**

## Common checks

- **Paths:** References are relative to the `AGENTS.md` directory, resolve to files, stay inside the repository root, and are not absolute paths or URLs.
- **Project overview:** The opening gives a concise, project-specific description.
- **Project structure and documentation entry points:** The structure section uses valid paths and points to relevant indexes or entry documents for specifications, designs, architecture decisions, and test plans when they exist.
- **Working rules:** Basic project-specific rules are documented in `AGENTS.md` or in a first-level referenced file.
- **Size:** `AGENTS.md` is fewer than 250 lines.
- **Design document:** The audit checks whether it refers to the exact `DESIGN.md` file; if not, it recommends defining one.
- **Technology stack and dependencies:** Referenced documentation contains concrete technology versions and package/library dependencies, rather than empty sections, TODOs, or placeholders. A textual dependency list is acceptable; a Mermaid package diagram is recommended when no dependency diagram exists.
- **Relational database schema:** If the project uses a relational database, the guidance points to documentation of its schema, including tables, indexes, and views.
- **Agent role:** Root `AGENTS.md` does not assign a role to the coding agent (for example, “You are a Senior Software Engineer”).

Only explicit repository-relative file paths directly written in the root `AGENTS.md` count as first-level references. Existing referenced files are evaluated; directories are skipped. Unresolved or invalid paths are reported as warnings, not as audit failures. The audit does not infer paths, search for similarly named files, or follow references inside referenced files.

## Report

The report has these sections, in order: **Target**, **Preflight**, **Criteria results**, **Reference path warnings**, and **Summary**. Each criterion is marked `fulfilled`, `not-fulfilled`, or `not-applicable`, with a rationale and evidence paths. The summary includes counts and up to five recommended fixes.

## Typical prompts

> Use agent-audit to audit the repository-root `AGENTS.md` and report the findings.

> Explain what agent-audit checks and show me examples of prompts I can use.

> Audit the root `AGENTS.md`. Include the evidence paths and prioritize the recommended fixes.

> The repository-root `AGENTS.md` is missing. Run agent-audit and report the preflight result.
