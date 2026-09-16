---
name: repo-nav
description: Generate hierarchical Markdown index files (docmap.md) for a project repository folder structure using progressive disclosure. Also called as Repository Navigation
Index generation or docmap generation
version: 1.1.0
author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
tags:
  - indexing
  - repository-structure
  - codebase-analysis
---

# Project Repository Navigation Index Generation Skill

## Purpose
Analyze a software repository and generate a hierarchy of index files that enables AI coding agents to rapidly understand the repository structure, architecture, implementation details, business features, dependencies, and change impact.

This skill **only generates index files** and is **not to be used by coding agents for project decision making**.

Generate Markdown index files (`DOCMAP.md` at root, `docmap.md` in each folder) that summarize the contents of a local repository using progressive disclosure.

**Progressive Disclosure principle:**

1. A coding agent should be able to understand the repository at a high level by reading a small number of files.
2. The agent should be guided toward the most relevant folders and files.
3. Detailed information should only appear at deeper levels of the hierarchy.
4. Each index/docmap should help the agent decide what to read next.
5. Each index should help the agent decide what files are likely to require modification.
6. Each child index must provide greater detail than its parent.
7. Each parent index must summarize child content.

The primary consumers of the generated indexes are AI coding agents.

DO NOT deviate from this SKILL instructions during the execution of the repo-nav workflow.

## Reference Workflow and Tools
- Use PowerShell on Windows and Bash on Unix-like systems. 
- `rg` (ripgrep) is a hard prerequisite for this skill. Do not begin repository discovery, inventory creation, or docmap generation until `rg` is confirmed available.
- Use the reference files in this section as part of the workflow. 
  - First check whether `rg` is available, then follow [`references/ripgrepsearch.md`](references/ripgrepsearch.md) for repository discovery, retained inventories, content searches, and `rg`-based validation. 
  - When PowerShell is the selected shell, also follow [`references/powershell.md`](references/powershell.md) for path handling and shell-side validation operations. 
  - When Bash is the selected shell on a Unix-like system, also follow [`references/bash.md`](references/bash.md) for path handling and shell-side validation operations.

- The reference workflow is mandatory: 
  - Do not replace its authoritative inventory with an ad hoc recursive scan,  
  - Do not generate Python, Node.js, or other helper scripts for docmap discovery or validation. 
- If `rg` is not available, stop immediately and instruct the user: install ripgrep from https://github.com/burntsushi/ripgrep, restart the editor, and then retry the repo-nav skill.

- Use following scripts for file listing/inventory purpose. It Generates a Markdown table listing repository files and their sizes.
  - On Windows PowerShell: `./scripts/filelist.ps1 <folder-path> <output-file>`
  - On Bash: `./scripts/filelist.sh <folder-path> <output-file>`

## Scope and boundaries

This skill applies only to the explicitly invoked repo-nav workflow for generating or updating `DOCMAP.md` and `docmap.md` files. It is not a general project workflow, coding standard, or replacement for project-wide rules in `AGENTS.md`.


## Objectives

The generated indexes/docmap shall help agents:

- Understand repository architecture
- Understand major business capabilities
- Locate implementation areas
- Understand technology stacks
- Understand dependencies
- Locate related tests
- Locate related specifications
- Evaluate change impact
- Determine which files to read
- Determine which files to modify
- Avoid unnecessary repository exploration

---
## Inputs
- Root directory path of the local repository.

## Outputs
- Markdown index files written directly into each folder of the repository.
- The root index file must be generated using the template `rootdocmap_tmpl.md`.
- All folder-level index files must be generated using the template `folderdocmap_tmpl.md`.

## Behavior
The skill establishes one authoritative repository inventory, processes eligible folders from deepest to shallowest, and generates index files containing:
- YAML frontmatter metadata
- Folder-level summary (4–5 lines)
- File listings with short summaries
- Semantic tags
- TODO / FIXME / NOTE detections
- Child folder references
- Dependency graph generation is reserved for a future requirement and is not calculated or inferred in the current version
- Use the templates defined in this skills `references/` folder only

### Template Usage
- **Root Index File (`DOCMAP.md`)**  
  Must be generated using the template defined in `./references/rootdocmap_tmpl.md`

- **Folder Index Files (`docmap.md`)**  
  Must be generated using the template defined in `./references/folderdocmap_tmpl.md`

- **Indexing Plan File (`docmap_plan.md`)**  
  Must be generated and tracked using the template defined in `./references/docmap_plan_tmpl.md`

