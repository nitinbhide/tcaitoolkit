<#
.SYNOPSIS
Lists the unique directories that contain repository files.

.DESCRIPTION
Uses the same file inventory and rules as filelist.ps1 (ripgrep discovery,
hidden paths and repo-nav documentation files excluded, empty files skipped),
then outputs the unique parent directory of each file, sorted.

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

$dirs = @(foreach ($file in $files) {
    $item = Get-Item -LiteralPath $file
    if ($item.Length -gt 0) {
        $item.DirectoryName
    }
}) | Sort-Object -Unique

if ($OutputFile) {
    $dirs | Set-Content -Path $OutputFile -Encoding UTF8
}
else {
    $dirs
}
