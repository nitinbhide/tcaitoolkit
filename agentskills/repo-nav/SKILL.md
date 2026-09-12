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

Generate Markdown index files (`DOCMAP.md` at root, `docmap.md` in each folder) that summarize the contents of a local repository using progressive disclosure.  

This skill **only generates index files** and is **not to be used by coding agents for project decision making**.

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
The skill performs a recursive scan of the repository and generates index files containing:
- YAML frontmatter metadata
- Folder-level summary (4–5 lines)
- File listings with short summaries
- Semantic tags
- TODO / FIXME / NOTE detections
- Child folder references
- Dependency graph generation is disabled for now
- Use the templates defined in this skills `references/` folder only

### Template Usage
- **Root Index File (`DOCMAP.md`)**  
  Must be generated using the template defined in `./references/rootdocmap_tmpl.md`

- **Folder Index Files (`docmap.md`)**  
  Must be generated using the template defined in `./folderdocmap_tmpl.md`

The skill must fill these templates with actual repository data.

### Root Index Requirements
The root `DOCMAP.md` **must include a section** explaining:
- how the index hierarchy is organized  
- how AI coding agents should use the index  

(The actual instruction text is defined inside the template `rootdocmap_tmpl.md`.)
This file is the primary entry point for all AI agents.

## File/Folder Inclusion/Exclusion Rules

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
- Binary files
- Vendor libraries
- Generated code
- file names is starting with '.'
- any file mentioned in ".gitignore" and other ignore files
- AGENTS.md 
- CLAUDE.md 
- Configuration and settings files (java property files, e.g., `.properties`, `.xml`, `.yaml`, `.yml`, `.ini`, `.settings`)

### Excluded Folders
- folder name starting with '.' (".git", ".agents", ".github")
- any folder mentioned in ".gitignore" , ".hgignore" and other version control "ignore" files

### Ignore precedence:
- Apply hard excludes first (binary, vendor, generated, hidden files/folders)
- Then Apply "Excluded Folders"
- Then apply ".gitignore" , ".hgignore" , and other version control ignore files
- Then apply included file type filtering

## Search Strategy

When searching the project folder structure/codebase, first detect whether `rg` (ripgrep) is installed and available on `PATH`.

**Ripgrep availability check**

- On Windows PowerShell, run `Get-Command rg -ErrorAction SilentlyContinue`.
- On Unix-like shells, run `command -v rg`.

If the check succeeds, load and follow the detailed ripgrep instructions in `./references/ripgrepsearch.md`. Use `rg --files` as the first and authoritative repository-discovery command, followed by targeted content or filename searches from that reference.

If the check fails, do not attempt to use `rg`. Use the platform-native fallback commands below instead:

- On Windows PowerShell, use `Get-ChildItem -Recurse -File` for file discovery and `Select-String -Path <path> -Pattern '<pattern>'` for content search. Filter with `-Include` or `Where-Object` when needed.
- On Unix-like systems, use `find <path> -type f` for file discovery and `grep -RIn '<pattern>' <path>` for content search. Use `grep -E` for regular expressions and `grep -F` for literal text.

Keep searches scoped to the smallest relevant folder, honor repository ignore rules where the fallback command supports them, and minimize repeated recursive scans. Use PowerShell or shell commands for operations that the selected search tool cannot express.

## Summary Generation Rules
- Folder Summary: concise summary in one paragraph about 4–5 sentences
- File Summary: concise summary in one paragraph about 4–5 sentences
- Detect TODO / FIXME / NOTE. Detect TODO, FIXME, and NOTE case-insensitively in comments and documentation text. Record each occurrence with its line number and exact marker.
- Generate lowercase, deduplicated, alphabetically sorted tags describing the file’s technologies, role, and major concepts.
- Summaries must be evidence-based and generated from the file’s actual contents; Do not use fixed templates.
- Child folders must be ordered lexicographically by relative path
- Files must be ordered lexicographically by filename within each folder
- TODO / FIXME / NOTE entries for each file must be sorted by line number

- All summaries shall:
  - Be concise
  - Be factual
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
- Dependency extraction and dependency graph generation are disabled for now
- Keep `dependencies` metadata as an empty list `[]`

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
1. ALWAYS Prepare the **indexing operation plan** using the following steps. **Instructions for indexing opperation plan creation**

  - Use the root `/.agents/memory/docmap_plan.md` to store the plan of the indexing operation at granular steps and to track progress of the index generation executation. 
  - ALWAYS Get the user's approval on plan BEFORE starting the plan execution. 
  - If the root `/.agents/memory/docmap_plan.md` exists, then update the file. 
2. Scan repository recursively for folders only to build the folder tree. if available, prefer the use "ripgrep"/"rg" for searching the files and folders.
3. For Each folder, do the following. Start from the deepest folder. And recursively go up. Check each folder with ignore list, then scan files for that folder.
  1. identify the text files (documents and source code) for this folder.
  2. Use the folder-scoped `/.agents/memory/repo-nav/<folder-relative-path>/filelist.md` to list down the input files that will be used in index generation in each folder.
  3. Generate file summaries. Extract metadata (semantic tags, TODO/FIXME/NOTE) while generating the file summary. File summary must be generated using the LLM summarization.
  4. Generate folder summary.
  5. Use the template as per `./references/folderdocmap_tmpl.md` to generate this folder’s `docmap.md`.
  6. Perform incremental update of folder level `docmap.md`
  7. **Use the 'subagent' to generate and execute steps for individual folder.**
4. Skip dependency graph generation for now.
5. Generate the **Specialized Repository Navigation Maps**
6. Use the template as per `./references/rootdocmap_tmpl.md` to generate (and/or update) the project root `DOCMAP.md`. Always update the root index as project root `/DOCMAP.md` if even you are updating some specific subfolder of the project.
7. Review and validate the generated `DOCMAP.md` and folder-level `docmap.md` files to ensure accuracy and completeness.

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