The skill must fill these templates with actual repository data.

### Root Index Requirements
The root `DOCMAP.md` **must include a section** explaining:
- how the index hierarchy is organized  
- how AI coding agents should use the index  

(The actual instruction text is defined inside the template `rootdocmap_tmpl.md`.)
This file is the primary entry point for all AI agents.

## File/Folder Inclusion/Exclusion Rules

### Use of filelist scripts (`filelist.ps1` and `filelist.sh`)

The repo-nav skill relies on the `filelist` scripts to generate an authoritative inventory of repository files. These scripts respect repository ignore rules and provide a consistent basis for subsequent indexing and analysis.

- Use `-Glob "<pattern>"` to restrict inventory output to matching file types, for example `-Glob "*.{ps1,md}"`. 
- By default, each script lists only files directly in the given folder. 
- Add `-Recurse` to scan recursively from the given folder.
- `-Recurse` and `-Glob` can be combined.

### Included File Types
- Source code (any language)
- Design documents
- Architecture documents and Architecture Decision Records (ADR)
- Specification documents
- Test plans and test cases
- Implementation plans
- SQL files
- Protobuf schema files
- Markdown (`.md`), text, Restructured Text (`.rst`)

### Excluded File Types
- Automatically Excluded by the filelist scripts (`filelist.ps1` and `filelist.sh`)
  - Binary files 
  - file names is starting with '.' ()
  - any file mentioned in ".gitignore" and other ignore files
  - AGENTS.md 
  - CLAUDE.md 
  - DOCMAP.md, docmap.md, *_MAP.md (e.g. FEATURE_MAP.md)
  - all hidden files
- Vendor libraries
- Generated code
- Configuration and settings files (java property files, e.g., `.properties`, `.xml`, `.yaml`, `.yml`, `.ini`, `.settings`)
- Use glob patterns with `-Glob "<pattern>"` to include/exclude additional file types while generating the inventory.

### Excluded Folders
- Default Excluded by the filelist scripts (`filelist.ps1` and `filelist.sh`)
  - folder name starting with '.' (".git", ".agents", ".github")
  - all hidden folders
  - any folder mentioned in ".gitignore" , ".hgignore" and other version control "ignore" files

### Ignore precedence:
- Apply hard excludes first (binary, vendor, generated, hidden files/folders)
- Then Apply "Excluded Folders"
- Then apply ".gitignore" , ".hgignore" , and other version control ignore files
- Then apply included file type filtering

## Search Strategy

Before any repository discovery, folder scan, file inventory, or docmap generation, verify that `rg` (ripgrep) is installed and available on `PATH`.

This is a required prerequisite for this skill. If `rg` is not available, stop immediately and do not proceed with repository analysis.

**Ripgrep availability check**

- On Windows PowerShell, run `Get-Command rg -ErrorAction SilentlyContinue`.
- On Unix-like shells, run `command -v rg`.

If the check succeeds, load and follow the detailed ripgrep instructions in `./references/ripgrepsearch.md`. Use `rg --files` as the first and authoritative repository-discovery command, followed by targeted content or filename searches from that reference.

If the check fails:

1. Tell the user that ripgrep is required for the repo-nav skill.
2. Instruct the user to install ripgrep from https://github.com/burntsushi/ripgrep.
3. Ask the user to restart the editor or terminal session.
4. Instruct the user to try the repo-nav skill again after the restart.
5. Stop execution; do not continue with any docmap generation or fallback scanning.

Keep searches scoped to the smallest relevant folder, honor repository ignore rules as configured by `rg`, and minimize repeated repository scans. Use PowerShell or shell commands for operations that the selected search tool cannot express.

Use only shell scripts (powershell, bash, batch files) for automation and repository navigation tasks. Do not generate any other types of scripts or code for these purposes.

## Summary Generation Rules
- Folder Summary: concise summary in one paragraph about 4–5 sentences
- File Summary: concise summary in one paragraph about 4–5 sentences
- File summaries must be generated from the actual file contents using LLM analysis. Do not generate or use helper scripts, lookup tables, hard-coded text, fixed templates, or extension-based rules to produce summaries for `.py`, `.md`, `.java`, test, config, script, or other file types. Do not use fixed templates.
- Before summarizing a file, read enough of that file to identify evidence for its purpose, responsibilities, key concepts, and relationships. If the file content does not provide enough evidence, say so with `confidence: low` instead of inventing a summary.
- Detect TODO / FIXME / NOTE. Detect TODO, FIXME, and NOTE case-insensitively in comments and documentation text. Record each occurrence with its line number and exact marker.
- Generate lowercase, deduplicated, alphabetically sorted tags describing the file’s technologies, role, and major concepts.
- Child folders must be ordered lexicographically by relative path
- Every child-folder entry must link to that folder's `docmap.md` using a relative path from the current index, whether the child index already exists or is pending generation. Use the form ``- `child/docmap.md` — <summary>``; do not list a child folder without its `docmap.md` link.
- Files must be ordered lexicographically by filename within each folder
- TODO / FIXME / NOTE entries for each file must be sorted by line number

