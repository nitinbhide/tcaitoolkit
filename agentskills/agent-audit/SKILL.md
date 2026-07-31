---
name: agent-audit
description: Evaluates AGENTS.md and all the files referenced by AGENTS.md for predefined quality criteria. The objective is to improve the effectiveness of AGETNS.md file and reduce the overall token consumption.
metadata: 
    author: Nitin Bhide (nitinbhide@thinkingcraftsman.in)
    version : "1.0"
license: Apache 2.0
allowed-tools : bash 
user-invocable: true
disable-model-invocation: true
---
# Agent Audit Skill

This skill evaulates AGENTS.md file at the root of the project for following criteria. Objective is to improve the quality of results fromLLMs, reduce the number of turns in agent loop and reduce the LLM token consumptions 

## How to Audit the AGENTS.md file
- Use the "evaluation criteria" given below and check each item the list
- Check all the files refered in the AGENTS.md for evaluation. Do not check Directories/folders.
- Output the results are criteria fulfilled or not fulfilled.

## Evaluation criteria

- [ ] It should give a one or two paragraph description about the project at the start.
- [ ] There must 'project structure' or 'repository structure' defined in the AGENTS.md. 
  - This project structure should refer the relative directory or file paths.
  - It should refere to 'index' files for documents like specifications, design and architecture, test plans etc
- [ ] It should define basic working rules for the project. The working rules can be in file refered in the AGENTS.md
- [ ] The AGENTS.md file size must be less 250 lines
- Check if the AGENTS.md refers the DESIGN.md file. If not, recommend the user to define a DESIGN.md file
- [ ] If the project is using relational database, check that AGENTS.md refers to a file that documents the schema (tables, index, views etc) for relational database
- [ ] It should document the technology stack (programming language, build system, unit test framework, webserver, thirdparty packages etc).
  - Usually 'technology stack' should documents desired versions of various tools, packages, languages 
  - The technology stack can be documented in a dedicated stack document or in an architecture/design document such as `ARCHITECTURE.md`.
  - Mark this criterion as fulfilled if AGENTS.md refers to that document and the referenced document contains the technology stack details.
- [ ] It should document the list of packages/libraries/modules and their expected dependencies. 
  - The package dependencies are usually documented as mermaid diagram
  - The technology stack can be documented in a dedicated document or in an architecture/design document such as `ARCHITECTURE.md`
  - Mark this criterion as fulfilled if AGENTS.md refers to that document and the referenced document contains the package depedency details.
  