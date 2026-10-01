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

## Mandatory Use of DOCMAPS
You MUST use DOCMAPS as the PRIMARY mechanism for determining which files are relevant to the coding task.

MANDATORY PIPELINE:
1. Read DOCMAPS.
2. Identify candidate files based on DOCMAPS descriptions.
3. Justify each candidate file using DOCMAPS text.
4. ONLY AFTER step 1–3, use grep/find to confirm symbol presence.
5. If DOCMAPS contradict grep/find, DOCMAPS wins.
6. If DOCMAPS is incomplete, ask for clarification.

**PROHIBITED:**
- Selecting files based on filename similarity **ALONE**.
- Selecting files based on grep/find **ALONE**.
- Guessing file purpose without DOCMAPS justification.

REQUIRED OUTPUT SECTION:
"FILE SELECTION JUSTIFICATION"
- List each selected file.
- Quote DOCMAPS entry.
- Explain mapping to task.
- State whether grep/find was used only as confirmation.

**SELF-CHECK BEFORE FINAL ANSWER:**
- Did I use DOCMAPS first?
- Did I justify each file?
- Did I avoid heuristic selection?
If NO → revise reasoning.