- All summaries shall:
  - Be concise
  - Be factual and evidence-based
  - Be generated from the actual file contents
  - Avoid speculation
  - Avoid marketing language
  - Describe intent before implementation

### Documentation (e.g. *.md, *.rst) File Summary Considerations
The file summary must consider 
- what is documented in this file (e.g. test case, usecase, specification, architecture, design, tech stack etc)
- purpose of the file 
- what are the key concepts in this file ?
- What are the responsibilities, types of files, semantic themes

### Source code (e.g. *.cpp, *.java, *.py ) File Summary Considerations
The file summary must consider 
- What is feature/functionality implemented in this file ?
- what are the design patterns, architecture patterns, unique data structures and algorithms used in this file ?
- what are the key concepts in this file ?
- How does this file interact with other files in the project?
- Are there any known bugs/limitations ? Report only explicitly documented or directly observable limitations. Do not perform separate bug analysis.
- What are the responsibilities, roles, and semantic themes?

**Good Example of Summary**
Implements authentication using the Passkey, JWT and OAuth2. Considers security considers like 2FA and progressive delays for authentication failures. Uses Factory and Observer patterns. SHA1024 hash algorithm is used.
Limitation- Automatic logout after some time is not implemented yet.

**Bad Example of Summary**
Implement JWTAuth, PasskeyAuth classes. Derived from AuthBase class.

### Folder Summary Considerations
The folder summary must consider
- Summaries of files in the folder
- Folder summaries of child folders

### Small-Folder Docmap Merge
- After generating or updating a folder's `docmap.md`, count the folder's immediate file entries plus immediate child-folder entries represented in that docmap.
- If the total count is less than 10, merge that folder's docmap content into its parent folder's `docmap.md` rather than keeping a separate child index.
- Perform merges from the deepest folders upward so that a parent receives the final content of all eligible descendants.
- Preserve the merged folder's summary, file summaries, child-folder summaries, tags, and TODO/FIXME/NOTE entries in the parent index.
- Rewrite every merged file and folder link relative to the parent docmap's location. Do not leave links relative to the absorbed child folder, and preserve anchors or other link fragments when present.
- Update the parent folder summary and entry counts after each merge, then remove the absorbed child `docmap.md` only after its content and corrected paths have been incorporated successfully.
- Do not merge the root `DOCMAP.md` into another file. If a merged parent also has fewer than 10 entries, continue applying this rule to that parent.

## Dependency Graph
- Dependency extraction and dependency graph generation are reserved for a future requirement.
- Do not calculate, infer, or validate dependency relationships in the current version.
- Keep the `dependencies` metadata field as an empty list `[]` and mark the dependency graph section as not generated.

## Incremental Update Rules
- Load existing index files if present
- Detect changed files using file size only
- Re-summarize only files with changed file size
- Remove deleted files
- Preserve unchanged summaries
- Update folder summaries when needed
- Apply the Small-Folder Docmap Merge rule after each folder index is generated or incrementally updated
- Rename detection not required
- Do not run a full sweep automatically
- Full sweep is only when explicitly requested by the developer

## Constraints
- No external systems (Jira, GitHub, etc.)
- No embeddings
- No AST parsing
- No call graph
- No bug/issue analysis
- DO NOT TRY TO GENERATE EVERYTHING WITH ONE SCRIPT. Usually Projects are large and the single script generation will fail.

---

# Specialized Repository Navigation Index/Maps

In addition to folder indexes, generate the following cross-cutting indexes when possible.

Use the generated authoritative `DOCMAP.md` and folder-level `docmap.md` files as the source of truth for all cross-cutting map generation. Do not re-scan the repository or source files for these maps; derive everything from the authoritative docmap hierarchy.

## FEATURE_MAP.md

Contains information about the important features of the system.

Feature information containss
- Requirements
- Design
- Source
- Tests
- Issues

