# Repository Navigation Index Generation Skill (`repo-nav`): Architecture & Design

## 1. Overview and Problem Statement

### 1.1 Context & Motivation
Modern AI coding agents face significant friction when introduced to complex or unfamiliar software repositories. Without structured navigation, agents default to ad-hoc, brute-force keyword searches (`grep`, `find`, globbing) or unguided exploration. This leads to:
- Excessive token consumption from ingesting irrelevant source files.
- Fragmented architectural mental models and hallucinations regarding system boundaries.
- High risk of missed dependencies, overlooked regression tests, or changes in the wrong layer.

The `repo-nav` skill solves this by generating an authoritative, hierarchical system of Markdown index files (`DOCMAP.md` at the project root and `docmap.md` in eligible subfolders), supplemented by cross-cutting navigation maps.

### 1.2 Evolution from Specification to Current Skill Architecture
The initial concept in [docs/agentic-skills/repo-nav/repo-nav-spec.md](docs/agentic-skills/repo-nav/repo-nav-spec.md) established the foundational requirement: a pure Markdown index adhering to **progressive disclosure** without external dependencies. 

As captured in the latest [agentskills/repo-nav/SKILL.md](agentskills/repo-nav/SKILL.md), the design has evolved to incorporate:
1. **Authoritative Single-Scan Discovery:** Enforcing `rg --files` as the single discovery point instead of repeated recursive filesystem sweeps.
2. **Bottom-Up Post-Order Processing:** Processing from the deepest leaf folders up to the root to ensure parent summaries are syntheses of verified child docmaps.
3. **Small-Folder Merge Optimization (< 10 entries):** Pruning sparse folder hierarchies to maximize agent reading density.
4. **Formalized Two-Tier State Tracking & Resumption:** Utilizing `docmap_plan.md` and folder-scoped `filelist.md` to guarantee robust execution and interruption recovery.
5. **Strict Shell & Tooling Contracts:** Using native PowerShell (Windows) or Bash (Unix) without ad-hoc helper scripts (Python/Node.js).

---

## 2. Core Architectural Philosophy: Progressive Disclosure

Progressive disclosure is the governing architectural principle of `repo-nav`. It dictates that information is organized from the broadest conceptual overview down to granular implementation specifics across discrete hierarchical layers.

```
+-------------------------------------------------------------------------+
| Level 1: Root DOCMAP.md & Cross-Cutting Maps                           |
| - High-level system purpose, architecture patterns, tech stack          |
| - Links to root-level modules & specialized cross-cutting maps          |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| Level 2: Folder-Level docmap.md                                         |
| - Module purpose, major responsibilities, technology notes              |
| - Agent guidance: Read When / Modify When / Avoid Modifying When        |
| - File listings with concise 4-5 line summaries, tags, sizes, TODOs     |
| - Links to immediate child folder docmaps                               |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
| Level 3: Source Code & Implementation Artifacts                         |
| - Granular classes, functions, algorithms, data structures               |
| - Read ONLY when the docmap indicates relevance to the task             |
+-------------------------------------------------------------------------+
```

### 2.1 The Three-Level Navigation Hierarchy
1. **Level 1: Root `DOCMAP.md`**  
   The single entry point for any coding agent. It summarizes the entire repository's architecture, business domain, language/tooling profile, module dependency graph, and links directly to first-level directories and cross-cutting maps.
2. **Level 2: Folder `docmap.md`**  
   Provides localized context for a subsystem or module. It explains *why* the folder exists, *what* responsibilities it owns, guidance on *when to read or modify* files in this folder, and short evidence-based summaries for each contained file.
3. **Level 3: Source & Documentation Files**  
   The actual implementation files. An agent only opens Level 3 files after Levels 1 and 2 confirm they contain the target feature, bug, or extension point.

### 2.2 Bottom-Up Synthesis
Summaries are never generated top-down (which leads to speculative hallucinations). Instead:
1. Leaf files are read and summarized first.
2. Folder summaries synthesize the file summaries within that folder and the summaries of already-generated child docmaps.
3. The root `DOCMAP.md` synthesizes the top-level folder summaries and cross-cutting insights.

