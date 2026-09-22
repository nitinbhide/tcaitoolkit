# `rg` (ripgrep) for Search and Validation of files

# Search Strategy
When searching the project folder structure/codebase, prefer `rg` (ripgrep) for both file discovery and content search over other tools.

Use `rg -h` (or `rg --help`) to view the help and available options for ripgrep.

Use this priority order:

1. `rg --files` (file discovery)
2. `rg <pattern>` (content search)
3. `rg --files | rg <pattern>` (filename search)

Use `rg --files` as the first and authoritative repository-discovery command. Do not use `Get-ChildItem`, `find`, or equivalent recursive file discovery unless you first verify that `rg` is unavailable. You may use PowerShell only after discovery for file sizes, directory existence, or operations that `rg` cannot express.

**Core search patterns**

- Use `rg -n "<pattern>" <path>` to include line numbers in matches.
- Use `rg -i "<pattern>" <path>` for case-insensitive searches.
- Use `rg -S "<pattern>" <path>` for smart-case matching.
- Use `rg -F "<literal text>" <path>` when the search text must not be interpreted as a regular expression.
- Use `rg -w "<word>" <path>` to match a complete word.
- Use `rg -C 3 "<pattern>" <path>` to show three lines of context around each match.
- Use `rg -l "<pattern>" <path>` to return only matching file names.

**Marker search examples**

- Search one file for TODO, FIXEME, or NOTE markers: `rg -n "TODO|FIXEME|NOTE" README.md`
- Search a folder recursively, ignoring case: `rg -n -i "TODO|FIXEME|NOTE" .`
- Search only Markdown files under a folder named "docs" : `rg -n "TODO|FIXEME|NOTE" docs -g "*.md"`

**Scope searches deliberately**

- Use `-t <type>` for recognized file types, such as `rg -t py` or `rg -t md`.
- Use `rg -g "<glob>"` to include or exclude paths, such as `rg -g "*.md"` or `rg -g "!**/node_modules/**"`.
- Search a specific folder whenever the owning area is known instead of rescanning the repository root.
- In PowerShell, quote patterns containing spaces or regular-expression characters such as `|`, `(`, and `)`.

**Ignore and hidden files**

`rg` automatically honors `.gitignore` and other ignore files. Keep the default behavior for repository analysis. 

`rg` automatically ignores the binary files (e.g. .dll, .so, .exe, .zip etc). DO NOT add additional filters to ignore binrary files.

Treat the repository’s ignore files as authoritative and avoid reproducing their patterns.

Minimize repeated repository scans and prefer targeted, file-type- or glob-filtered `rg` queries. Use `rg --files` to establish the searchable file set before content searches when repository scope is unclear.

Use the following flag only when task **EXPLICITLY** requires them
- Use `--hidden` to include hidden files, 
- `--no-ignore` to bypass ignore rules, 
- `-uu` to include both hidden and ignored files 

## Repository Scan Contract

- Check availability first: use `Get-Command rg -ErrorAction SilentlyContinue` on Windows PowerShell or `command -v rg` on Unix-like shells.
- When available, establish one authoritative inventory with `rg --files` and retain it for grouping, candidate selection, metadata extraction, and final checks. Do not rescan the repository for each phase.
- `rg --files` already honors `.gitignore`, `.ignore`, and `.git/info/exclude`. Do not copy repository ignore patterns into additional globs. The only normal workflow-specific exclusion is `--glob '!**/docmap.md'` when generated indexes must be omitted from the input inventory.
- Apply file-type, hidden-name, configuration, binary, `AGENTS.md`, and `CLAUDE.md` eligibility filtering after discovery. Do not replace the authoritative inventory with recursive PowerShell enumeration.
- Keep discovery, folder selection, metadata extraction, index generation, and validation as separate phases. A validation command must consume the selected folder or retained inventory; it must not silently perform a new full-repository scan.
- If `rg` is unavailable, use the platform-native fallback only: `Get-ChildItem -Recurse -File` and `Select-String` on Windows, or `find` and `grep` on Unix-like systems. Keep fallback searches scoped and honor ignore rules where supported.

### Listing existing docmap files
- Use `rg --files -g "{docmap,DOCMAP}.md"` to list all the existing docmap files in the repository.

## Ripgrep Validation Contract

- Use `rg -n` for marker discovery and `rg --only-matching` for child-link extraction. Do not parse child links with `[regex]::Matches`.
- Extract child links with a line-oriented pattern such as `rg --no-filename --only-matching '^- `[^`]+/docmap\.md`' <docmap>`. Use the shell only to remove the Markdown wrapper and compare arrays.
- Validate the exact relative `child/docmap.md` strings and their lexicographic order. A link to a pending child index is valid; child-index existence must not be treated as a validation failure.
- Validate one edited folder immediately after generation or merge. Check direct file inventory, marker lines, child links, and absorbed-folder removal with targeted `rg` queries before selecting another folder.
- If a validation command fails because of parsing, path, timeout, or null-value handling, classify it as inconclusive, repair the command, and rerun the same focused check. Do not regenerate the index until the check is discriminating.
