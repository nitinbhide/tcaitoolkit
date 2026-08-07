# ARCHITECTURE OF {{cookiecutter.proj_full_name}}

## Key Architecture Guidelines
Always follow the decisions in `ADR.md`

### Modules
- each folder in the `src/{{cookiecutter.proj_name}}` represents a module or a submodule
- modules must have acyclic dependency
- Higher layer modules can depend on lower layer module
- Modules in the Same layer cannot depend on each other

### Implementation guidelines
- Generate the top level file (containing the main or entry point function) for application in the `src/` folder.
- Generate and update package design diagram in `docs/design/packagedesign.md` when a new package is added to the system. The file will be in markdown format and diagrams in mermaid.js format.

## Technology Stack
backend : 
frontend : 
build tool : 
unit test framework : 
web server : (tomcat, apache, nginx)
Other tools/libraries/frameworks : (bootstrap, tailwind, )
package managers:

## Technolgy stack specific instructions for Code generation

## Development Setup
IDE : 

## Deployment Setup
_Desktop installer, docker deployment, etc etc
Operating System : 

## Design Documents
- `docs/design/sourcemap.md` : list of source code files and their purpose. Use this information to decide which files to modify or update during the code generation.
