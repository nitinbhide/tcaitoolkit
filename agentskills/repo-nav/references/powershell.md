# PowerShell Operations

Use this reference for PowerShell operations that supplement the authoritative `rg --files` inventory. PowerShell is for filesystem operations and comparisons that ripgrep cannot express, not for replacing repository discovery.

## Content Search

Use ripgrep (`rg`) to search file contents using regular expressions. Do not use PowerShell regex commands such as `Select-String` for file content searches when `rg` is available. Quote patterns containing spaces or regular-expression characters:

```powershell
rg -n "TODO|FIXEME|NOTE" .
rg -n "TODO|FIXEME|NOTE" docs -g "*.md"
```

## Path Handling

- Treat repository-relative paths as strings using `/` separators. Normalize a path with `.Replace([char]92, [char]47)` when needed; do not use `-replace '\\'` or other regex-based backslash replacement.
- Convert a normalized repository-relative path to a filesystem path only at the boundary with `Join-Path`, replacing `/` with `[char]92` there if required by Windows.
- Build `docmap.md` paths from the directory value with `Join-Path`.
- Check for null or empty directory values before calling `Test-Path` or `Join-Path`.
- Calculate depth only from normalized `/`-separated repository-relative paths.
- Exclude folders already merged into a parent from subsequent candidate selection.

## Allowed Operations

Use PowerShell for:

- byte-size checks with `Get-Item` or `[IO.File]::ReadAllBytes()`;
- array comparison and ordering with `Compare-Object` and `Sort-Object`;
- filesystem existence checks with `Test-Path`;
- immediate-directory checks with `Get-ChildItem` after the inventory has been established;
- merge bookkeeping and relative-path rewriting that `rg` cannot express.

Do not use PowerShell recursive enumeration as the initial repository scan. 
Do not create Python, Node.js, or other helper scripts for discovery or validation.
Do not user Powershell for searching contents based on regex. Use `rg` for searching the content using regex

## Validation Recovery

Run validation for the edited folder immediately after generation or merge. If a PowerShell validator reports a parsing, path, timeout, or null-value error, treat the result as inconclusive, simplify or repair the validator, and rerun the same focused check. Do not regenerate the docmap until the validator can discriminate pass from failure.
