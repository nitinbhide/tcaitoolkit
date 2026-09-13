# Repository Indexing Plan & Execution State Schema

Use this template to generate and update the plan file at `/.agents/memory/docmap_plan.md`.
The plan tracks repository inventory, execution order, folder merge decisions, incremental change detection, and execution progress for initial generation, incremental updates, and resumption after interruptions.

---

## Template Format

```markdown
---
plan_version: "1.1.0"
mode: "<full_baseline | incremental>"
status: "<PENDING_APPROVAL | IN_PROGRESS | COMPLETED | FAILED>"
created_at: "<ISO-8601 Timestamp>"
updated_at: "<ISO-8601 Timestamp>"
total_folders: <integer>
total_eligible_files: <integer>
dirty_folders_count: <integer>
resumption_count: <integer>
last_interrupted_folder: "<relative/folder/path or null>"
---

# Repository Navigation Indexing Plan

## 1. Inventory & Execution Summary
- **Repository Root**: `<absolute or root-relative path>`
- **Discovery Tool**: `<rg | powershell_fallback | bash_fallback>`
- **Execution Strategy**: Bottom-up (deepest leaf folders to repository root)
- **Small-Folder Merge Threshold**: `< 10 direct entries (direct files + immediate child docmap links + absorbed files)`

## 2. Incremental Change Detection (Only for mode: incremental)
<!-- If mode is full_baseline, mark this section as 'N/A - Full Baseline Scan' -->

### Changed / Added / Deleted Files
- `MODIFIED`: `<path/to/file1>` (Old Size: <bytes> bytes -> New Size: <bytes> bytes)
- `ADDED`: `<path/to/file2>` (Size: <bytes> bytes)
- `DELETED`: `<path/to/file3>`

### Invalidation Summary
- Direct Dirty Folders: `<count>`
- Ancestor / Indirect Dirty Folders: `<count>`
- Clean (Skipped) Folders: `<count>`

---

## 3. Folder Execution Queue (Bottom-Up Post-Order)
<!--
Folders MUST be ordered by Depth descending (deepest first), then lexicographically by relative path.

Status Lifecycle & Merge Protocol:
- PENDING: Queued for execution.
- IN_PROGRESS: Subagent or worker currently analyzing files in folder and writing filelist.md.
- MARKED_FOR_MERGE: Folder analyzed and effective entries < 10. Summary and file entries are staged in agent memory (/.agents/memory/repo-nav/<path>/) awaiting parent folder incorporation. Child docmap.md is NOT published.
- MERGED_INTO_PARENT: Parent folder has processed and incorporated this child's staged summaries with rewritten relative links. Child docmap.md is confirmed deleted or absent from disk.
- COMPLETED: Standalone docmap.md generated, validated, and effective entry count >= 10 (or root DOCMAP.md).
- SPLIT_REQUIRED: (Incremental mode) Folder was previously merged in parent, but added files increased its count to >= 10; requires dedicated docmap.md generation and removal of inlined entries from parent docmap.
- SKIPPED_CLEAN: (Incremental mode) Folder and all its descendant subtrees had zero changes.

Effective Entries Calculation:
Effective Entries = Direct Files + Immediate Child Docmap Links + Absorbed Child Files
-->

| Depth | Folder Path | Direct Files | Effective Entries | Invalidation Reason | Status | Target Docmap | Absorbed By (Parent) | Surviving Docmap |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 3 | `src/auth/crypto` | 11 | 11 | DIRECT_CHANGE | COMPLETED | `src/auth/crypto/docmap.md` | - | `src/auth/crypto/docmap.md` |
| 3 | `src/auth/tokens` | 3 | 3 | FULL_BASELINE | MERGED_INTO_PARENT | (staged in memory) | `src/auth` | `src/auth/docmap.md` |
| 2 | `src/auth` | 6 | 10 | CHILD_INVALIDATED | IN_PROGRESS | `src/auth/docmap.md` | - | `src/auth/docmap.md` |
| 2 | `src/utils` | 12 | 12 | UNCHANGED | SKIPPED_CLEAN | `src/utils/docmap.md` | - | `src/utils/docmap.md` |
| 1 | `src` | 2 | 4 | CHILD_INVALIDATED | PENDING | `src/docmap.md` | - | `src/docmap.md` |
| 0 | `/` | 2 | 3 | ROOT_UPDATE | PENDING | `DOCMAP.md` | - | `DOCMAP.md` |

*(Note on effective entries above: `src/auth` has 6 direct files + 1 child link (`crypto/docmap.md`) + 3 absorbed files from `tokens` = 10 effective entries $\ge 10$, so it becomes a standalone docmap).*

---

## 4. Specialized Cross-Cutting Maps Queue
<!-- Cross-cutting maps generated after folder-level docmaps are complete -->

- [ ] `FEATURE_MAP.md` — Major business capabilities mapped to requirements, design, source, tests
- [ ] `ARCHITECTURE_MAP.md` — Architectural patterns, layer definitions, and system constraints
- [ ] `TECHNOLOGY_MAP.md` — Languages, frameworks, runtime versions, build tooling
- [ ] `TESTING_MAP.md` — Test suites, strategy, coverage areas, feature-to-test mapping
- [ ] `CHANGE_IMPACT_MAP.md` — Common modification scenarios and affected file cascades

---

## 5. Resumption & Checkpoint Instructions

1. **On Session Interruption / Resume**:
   - Read `/.agents/memory/docmap_plan.md`.
   - Locate the highest-depth (deepest) folder with status `IN_PROGRESS`, `MARKED_FOR_MERGE`, or `PENDING`.
   - If an `IN_PROGRESS` folder exists:
     - Check `/.agents/memory/repo-nav/<folder-relative-path>/filelist.md` to resume incomplete file summaries.
     - Count effective entries:
       - If effective entries $< 10$ and not root: stage content in `/.agents/memory/repo-nav/<folder-path>/` and mark status `MARKED_FOR_MERGE`. Ensure no child `docmap.md` is left on disk.
       - If effective entries $\ge 10$ or root: write `docmap.md`, validate, and mark status `COMPLETED`.
   - If a folder is `MARKED_FOR_MERGE`:
     - Verify staged memory exists, then proceed to its parent folder when the queue reaches it.
   - Continue processing remaining `PENDING` items in queue order.
2. **Cascading Merge Handling**:
   - When a parent folder processes, it must check all immediate child folders in the queue marked `MARKED_FOR_MERGE`.
   - The parent incorporates their staged summaries, rewrites their links relative to itself, and updates child status to `MERGED_INTO_PARENT`.
   - If the parent's resulting effective count is still $< 10$ (and not root `/`), the parent itself transitions to `MARKED_FOR_MERGE` for absorption into the grandparent.
3. **State Transition Invariants**:
   - Never re-analyze folders marked `COMPLETED`, `MERGED_INTO_PARENT`, or `SKIPPED_CLEAN`.
   - Always update `DOCMAP.md` at root as the final folder step before or alongside specialized maps.
```
