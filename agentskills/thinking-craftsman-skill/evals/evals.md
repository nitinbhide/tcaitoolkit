# Skil evaluation tests for Thinking Craftsman Skill

**Eval Id** : Test 1
**prompt**: Review the test.py file using guidelines from "thinking-craftsman-skill" and identify the potential issues. Report only issues. Do not output anything else.
**inputs** : ./test.py
**expected output**: similar to
- [./evals/test.py:4] The function `dead_code` is defined but never called. This is considered dead code.
- [/evals/test.py:5] The code inside the `if False:` block will never be executed. This is considered dead code.
