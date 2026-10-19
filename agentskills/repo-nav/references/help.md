# Repo-nav help

Repo-nav builds Markdown maps that help coding agents navigate a repository. Maps point agents to relevant source; they do not replace reading it.

## Roots

The **project root** is the physical top-level repository folder. Repo-nav stores its plans and logs under `<project root>/.agents/memory/`.

The **Designated Root Folder (DRF)** is the logical root for an indexing run. DRFs are especially useful in large repositories where major modules or packages are large enough to need their own root `DOCMAP.md` and cross-navigation maps. A repository can have multiple DRFs, each scoped to its own subtree. The project root `DOCMAP.md` then gives the repository-wide overview and combines or links to each DRF's maps. If the repository is small or has one coherent project, the project root can itself be the single DRF; its `DOCMAP.md` serves both roles.

Per-DRF working state is kept in `<project root>/.agents/memory/<DRF-key>/`, where the key is the DRF's path relative to the project root with separators replaced by `_` (`root` for the project root).

## Maps and outputs

Docmaps use progressive disclosure: start at the DRF's `DOCMAP.md`, follow folder `docmap.md` links, then read relevant source files. Folder docmaps summarize purpose, files, tags, and child folders. Small-folder content may be merged into a parent after docmaps are first written in their source folders.

Each DRF also gets cross-navigation maps, derived from docmaps (not rescanned source):

- `FEATURE_MAP.md` — documented features, requirements, source, tests, and markers.
- `ARCHITECTURE_MAP.md` — architecture, patterns, layers, and constraints.
- `TECHNOLOGY_MAP.md` — languages, frameworks, libraries, and tooling.
- `TESTING_MAP.md` — strategy, suites, coverage, and feature/test links.
- `CHANGE_IMPACT_MAP.md` — documented changes and likely affected files.

Repo-nav also updates or creates project-root `AGENTS.md` guidance. Per-DRF working files are `docmap_plan.md` (plan and progress), `docmap_plan_log.md` (append-only log), and `repo-nav/` (merge state).

## Typical prompts

First-time generation for one project:

> Generate repo-nav docmaps for the repository. Use the repository root as the DRF and show me the plan for approval before executing.

For a large repository with separate modules, designate each substantial module as a DRF, then build the project-root overview:

> Generate repo-nav maps for `services/billing` and `services/accounts` as separate DRFs. Keep each run scoped to its subtree and show each plan for approval. Then update the project-root `DOCMAP.md` to summarize the repository and link to both DRF root docmaps and their cross-navigation maps.

Checkpoint and stop:

> Finish the current folder, checkpoint completed and remaining work in `docmap_plan.md`, append the interruption to `docmap_plan_log.md`, then stop.

Resume:

> Resume repo-nav for `services/billing` from its saved plan and log. Check the current instructions and run mode, then continue from the checkpoint.

Tip: explicitly load the DRF's `.agents/memory/<DRF-key>/docmap_plan.md` into the agent context before resuming for better results.

Incremental update:

> Update repo-nav for `services/billing` after recent source changes. Identify changed files, preserve unchanged summaries, update affected ancestors and DRF maps, and do not run a full regeneration.

## Baseline, resume, and updates

The existence of a root `DOCMAP.md` at the project root or current DRF selects the mode. If one exists, update the existing maps based on detected changes; otherwise, create the initial maps. When resuming an interrupted first-time run, continue from the saved plan even if some folder docmaps have already been written. The plan tracks progress; append to the execution log rather than replacing it.

Incremental updates refresh summaries for changed or new files, remove deleted files, retain unchanged summaries, and propagate updates to affected parent maps and the DRF root. Request a full regeneration when needed.
