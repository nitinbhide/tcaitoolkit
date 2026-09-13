# Repository Indexing Plan & Execution State Schema

Use this template to generate and update the plan file at `/.agents/memory/docmap_plan.md`.
The plan tracks repository inventory, execution order, folder merge decisions, incremental change detection, and execution progress for initial generation, incremental updates, and resumption after interruptions.

---

## Template Format

```markdown
---
plan_version: "1.0.0"
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
- **Small-Folder Merge Threshold**: `< 10 direct entries (files + immediate child docmaps)`

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

Status Lifecycle:
- PENDING: Queued for execution.
- IN_PROGRESS: Subagent or worker currently analyzing folder and generating filelist/docmap.
- COMPLETED: docmap.md generated, validated, and entry count >= 10 (or root DOCMAP.md).
- MERGED_INTO_PARENT: Total direct entries < 10; content absorbed into parent; child docmap removed.
- SKIPPED_CLEAN: In incremental mode, folder and its subtree had zero changes.
-->

| Depth | Folder Path | File Count | Invalidation Reason | Status | Target Output | Absorbed By |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| 3 | `src/auth/crypto` | 3 | DIRECT_CHANGE | COMPLETED | `src/auth/crypto/docmap.md` | - |
| 3 | `src/auth/tokens` | 2 | FULL_BASELINE | MERGED_INTO_PARENT | absorbed | `src/auth` |
| 2 | `src/auth` | 5 | CHILD_INVALIDATED | IN_PROGRESS | `src/auth/docmap.md` | - |
| 2 | `src/utils` | 8 | UNCHANGED | SKIPPED_CLEAN | `src/utils/docmap.md` | - |
| 1 | `src` | 2 | CHILD_INVALIDATED | PENDING | `src/docmap.md` | - |
| 0 | `/` | 1 | ROOT_UPDATE | PENDING | `DOCMAP.md` | - |

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
   - Locate the highest-depth (deepest) folder with status `IN_PROGRESS` or `PENDING`.
   - If an `IN_PROGRESS` folder exists:
     - Check `/.agents/memory/repo-nav/<folder-relative-path>/filelist.md` to resume incomplete file summaries.
     - Finalize `docmap.md` (or merge into parent if entries < 10).
     - Update status to `COMPLETED` or `MERGED_INTO_PARENT`.
   - Continue processing remaining `PENDING` items in queue order.
2. **State Transition Rules**:
   - Never re-analyze folders marked `COMPLETED` or `SKIPPED_CLEAN`.
   - If a folder is marked `MERGED_INTO_PARENT`, ensure its content is carried forward in parent queue processing and its child `docmap.md` does not remain on disk.
   - Always update `DOCMAP.md` at root as the final folder step before or alongside specialized maps.
```
