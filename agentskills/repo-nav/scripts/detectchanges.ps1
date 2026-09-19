<#
.SYNOPSIS
Parses a folder-level docmap.md file and reports files whose recorded size no longer matches the current file system.

.DESCRIPTION
Uses ripgrep (`rg`) to extract the file entries and their sizes from a docmap.md file,
then compares those values against the actual files on disk in the same folder.
This supports repo-nav workflows where a docmap is treated as a snapshot of file sizes.

.EXAMPLE
./detectchanges.ps1 ../evals/docmap.md
#>
param(
    [string]$DocMapPath = "docmap.md",
    [switch]$Debug
)

# File paths inside the docmap are always interpreted relative to the parent
# directory of the provided docmap.md, so there is no separate RootPath parameter.

$ErrorActionPreference = "Stop"

if (-not (Get-Command rg -ErrorAction SilentlyContinue)) {
    throw "ripgrep ('rg') is required but was not found on PATH."
}

if (-not $DocMapPath) {
    throw "DocMapPath is required."
}

$resolvedDocMapPath = (Resolve-Path -LiteralPath $DocMapPath -ErrorAction Stop).Path
$folderRoot = Split-Path -Parent $resolvedDocMapPath

# Parse file-name and size lines in one pass, preserving their document order so
# each size is associated with the file entry immediately before it.
$docMapPattern = '^\s*-\s*(?:`(?<file>(?![^`]+/docmap\.md`)(?![^`/]+_MAP\.md`)[^`]+)`|Size\s*:\s*(?<size>\d+)\s+bytes)'

$docMapMatches = @(
    & rg --pcre2 -N -o $docMapPattern $resolvedDocMapPath
)

$recordedFiles = @{}
$docMapEntries = @()

$pendingFile = $null
foreach ($matchText in $docMapMatches) {
    $parsedMatch = [regex]::Match($matchText, $docMapPattern)

    if ($parsedMatch.Groups['file'].Success) {
        $fileName = $parsedMatch.Groups['file'].Value.Trim()
        if (-not [string]::IsNullOrWhiteSpace($fileName)) {
            $pendingFile = $fileName.Replace('\\', '/').Replace('\', '/')
        }
        continue
    }

    if ($parsedMatch.Groups['size'].Success -and $null -ne $pendingFile) {
        $size = [int]$parsedMatch.Groups['size'].Value
        $recordedFiles[$pendingFile] = $size
        $docMapEntries += [PSCustomObject]@{
            File = $pendingFile
            Size = $size
        }
        $pendingFile = $null
    }
}

$changes = @()
$liveFiles = @{}

# Use the same rg-based file filtering logic as filelist.ps1 so the docmap change
# detection follows the exact repo-nav inclusion/exclusion rules.
$rgArgs = @("--files")
$rgArgs += @(
    "--glob", "!\.*",
    "--glob", "!**/\.*",
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
$rgArgs += $folderRoot

$inventoryFiles = @( & rg @rgArgs )

foreach ($file in $inventoryFiles) {
    $fullFilePath = (Resolve-Path -LiteralPath $file -ErrorAction Stop).Path
    $baseFullPath = [System.IO.Path]::GetFullPath($folderRoot).TrimEnd([char]92, [char]47)
    $relative = if ($fullFilePath.StartsWith($baseFullPath, [System.StringComparison]::OrdinalIgnoreCase)) {
        $tmp = $fullFilePath.Substring($baseFullPath.Length)
        $tmp.TrimStart([char]92, [char]47)
    } else {
        [System.IO.Path]::GetFileName($fullFilePath)
    }
    $relative = $relative.Replace('\\', '/').Replace('\', '/')
    if (-not [string]::IsNullOrWhiteSpace($relative) -and $relative -ne 'docmap.md') {
        $liveFiles[$relative] = (Get-Item -LiteralPath $fullFilePath).Length
    }
}

foreach ($entry in $recordedFiles.Keys | Sort-Object) {
    $expectedSize = $recordedFiles[$entry]
    $fullPath = Join-Path $folderRoot $entry.Replace('/', [System.IO.Path]::DirectorySeparatorChar)

    if (-not (Test-Path -LiteralPath $fullPath)) {
        $changes += [PSCustomObject]@{
            File = $entry
            DocMapSize = $expectedSize
            ActualSize = 0
            Status = 'DELETED'
        }
        continue
    }

    $actualSize = $liveFiles[$entry]
    if ($null -eq $actualSize) {
        $actualSize = (Get-Item -LiteralPath $fullPath).Length
    }

    if ($actualSize -ne $expectedSize) {
        $changes += [PSCustomObject]@{
            File = $entry
            DocMapSize = $expectedSize
            ActualSize = $actualSize
            Status = 'MODIFIED'
        }
    }
}

foreach ($entry in ($liveFiles.Keys | Sort-Object)) {
    if (-not $recordedFiles.ContainsKey($entry)) {
        $changes += [PSCustomObject]@{
            File = $entry
            DocMapSize = 0
            ActualSize = $liveFiles[$entry]
            Status = 'ADDED'
        }
    }
}

if ($Debug) {
    Write-Host "Detected files from docmap:"
    if ($docMapEntries.Count -gt 0) {
        $docMapEntries | Sort-Object File | ForEach-Object {
            Write-Host ("  {0} : {1} bytes" -f $_.File, $_.Size)
        }
    } else {
        Write-Host "  (none)"
    }

    Write-Host ""
}

if (-not $changes) {
    Write-Host "No changed files detected for $resolvedDocMapPath"
    return
}

$markdownRows = @(
    "| Filename | Size in DocMap | Actual Size | Status |",
    "| --- | ---: | ---: | --- |"
)

foreach ($change in ($changes | Sort-Object File)) {
    $markdownRows += "| $($change.File) | $($change.DocMapSize) | $($change.ActualSize) | $($change.Status) |"
}

$markdownRows | ForEach-Object { Write-Host $_ }
