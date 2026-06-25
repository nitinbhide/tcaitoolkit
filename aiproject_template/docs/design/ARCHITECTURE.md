# ARCHITECTURE OF {{PROJECT NAME}}

## Key Architecture Guidelines
Always follow the decisions in `ADR.md`

### Modules
- each folder in the `src/{{project}}` represents a module or a submodule
- modules must have acyclic dependency
- Higher layer modules can depend on lower layer module
- Modules in the Same layer cannot depend on each other

### Implementation guidelines
- Generate the top level file (containing the main or entry point function) for application in the `src/` folder.
- Generate and update package design diagram in `docs/design/packagedesign.md`. The file will be in markdown format with diagrams in mermaid.js format.

## Technology Stack
backend : 
frontend : 
build tool : 
unit test framework : 

## Technolgy stack specific instructions for Code generation

