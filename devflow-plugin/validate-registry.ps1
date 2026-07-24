# DevFlow Skill Registry Validation Script
# Validates devflow-config.json skills array completeness
# Usage: .\validate-registry.ps1

param([switch]$Quiet)

$ConfigPath = Join-Path $PSScriptRoot "devflow-config.json"

if (-not (Test-Path $ConfigPath)) {
    Write-Host "[ERR] devflow-config.json not found" -ForegroundColor Red
    exit 1
}

$config = Get-Content $ConfigPath -Encoding UTF8 | ConvertFrom-Json
$errors = @()

# 1. Check skillCount matches actual array length
if ($config.skills.Count -ne $config.skillCount) {
    $errors += "skillCount mismatch: declared=$($config.skillCount), actual=$($config.skills.Count)"
}

# 2. Check each skill has required fields
foreach ($skill in $config.skills) {
    if (-not $skill.name) { $errors += "Skill entry missing 'name'" }
    if (-not $skill.source) { $errors += "Skill '$($skill.name)' missing 'source'" }
    if (-not $skill.category) { $errors += "Skill '$($skill.name)' missing 'category'" }
}

# 3. Check layers consistency
$layerNames = @()
foreach ($layer in $config.layers.PSObject.Properties) {
    $layerNames += $layer.Value
}
$allLayerNames = $layerNames | ForEach-Object { $_ } | Sort-Object -Unique

$registryNames = $config.skills.name | Sort-Object -Unique
$missingFromRegistry = Compare-Object $allLayerNames $registryNames | Where-Object { $_.SideIndicator -eq '<=' } | ForEach-Object { $_.InputObject }
$extraInRegistry = Compare-Object $allLayerNames $registryNames | Where-Object { $_.SideIndicator -eq '=>' } | ForEach-Object { $_.InputObject }

if ($missingFromRegistry) { $errors += "Skills in layers but missing from registry: $($missingFromRegistry -join ', ')" }
if ($extraInRegistry) { $errors += "Skills in registry but missing from layers: $($extraInRegistry -join ', ')" }

# Summary
if ($errors.Count -eq 0) {
    if (-not $Quiet) { Write-Host "[OK] Registry validation passed: $($config.skillCount) skills, 0 errors" -ForegroundColor Green }
    exit 0
} else {
    if (-not $Quiet) {
        Write-Host "[FAIL] Registry validation failed: $($errors.Count) error(s)" -ForegroundColor Red
        foreach ($err in $errors) { Write-Host "  - $err" -ForegroundColor Yellow }
    }
    exit 1
}
