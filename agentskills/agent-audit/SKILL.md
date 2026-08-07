---
name: agent-audit
description: Evaluates the repository-root AGENTS.md and its first-level referenced files against predefined quality criteria. If the repository-root AGENTS.md is missing, the audit must stop and report a hard failure. The objective is to improve the effectiveness of AGENTS.md and reduce overall token consumption.
metadata: 
    author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
    version : "1.0"
license: Apache 2.0
allowed-tools : bash 
user-invocable: true
disable-model-invocation: true
---
# Agent Audit Skill

This skill evaulates AGENTS.md file at the root of the project for following criteria. Objective is to improve the quality of results fromLLMs, reduce the number of turns in agent loop and reduce the LLM token consumptions 

## How to Audit the AGENTS.md file
- Audit only the repository-root `AGENTS.md` file.
- If the repository root does not contain an `AGENTS.md` file, stop immediately and report that the audit could not run because the repository-root `AGENTS.md` is missing.
- Use the "evaluation criteria" given below and check each item the list
- Treat a "first-level referenced file" as an explicit repository-relative file path written directly in the repository-root `AGENTS.md`.
- Check only first-level referenced paths for evaluation. Evaluate files that resolve to existing files and skip directories/folders.
- If a first-level referenced path is unresolved or invalid, record it as a warning only. Do not fail the entire audit because of unresolved or invalid referenced paths.
- Do not infer file paths, search the repository for matching filenames, or follow vague references such as "see design docs" unless a concrete file path is given.
- Stop at first-level references from `AGENTS.md`. Do not recurse into files referenced by those files.
- Output the report using the fixed format defined below.

## Output format
Use the following sections in this exact order.

1. Target
  - Repository root path.
  - Audited file path (must be repository-root `AGENTS.md`).

2. Preflight
  - Repository-root `AGENTS.md` present: yes/no.
  - If no, report hard failure and stop.

3. Criteria results
  - Report one line per criterion.
  - Allowed status values: fulfilled, not-fulfilled, not-applicable.
  - Include a short rationale for each status.
  - Include the evidence file paths used for evaluation.

4. Reference path warnings
  - List unresolved or invalid first-level referenced file paths as warnings.
  - Explicitly state that these warnings do not cause audit failure.

5. Summary
  - Report counts for fulfilled, not-fulfilled, not-applicable, and warnings.
  - Provide top recommended fixes (maximum 5).

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
  - It should refere to 'index' files for documents like specifications, design and architecture, test plans etc
  - If the repository has specifications, design docs, ADRs, or test plans, AGENTS.md should point to the key index or entry documents for each of those document sets.
  - A plain directory listing without these key document references does not satisfy this criterion.
- [ ] It should define basic working rules for the project. The working rules can be in file refered in the AGENTS.md
- [ ] The AGENTS.md file size must be less 250 lines
- Check if the AGENTS.md refers the exact `DESIGN.md` file. If not, recommend the user to define a `DESIGN.md` file.
- [ ] If the project is using relational database, check that AGENTS.md refers to a file that documents the schema (tables, index, views etc) for relational database
- [ ] It should document the technology stack (programming language, build system, unit test framework, webserver, thirdparty packages etc).
  - Usually 'technology stack' should documents desired versions of various tools, packages, languages 
  - The technology stack can be documented in a dedicated stack document or in an architecture/design document such as `ARCHITECTURE.md`.
  - Mark this criterion as fulfilled only if AGENTS.md refers to that document and the referenced document contains concrete technology stack details.
  - Empty sections, blank values, TODO markers, or template placeholders do not satisfy this criterion.
- [ ] It should document the list of packages/libraries/modules and their expected dependencies. 
  - A textual list of dependencies is enough for now.
  - Mark this criterion as fulfilled if AGENTS.md refers to a document that contains concrete package dependency details, even if it is only a textual list.
  - If there is no explicit dependency diagram and only a textual list, recommend using a mermaid package diagram, preferably a C4 component diagram.
  - Empty sections, blank values, TODO markers, or template placeholders do not satisfy this criterion.
- [ ] It should not define a 'role' for AI Agent. For example, "You are Senior Software Engineer". 
  - AGENTS.md is used for all Coding Agents. It is starting point of 'context'. Hence AGENTS.md in project root should not define any 'role' for the AI Agent