### 2.3 Information Density: Small-Folder Merging Rule
Deep, sparse directory trees (e.g., `src/main/java/com/org/app/module/impl/`) create navigation fatigue where an agent must traverse multiple docmaps containing 1–2 files each.
- **Rule:** If a folder's effective entry count is **less than 10**, its content is merged directly into its parent folder's docmap rather than keeping a separate child index.
- **Effective Entries Formula:**
  $$\text{Effective Entries} = \text{Direct Files} + \text{Immediate Child Docmap Links} + \sum \text{Absorbed Child Files}$$
- **Staged Merge Protocol:** Merges happen bottom-up. When a child folder is processed with $< 10$ entries, its summaries and metadata are staged in working memory (`/.agents/memory/repo-nav/<path>/`) with status `MARKED_FOR_MERGE` (no child `docmap.md` is emitted to disk).
- **Parent Absorption & Link Rewriting:** When the parent folder is processed, it incorporates all immediate children marked `MARKED_FOR_MERGE`, rewrites their file and folder links relative to the parent docmap, and marks child status as `MERGED_INTO_PARENT`.
- **Cascading Merges:** If the parent folder itself (including direct files and absorbed content) still totals $< 10$ entries, it cascades upward to its grandparent as `MARKED_FOR_MERGE`.
- **Root Protection:** The root `DOCMAP.md` is never merged into another file regardless of entry count.

---

## 3. Specialized Cross-Cutting Navigation Maps

While folder-level `docmap.md` files follow physical disk organization, real-world development tasks cut across directory structures. The skill defines five specialized cross-cutting maps located at the repository root.

```
Repository Root
├── DOCMAP.md               (Primary Hierarchical Entry Point)
├── FEATURE_MAP.md          (Capabilities -> Requirements, Design, Source, Tests)
├── ARCHITECTURE_MAP.md     (Patterns, Layers, Boundaries, System Constraints)
├── TECHNOLOGY_MAP.md       (Languages, Frameworks, Build Tools, Versions)
├── TESTING_MAP.md          (Suites, Test Strategy, Coverage Matrix)
└── CHANGE_IMPACT_MAP.md    (Common Change Scenarios & Blast Radii)
```

### 3.1 `FEATURE_MAP.md`
Maps system business capabilities to their concrete artifacts across the codebase.
- **Components per Feature:**
  - Capability description & business intent.
  - Requirement & specification references (`docs/specs/*.md`).
  - Architecture & design documents (`docs/design/*.md`, ADRs).
  - Primary source files & service classes.
  - Verification & test suites.
  - Known issues or TODO items.

### 3.2 `ARCHITECTURE_MAP.md`
Documents the structural blueprint and engineering conventions.
- **Components:**
  - High-level architectural pattern (e.g., Clean Architecture, Microservices, Event-Driven, MVC).
  - Layer definitions and boundary rules (e.g., domain layer must not import infrastructure layer).
  - Major component responsibilities and data flow narratives.
  - Architectural constraints and invariants.

### 3.3 `TECHNOLOGY_MAP.md` (Tech Stack Map)
Catalogues the technological ecosystem across all repository subprojects.
- **Components:**
  - Programming languages and language standards (e.g., Python 3.12, C++20, TypeScript 5.4).
  - Core frameworks (e.g., React, Spring Boot, PyTorch, Fastify).
  - Third-party libraries and runtime dependencies.
  - Build tooling, package managers, and CI scripts (e.g., CMake, Maven, Poetry, pnpm).
  - Database engines, ORMs, schemas, and serialization protocols (e.g., Protobuf, OpenAPI).

### 3.4 `TESTING_MAP.md`
Provides agents with direct visibility into verification mechanisms so they can immediately locate or write tests when making code edits.
- **Components:**
  - Testing frameworks and runners (e.g., pytest, JUnit 5, Jest).
  - Suite taxonomy (Unit, Integration, Performance, End-to-End).
  - Test locations and naming conventions.
  - Feature-to-test mapping matrix.

### 3.5 `CHANGE_IMPACT_MAP.md`
Anticipates ripple effects for frequent modification scenarios, minimizing regression bugs.
- **Components:**
  - Scenarios (e.g., "Adding a new API endpoint", "Modifying database schema", "Changing Auth provider").
  - Primary file changes required.
  - Secondary/downstream files requiring updates (serializers, clients, mock fixtures).
  - Verification test suites that must be executed for the scenario.

---

## 4. Key Principles for Robust State Tracking

Generating or updating repository docmaps can involve hundreds of files and significant LLM summarization work. The state tracking architecture guarantees complete fault tolerance, idempotency, and resume capability.

