---
name: repo-indexer
description: Generate hierarchical Markdown index files for a project  repository folder structure using progressive disclosure.
version: 1.1.0
author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
tags:
  - indexing
  - repository-structure
  - codebase-analysis
---

# Project Repository Indexer Skill

## Purpose
Generate Markdown index files (`INDEX.md` at root, `index.md` in each folder) that summarize the contents of a local repository using progressive disclosure.  
This skill **only generates index files** and is **not used by coding agents for project decision making**.

## Inputs
- Root directory path of the local repository.

## Outputs
- Markdown index files written directly into each folder of the repository.
- The root index file must be generated using `rootindex_tmpl.md`.
- All folder-level index files must be generated using `folderindex_tmpl.md`.

## Behavior
The skill performs a recursive scan of the repository and generates index files containing:
- YAML frontmatter metadata
- Folder-level summary (4–5 lines)
- File listings with short summaries
- Semantic tags
- TODO / FIXME / NOTE detections
- Child folder references
- Module-level dependency graph (root only)

### Template Usage
- **Root Index File (`INDEX.md`)**  
  Must be generated using the template in:  
  `rootindex_tmpl.md`

- **Folder Index Files (`index.md`)**  
  Must be generated using the template in:  
  `folderindex_tmpl.md`

The skill must fill these templates with actual repository data.

### Root Index Requirements
The root `INDEX.md` **must include a section** explaining:
- how the index hierarchy is organized  
- how AI coding agents should use the index  

(The actual instruction text is defined inside `rootindex_tmpl.md`.)

## Included File Types
- Source code (any language)
- Design documents
- Specification documents
- Test plans and test cases
- Implementation plans
- SQL files
- Protobuf schema files
- Markdown, text, YAML, JSON

## Excluded File Types
- Binary files
- Vendor libraries
- Generated code

## Summarization Rules
- Folder summaries: 4–5 lines
- File summaries: 4–5 lines
- Detect TODO / FIXME / NOTE
- Extract semantic tags heuristically
- Summaries generated using an LLM

## Dependency Graph
- Folder-level dependency graph inferred from import/include/require statements
- Included only in root `INDEX.md`

## Incremental Update Rules
- Load existing index files if present
- Re-summarize only changed files
- Remove deleted files
- Preserve unchanged summaries
- Update folder summaries when needed
- Rename detection not required

## Constraints
- Single monolithic skill
- No external systems (Jira, GitHub, etc.)
- No embeddings
- No AST parsing
- No call graph
- No bug/issue analysis

## Steps
1. Prepare the **indexing operation plan** using the following steps. Use `.agents/memory/indexing_plan.md` to store the plan of the indexing operation at granular steps and to track progress of the index generation executation. Get the user's approval on plan before starting the execution.
3. Scan repository recursively for folders only.
4. For Each folder, do the following. Start from the deepest folder. And recursively go up. Check each folder with ignore list.
  1. identify the text based files for this folder.
  2. Use the `.agents/memory/filelist.md` to list down the input files that will be used in index generation in each folder. Overwrite this file for individual folder index generation for each folder.
  3. Generate file summaries. Extract metadata (semantic tags, TODO/FIXME/NOTE) while generating the file summary.. 
  4. Generate folder summary.
  5. Use the template `references/folderindex_tmpl.md` to generate this folder’s `index.md`.
  6. Perform incremental update of folder level `index.md`
5. Build dependency graph.
6. Use the template `references/rootindex_tmpl.md` to generate the root `INDEX.md`.
7. DO NOT TRY TO GENERATE EVERYTHING WITH ONE SCRIPT. Usually Projects are large the single script generation will fail.





