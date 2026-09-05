---
name: version-control-skill
description: Enable AI agents to efficiently query history, compute differences, and follow safe workflows across version control systems.
metadata: 
    author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
    version : "1.0"
license: Apache 2.0
allowed-tools : bash git hg svn  
user-invocable: true
disable-model-invocation: true
---

# Version Control - Activity Skill

## Purpose
Enable AI agents to efficiently query history, compute differences, and follow safe workflows across version control systems.


## Core Principles

1. Enforce hard-gate safety checks before modification operations.
2. Prefer read-only operations for history exploration.
3. Keep user time-range inputs as: today, yesterday, last week; normalize them internally to concrete timestamps before command execution.
4. Generate outputs in a consistent, human-readable format.
5. Delegate actual command execution to VCS-specific references.
6. Auto-detect VCS backend from repository markers (`.git`, `.hg`, `.svn`); if ambiguous, ask user and do not guess.


## Scenarios

### 1. Generate Change Logs

#### Inputs
- Time range:
  - today
  - yesterday
  - last week

#### Flow
1. Resolve the time range into concrete start and end timestamps.
2. Query commit history within the range.
3. Extract:
   - commit identifier
   - author
   - timestamp
   - message
4. Format output as chronological log (latest first preferred).

#### Output Format
Will be as per the version control that you are using.

### 2. Log Between Two Branches

#### Assumption
Branches share a common ancestor.

No explicit pre-check is required; rely on version control command outcomes.

#### Inputs
- source branch
- target branch

#### Flow
1. Identify commits reachable from one branch and not the other.
2. Direction:
   - changes in source not in target
3. Retrieve commit metadata.
4. Present ordered list.

#### Output Format
Same as change logs.

---

### 3. Generate Unified Diff Between Two Branches

#### Inputs
- base branch
- comparison branch

#### Flow
1. Resolve both branches to their latest revisions.
2. Compute differences between trees.
3. Generate unified diff format:
   - file paths
   - additions (+)
   - deletions (-)

#### Output Format
Standard unified diff format

---

### 4. Ensure Safe Working State Before Modification

#### Flow
1. Check if local working copy is clean.
2. Synchronize with remote repository when a remote is configured.
3. If no remote is configured, treat synchronization as not applicable.
4. If dirty working copy or synchronization/conflict checks fail, stop immediately (hard gate).
5. Only then allow further operations (outside scope).

---

## Error Handling

- If branches do not share a common ancestor → abort with explanation.
- If working directory is dirty for a modification flow → stop immediately (hard gate).
- If time range yields no commits → return empty result.
- If repository backend is ambiguous (multiple of `.git`, `.hg`, `.svn`) → ask user to choose backend; do not guess.
- For command errors, return raw command output and add an extra comment to help user resolve the error.

---

## References

- See `/references/git.md` for using Git version control
- See `/references/hg.md` for using Mercurial (hg) version control
- See `/references/subversion.md` for using Subversion version control

Each reference maps these flows to concrete commands for specific version control system.
