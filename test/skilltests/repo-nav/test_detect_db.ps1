<#
.SYNOPSIS
Tests detect_db.ps1 against test/testdata/detect_db/docmap.md.

.EXAMPLE
./test_detect_db.ps1
#>
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "../../..")).Path
$detectDb = Join-Path $repoRoot "agentskills/repo-nav/scripts/detect_db.ps1"
$testData = Join-Path $repoRoot "test/testdata/detect_db"

# Files must be listed in sorted order. Entries without a Database section, with
# an empty one, or with an unfilled placeholder must not appear.
$expected = [ordered]@{
    "after_placeholder.sql" = "settings"
    "audit.sql"             = "Audit Events, ix_audit_events_ts"
    "migrations.sql"        = "accounts, ix_accounts_email"
    "models.py"             = "orders, ix_orders_customer"
    "schema.sql"            = "users, posts, idx_posts_user_id, user_posts_view"
}

$failures = [System.Collections.Generic.List[string]]::new()

$outputLines = @(& $detectDb -Path $testData | Out-String -Width 4096 -Stream |
    ForEach-Object { $_.TrimEnd() } | Where-Object { $_ })

if ($outputLines.Count -lt 2 -or $outputLines[0] -notmatch '^Filename\s+DatabaseObjects$') {
    $failures.Add("Expected a 'Filename DatabaseObjects' header, got: $($outputLines -join ' | ')")
}

$actual = [ordered]@{}
foreach ($line in ($outputLines | Select-Object -Skip 2)) {
    if ($line -notmatch '^(?<file>\S+)\s+(?<objects>.+)$') {
        $failures.Add("Unparseable output row: '$line'")
        continue
    }
    $actual[$Matches.file] = $Matches.objects.Trim()
}

foreach ($file in $expected.Keys) {
    if (-not $actual.Contains($file)) {
        $failures.Add("Missing file in output: $file")
    } elseif ($actual[$file] -ne $expected[$file]) {
        $failures.Add("$file : expected '$($expected[$file])' but got '$($actual[$file])'")
    }
}

foreach ($file in $actual.Keys) {
    if (-not $expected.Contains($file)) {
        $failures.Add("Unexpected file in output: $file")
    }
}

if ((@($actual.Keys) -join ",") -ne (@($expected.Keys) -join ",")) {
    $failures.Add("Output files or their order differ from expected (rows must be sorted by filename).")
}

if ($failures.Count -gt 0) {
    $failures | ForEach-Object { Write-Host "FAIL: $_" }
    Write-Host "detect_db.ps1 test FAILED ($($failures.Count) problem(s))."
    exit 1
}

Write-Host "detect_db.ps1 test PASSED ($($expected.Count) files verified)."
