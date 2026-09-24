---
folder: "<designated root folder. Default '/'>"
generated_on: "<timestamp>"
num_files: <integer>
semantic_tags: [<tags>]
todos_present: <true/false>
dependencies: []
---

# Repository Overview
<4–5 line summary of the entire repository, its purpose, major components, and architectural themes.>

- Repository purpose
- Business domain
- Overall architecture summary

## Technology Summary

Detected:

- Languages
- Frameworks
- Databases
- Build systems
- Testing frameworks

## Architecture Summary

High-level architecture overview.

## Business Capability Summary

Major capabilities supported by the repository.

# Module Dependency Graph
Dependency graph generation is reserved for a future requirement and is not included in this index.
The `dependencies` metadata field remains an empty list until dependency extraction is implemented.

# Repository Navigation

## Specialized Cross Navigation Maps
List of specialized navigation maps generated. Use the format

- `<navigation map file name>` : one line purpose of the map.

## Merged Child Folders
`docmap.md` of following child folders are merged in this file.

- `<child1>` : <one short paragraph summary of contents of files in "child1" folder>
- `<child2>` : <one short paragraph summary of contents of files in "child2" folder>

(Repeat for all merged folders)

## Folders
- `<folder1>/docmap.md` — <short summary of content of the folder/description>
- `<folder2>/docmap.md` — <short summary of content of the folder/description>short summary of content of the folder/description
- `<folder3>/docmap.md` — <short summary of content of the folder/description>

## Files
- `<filename1>` : <one concise  paragraph summary/description.>
    - Size : <file size in bytes>
    - Tags: [<tags>]
    - TODO/FIXME/NOTE: <only if there is a TODO/FIXME/NOTE>

- `<filename2>` : <one concise  paragraph summary/description.>
    - Size : <file size in bytes>
    - Tags: [<tags>]
    - TODO/FIXME/NOTE: <only if there is a TODO/FIXME/NOTE>

(Repeat for all files)

---

# Instructions for AI Coding Agents

## When to Use This Index/DOCMAP
- Agents should use docmaps to identify candidate files before searching. 
- Source searches must be narrowly scoped to the relevant package or feature directory; generated build artifacts are not source-of-truth files.
- Use this index/DOCMAP to 
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
- Avoid unnecessary repository exploration using 'find', 'grep' kind of searches.

## How This Index Is Organized
This repository uses a progressive disclosure index hierarchy.  
Each folder contains an `docmap.md` summarizing its contents.  
This root `DOCMAP.md` provides the top-level overview and links to major modules.

Hierarchy:
- Root `DOCMAP.md` → repository overview + dependency graph  
- Folder `docmap.md` → folder summary + file summaries  
- File entries → purpose + responsibilities + semantic tags + TODO/FIXME/NOTE  

## How to Use This Index/DOCMAP
1. Start at this root `DOCMAP.md` to understand the repository shape.
2. Navigate into the relevant package or sample app using the links above.
3. Follow the folder level/child docmaps to the implementation area that matches the task.
4. Read the specific source files only after narrowing the folder or feature.
5. Use folder summaries and semantic tags to avoid broad repository exploration.
6. Always read the actual source code before making changes.  

### Additional Tips
- To find files relevant to a topic check the semantic_tags and Tags: attributes in folder-level docmap.md files instead of scanning raw source code."
- Try to use "Cross Navigation Maps" for relevant folder docmap files.  

## Notes
- Summaries are intentionally short (4–5 sentences, one paragraph).  
- Semantic tags highlight functional areas.  
- TODO/FIXME/NOTE markers indicate hotspots/pending actions.  
