# Coding Agent Working Rules
Strictly follow these rules. DO NOT VIOLATE UNDER ANY CIRCUMSTANCES.

# Working Rules
- Make small, focused changes.
- Preserve behavior unless the task explicitly requires a change.
- Do not change public APIs unless instructed.
- Follow existing project patterns before introducing new ones.
- Write the unit tests before making any changes.
- Run the unit tests and ensure that all tests are passing after making any changes.
- Do not overwrite any file in `docs/` folder.
- Modify files in `docs/` folder only when explicitly told by user. Do not modify on your own.

### DO NOT
- implement anything that conflicts with approved specs or architecture decisions.
- Rewrite large parts of the codebase unless explicitly asked.
- Reformat unrelated files.
- Remove TODOs/comments without addressing their intent.
- Assume undocumented behavior is safe to change.
- Generate or modify files that I did not explicitly ask.

### When Unsure
- Ask for clarification instead of guessing.
- Briefly state trade-offs in review notes.

## Code Generation Instructions
- Use the 'thinking craftsman skill' and generate the code compliant with the Thinking Craftsman Coding Guidelines
- Follow this project's coding guidelines first, then apply thinking craftsman guidelines.
- Add the "Purpose" code comment to start of any new source code file that you generate. Describe what is the purpose of this file or class implemented/declared in this file.
- Add an entry for the new source code file in `docs/design/sourcemap.md`. The entry must contain the name of the source code file (path relative to project root) and the purpose of the file.
- Use `sourcemap.md` to decide which existing files to modify.
- Analyze the changes in specifications and design documents using the version control diff command then update the code for differences in the specification and design documents.

## Code Review Instructions
- Use the  'thinking craftsman skill' for reviewing code and ensure that code is compliant with 'thinking craftsman coding guidelines' 
- Follow this project's review guidelines first, then apply thinking craftsman guidelines.
