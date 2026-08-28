# Designing Repository Indexing SKILL

## Need
There are many exising software projects. If we want to introduce coding agents to these projects, then we need a way to help Coding Agents **navigate** these project. Otherwise Coding Agents typically search (find/grep) in the source code files and try to make sense about the project. They may create 'agent memories' but these are usually not sufficient. This skill is an attempt to generate basic document source code navigation indices that a Coding Agent can use.

Following prompts were used in creating this skill.

## Prompts

- Help in me in writing a new agent skill. The purpose of the skill is to analyze existing code base, (source code, design documents, speficiation documents, plans, bugs/issues, test cases and test plans). Objective to create hierarchical index files. The index files should follow "progressive disclosure" principle. Each index file will contain filenames/paths and sumary of content of that file. The AI coding agents will use these index files to understand the code structure, design and take decisions about implementation. especially which files to read and modify.
- Ask me questions first. Then generate skeleton of skill file

- The expected output format is markdown 

- Initially analyze only content of repository. Do not go outside the repository 

- Summary should be 4-5 lines maximum. It is document purpose of the file and any other important meta data 

- Each folder will have a index file. Parent folder will have reference to child folders index files. I want to generate 'folder level' summary of contents of the folder. Parent folder will have reference to child folder index file name and the summary 

- the root level index file must have instructions on how the index is orgnalized and how AI coding agent should use the index. 

- Avoid hierarchy definitions like 
    |-- Index.md
    |--src/
    |      |--Index.md


- Prefer simpler format like
    - `Index.md` : <purpose of file>
    - `src/index.md` : purpose file 

## Guiding Principle
The index hierarchy is a navigation aid for AI coding agents, not a replacement for source code or documentation.
 
Agents should use index files to identify relevant folders and files before reading implementation artifacts. The objective is to minimize repository exploration while preserving sufficient architectural understanding to make correct implementation decisions.
What will be your strategy guideline for cross cutting indexes ? 
