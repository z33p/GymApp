[CmdletBinding()]
param(
    [string]$DatabaseUrl = $env:DATABASE_URL
)

$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'apply_postgres_migrations.ps1') -DatabaseUrl $DatabaseUrl

$psql = Get-Command psql -ErrorAction Stop
$test = Join-Path (Split-Path -Parent $PSScriptRoot) 'tests\scoring_smoke.sql'
& $psql.Source --dbname=$DatabaseUrl --set ON_ERROR_STOP=1 --file $test
if ($LASTEXITCODE -ne 0) { throw 'O smoke test do schema falhou.' }
Write-Host 'Schema PostgreSQL verificado; a transação de teste foi revertida.'
