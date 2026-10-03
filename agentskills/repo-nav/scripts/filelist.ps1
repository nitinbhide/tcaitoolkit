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
. (Join-Path $PSScriptRoot "fileinventory.ps1")
Assert-RipgrepAvailable

$utf8Encoding = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8Encoding
[Console]::OutputEncoding = $utf8Encoding
$OutputEncoding = $utf8Encoding

$resolvedPath = (Resolve-Path -Path $Path).Path

$files = @(Get-RepoNavFileInventory -Path $resolvedPath -Glob $Glob -Recurse:$Recurse)

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
    if ($item.Length -gt 0) {
        [PSCustomObject]@{
            File = $item.FullName
            SizeBytes = $item.Length
        }
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
