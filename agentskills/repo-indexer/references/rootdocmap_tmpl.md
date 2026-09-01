---
folder: "/"
generated_on: "<timestamp>"
num_files: <integer>
semantic_tags: [<tags>]
todos_present: <true/false>
dependencies: [<moduleA>, <moduleB>, ...]
---

# Repository Overview
<4–5 line summary of the entire repository, its purpose, major components, and architectural themes.>

# Module Dependency Graph
<High-level folder/module dependency relationships inferred from imports/includes.>

# Top-Level Folders
- `<folder1>/docmap.md` — <short summary of content of the folder/description>
- `<folder2>/docmap.md` — <short summary of content of the folder/description>short summary of content of the folder/description
- `<folder3>/docmap.md` — <short summary of content of the folder/description>

# Files
- `<filename1>` : <one short paragraph summary/description.>
    - Size : <file size in bytes>
    - Tags: [<tags>]
    - TODO/FIXME/NOTE: <only if there is a TODO/FIXME/NOTE>

- `<filename2>` : <one short paragraph summary/description.>
    - Size : <file size in bytes>
    - Tags: [<tags>]
    - TODO/FIXME/NOTE: <only if there is a TODO/FIXME/NOTE>

(Repeat for all files)

---

# Instructions for AI Coding Agents

## How This Index Is Organized
This repository uses a progressive disclosure index hierarchy.  
Each folder contains an `docmap.md` summarizing its contents.  
This root `DOCMAP.md` provides the top-level overview and links to major modules.

Hierarchy:
- Root `DOCMAP.md` → repository overview + dependency graph  
- Folder `docmap.md` → folder summary + file summaries  
- File entries → purpose + responsibilities + semantic tags + TODO/FIXME/NOTE  

## How to Use This Index/DOCMAP
1. Start at this root `DOCMAP.md` to understand the repository structure.  
2. Navigate into relevant folders using the links above.  
3. Use folder-level summaries to narrow down your search.  
4. Use file summaries and semantic tags to identify candidate files.  
5. Always read the actual source code before making changes.  

## Notes
- Summaries are intentionally short (4–5 lines).  
- Semantic tags highlight functional areas.  
- TODO/FIXME/NOTE markers indicate hotspots/pending actions.  