### 4.1 Two-Tier State Hierarchy
State tracking is separated into two clean layers under `/.agents/memory/`:

1. **Tier 1 — Global Plan & Execution State (`/.agents/memory/docmap_plan.md`):**
   - Stores the authoritative repository inventory, scan mode, bottom-up traversal queue, merge states, dirty invalidation breakdowns, and specialized map progress.
   - Structured per the schema in [agentskills/repo-nav/references/docmap_plan_tmpl.md](agentskills/repo-nav/references/docmap_plan_tmpl.md).
   - Tracks explicit table attributes per folder: `Depth`, `Folder Path`, `Direct Files`, `Effective Entries`, `Invalidation Reason`, `Status`, `Target Docmap`, `Absorbed By (Parent)`, and `Surviving Docmap`.
2. **Tier 2 — Local Folder Inventory State (`/.agents/memory/repo-nav/<folder-path>/filelist.md`):**
   - Scoped strictly to one folder.
   - Tracks individual file analysis, byte sizes, extracted tags, line-numbered TODO markers, and summarization status (`PENDING`, `SUMMARIZED`).
   - Serves as the staging area when a folder is in `MARKED_FOR_MERGE` state awaiting parent consumption.

### 4.2 Folder Lifecycle State Machine
Each folder in the execution queue transitions through an explicit state machine:

```mermaid
stateDiagram-v2
    [*] --> PENDING: Plan Initialized
    PENDING --> SKIPPED_CLEAN: Incremental Mode (No Changes)
    PENDING --> IN_PROGRESS: Subagent / Worker Starts
    IN_PROGRESS --> MARKED_FOR_MERGE: Effective Entries < 10 (Staged in Memory)
    IN_PROGRESS --> COMPLETED: Effective Entries >= 10 or Root (docmap.md Written)
    MARKED_FOR_MERGE --> MERGED_INTO_PARENT: Parent Incorporates Child & Cleans Disk
    PENDING --> SPLIT_REQUIRED: Incremental Mode (Grew to >= 10 Entries)
    SPLIT_REQUIRED --> IN_PROGRESS: Split & Generate Dedicated docmap.md
    MERGED_INTO_PARENT --> [*]
    COMPLETED --> [*]
    SKIPPED_CLEAN --> [*]
```

- **`PENDING`**: Folder queued for analysis.
- **`SKIPPED_CLEAN`**: In incremental updates, folder and all descendant subtrees have zero modifications; completely bypassed.
- **`IN_PROGRESS`**: Folder is currently being analyzed, file summaries are generating in `filelist.md`.
- **`MARKED_FOR_MERGE`**: Folder analysis is complete and effective entry count is $< 10$. Summaries are staged in memory awaiting parent folder incorporation. Child `docmap.md` is omitted or removed from disk.
- **`MERGED_INTO_PARENT`**: Parent folder has incorporated the child's staged summaries with rewritten relative links.
- **`COMPLETED`**: `docmap.md` has been generated, validated, and effective entry count is $\ge 10$ (or is root `/`).
- **`SPLIT_REQUIRED`**: In incremental mode, a previously merged child folder grew to $\ge 10$ entries and requires a new standalone `docmap.md` and cleanup from its parent docmap.

---

## 5. Execution Scenarios & Resumption Logic

### 5.1 Scenario 1: First-Time Docmap Generation (Full Baseline)

```mermaid
sequenceDiagram
    participant Agent as Coordinating Agent
    participant RG as ripgrep (rg --files)
    participant Plan as docmap_plan.md
    participant Worker as Folder Subagent
    participant Staging as Memory Staging (filelist.md)
    participant FS as Local Filesystem

    Agent->>RG: Run rg --files (authoritative scan)
    RG-->>Agent: Inventory of all files
    Agent->>Agent: Filter exclusions & build folder tree
    Agent->>Agent: Sort folders in post-order (deepest first)
    Agent->>Plan: Write initial docmap_plan.md (status: PENDING_APPROVAL)
    Agent->>Agent: Obtain User Approval
    Plan->>Plan: Status -> IN_PROGRESS
    
    loop For each folder in post-order queue
        Agent->>Worker: Delegate folder processing
        Worker->>FS: Read files in folder
        Worker->>Staging: Write filelist.md with summaries & tags
        Worker->>Worker: Check child folders marked MARKED_FOR_MERGE
        Worker->>Worker: Calculate Effective Entries = Direct Files + Child Links + Absorbed Files
        alt Effective entries < 10 and not root
            Worker->>Staging: Stage merged content in memory
            Worker->>Plan: Mark status MARKED_FOR_MERGE
        else Effective entries >= 10 or root
            Worker->>Worker: Incorporate staged children & rewrite paths
            Worker->>FS: Write folder docmap.md
            Worker->>Plan: Mark status COMPLETED
            Worker->>Plan: Update absorbed children status to MERGED_INTO_PARENT
        end
    end

    Agent->>FS: Generate Specialized Maps & root DOCMAP.md
    Agent->>Plan: Mark status COMPLETED
```

