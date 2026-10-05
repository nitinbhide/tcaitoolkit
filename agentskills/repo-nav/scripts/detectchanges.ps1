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
. (Join-Path $PSScriptRoot "fileinventory.ps1")
Assert-RipgrepAvailable

$utf8Encoding = [System.Text.UTF8Encoding]::new($false)
[Console]::InputEncoding = $utf8Encoding
[Console]::OutputEncoding = $utf8Encoding
$OutputEncoding = $utf8Encoding

if (-not $DocMapPath) {
    throw "DocMapPath is required."
}

$nativeDocMapPath = ConvertTo-NativePath -Path $DocMapPath
# Docmap generation may have been interrupted; a missing docmap is not an error.
$docMapMissing = -not (Test-Path -LiteralPath $nativeDocMapPath -PathType Leaf)
if ($docMapMissing) {
    $resolvedDocMapPath = [System.IO.Path]::GetFullPath($nativeDocMapPath)
    $folderRoot = (Resolve-Path -LiteralPath (Split-Path -Parent $resolvedDocMapPath) -ErrorAction Stop).Path
} else {
    $resolvedDocMapPath = (Resolve-Path -LiteralPath $nativeDocMapPath -ErrorAction Stop).Path
    $folderRoot = Split-Path -Parent $resolvedDocMapPath
}

# Parse each file entry and its size as one multiline rg match. The two size
# locations cover both documented forms; the boundary prevents crossing into
# another backtick file entry.
$docMapPattern = '(?ms)^\s*-\s*`(?<file>(?![^`]+/docmap\.md`)(?![^`/]+_MAP\.md`)[^`]+)`(?:(?:[^\r\n]*?\(\s*Size\s*:\s*)|(?:(?!^\s*-\s*`).)*?^\s*-\s*Size\s*:\s*)(?<size>[\d,]+)\s+bytes'
$docMapReplacement = '${file}' + [char]9 + '${size}'

$docMapMatches = if ($docMapMissing) { @() } else {
    @(& rg --pcre2 -U -N -o --replace $docMapReplacement $docMapPattern $resolvedDocMapPath)
}

$recordedFiles = @{}
$docMapEntries = @()
foreach ($matchText in $docMapMatches) {
    $separatorIndex = $matchText.IndexOf("`t")
    $fileName = $matchText.Substring(0, $separatorIndex).Trim()
    $size = [int]($matchText.Substring($separatorIndex + 1).Replace(',', ''))
    $normalized = $fileName.Replace('\\', '/').Replace('\', '/')
    $recordedFiles[$normalized] = $size
    $docMapEntries += [PSCustomObject]@{
        File = $normalized
        Size = $size
    }
}

$changes = @()
$liveFiles = @{}

# Inventory the docmap folder and represented child folders without recursively
# including unrelated folders, which have their own docmaps.
# NOTE: All file filtering logic must live in Get-RepoNavFileInventory
# (fileinventory.ps1). Do not add filters (size, name, type) in this script.
if ($docMapMissing) {
    # Case 1: no docmap here, so every file in the tree is ADDED.
    $inventoryFiles = @(Get-RepoNavFileInventory -Path $folderRoot -Recurse)
} else {
    $inventoryFiles = @(Get-RepoNavFileInventory -Path $folderRoot)
}

$mergedFolders = @{}
foreach ($entry in $recordedFiles.Keys) {
    $separatorIndex = $entry.LastIndexOf('/')
    if ($separatorIndex -gt 0) {
        $mergedFolders[$entry.Substring(0, $separatorIndex)] = $true
    }
}

foreach ($mergedFolder in $mergedFolders.Keys) {
    $mergedFolderPath = Join-Path $folderRoot $mergedFolder.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
    $inventoryFiles += @(Get-RepoNavFileInventory -Path $mergedFolderPath)
}

# Case 2: immediate child folders that are not covered by this docmap and have
# no docmap of their own are new folders; report the folder and all its files.
if (-not $docMapMissing) {
    foreach ($dir in (Get-ChildItem -LiteralPath $folderRoot -Directory)) {
        $dirName = $dir.Name
        if ($dirName.StartsWith('.')) { continue }
        $covered = $false
        foreach ($mergedFolder in $mergedFolders.Keys) {
            if ($mergedFolder -eq $dirName -or $mergedFolder.StartsWith("$dirName/")) { $covered = $true; break }
        }
        if ($covered) { continue }
        if ((Test-Path -LiteralPath (Join-Path $dir.FullName 'docmap.md')) -or
            (Test-Path -LiteralPath (Join-Path $dir.FullName 'DOCMAP.md'))) { continue }

        $newFolderFiles = @(Get-RepoNavFileInventory -Path $dir.FullName -Recurse)
        if ($newFolderFiles.Count -eq 0) { continue }
        $inventoryFiles += $newFolderFiles
        $changes += [PSCustomObject]@{
            File = "$dirName/"
            DocMapSize = ''
            ActualSize = ''
            Status = 'ADDED'
        }
    }
}

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
    if (-not [string]::IsNullOrWhiteSpace($relative)) {
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
