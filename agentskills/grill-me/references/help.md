# Grill-me skill

Use the grill-me skill to clarify and stress-test written plans and designs through a focused interview. It is especially useful for:

- **Software specifications:** resolve ambiguous requirements, user flows, constraints, and acceptance criteria.
- **Design documents:** explore design choices, dependencies, trade-offs, and open decisions until there is a shared understanding.
- **Markdown documentation:** compare related documents and identify statements that conflict or do not agree.
- **Under-specified documents:** find decisions or details that are missing, vague, or need more explanation.

Name the document or documents you want to examine and describe your goal. The skill asks questions one at a time and recommends an answer for each. If a question can be answered by examining the codebase, it explores the codebase instead of asking you. It does not analyze source-code files; if given one, it will say so and stop.

## Sample prompts

- “grill-me on `<document>`”
- “Grill me on `docs/specs/account-recovery.md`. Ask one question at a time and recommend an answer for each.”
- “Interview me about this design document until we agree on the architecture and its trade-offs.”
- “Compare the Markdown files in `docs/specs/` and `docs/design/`. Find conflicting statements, cite the documents, and ask me about each conflict one question at a time.”
- “Review this specification for details that are missing or too vague to implement. Ask me about each important gap and recommend what to specify.”