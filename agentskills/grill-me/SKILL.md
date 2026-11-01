---
name: grill-me
description: Interview the user about natural-language documents to clarify ambiguities, conflicts, and missing details until reaching shared understanding. Use when the user wants to stress-test a document or says "grill me". (Copied from Grill-me skill of mattpocock
origin: https://github.com/mattpocock/skills/tree/main/skills/productivity/grill-me
author:
    - mattpocock (updated by Nitin Bhide)
license: MIT
---

## Purpose
The purpose of the grill-me skill is to interview the user about natural-language documents to clarify ambiguities, conflicts, and missing details until a shared understanding is reached. It is particularly useful for stress-testing documents and ensuring comprehensive coverage of important aspects.

Grill-me is for natural-language text, not standalone source code, diagrams, CAD files, or other non-prose material. 

## Steps

1. Interview me about the important aspects of the provided natural-language document or documents until we reach a shared understanding. This applies to specifications, designs, use cases, plans, and other prose in any domain. Follow dependencies between decisions one at a time. For each question, provide one recommended answer with a brief rationale; mention alternatives only when they are genuinely useful.

2. Use 'why', 'how', 'when', 'what', and 'who' as helpful prompts for deeper analysis, not as mandatory wording or criteria for every question.

3. Ask the questions one at a time.

4. If a question can be answered by inspecting relevant available materials, inspect them instead of asking the user. For conflicting documents, cite the conflicting statements and explain their impact. Check for an authoritative source when available; if precedence remains unclear, ask the user to resolve it rather than silently choosing.

5. If non-prose material can be understood together with the surrounding text, analyze them together; otherwise, tell the user that separate review is required.

6. Continue until the important ambiguities, conflicts, and missing decisions have been discussed and the user confirms the shared understanding. Then create a separate `<docname>_clarifications.md` file containing the agreed clarifications and any unresolved items. Save it in the same folder as the original file. For multiple source files, use a topic-based filename and the folder of the first selected file. If the source is pasted text without a source folder, ask where to save it.

7. After creating the clarifications file, ask the user to choose whether to update the original with the agreed clarifications and add a link to the clarifications file at the end, or leave the original's content unchanged and add only a link to the clarifications file at the end.

## Help
If the user asks for help with the grill-me skill, read and show the relevant content from [references/help.md](./references/help.md).
