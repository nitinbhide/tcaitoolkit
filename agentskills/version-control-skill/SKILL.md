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

1. Always ensure working copy is synchronized before performing operations.
2. Prefer read-only operations for history exploration.
3. Use explicit time ranges or branch references when querying logs.
4. Generate outputs in a consistent, human-readable format.
5. Delegate actual command execution to VCS-specific references.


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
Will as per the version control that you are using.


### 2. Log Between Two Branches

#### Assumption
Branches share a common ancestor.

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
Standard unified diff.

---

### 4. Ensure Safe Working State Before Modification

#### Flow
1. Check if local working copy is clean.
2. Synchronize with remote repository.
3. Handle conflicts if detected.
4. Only then allow further operations (outside scope).

---

## Error Handling

- If branches do not share a common ancestor → abort with explanation.
- If working directory is dirty → warn before proceeding.
- If time range yields no commits → return empty result.

---

## References

- See `/references/git.md`
- See `/references/hg.md`
- See `/references/subversion.md`

Each reference maps these flows to concrete commands for specific version control system.s