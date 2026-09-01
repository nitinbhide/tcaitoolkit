---
name: repo-indexer
description: Generate hierarchical Markdown index files (docmap.md) for a project  repository folder structure using progressive disclosure.
version: 1.1.0
author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
tags:
  - indexing
  - repository-structure
  - codebase-analysis
---

# Project Repository Indexer Skill

## Purpose
Generate Markdown index files (`DOCMAP.md` at root, `docmap.md` in each folder) that summarize the contents of a local repository using progressive disclosure.  
This skill **only generates index files** and is **not used by coding agents for project decision making**.
The skill generates documentation that may target coding agents; this skill itself does not perform coding-agent decision workflows.

DO NOT deviate from this SKILL instructions.


## Inputs
- Root directory path of the local repository.

## Outputs
- Markdown index files written directly into each folder of the repository.
- The root index file must be generated using `rootdocmap_tmpl.md`.
- All folder-level index files must be generated using `folderdocmap_tmpl.md`.

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
  Must be generated using the template defined in `rootdocmap_tmpl.md`

- **Folder Index Files (`docmap.md`)**  
  Must be generated using the template defined in `folderdocmap_tmpl.md`

The skill must fill these templates with actual repository data.

### Root Index Requirements
The root `DOCMAP.md` **must include a section** explaining:
- how the index hierarchy is organized  
- how AI coding agents should use the index  

(The actual instruction text is defined inside `rootdocmap_tmpl.md`.)

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
- any folder mentioned in ".gitignore" and other ignore files

### Ignore precedence:
- Apply hard excludes first (binary, vendor, generated, hidden files/folders)
- Then Apply "Excluded Folders"
- Then apply ".gitignore" and other ignore files
- Then apply included file type filtering

## Summarization Rules
- Folder summaries: 4–5 lines
- File summaries: 4–5 lines
- Detect TODO / FIXME / NOTE
- Extract semantic tags heuristically
- Summaries generated using an LLM. The summaries will be different for different files. Do not use templated summaries
- Child folders must be ordered lexicographically by relative path
- Files must be ordered lexicographically by filename within each folder
- Semantic tags must be lowercase, deduplicated, and sorted
- TODO / FIXME / NOTE entries for each file must be sorted by line number

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

## Steps
1. ALWAYS Prepare the **indexing operation plan** using the following steps. **Instructions for indexing opperation plan creation**
  - Use the root `/.agents/memory/docmap_plan.md` to store the plan of the indexing operation at granular steps and to track progress of the index generation executation. 
  - ALWAYS Get the user's approval on plan BEFORE starting the plan execution. 
  - If the root `/.agents/memory/docmap_plan.md` exists, then update the file. 
2. Scan repository recursively for folders only to build the folder tree. if available, prefer the use "ripgrep"/"rg" for searching the files and folders.
3. For Each folder, do the following. Start from the deepest folder. And recursively go up. Check each folder with ignore list, then scan files for that folder.
  1. identify the text based files for this folder.
  2. Use the folder-scoped `/.agents/memory/repo-indexer/<folder-relative-path>/filelist.md` to list down the input files that will be used in index generation in each folder.
  3. Generate file summaries. Extract metadata (semantic tags, TODO/FIXME/NOTE) while generating the file summary. File summary must be generated using the LLM summarization.
  4. Generate folder summary.
  5. Use the template `./references/folderdocmap_tmpl.md` to generate this folder’s `docmap.md`.
  6. Perform incremental update of folder level `docmap.md`
  7. Use a 'subagent' to generate the steps for each folder.
4. Skip dependency graph generation for now.
5. Use the template `./references/rootdocmap_tmpl.md` to generate (and/or update) the project root `DOCMAP.md`. Always update the root index as project root `/DOCMAP.md` if even you are updating some specific subfolder of the project.






