# One-command demo setup. Requires PostgreSQL CLI, PowerShell and Python on PATH.
# SAFETY: Refuses to run if turboquery or turboquery_restore database already exists.
$ErrorActionPreference = 'Stop'
if (-not $env:PGUSER) { $env:PGUSER = 'postgres' }
$required = @('psql', 'createdb', 'pg_dump', 'pg_restore', 'dropdb')
foreach ($program in $required) {
    if (-not (Get-Command $program -ErrorAction SilentlyContinue)) {
        throw "Missing PostgreSQL command '$program'. Add its bin directory to PATH."
    }
}
if (-not (Test-Path 'README.md') -or -not (Test-Path 'sql/schema.sql')) {
    throw 'Start from the TurboQuery project ROOT folder (containing README.md).'
}
function Invoke-Checked([string]$program, [string[]]$arguments) {
    & $program @arguments
    if ($LASTEXITCODE -ne 0) { throw "FAILED: $program exited with $LASTEXITCODE" }
}
foreach ($db in @('turboquery','turboquery_restore')) {
    $existing = & psql -X -A -t -d postgres -c "SELECT 1 FROM pg_database WHERE datname='$db';"
    if ($LASTEXITCODE -ne 0) { throw 'Unable to check database existence; verify PGUSER/password.' }
    if ("$existing".Trim() -eq '1') {
        throw "SAFETY STOP: database $db already exists. This script only runs on a fresh, isolated setup. Use README steps to continue existing work."
    }
}
Write-Host '1/7 - Creating dedicated turboquery database...'
Invoke-Checked 'createdb' @('turboquery')
Write-Host '2/7 - Generating fictional data if needed...'
if (-not (Test-Path 'sample_data/vehicles.csv')) {
    Invoke-Checked 'python' @('scripts/seed_data.py','--rows','100000','--seed','4355')
} else {
    Write-Host 'Using included sample_data CSV files.'
}
Write-Host '3/7 - Schema, data import and verification...'
foreach ($script in @('schema.sql','import_data.sql','verify_data.sql')) {
    Invoke-Checked 'psql' @('-X','-v','ON_ERROR_STOP=1','-d','turboquery','-f',"sql/$script")
}
Write-Host '4/7 - Capturing baseline plans BEFORE indexes...'
Invoke-Checked 'psql' @('-X','-v','ON_ERROR_STOP=1','-d','turboquery','-f','sql/baseline_queries.sql')
Write-Host '5/7 - Adding indexes and capturing optimized plans...'
Invoke-Checked 'psql' @('-X','-v','ON_ERROR_STOP=1','-d','turboquery','-f','sql/indexes.sql')
Invoke-Checked 'psql' @('-X','-v','ON_ERROR_STOP=1','-d','turboquery','-f','sql/performance_tests.sql')
Write-Host '6/7 - Creating demo roles and running permission checks...'
Invoke-Checked 'psql' @('-X','-v','ON_ERROR_STOP=1','-d','turboquery','-f','sql/roles.sql')
Invoke-Checked 'psql' @('-X','-v','ON_ERROR_STOP=1','-d','turboquery','-f','sql/security_tests.sql')
Write-Host '7/7 - Backup, simulated data loss in test database, verified restore...'
& "$PSScriptRoot/backup_restore.ps1"
if (-not $?) { throw 'Backup and restore failed.' }
Write-Host 'DONE. Check docs/results/baseline.txt and optimized.txt. Save screenshots and logs for final report.'