## ARCHITECTURE_MAP.md

Contains:

- Architecture overview
- Architectural patterns
- Layer definitions
- Major responsibilities
- Architectural constraints

## TECHNOLOGY_MAP.md

Contains:

- Languages
- Frameworks
- Libraries
- Build tooling
- Version information if discoverable

## TESTING_MAP.md

Contains:

- Test strategy
- Test suites
- Coverage areas
- Feature to test mapping

## CHANGE_IMPACT_MAP.md

Contains:

Common modification scenarios and likely affected files.

Example:

```text
Authentication Change
  -> AuthService.java
  -> UserRepository.java
  -> SessionManager.java
  -> AuthenticationTests.java
```

## Steps
1. ALWAYS Prepare the **indexing operation plan** using the following steps. **Instructions for indexing operation plan creation**

  - Use the template as per `./references/docmap_plan_tmpl.md` to create and update `/.agents/memory/docmap_plan.md`.
  - Use the root `/.agents/memory/docmap_plan.md` to store the plan of the indexing operation at granular steps and to track progress of the index generation execution. 
  - ALWAYS Get the user's approval on plan BEFORE starting the plan execution. 
  - If the root `/.agents/memory/docmap_plan.md` exists, then update the file. 
2. Scan repository recursively for folders only to build the folder tree. if available, prefer the use "ripgrep"/"rg" for searching the files and folders.
3. For each folder, determine the eligible files to include in the folder-level `docmap.md` by running the repo-nav inventory script:
  - On Windows PowerShell: `./scripts/filelist.ps1 <folder-path> <output-file>`
  - On Bash: `./scripts/filelist.sh <folder-path> <output-file>`
  - Use the generated Markdown inventory as the authoritative file set for this folder, after applying repo-nav eligibility rules (text files, ignore rules, excluded folders, and `AGENTS.md` / `CLAUDE.md` exclusions).
  - Keep the file list and its output in the folder-scoped memory state at `/.agents/memory/repo-nav/<folder-relative-path>/filelist.md`.
4. For incremental change detection, run the same filelist script against the current repository state and compare it to the previously stored filelist output for the same folder. Compare file size values; files whose size changed are `MODIFIED`, files missing from the previous output are `DELETED`, and files newly added are `ADDED`.
  - On Windows PowerShell: `./scripts/filelist.ps1 <folder-path> <current-output> -CompareToFile <previous-output>`
  - On Bash: `./scripts/filelist.sh <folder-path> <current-output> <previous-output>`
  - If any file is `MODIFIED` or `ADDED`, regenerate or update that folder’s `docmap.md`.
5. For each folder, starting from the deepest folder and moving upward, do the following:
  1. identify the eligible text files (documents and source code) for this folder.
  2. Use the folder-scoped `/.agents/memory/repo-nav/<folder-relative-path>/filelist.md` to list down the input files that will be used in index generation in each folder.
  3. Generate file summaries. Extract metadata (semantic tags, TODO/FIXME/NOTE) while generating the file summary. File summary must be generated using the LLM summarization.
  4. Generate folder summary.
  5. Use the template as per `./references/folderdocmap_tmpl.md` to generate this folder’s `docmap.md`.
  6. Perform incremental update of folder level `docmap.md`
  7. **Use the 'subagent' to generate and execute steps for individual folder.**
6. Skip dependency graph generation for now.
7. Generate the **Specialized Repository Navigation Maps**
8. Use the template as per `./references/rootdocmap_tmpl.md` to generate (and/or update) the project root `DOCMAP.md`. Always update the root index as project root `/DOCMAP.md` if even you are updating some specific subfolder of the project.
9. Review and validate the generated `DOCMAP.md` and folder-level `docmap.md` files to ensure accuracy and completeness.
10. Update the "**Executation Log**" section of `docmap_plan.md` after each incremental update. 

# Confidence Rules

Only state information that can be supported by repository evidence.

When uncertainty exists:

```yaml
confidence: low
```

When supported by multiple sources:

```yaml
confidence: high
```

Never fabricate architecture, requirements, dependencies, or business purpose.

---

# Success Criteria

The generated indexes/docmaps are successful when a coding agent can:

1. Understand repository purpose from `DOCMAP.md`
2. Navigate to relevant modules without scanning the entire repository
3. Locate implementation files faster
4. Understand feature ownership
5. Assess change impact
6. Discover related tests and requirements
7. Determine likely modification locations
8. Use progressive disclosure to avoid unnecessary file reads



