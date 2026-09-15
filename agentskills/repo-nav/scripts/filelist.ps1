<#
.SYNOPSIS
Generates a Markdown table listing repository files and their sizes.

.DESCRIPTION
Uses ripgrep (`rg --files`) as the authoritative repository inventory and then
uses PowerShell to inspect file sizes. This matches the repo-nav workflow, where
`rg` is used for file discovery and PowerShell is used only for validation or
metadata operations that `rg` cannot express directly.

When a baseline file is supplied, the script compares the current inventory against
that baseline and reports files that were added, modified, or deleted based on
file size changes. This is used by the repo-nav skill to decide which files need
index updates.

.EXAMPLE
./filelist.ps1 .

.EXAMPLE
./filelist.ps1 . output.md

.EXAMPLE
./filelist.ps1 . output.md -CompareToFile previous.md
#>
param(
    [string]$Path = ".",
    [string]$OutputFile = "",
    [string]$CompareToFile = "",
    [switch]$OnlyChanged
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
$files = @(
    & rg --files `
        "$resolvedPath"
)

# Filter known agent metadata files after discovery.
$files = $files | Where-Object {
    $_ -notmatch '(^|[\\/])(AGENTS\.md|CLAUDE\.md)$'
}

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

if ($CompareToFile) {
    $baseline = @{}
    if (Test-Path -LiteralPath $CompareToFile) {
        $lines = Get-Content -LiteralPath $CompareToFile
        foreach ($line in $lines) {
            if ($line -match '^\|\s*(.+?)\s*\|\s*(\d+)\s*\|$') {
                $baseline[$matches[1].Trim()] = [int]$matches[2]
            }
        }
    }

    $changedRows = @()
    foreach ($row in $rows) {
        $currentSize = $row.SizeBytes
        $previousSize = $baseline[$row.File]
        if ($null -eq $previousSize) {
            $changedRows += [PSCustomObject]@{ File = $row.File; SizeBytes = $currentSize; Change = 'ADDED' }
        }
        elseif ($previousSize -ne $currentSize) {
            $changedRows += [PSCustomObject]@{ File = $row.File; SizeBytes = $currentSize; Change = 'MODIFIED' }
        }
    }

    foreach ($key in $baseline.Keys) {
        $exists = $rows | Where-Object { $_.File -eq $key }
        if (-not $exists) {
            $changedRows += [PSCustomObject]@{ File = $key; SizeBytes = $baseline[$key]; Change = 'DELETED' }
        }
    }

    $markdown = @(
        "| File | Size (bytes) | Change |",
        "| --- | ---: | --- |"
    ) + ($changedRows | Sort-Object { $_.File } | ForEach-Object {
        "| $($_.File.Replace('|', '\\|')) | $($_.SizeBytes) | $($_.Change) |"
    })

    $markdownText = $markdown -join [Environment]::NewLine
}
else {
    $markdown = @(
        "| File | Size (bytes) |",
        "| --- | ---: |"
    ) + ($rows | ForEach-Object {
        "| $($_.File.Replace('|', '\\|')) | $($_.SizeBytes) |"
    })

    $markdownText = $markdown -join [Environment]::NewLine
}

if ($OutputFile) {
    $markdownText | Set-Content -Path $OutputFile -Encoding UTF8
}
else {
    $markdownText
}
