# AGENTS.md for Thinking Craftsman AI Toolkit

This file is for AI Agents working on this project. [README.md](./README.md) is for Humans working on this project.

# Overview
This project is a set of utilities to help human software developers adopt AI Coding Agents in their existing or new projects. This is developed by [Nitin Bhide](https://thinkingcraftsman.in)

## Project Structure

- `doc/` - documents folder
- `doc/agentskills/` - folder for specification and design documents of various Agent Skills
- `agentic_cc/` - source of python cookie cutter to generate the folder structure for a new project. Use this when you want to start a new project with use of AI Coding Agents from the day one.
- `agentskills/` - Useful agent skills like grill-me, repo-nav, agent-audit, thinking-craftsman-skill for coding and code reviews etc.

## Testing Bash Scripts from Windows with WSL

- Windows checkouts may give shell scripts CRLF line endings, which can make WSL Bash fail with errors such as `$'\r': command not found` or a syntax error near `in\r`. Do not change tracked line endings just to test. Normalize temporary copies with `sed 's/\r$//'`.
- If a script sources helpers or reads other files using paths relative to itself, copy the script and its dependencies to a temporary directory while preserving their relative directory structure. Invoke temporary scripts with `bash "$tmp_dir/path/to/script.sh"`; the copies may not have executable permissions.
- For syntax checks, run `bash -n` on each normalized copy. For behavior checks, run the normalized script with `bash` against a temporary fixture and clean up the fixture afterward.
- When launching a multiline Bash test from PowerShell, pass it to WSL as one argument. Encode the here-string before invoking `wsl.exe` to avoid PowerShell native-argument splitting or expansion:

	```powershell
	$encoded = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($bashCmd))
	wsl.exe bash -lc "printf '%s' '$encoded' | base64 -d | bash"
	```

- Check that WSL provides required commands and features before interpreting a runtime test failure as a script regression. For example, verify ripgrep's PCRE2 support with `printf x | rg --pcre2 -e x >/dev/null` before testing scripts that use `rg --pcre2`.

   
## Installation
For now, no instructions on installation. Users should use [README.md](./README.md)
