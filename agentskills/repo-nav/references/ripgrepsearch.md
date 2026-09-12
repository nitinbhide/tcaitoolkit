# `rg' (ripgrep) use to search the files

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

**Scope searches deliberately**

- Use `-t <type>` for recognized file types, such as `rg -t py` or `rg -t md`.
- Use `rg -g "<glob>"` to include or exclude paths, such as `rg -g "*.md"` or `rg -g "!**/node_modules/**"`.
- Search a specific folder whenever the owning area is known instead of rescanning the repository root.
- In PowerShell, quote patterns containing spaces or regular-expression characters such as `|`, `(`, and `)`.

**Ignore and hidden files**

`rg` automatically honors `.gitignore` and other ignore files. Keep the default behavior for repository analysis. Use `--hidden` to include hidden files, `--no-ignore` to bypass ignore rules, or `-uu` to include both hidden and ignored files only when the task explicitly requires them.

Treat the repository’s ignore files as authoritative and avoid reproducing their patterns.

Minimize repeated repository scans and prefer targeted, file-type- or glob-filtered `rg` queries. Use `rg --files` to establish the searchable file set before content searches when repository scope is unclear.
