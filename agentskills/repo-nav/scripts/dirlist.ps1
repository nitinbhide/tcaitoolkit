<#
.SYNOPSIS
Lists directories containing repository files in a Markdown table.

.DESCRIPTION
Uses the same file inventory and rules as filelist.ps1 (ripgrep discovery,
hidden paths and repo-nav documentation files excluded, empty files skipped),
then outputs each directory's depth and direct file count, deepest first.

.EXAMPLE
./dirlist.ps1 .

.EXAMPLE
./dirlist.ps1 . output.txt -Glob "*.{ps1,md}" -Recurse
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

$folderCounts = @{}
foreach ($file in $files) {
    $item = Get-Item -LiteralPath $file
    if ($item.Length -gt 0) {
        $folder = $item.DirectoryName
        if (-not $folderCounts.ContainsKey($folder)) {
            $folderCounts[$folder] = 0
        }
        $folderCounts[$folder]++
    }
}

$root = $resolvedPath.TrimEnd([char[]]@('\', '/'))
$rootPrefix = if ($root.Length -eq 0) {
    [System.IO.Path]::DirectorySeparatorChar.ToString()
}
else {
    $root + [System.IO.Path]::DirectorySeparatorChar
}

$rows = @(
    foreach ($folder in $folderCounts.Keys) {
        if ($folder -eq $resolvedPath) {
            $depth = 0
        }
        else {
            $relativeFolder = $folder.Substring($rootPrefix.Length)
            $depth = @($relativeFolder -split '[\\/]' | Where-Object { $_ }).Count
        }

        [PSCustomObject]@{
            Depth = $depth
            FolderPath = $folder
            DirectFilesCount = $folderCounts[$folder]
        }
    }
) | Sort-Object @{ Expression = 'Depth'; Descending = $true }, @{ Expression = 'FolderPath'; Descending = $false }

$markdown = @(
    "| Depth | Folder Path | Direct Files Count |",
    "| ---: | --- | ---: |"
) + ($rows | ForEach-Object {
    $displayPath = $_.FolderPath.Replace('|', '\|')
    "| $($_.Depth) | $displayPath | $($_.DirectFilesCount) |"
})
$markdownText = $markdown -join [Environment]::NewLine

if ($OutputFile) {
    $markdownText | Set-Content -Path $OutputFile -Encoding UTF8
}
else {
    $markdownText
}
