# Run from project root in PowerShell, with PostgreSQL bin directory on PATH.
# SAFETY: never touches the source turboquery DB beyond pg_dump/read-only checks.
# Destructive operations happen ONLY to dedicated turboquery_restore test DB.
$ErrorActionPreference = 'Stop'
$sourceDb = 'turboquery'
$testDb = 'turboquery_restore'
$stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
New-Item -ItemType Directory -Force -Path 'backups' | Out-Null
$dumpFile = "backups/turboquery_$stamp.dump"

function Invoke-PgTool([string]$command, [string[]]$parameters) {
    & $command @parameters
    if ($LASTEXITCODE -ne 0) { throw "$command failed with exit code $LASTEXITCODE" }
}

Write-Host 'Creating custom-format backup...'
Invoke-PgTool 'pg_dump' @('-Fc', '--no-owner', '--no-acl', '-d', $sourceDb, '-f', $dumpFile)
if ((Get-Item $dumpFile).Length -le 0) { throw 'Backup file is empty' }
Write-Host "Backup created: $dumpFile"

# Always drop/recreate the disposable restore database, not the source database.
Write-Host "Recreating disposable test DB $testDb ..."
Invoke-PgTool 'dropdb' @('--if-exists', $testDb)
Invoke-PgTool 'createdb' @($testDb)
Invoke-PgTool 'pg_restore' @('--exit-on-error', '--no-owner', '--no-acl', '-d', $testDb, $dumpFile)

$query = "SELECT (SELECT count(*) FROM public.sellers)::text || ':' || (SELECT count(*) FROM public.buyers)::text || ':' || (SELECT count(*) FROM public.vehicles)::text || ':' || (SELECT count(*) FROM public.offers)::text;"
$sourceCount = (& psql -X -A -t -d $sourceDb -c $query)
if ($LASTEXITCODE -ne 0) { throw 'Failed to query source DB' }
$restoreCount = (& psql -X -A -t -d $testDb -c $query)
if ($LASTEXITCODE -ne 0) { throw 'Failed to query restore DB' }
Write-Host "Source counts (sellers:buyers:vehicles:offers): $sourceCount"
Write-Host "Restored counts: $restoreCount"
if ($sourceCount -ne $restoreCount) { throw 'FAIL: row count mismatch' }

# Simulate accidental data loss only in the disposable restore copy.
Invoke-PgTool 'psql' @('-X','-v','ON_ERROR_STOP=1','-d',$testDb,'-c','TRUNCATE TABLE public.offers;')
$empty = (& psql -X -A -t -d $testDb -c 'SELECT count(*) FROM public.offers;')
if ($LASTEXITCODE -ne 0 -or "$empty".Trim() -ne '0') { throw 'Loss simulation unsuccessful' }
Write-Host 'Simulated loss in test database: offers table now has zero rows.'

# Rebuild disposable copy and restore again (avoids duplicate-key restores).
Invoke-PgTool 'dropdb' @('--if-exists', $testDb)
Invoke-PgTool 'createdb' @($testDb)
Invoke-PgTool 'pg_restore' @('--exit-on-error', '--no-owner', '--no-acl', '-d', $testDb, $dumpFile)
$finalCount = (& psql -X -A -t -d $testDb -c $query)
if ($LASTEXITCODE -ne 0 -or "$finalCount".Trim() -ne "$sourceCount".Trim()) {
    throw 'FAIL: recovered row counts do not match source'
}
Write-Host "PASS: restore verified after simulated loss. Counts: $finalCount"
Write-Host 'Capture the console output and run sql/recovery_checks.sql on both DBs for report evidence.'
