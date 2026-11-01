# Documents Index for TC AI Toolkit

## Documents of Agent Skills
Implementation of these specification and design documents are in folder `/agentskills`

### `repo-nav` agent skill.

The implementation of skill is in folder `/agentskills/repo-nav/`

- `./agentskills/repo-nav/repo-nav-spec.md` : Specification document for repository navigation documents generation AI Agent Skill (repo-nav Agent Skill)
- `./agentskills/repo-nav/repo-nav-design.md` : Algorithms and logic used in "repo-nav" Agent skill
- `./agentskills/repo-nav/detectchanges-spec.md` : Specification and algorithm document of "detectchanges" script in repo-nav spec. "detectchanges" script (`detectchanges.ps1` and `detectchanges.sh`) is used to extract the source and documentatino files and their sizes from a docmap file (`docmap.md` and `DOCMAP.md`) and compare with the files on the disk. Then identify which files are modified, new files added or deleted.

### grill-me skill

The purpose of the "grill-me" skill is to interview the user about natural-language documents to clarify ambiguities, conflicts, and missing details until a shared understanding is reached. It is particularly useful for stress-testing documents and ensuring comprehensive coverage of important aspects.

The implementation of skill is in folder `/agentskills/grill-me/`

- [Grill Me Clarification](./agentskills/grill-me/grill-me-clarification.md) Specificaition and clarification document for grill-me agent skill

### agent-audit skill

"agent-audit" skill evaluates the repository-root `AGENTS.md` to improve agent effectiveness and reduce unnecessary turns and token consumption. It reports recommendations only and never edits files.

The implementation of skill is in folder `/agentskills/agent-audit/`

- [Agent Audit Clarification](./agentskills/agent-audit/agent-audit-clarification.md) Specificaition and clarification document for Agent audit agent skill





