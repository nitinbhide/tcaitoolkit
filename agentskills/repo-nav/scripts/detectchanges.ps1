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

# Parse the docmap using rg in two passes: first collect file-name lines, then
# collect the corresponding "- Size : <n> bytes" lines. The repo-nav template uses
# this pattern in references/folderdocmap_tmpl.md and evals/docmap.md. File paths in
# the docmap are relative to the folder containing docmap.md, so $folderRoot is the
# parent directory of the provided docmap.
$docMapFilePattern = '^\s*-\s*`(?<file>[^`]+)`'
$docMapSizePattern = '^\s*-\s*Size\s*:\s*(?<size>\d+)\s+bytes'

$fileNameMatches = @(
    & rg --pcre2 -N -o $docMapFilePattern $resolvedDocMapPath
)
$sizeMatches = @(
    & rg --pcre2 -N -o $docMapSizePattern $resolvedDocMapPath
)

$rawMatches = @()
$maxCount = [Math]::Min($fileNameMatches.Count, $sizeMatches.Count)
for ($i = 0; $i -lt $maxCount; $i++) {
    $rawMatches += "$($fileNameMatches[$i])`n$($sizeMatches[$i])"
}

$recordedFiles = @{}
$docMapEntries = @()
foreach ($matchText in $rawMatches) {
    if ($matchText) {
        $fileMatch = [regex]::Match($matchText, '^\s*-\s*`(?<file>[^`]+)`', [System.Text.RegularExpressions.RegexOptions]::Multiline)
        $sizeMatch = [regex]::Match($matchText, '^\s*-\s*Size\s*:\s*(?<size>\d+)\s+bytes', [System.Text.RegularExpressions.RegexOptions]::Multiline)

        if ($fileMatch.Success -and $sizeMatch.Success) {
            $fileName = $fileMatch.Groups['file'].Value.Trim()
            $size = [int]$sizeMatch.Groups['size'].Value
            if (-not [string]::IsNullOrWhiteSpace($fileName)) {
                $normalized = $fileName.Replace('\\', '/').Replace('\', '/')
                $recordedFiles[$normalized] = $size
                $docMapEntries += [PSCustomObject]@{
                    File = $normalized
                    Size = $size
                }
            }
        }
    }
}

$changes = @()
$liveFiles = @{}

Get-ChildItem -Path $folderRoot -Recurse -File | Where-Object {
    $_.FullName -ne $resolvedDocMapPath
} | ForEach-Object {
    $baseFullPath = [System.IO.Path]::GetFullPath($folderRoot).TrimEnd([char]92, [char]47)
    $fullFilePath = [System.IO.Path]::GetFullPath($_.FullName)
# Use the same rg-based file filtering logic as filelist.ps1 so the docmap change
# detection follows the exact repo-nav inclusion/exclusion rules.
$rgArgs = @("--files")
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
$rgArgs += $folderRoot

$inventoryFiles = @( & rg @rgArgs )

foreach ($file in $inventoryFiles) {
    $fullFilePath = (Resolve-Path -LiteralPath $file -ErrorAction Stop).Path
    $baseFullPath = [System.IO.Path]::GetFullPath($folderRoot).TrimEnd('\\', '/')
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
