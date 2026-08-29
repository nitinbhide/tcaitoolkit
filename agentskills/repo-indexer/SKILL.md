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
1. Scan repository recursively for folders only.
2. For Each folder, do the following. Start from the deepest folder. And recursively go up. Check each folder with ignore list.
  1. identify the text based files.
  2. Generate file summaries. Extract metadata (semantic tags, TODO/FIXME/NOTE) while generating the file summary.. 
  3. Generate folder summary.
  4. Use `references/folderindex_tmpl.md` to generate each folder’s `index.md`.
  5. Perform incremental update of folder level `index.md`
6. Build dependency graph.
9. Use `references/rootindex_tmpl.md` to generate the root `INDEX.md`.
10. Use `.agents/memory/indexer_progress.md` to plan the index generation at granular steps and to track progress of the index generation executation.
11. Use the `.agents/memory/filelist.md` to list down the input files that will be used in index generation in each folder. Overwrite this file for individual folder index generation
12. DO NOT TRY TO GENERATE EVERYTHING WITH ONE SCRIPT. Usually Projects are large the single script generation will fail.




