# AGENTS.md section

**Purpose and Use of this template**
Add following section to project/repository root AGENTS.md or CLAUDE.md file so that coding agents understand the DOCMAPS.

# Section Template Format

## Source and Documentation Index

The root `DOCMAP.md` and the cross-cutting maps are the preferred entry points for repository navigation. They are authoritative for high-level understanding and for deciding where to read source code and documentation.

Use the repository navigation maps (docmaps) in this order:

1. Start at `DOCMAP.md` for the repository overview, package entry points, and top-level navigation.
2. Read the cross-cutting maps to understand capability, architecture, technology, testing, and change-impact before drilling into implementation:
   - `FEATURE_MAP.md`
   - `ARCHITECTURE_MAP.md`
   - `TECHNOLOGY_MAP.md`
   - `TESTING_MAP.md`
   - `CHANGE_IMPACT_MAP.md`
3. Then read the authoritative folder-level `docmap.md` files under the relevant package or app folder.
4. Only read source files after narrowing to the right module or feature area.

# Additional  Behavioral Requirements

## Primary File Selection Must Be Docmaps‑Driven
You must determine file relevance exclusively from DOCMAPS during the primary selection phase.

- DOCMAPS is the authoritative description of file purpose.
- File selection must be based on DOCMAPS entries.
- You must not infer file relevance from filenames, directory structure, or keyword similarity during primary selection.

## Heuristic Scanning Allowed Only as Secondary Fallback
Heuristic scanning (grep, find, ripgrep, keyword search, symbol search, directory traversal) is prohibited during primary file selection.

Heuristic scanning is allowed only if:
- DOCMAPS-based selection produces zero candidate files, AND
- The task cannot proceed without identifying relevant files.

When heuristic scanning is used:
- It must be explicitly declared as fallback.
- All heuristic-selected files must be justified.
- You must re-evaluate heuristic candidates against DOCMAPS (if applicable).
- Any heuristic-selected file that contradicts DOCMAPS must be discarded.

## Mandatory File-Selection Pipeline
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

4. Discarding Improperly Selected Files
If YOU detect that a file was selected using heuristics during the primary DOCMAPS phase, or without proper fallback conditions:

- The file must be discarded.
- You must not open or modify it.
- The file must not be included in subsequent context.
- You must re-run the selection pipeline.

5. Self-Verification Requirement
Before producing final output, You must verify:
- DOCMAPS was used as the primary decision source.
- Heuristic scanning was used only if DOCMAPS produced zero results.
- Every selected file has valid justification.
- No implicit or unjustified file access occurred.

If any condition fails, the agent must revise its reasoning.

6. Failure Mode Handling
If DOCMAPS produces zero results and heuristic scanning also produces zero results:
- YOu must not guess.
- YOu must request clarification from the user

7. Absolute Rules for file selection for reading and/or writing
These rules override all others:

- DOCMAPS is the primary authority.
- Heuristic scanning is allowed only when DOCMAPS selects zero files.
- Only justified files may be modified.
- No implicit or unjustified file access.
- Self-verification is mandatory.