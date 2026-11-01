# Grill-me skill clarifications

These clarifications record the agreed behavior for the grill-me skill.

## Scope

- Grill-me is domain-neutral and is intended for natural-language documents, including specifications, designs, use cases, plans, and other prose.
- Do not analyze source code, diagrams, or CAD files as standalone inputs.
- When non-prose material can be understood together with the surrounding natural-language text, analyze the material together. Otherwise, state that it requires separate review.

## Interview behavior

- Ask one question at a time and follow dependencies between decisions.
- Use “why,” “how,” “when,” “what,” and “who” as helpful prompts, not mandatory criteria or wording.
- For each question, give one recommended answer with a brief rationale. Mention alternatives only when they are genuinely useful.
- Inspect relevant available materials before asking questions that those materials may answer.
- For conflicting documents, cite the conflicting statements and explain their impact. Check for an authoritative source when available. If precedence remains unclear, ask the user to decide rather than silently choosing.
- Continue until the important ambiguities, conflicts, and missing decisions have been discussed and the user confirms the shared understanding.

## Clarifications document and source follow-up

- After the user confirms the shared understanding, create a separate `<docname>_clarifications.md` file containing the agreed clarifications and any unresolved items.
- Save it in the same folder as the original file. For multiple source files, use a topic-based filename and the folder of the first selected file. If the source is pasted text without a source folder, ask where to save it.
- After creating the clarifications file, ask the user to choose one of these source-document actions:
  1. Update the original with the agreed clarifications and add a link to the clarifications file at the end.
  2. Leave the original's content unchanged and add only a link to the clarifications file at the end.
