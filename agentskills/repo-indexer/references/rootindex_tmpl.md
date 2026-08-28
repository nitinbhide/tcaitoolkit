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
- `<folder1>/index.md` — <short description>
- `<folder2>/index.md` — <short description>
- `<folder3>/index.md` — <short description>

# Files
- `<filename1>` : <4–5 line summary>
    - Tags: [<tags>]
    - TODO/FIXME/NOTE:
    - <line or short description>
    - <line or short description>

- `<filename2>` : <4–5 line summary>
    - Tags: [<tags>]
    - TODO/FIXME/NOTE:
    - <line or short description>

(Repeat for all files)

---

# Instructions for AI Coding Agents

## How This Index Is Organized
This repository uses a progressive disclosure index hierarchy.  
Each folder contains an `index.md` summarizing its contents.  
This root `Index.md` provides the top-level overview and links to major modules.

Hierarchy:
- Root `INDEX.md` → repository overview + dependency graph  
- Folder `index.md` → folder summary + file summaries  
- File entries → purpose + responsibilities + semantic tags + TODO/FIXME/NOTE  

## How to Use This Index
1. Start at this root `INDEX.md` to understand the repository structure.  
2. Navigate into relevant folders using the links above.  
3. Use folder-level summaries to narrow down your search.  
4. Use file summaries and semantic tags to identify candidate files.  
5. Always read the actual source code before making changes.  

## Notes
- Summaries are intentionally short (4–5 lines).  
- Semantic tags highlight functional areas.  
- TODO/FIXME/NOTE markers indicate hotspots.  
