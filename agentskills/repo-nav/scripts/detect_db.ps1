<#
.SYNOPSIS
Lists files with database definitions recorded in docmaps.

.DESCRIPTION
Reads file entries from one docmap or recursively discovered docmaps under a
directory. Only names listed in a file entry's Database section are reported.

.PARAMETER Path
A docmap file or a directory to search. Defaults to the current directory.

.EXAMPLE
./detect_db.ps1 .

.EXAMPLE
./detect_db.ps1 ../src/docmap.md
#>
param(
    [string]$Path = "."
)

$ErrorActionPreference = "Stop"
. (Join-Path $PSScriptRoot "fileinventory.ps1")
Assert-RipgrepAvailable

$nativePath = ConvertTo-NativePath -Path $Path
$resolvedPath = (Resolve-Path -LiteralPath $nativePath -ErrorAction Stop).Path
$pathItem = Get-Item -LiteralPath $resolvedPath

if ($pathItem.PSIsContainer) {
    $rootPath = $pathItem.FullName
    $docMapPaths = @(
        & rg --files `
            --glob "docmap.md" `
            --glob "DOCMAP.md" `
            -- $rootPath
    )
    if ($LASTEXITCODE -gt 1) {
        throw "ripgrep failed while searching for docmap files under '$rootPath'."
    }
} elseif ($pathItem.Name -ieq "docmap.md" -or $pathItem.Name -ieq "DOCMAP.md") {
    $rootPath = Split-Path -Parent $pathItem.FullName
    $docMapPaths = @($pathItem.FullName)
} else {
    throw "Path must be a directory or a docmap.md/DOCMAP.md file."
}

# One multiline match (default Rust regex engine) per file entry that has a
# Database subsection. Only indented lines may sit between the file entry and
# its Database line, so the match cannot cross into the next file entry.
$databasePattern = '(?m)^[ \t]*-[ \t]*`(?P<file>[^`\r\n]+)`[^\n]*\n(?:[ \t]+[^\n]*\n)*?[ \t]+-[ \t]*Database[ \t]*:[ \t]*\[(?P<objects>[^\]\r\n]*)\]'
$databaseReplacement = '${file}' + [char]9 + '${objects}'

$databaseObjectsByFile = @{}
foreach ($docMapPath in $docMapPaths) {
    $resolvedDocMapPath = (Resolve-Path -LiteralPath $docMapPath -ErrorAction Stop).Path
    $docMapDirectory = Split-Path -Parent $resolvedDocMapPath

    $entryMatches = @(& rg -U -N -o --replace $databaseReplacement $databasePattern $resolvedDocMapPath)
    if ($LASTEXITCODE -gt 1) {
        throw "ripgrep failed while parsing '$resolvedDocMapPath'."
    }

    foreach ($entry in $entryMatches) {
        $separatorIndex = $entry.IndexOf([char]9)
        $currentFile = $entry.Substring(0, $separatorIndex).Trim()
        $objectList = $entry.Substring($separatorIndex + 1)

        $names = @(
            $objectList -split '[,;]' |
                ForEach-Object { $_.Trim().Trim('`') } |
                Where-Object { $_ -and $_ -notmatch '[<>]' } |
                Select-Object -Unique
        )
        if (-not $names) {
            continue
        }

        $nativeFile = $currentFile.Replace('/', [System.IO.Path]::DirectorySeparatorChar)
        $absoluteFile = [System.IO.Path]::GetFullPath((Join-Path $docMapDirectory $nativeFile))
        $rootPrefix = [System.IO.Path]::GetFullPath($rootPath).TrimEnd(
            [System.IO.Path]::DirectorySeparatorChar,
            [System.IO.Path]::AltDirectorySeparatorChar
        ) + [System.IO.Path]::DirectorySeparatorChar
        $relativeFile = if ($absoluteFile.StartsWith($rootPrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
            $absoluteFile.Substring($rootPrefix.Length)
        } else {
            $absoluteFile
        }
        $relativeFile = $relativeFile.Replace([System.IO.Path]::DirectorySeparatorChar, '/')

        if (-not $databaseObjectsByFile.ContainsKey($relativeFile)) {
            $databaseObjectsByFile[$relativeFile] = [System.Collections.Generic.List[string]]::new()
        }
        foreach ($name in $names) {
            if (-not $databaseObjectsByFile[$relativeFile].Contains($name)) {
                $databaseObjectsByFile[$relativeFile].Add($name)
            }
        }
    }
}

$rows = @(
    foreach ($file in ($databaseObjectsByFile.Keys | Sort-Object)) {
        [PSCustomObject]@{
            Filename = $file
            DatabaseObjects = $databaseObjectsByFile[$file] -join ", "
        }
    }
)

if ($rows.Count -eq 0) {
    Write-Output "No database definitions found."
    return
}

$rows | Format-Table -AutoSize -Wrap
