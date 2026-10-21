# Documents Index for TC AI Toolkit

## Documents of Agent Skills
Implementation of these specification and design documents are in folder `/agentskills`

### `repo-nav` agent skill.

The implementation of skill is in folder `/agentskills/repo-nav/ 

- `./agentskills/repo-nav/repo-nav-spec.md` : Specification document for repository navigation documents generation AI Agent Skill (repo-nav Agent Skill)
- `./agentskills/repo-nav/repo-nav-design.md` : Algorithms and logic used in "repo-nav" Agent skill
- `./agentskills/repo-nav/detectchanges-spec.md` : Specification and algorithm document of "detectchanges" script in repo-nav spec. "detectchanges" script (`detectchanges.ps1` and `detectchanges.sh`) is used to extract the source and documentatino files and their sizes from a docmap file (`docmap.md` and `DOCMAP.md`) and compare with the files on the disk. Then identify which files are modified, new files added or deleted.