#### Step-by-Step Execution:
1. **Authoritative Discovery:** Run `rg --files` once. Apply file-type inclusion and hard/ignore exclusions.
2. **Post-Order Depth Queue:** Sort unique folders by `Depth` descending, then lexicographically by path.
3. **Plan Generation:** Create `/.agents/memory/docmap_plan.md` with all folders initialized to `PENDING`.
4. **Approval Checkpoint:** Present plan to user for confirmation before starting LLM synthesis.
5. **Folder Processing Loop (Bottom-Up):**
   - Create folder-scoped `filelist.md` to track per-file summarization.
   - Summarize files, extract tags and line-numbered TODO markers.
   - Query `docmap_plan.md` for any immediate child folders marked `MARKED_FOR_MERGE`.
   - Calculate effective entries: $\text{Direct Files} + \text{Immediate Child Docmap Links} + \sum \text{Absorbed Child Files}$.
   - **Branching Decision:**
     - **If Effective Entries $< 10$ and not root:** Stage summaries in memory; mark folder as `MARKED_FOR_MERGE`; do not write `docmap.md` to disk.
     - **If Effective Entries $\ge 10$ or root:** Incorporate staged child summaries with relative link rewriting; write `docmap.md` using [agentskills/repo-nav/references/folderdocmap_tmpl.md](agentskills/repo-nav/references/folderdocmap_tmpl.md); mark folder as `COMPLETED`; update absorbed children to `MERGED_INTO_PARENT`.
   - Commit updated state to `docmap_plan.md`.
6. **Root & Cross-Cutting Assembly:** Generate specialized maps and root `DOCMAP.md` using [agentskills/repo-nav/references/rootdocmap_tmpl.md](agentskills/repo-nav/references/rootdocmap_tmpl.md).

#### Interruption & Resumption (Scenario 1):
If processing is stopped mid-way (user exit, token timeout, network interruption):
1. **Reload Plan:** Read `/.agents/memory/docmap_plan.md`.
2. **Locate Resume Point:** Find the deepest folder marked `IN_PROGRESS`, `MARKED_FOR_MERGE`, or `PENDING`.
3. **Reconcile Active Folder:**
   - If `IN_PROGRESS`, inspect its `filelist.md` to resume incomplete file summaries.
   - Calculate effective entries:
     - If $< 10$ and not root: ensure staged memory is written, set status to `MARKED_FOR_MERGE`.
     - If $\ge 10$ or root: emit `docmap.md`, set status to `COMPLETED`, update absorbed children to `MERGED_INTO_PARENT`.
   - If `MARKED_FOR_MERGE`, verify staged memory exists, then proceed to the parent folder when reached in the queue.
4. **Continue Queue:** Pick up subsequent `PENDING` folders in bottom-up order. Never re-process folders marked `COMPLETED` or `MERGED_INTO_PARENT`.

---

### 5.2 Scenario 2: Incremental Docmap Generation (Source Code Modified)

```mermaid
flowchart TD
    A[rg --files + byte sizes] --> B[Diff with file metadata in existing docmaps]
    B --> C{Categorize File Diffs}
    C -->|Size Changed| D[MODIFIED]
    C -->|New File| E[ADDED]
    C -->|Missing File| F[DELETED]
    C -->|Same Size| G[UNCHANGED]
    
    D & E & F --> H[Identify Direct Dirty Folders]
    G --> I[Mark Subtrees Clean]
    
    H --> J[Propagate Dirty Status upward to Root]
    J --> K[Check previously merged folders: Split required?]
    K --> L[Generate Incremental Plan in docmap_plan.md]
    
    L --> M[Process Dirty Folders Bottom-Up]
    M --> N[Retain UNCHANGED File Summaries Verbatim]
    N --> O[Re-summarize MODIFIED/ADDED files]
    O --> P[Re-evaluate Small Folder Merge / Split Condition]
    P --> Q[Update Root DOCMAP.md & Specialized Maps]
```

