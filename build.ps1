# DevFlow Build Script (PowerShell)
# Usage: .\build.ps1 [-DryRun]
#
# 同步 skill-sources/ → devflow-plugin/skills/ 分层目录
# Source of Truth: DevFlow\skill-sources\
# Build Output:    DevFlow\devflow-plugin\skills\{L1,L2,L3}\

param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# Resolve paths relative to project root (build.ps1 is at DevFlow/build.ps1)
$ProjectRoot = Split-Path $MyInvocation.MyCommand.Path -Parent
$SourcesDir = Join-Path $ProjectRoot "skill-sources"
$PluginSkillsDir = Join-Path $ProjectRoot "devflow-plugin\skills"

function Write-Header($text) {
    Write-Host "`n=== $text ===" -ForegroundColor Cyan
}

function Write-Success($text) {
    Write-Host "[OK] $text" -ForegroundColor Green
}

function Write-Warn($text) {
    Write-Host "[WARN] $text" -ForegroundColor Yellow
}

# Validate source directory exists
if (-not (Test-Path $SourcesDir)) {
    Write-Host "[ERROR] Source directory not found: $SourcesDir" -ForegroundColor Red
    exit 1
}

# Layer mapping: skill filename → target layer directory
$L1Skills = @(
    "project-development-workflow.md",
    "project-document-management.md",
    "project-role-management.md"
)

$L2Skills = @(
    "version-planning-stage-execution.md",
    "requirements-stage-execution.md",
    "design-stage-execution.md",
    "coding-stage-execution.md",
    "testing-stage-execution.md",
    "operations-stage-execution.md"
)

$L3Skills = @(
    "project-coding-conventions.md",
    "code-static-quality-check.md",
    "code-logic-review.md",
    "cicd-pipeline-management.md",
    "observability-standards.md",
    "project-document-templates.md"
)

# All skills that should exist in skill-sources/
$AllKnownSkills = $L1Skills + $L2Skills + $L3Skills

Write-Header "DevFlow Build: skill-sources → devflow-plugin/skills"
Write-Host "Source:  $SourcesDir"
Write-Host "Target:  $PluginSkillsDir"
Write-Host ""

$syncCount = 0
$skipCount = 0
$warnCount = 0

function Sync-Skill($skillName, $layerDir) {
    $src = Join-Path $SourcesDir $skillName
    $dst = Join-Path $PluginSkillsDir "$layerDir\$skillName"

    if (Test-Path $src) {
        # Compare content to avoid unnecessary writes
        if ((Test-Path $dst) -and (Get-FileHash $src).Hash -eq (Get-FileHash $dst).Hash) {
            Write-Host "  [SKIP] $skillName → $layerDir (unchanged)" -ForegroundColor DarkGray
            $script:skipCount++
        } else {
            if (-not $DryRun) {
                Copy-Item $src $dst -Force
            }
            Write-Success "  $skillName → $layerDir\$skillName"
            $script:syncCount++
        }
    } else {
        Write-Warn "  [MISSING] $skillName not found in skill-sources/"
        $script:warnCount++
    }
}

# Sync L1
Write-Host "L1 (Master Control):"
foreach ($s in $L1Skills) { Sync-Skill $s "L1" }

# Sync L2
Write-Host "`nL2 (Stage Execution):"
foreach ($s in $L2Skills) { Sync-Skill $s "L2" }

# Sync L3
Write-Host "`nL3 (Specialized Reference):"
foreach ($s in $L3Skills) { Sync-Skill $s "L3" }

# Check for orphan files in source that are not in any layer
Write-Host ""
Write-Host "Checking for orphan source files..."
$orphans = Get-ChildItem -Path $SourcesDir -Filter "*.md" |
    Where-Object { $AllKnownSkills -notcontains $_.Name }

foreach ($orphan in $orphans) {
    Write-Warn "  [ORPHAN] $($orphan.Name) — not assigned to any layer"
    $warnCount++
}

# Check for stale files in build output that have no source
Write-Host ""
Write-Host "Checking for stale build files..."
$staleFiles = @()
foreach ($layer in @("L1", "L2", "L3")) {
    $layerDir = Join-Path $PluginSkillsDir $layer
    if (Test-Path $layerDir) {
        Get-ChildItem -Path $layerDir -Filter "*.md" |
            Where-Object { $AllKnownSkills -contains $_.Name } |
            ForEach-Object {
                $src = Join-Path $SourcesDir $_.Name
                if (-not (Test-Path $src)) {
                    $staleFiles += "$layer\$($_.Name)"
                }
            }
    }
}

if ($staleFiles.Count -gt 0) {
    Write-Warn "  Stale files (no matching source):"
    foreach ($f in $staleFiles) {
        Write-Host "    [STALE] $f" -ForegroundColor Yellow
    }
}

# Summary
Write-Header "Build Summary"
if ($DryRun) {
    Write-Host "Dry run mode — no files were modified." -ForegroundColor Yellow
}
Write-Host "Synced: $syncCount  |  Skipped: $skipCount  |  Warnings: $warnCount" -ForegroundColor $(if ($warnCount -gt 0) { "Yellow" } else { "Green" })

if ($DryRun) {
    Write-Host "`nRun without -DryRun to apply changes." -ForegroundColor DarkGray
}
