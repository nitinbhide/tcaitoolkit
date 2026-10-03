<#
.SYNOPSIS
Returns the repo-nav file inventory for a directory.

.DESCRIPTION
Uses ripgrep (`rg --files`) as the authoritative source for file discovery so
repository ignore rules are honored consistently. The shared inventory excludes
hidden paths and repo-nav documentation or agent-instruction files. Callers can
use the returned paths for metadata operations such as measuring file sizes.

By default, only files directly inside the specified directory are returned.
Use -Recurse to include files in descendant directories, and -Glob to apply an
additional ripgrep glob filter.

.PARAMETER Path
Directory to inventory.

.PARAMETER Glob
Optional ripgrep glob used to further filter the inventory.

.PARAMETER Recurse
Includes files from descendant directories when specified.

.OUTPUTS
System.String. Paths returned by ripgrep for matching files.

.EXAMPLE
Get-RepoNavFileInventory -Path . -Recurse -Glob '*.ps1'
#>
function Assert-RipgrepAvailable {
    if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
        throw "ripgrep ('rg') is required but was not found on PATH."
    }
}

function Get-RepoNavFileInventory {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Path,
        [string]$Glob = "",
        [switch]$Recurse
    )

    Assert-RipgrepAvailable

    $resolvedPath = (Resolve-Path -Path $Path).Path
    $rgArgs = @("--files")
    if (-not $Recurse) {
        $rgArgs += @("--max-depth", "1")
    }
    if ($Glob) {
        $rgArgs += @("--glob", $Glob)
    }
    $rgArgs += @(
        "--glob", "!\.*",
        "--glob", "!**/\. *",
        "--glob", "!**/\.*/**",
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

    @(& rg @rgArgs)
}