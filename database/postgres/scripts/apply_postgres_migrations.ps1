[CmdletBinding()]
param(
    [string]$DatabaseUrl = $env:DATABASE_URL
)

$ErrorActionPreference = 'Stop'
if ([string]::IsNullOrWhiteSpace($DatabaseUrl)) {
    throw 'Informe -DatabaseUrl ou defina DATABASE_URL. Exemplo: postgresql://user:password@localhost:5432/gymapp'
}

$psql = Get-Command psql -ErrorAction Stop
$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$migrations = Join-Path $root 'migrations'

& $psql.Source --dbname=$DatabaseUrl --set ON_ERROR_STOP=1 --command 'CREATE SCHEMA IF NOT EXISTS gymapp; CREATE TABLE IF NOT EXISTS gymapp.schema_migrations (name text PRIMARY KEY, applied_at timestamptz NOT NULL DEFAULT now());'
if ($LASTEXITCODE -ne 0) { throw 'Não foi possível preparar o controle de migrations.' }

Get-ChildItem -LiteralPath $migrations -Filter '*.sql' -File | Sort-Object Name | ForEach-Object {
    $name = $_.Name
    $applied = & $psql.Source --dbname=$DatabaseUrl --tuples-only --no-align --command "SELECT 1 FROM gymapp.schema_migrations WHERE name = '$name';"
    if ($LASTEXITCODE -ne 0) { throw "Não foi possível consultar a migration $name." }
    if ($applied -match '1') {
        Write-Host "[skip] $name"
        return
    }

    Write-Host "[apply] $name"
    & $psql.Source --dbname=$DatabaseUrl --set ON_ERROR_STOP=1 --single-transaction --file $_.FullName
    if ($LASTEXITCODE -ne 0) { throw "Falhou ao aplicar $name." }
    & $psql.Source --dbname=$DatabaseUrl --set ON_ERROR_STOP=1 --command "INSERT INTO gymapp.schema_migrations (name) VALUES ('$name');"
    if ($LASTEXITCODE -ne 0) { throw "Falhou ao registrar $name." }
}

Write-Host 'PostgreSQL GymApp atualizado.'