#### Step-by-Step Execution:
1. **Fast Discovery & Size Extraction:** Run `rg --files` and extract current byte sizes via PowerShell/Bash native calls.
2. **Metadata Diffing:** Compare against the file sizes recorded in existing `docmap.md` files:
   - **`UNCHANGED`**: Same path, same byte size $\rightarrow$ file summary preserved verbatim.
   - **`MODIFIED`**: Same path, byte size differs $\rightarrow$ file marked for re-summarization.
   - **`ADDED`**: New path $\rightarrow$ file marked for new summarization.
   - **`DELETED`**: Path in docmap no longer on disk $\rightarrow$ entry removed.
3. **Upward Dirty Invalidation Propagation:**
   - Any folder containing a `MODIFIED`, `ADDED`, or `DELETED` file is **Directly Dirty**.
   - All parent/ancestor folders of a dirty folder are marked **Indirectly Dirty** (because their child summaries or counts change).
   - Any subtree without modifications is marked `SKIPPED_CLEAN`.
4. **Dynamic Merge / Split Handling:**
   - **Split Case (`SPLIT_REQUIRED`):** If added files push a previously absorbed folder to effective entries $\ge 10$, it splits out: generates a dedicated child `docmap.md` and replaces its inlined summaries in the parent docmap with a child docmap link.
   - **Merge Case (`MARKED_FOR_MERGE`):** If deleted files drop an independent folder below 10 entries, it merges into its parent and its child `docmap.md` is removed.
5. **Targeted Bottom-Up Execution:** Execute LLM summarization *only* for the dirty queue. Clean folders are touched zero times.
6. **Update Root & Cross-Cutting Maps:** Update root `DOCMAP.md` and touch affected specialized maps (e.g., update `TESTING_MAP.md` if test files changed).

#### Interruption & Resumption (Scenario 2):
If incremental processing is interrupted:
1. **Reload Incremental State:** Read `docmap_plan.md` (`mode: incremental`).
2. **Resume at Dirty Boundary:** Locate the first `IN_PROGRESS`, `MARKED_FOR_MERGE`, or `PENDING` dirty folder in the post-order queue.
3. **Preserve Integrity:** Existing unchanged file summaries remain intact; only pending dirty files in that folder are processed before moving up to ancestor folders.
1. **Reload Incremental State:** Read `docmap_plan.md` (`mode: incremental`).
2. **Resume at Dirty Boundary:** Locate the first `IN_PROGRESS` or `PENDING` dirty folder in the post-order queue.
3. **Preserve Integrity:** Existing unchanged file summaries remain intact; only pending dirty files in that folder are processed before moving up to ancestor folders.

---

## 6. Tooling & Platform Contracts

To ensure reproducible execution without environment corruption, `repo-nav` enforces strict platform contracts:

| Responsibility | Tool / Contract | Prohibited Patterns |
| :--- | :--- | :--- |
| **Repository Discovery** | `rg --files` (honors `.gitignore` automatically) | No `Get-ChildItem -Recurse`, `find`, or ad-hoc filesystem walks |
| **Filesystem Inspection** | PowerShell (`Get-Item`, `Test-Path`) / Bash (`test -f`, `stat`) | No Python/Node scripts generated on the fly |
| **Path Conventions** | Normalized `/` separators across all internal plan representations | No backslash escaping in regex or cross-platform paths |
| **Validation Checks** | Targeted `rg -n` and `rg --only-matching` queries | No full-repository rescanning during validation |
| **Memory Persistence** | `/.agents/memory/docmap_plan.md` and `/.agents/memory/repo-nav/` | No storing execution state in ephemeral subagent context |

---

## 7. Success & Validation Criteria

An index generation or update run is verified complete and valid when:
1. **Structural Completeness:** Every eligible folder has either a dedicated `docmap.md` or a documented absorption entry in its parent docmap.
2. **Relative Link Integrity:** Every child link in a docmap points to an existing `docmap.md` or an existing source file using valid relative paths.
3. **Accurate Metadata:** All file sizes, tags, line-numbered TODO markers, and file counts match the physical filesystem.
4. **Progressive Disclosure Utility:** A coding agent can start at `/DOCMAP.md`, select relevant submodules, and pinpoint the exact files to read or modify without scanning or reading unneeded files.
