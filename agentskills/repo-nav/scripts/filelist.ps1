<#
.SYNOPSIS
Generates a Markdown table listing repository files and their sizes.

.DESCRIPTION
Uses ripgrep (`rg --files`) as the authoritative repository inventory and then
uses PowerShell to inspect file sizes. This matches the repo-nav workflow, where
`rg` is used for file discovery and PowerShell is used only for validation or
metadata operations that `rg` cannot express directly.

The script emits a current repository inventory for the repo-nav workflow.

.EXAMPLE
./filelist.ps1 .

.EXAMPLE
./filelist.ps1 . output.md

.EXAMPLE
./filelist.ps1 . output.md -Glob "*.{ps1,md}"

.EXAMPLE
./filelist.ps1 . output.md -Recurse

#>
param(
    [string]$Path = ".",
    [string]$OutputFile = "",
    [string]$Glob = "",
    [switch]$Recurse
)

$ErrorActionPreference = "Stop"

if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    throw "ripgrep ('rg') is required but was not found on PATH."
}

$resolvedPath = (Resolve-Path -Path $Path).Path

# Use rg --files as the authoritative repository inventory.
# rg already ignores VCS metadata folders such as .git, .hg, and .svn by default,
# so no additional glob-based ignore patterns are required for those directories.
# The inventory remains separate from PowerShell file-size inspection, as required
# by the repo-nav workflow.
$rgArgs = @("--files")
if (-not $Recurse) {
    $rgArgs += @("--max-depth", "1")
}
if ($Glob) {
    $rgArgs += @("--glob", $Glob)
}
$rgArgs += @(
    "--glob", "!.*",
    "--glob", "!**/.*",
    "--glob", "!**/.*/**",
    "--glob", "!AGENTS.md",
    "--glob", "!**/AGENTS.md",
    "--glob", "!CLAUDE.md",
    "--glob", "!**/CLAUDE.md",
    "--glob", "!DOCMAP.md",
    "--glob", "!**/DOCMAP.md",
    "--glob", "!docmap.md",
    "--glob", "!**/docmap.md",
    "--glob", "!*_MAP.md",
    "--glob", "!**/*_MAP.md"
)
$rgArgs += $resolvedPath

$files = @(
    & rg @rgArgs
)

if (-not $files) {
    $table = @"
| File | Size (bytes) |
| --- | ---: |
"@

    if ($OutputFile) {
        $table | Set-Content -Path $OutputFile -Encoding UTF8
    }
    else {
        $table
    }

    return
}

$rows = @(foreach ($file in $files) {
    $item = Get-Item -LiteralPath $file
    [PSCustomObject]@{
        File = $item.FullName
        SizeBytes = $item.Length
    }
}) | Sort-Object { $_.File }

$markdown = @(
    "| File | Size (bytes) |",
    "| --- | ---: |"
) + ($rows | ForEach-Object {
    "| $($_.File.Replace('|', '\\|')) | $($_.SizeBytes) |"
})

$markdownText = $markdown -join [Environment]::NewLine

if ($OutputFile) {
    $markdownText | Set-Content -Path $OutputFile -Encoding UTF8
}
else {
    $markdownText
}
