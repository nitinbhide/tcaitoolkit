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

This skill evaulates AGENTS.md file at the root of the project for following criteria. Objective is to improve the quality of results from LLMs, reduce the number of turns in agent loop and reduce the LLM token consumptions 

## Evaluation criteria

- It should give a one or two paragraph description about the project at the start.
- There must 'project structure' or 'repository structure' defined in the AGENTS.md. 
  - This project structure should refer the relative directory or file paths.
  - It should refere to 'index' files for documents like specifications, design and architecture, test plans etc
- It should define basic working rules for the project. The working rules can be in file refered in the AGENTS.md
- The AGENTS.md file size must be less 250 lines
- Check if the AGENTS.md refers the DESIGN.md file. If not, recommend the user to define a DESIGN.md file
- 
  