---
name: agent-audit
description: Evaluates the repository-root AGENTS.md and its first-level referenced files against predefined quality criteria. If the repository-root AGENTS.md is missing, the audit must stop and report a hard failure. The objective is to improve the effectiveness of AGENTS.md and reduce overall token consumption. Use when user asks to review AGENTS.md or the project's agent setup, or the overall agent configuration
metadata: 
    author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
    version : "1.0"
license: Apache 2.0
allowed-tools : bash 
user-invocable: true
---
# Agent Audit Skill

This skill evaluates the repository-root `AGENTS.md` to improve agent effectiveness and reduce unnecessary turns and token consumption. It reports recommendations only and never edits files.

For a user-oriented explanation of the audit's purpose, common checks, report, and example prompts, see [`references/help.md`](references/help.md).
- If the user asks for help with this skill, present the contents of [`references/help.md`](references/help.md) first, without starting an audit.

## How to Audit the AGENTS.md file
- Audit only the repository-root `AGENTS.md` file.
- If the repository root does not contain an `AGENTS.md` file, report the target and preflight hard failure, then stop without the remaining report sections.
- Use the evaluation criteria below and check each item.
- Treat a "first-level referenced file" as an explicit repository-relative file path written directly in the repository-root `AGENTS.md`.
- Evaluate only the root `AGENTS.md` and files it explicitly references at the first level. Do not search or scan unreferenced files to discover project characteristics or determine whether conditional criteria apply. Use only these allowed files as evidence; if they do not establish that a conditional check applies, mark it `not-applicable`.
- Evaluate existing first-level referenced files, but do not follow references inside them. A referenced manifest can provide stack or dependency evidence only when `AGENTS.md` explicitly references it.
- Validate directory paths in the project structure for relative syntax, containment within the repository root, and existence. Do not evaluate directory contents or recurse into them.
- Record unresolved or invalid referenced paths as warnings and mark `Path Rules` `not-fulfilled` when a path violates a path rule. Continue the audit; these warnings are not hard failures.
- Do not infer file paths, search the repository for matching filenames, or follow vague references such as "see design docs" unless a concrete file path is given.
- Output the report using the fixed format defined below.

## Output format
Use the following sections in this exact order.

1. Target
  - Repository root path.
  - Audited file path (must be repository-root `AGENTS.md`).

2. Preflight
  - Repository-root `AGENTS.md` present: yes/no.
  - If no, report the hard failure and stop; do not include the remaining sections.

3. Criteria results
  - Report one line per criterion.
  - Allowed status values: fulfilled, not-fulfilled, not-applicable.
  - Include a short rationale for each status.
  - Include repository-relative evidence paths and line numbers when available; use a path without line numbers if exact locations cannot be determined.

4. Reference path warnings
  - List unresolved or invalid first-level referenced file paths as warnings.
  - Explicitly state that these warnings do not cause audit failure.

5. Summary
  - Report counts for fulfilled, not-fulfilled, not-applicable, and warnings.
  - Provide up to five recommended fixes, ranked by blockers and impact; prioritize shared/root causes over isolated cleanup.

## Evaluation criteria

- **Path Rules** : All the file paths in the AGENTS.md file should follow these rules
  - [ ] All paths in AGENTS.md are resolved relative to the directory containing AGENTS.md.
  - [ ] Do not use OS‑absolute paths (C:/…, /usr/…).
  - [ ] Do not use URL paths (file://…).
  - [ ] Reject references that escape the project root (../../../../). Folder of the AGENTS.md file is the project root.
- [ ] It should give a one or two paragraph description about the project at the start.
  - The description must be project-specific and explain what the project does.
  - Template placeholders, boilerplate text, or empty descriptions do not satisfy this criterion.
- [ ] There must 'project structure' or 'repository structure' defined in the AGENTS.md. 
  - This project structure should refer paths as per the "Path Rules".
  - It should refer to index files or canonical entry documents for specifications, designs, architecture, and test plans.
  - If allowed evidence establishes that a document set exists, `AGENTS.md` should point to its entry point. A canonical entry document is acceptable for a single document or when no index exists; recommend an index for larger collections.
  - A plain directory listing without these key document references does not satisfy this criterion.
- [ ] It should define basic working rules for the project. The working rules can be in file refered in the AGENTS.md
- [ ] The repository-root `AGENTS.md` must contain fewer than 250 physical lines, excluding blank lines and headings.
- [ ] `AGENTS.md` must refer to the exact `DESIGN.md` filename. If it does not, recommend referencing it if it exists, standardizing existing design material to that filename, or defining it if no design document exists.
- [ ] If allowed evidence establishes that the project uses a relational database, check that `AGENTS.md` refers to a file documenting its schema (tables, indexes, views, etc.).
- [ ] It should document the technology stack (programming language, build system, unit test framework, webserver, thirdparty packages etc).
  - Usually 'technology stack' should documents desired versions of various tools, packages, languages 
  - The technology stack can be documented in a dedicated stack document or in an architecture/design document such as `ARCHITECTURE.md`.
  - A referenced manifest may also provide evidence for details it declares. Mark this criterion fulfilled only if `AGENTS.md` refers to a file containing concrete technology stack details.
  - Empty sections, blank values, TODO markers, or template placeholders do not satisfy this criterion.
- [ ] It should document the list of packages/libraries/modules and their expected dependencies. 
  - A textual list of dependencies is enough for now.
  - Mark this criterion fulfilled if `AGENTS.md` refers to a document or manifest containing concrete package dependency details, even if it is only a textual list.
  - If there is no explicit dependency diagram and only a textual list, recommend using a mermaid package diagram, preferably a C4 component diagram.
  - Empty sections, blank values, TODO markers, or template placeholders do not satisfy this criterion.
- [ ] It should not define a 'role' for AI Agent. For example, "You are Senior Software Engineer". 
  - Flag explicit persona or identity assignments to the AI agent. Ordinary task responsibilities and quality expectations are not role assignments.

Agent-audit is recommendation-only and never edits `AGENTS.md` or other files.

