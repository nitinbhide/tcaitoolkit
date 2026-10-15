# AGENTS.md section

**Purpose and Use of this template**
Add following section to project/repository root AGENTS.md or CLAUDE.md file so that coding agents understand the DOCMAPS.

# Section Template Format

## Source and Documentation Index

The project root may have its own `DOCMAP.md` describing the repository as a whole, in addition to multiple Designated Root Folders (DRFs), each with its own root `DOCMAP.md` and cross-cutting maps. These indexes have different scopes and may coexist. Start with the project-root docmap when available to understand the repository and identify the relevant DRF; then use that DRF's maps as the preferred entry points for its scope. If the project root is itteself a DRF, its single `DOCMAP.md` serves both roles and should not be listed twice.

### Project Root Docmap

- `<project-root-DOCMAP-path>` — <repository-wide scope>

### Root Docmaps of Designated Root Folders

List of 
- `<path-to-designated-root-folder>/DOCMAP.md` — <scope or project summarized by this DRF>

## How and When to repository navigation maps (docmaps)
Use the repository navigation maps for the relevant DRF in this order:

1. Start at the relevant DRF's `DOCMAP.md` for its overview, package entry points, and top-level navigation. If the project-root docmap identifies the relevant DRF, follow its link or path.
2. Read that DRF's cross-cutting maps to understand capability, architecture, technology, testing, and change-impact before drilling into implementation:
   - `FEATURE_MAP.md`
   - `ARCHITECTURE_MAP.md`
   - `TECHNOLOGY_MAP.md`
   - `TESTING_MAP.md`
   - `CHANGE_IMPACT_MAP.md`
3. Then read the authoritative folder-level `docmap.md` files under the relevant package or app folder within that DRF.
4. Only read source files after narrowing to the right module or feature area.

## Additional Behavioral Requirements

### Primary File Selection Must Be Docmaps‑Driven
You must determine file relevance exclusively from DOCMAPS during the primary selection phase.

- DOCMAPS is the authoritative description of file purpose.
- File selection must be based on DOCMAPS entries.
- You must not infer file relevance from filenames, directory structure, or keyword similarity during primary selection.

### Heuristic Scanning Allowed Only as Secondary Fallback
Heuristic scanning (grep, find, ripgrep, keyword search, symbol search, regex search or complete directory traversal) is prohibited during primary file selection.

Heuristic scanning is allowed only if:
- DOCMAPS-based selection produces zero candidate files, AND
- The task cannot proceed without identifying relevant files.

When heuristic scanning is used:
- It must be explicitly declared as fallback.
- All heuristic-selected files must be justified.
- You must re-evaluate heuristic candidates against DOCMAPS (if applicable).
- Any heuristic-selected file that contradicts DOCMAPS must be discarded.

### Mandatory File-Selection Pipeline
You must follow this pipeline exactly:

Step 1 — DOCMAPS Primary Selection
Identify candidate files based solely on DOCMAPS descriptions.

Step 2 — Zero-Result Check
If DOCMAPS produces zero candidate files, YOU may proceed to fallback heuristic scanning.

Step 3 — Fallback Heuristic Selection (Only If Step 2 = Zero Files)
Use grep/find/keyword search to identify potential files.
Heuristic scanning must be explicitly declared as fallback.

Step 4 — Produce FILE SELECTION JUSTIFICATION
You must output a section titled:

```
FILE SELECTION JUSTIFICATION
```
For each candidate file:
- Quote the DOCMAPS entry (if DOCMAPS-selected).
- OR explain fallback heuristic reasoning (if DOCMAPS produced zero results).
- Explain why the file is relevant to the task.

Step 5 — Modify Only Selected Files
You must modify only the files selected and justified in the FILE SELECTION JUSTIFICATION section.

### Discarding Improperly Selected Files
If YOU detect that a file was selected using heuristics during the primary DOCMAPS phase, or without proper fallback conditions:

- The file must be discarded.
- You must not open or modify it.
- The file must not be included in subsequent context.
- You must re-run the selection pipeline.

### Self-Verification Requirement
Before producing final output, You must verify:
- DOCMAPS was used as the primary decision source.
- Heuristic scanning was used only if DOCMAPS produced zero results.
- Every selected file has valid justification.
- No implicit or unjustified file access occurred.

If any condition fails, the agent must revise its reasoning.

### Failure Mode Handling
If DOCMAPS produces zero results and heuristic scanning also produces zero results:
- YOu must not guess.
- YOu must request clarification from the user

### Absolute Rules for File Selection for Reading and/or Writing
These rules override all others:

- DOCMAPS is the primary authority.
- Heuristic scanning is allowed only when DOCMAPS selects zero files.
- Only justified files may be modified.
- No implicit or unjustified file access.
- Self-verification is mandatory.