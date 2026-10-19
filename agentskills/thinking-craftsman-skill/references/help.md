# Thinking Craftsman Coding Skill Help

## Purpose

Thinking Craftsman Coding Skill provides language- and technology-independent principles for generating and reviewing software. It helps keep changes focused, respect existing design decisions, handle errors explicitly, and produce code that is clear and difficult to misuse. During review, it evaluates the applicable mandatory, preferred, and review-only guidelines and reports concrete findings with rationale.

The skill can guide implementation as well as review. It does not replace project-specific specifications, conventions, tests, or language-specific guidance; those should be consulted when relevant.

## Common checks

- **Requirements and context:** Read the task, relevant specifications, design decisions, and code comments before proposing or reviewing changes. Surface uncertainty rather than guessing.
- **Scope and compatibility:** Keep changes focused, preserve existing behavior and public APIs unless a change is requested, follow project conventions, and avoid unrelated edits or dependencies.
- **Boundaries and design:** Respect module boundaries and layering, avoid circular dependencies, and check derived classes against the expectations of their base classes.
- **Errors and inputs:** Handle errors explicitly, avoid silently swallowed exceptions, validate assumptions, and fail fast when inputs or conditions are invalid.
- **Function and class design:** Keep functions focused and understandable; avoid APIs that are easy to misuse, excessive object-internal access, and unnecessary mutable global state.
- **Complexity and side effects:** Look for unnecessary complexity, implicit assumptions, and unintended side effects such as overwrites, aliasing, or lifetime problems.
- **Review-only checks:** When reviewing, look for dead or redundant code and duplication. Treat these as review prompts, not automatic failures without a concrete issue.
- **Tests:** Check relevant happy paths, boundaries, invalid or null inputs, and expected errors. Prefer Arrange-Act-Assert tests, clear names, and isolated external dependencies.
- **Validation:** Validate the completed change with relevant tests or checks and report what was run and any gaps.

Mandatory rules are hard constraints by default; preferred guidelines are strong defaults that can be relaxed with justification; review-only items are inspection prompts and should not block code generation by themselves.

## Typical prompts

> Review this change using the Thinking Craftsman principles. Prioritize concrete defects and explain the evidence for each finding.

> Review `src/example.py` for correctness, error handling, and adherence to the Thinking Craftsman guidelines.

> Apply the Thinking Craftsman guidelines while implementing this feature. First inspect the relevant requirements and code, then propose a focused plan.

> Review the diff between my branch and `main`. Check behavior changes, public API compatibility, and newly introduced dependencies.

> Help me write tests for this function using Arrange-Act-Assert. Include boundary cases and expected errors.

> Explain what the Thinking Craftsman skill checks and give me some prompts I can use.
