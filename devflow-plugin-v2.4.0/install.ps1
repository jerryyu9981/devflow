<#
.SYNOPSIS
    DevFlow Plugin Installer v2.4.0 - Interactive Installation Wizard
.DESCRIPTION
    5-step interactive wizard: Welcome -> Environment Detection ->
    Configuration Guide -> Installation Execution -> Result Summary.
    Includes environment detection, branch strategy selection, progress
    bar display, and result summary with error recovery.
.NOTES
    File encoding: UTF-8 with BOM (PowerShell 5.1 compatible)
    No third-party dependencies.
#>

$ErrorActionPreference = "Stop"

# ============================================================
# Initialize
# ============================================================

$PluginDir = $PSScriptRoot

# Read version from version.json
$VersionJsonPath = Join-Path $PluginDir "version.json"
$Version = "2.4.0"
$TemplateCount = 19
if (Test-Path $VersionJsonPath) {
    $raw = [System.IO.File]::ReadAllText($VersionJsonPath, [System.Text.Encoding]::UTF8)
    $verInfo = $raw | ConvertFrom-Json
    $Version = $verInfo.version
    if ($verInfo.templates) { $TemplateCount = $verInfo.templates }
}

# ============================================================
# Skill Map (v2.4.0 - 26 skills)
# ============================================================

$skillMap = @{
    # --- Orchestrator (3) ---
    "devflow-init"                        = "devflow-init\SKILL.md"
    "devflow-phase-manager"               = "devflow-phase-manager\SKILL.md"
    "devflow-project-config"              = "devflow-project-config\SKILL.md"
    # --- L1 - Workflow Foundation (3) ---
    "project-development-workflow"         = "skills\L1\project-development-workflow.md"
    "project-document-management"          = "skills\L1\project-document-management.md"
    "project-role-management"              = "skills\L1\project-role-management.md"
    # --- L2 - Stage Execution (6) ---
    "version-planning-stage-execution"    = "skills\L2\version-planning-stage-execution.md"
    "requirements-stage-execution"        = "skills\L2\requirements-stage-execution.md"
    "design-stage-execution"               = "skills\L2\design-stage-execution.md"
    "coding-stage-execution"               = "skills\L2\coding-stage-execution.md"
    "testing-stage-execution"              = "skills\L2\testing-stage-execution.md"
    "operations-stage-execution"           = "skills\L2\operations-stage-execution.md"
    # --- L3 - Engineering Standards (8) ---
    "project-coding-conventions"           = "skills\L3\project-coding-conventions.md"
    "code-static-quality-check"            = "skills\L3\code-static-quality-check.md"
    "code-logic-review"                   = "skills\L3\code-logic-review.md"
    "cicd-pipeline-management"            = "skills\L3\cicd-pipeline-management.md"
    "observability-standards"              = "skills\L3\observability-standards.md"
    "project-document-templates"           = "skills\L3\project-document-templates.md"
    "code-version-backup-management"       = "skills\L3\code-version-backup-management.md"
    "skill-md-writing-standards"           = "skills\L3\skill-md-writing-standards.md"
    # --- L3 - v2.4.0 New Skills (4) ---
    "prototype-coverage"                  = "skills\L3\prototype-coverage.md"
    "backend-coverage"                    = "skills\L3\backend-coverage.md"
    "api-contract-management"              = "skills\L3\api-contract-management.md"
    # --- L3 - v2.4.0 Phase 3 New Skills (3) ---
    "security-design-review"              = "skills\L3\security-design-review.md"
    "secure-coding-practices"             = "skills\L3\secure-coding-practices.md"
    "container-deployment"               = "skills\L3\container-deployment.md"
}

$SkillCount = $skillMap.Count

# Installation result tracking
$script:installSuccess = 0
$script:installFail    = 0
$script:installSkip    = 0
$script:failedItems    = @()

# ============================================================
# Helper Functions
# ============================================================

function Write-Banner($text) {
    $innerWidth = 50
    $line = "+" + ("=" * $innerWidth) + "+"
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    $padTotal = $innerWidth - 2
    $padLeft  = [math]::Floor(($padTotal - $text.Length) / 2)
    $padRight = $padTotal - $text.Length - $padLeft
    if ($padLeft -lt 0) { $padLeft = 0; $padRight = $padTotal - $text.Length }
    Write-Host ("| " + (" " * $padLeft) + $text + (" " * $padRight) + " |") -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
}

function Write-SectionHeader($stepNum, $totalSteps, $title) {
    $header = "[Step $stepNum/$totalSteps] $title"
    $innerWidth = 50
    $line = "+" + ("=" * $innerWidth) + "+"
    Write-Host ""
    Write-Host $line -ForegroundColor Cyan
    $padTotal = $innerWidth - 2
    $padLeft  = [math]::Floor(($padTotal - $header.Length) / 2)
    $padRight = $padTotal - $header.Length - $padLeft
    if ($padLeft -lt 0) { $padLeft = 0; $padRight = $padTotal - $header.Length }
    Write-Host ("| " + (" " * $padLeft) + $header + (" " * $padRight) + " |") -ForegroundColor Cyan
    Write-Host $line -ForegroundColor Cyan
}

function Write-SubSection($text) {
    $innerWidth = 50
    $suffixLen = $innerWidth - $text.Length - 7
    if ($suffixLen -lt 1) { $suffixLen = 1 }
    Write-Host ""
    Write-Host ("+--- " + $text + " " + "-" * $suffixLen + "+") -ForegroundColor DarkCyan
}

function Write-Success($text) {
    Write-Host ("  [OK]   " + $text) -ForegroundColor Green
}

function Write-Warn($text) {
    Write-Host ("  [WARN] " + $text) -ForegroundColor Yellow
}

function Write-Fail($text) {
    Write-Host ("  [FAIL] " + $text) -ForegroundColor Red
}

function Write-Info($text) {
    Write-Host ("  [INFO] " + $text) -ForegroundColor Blue
}

function Write-ProgressBar($percent, $description) {
    $percent = [math]::Max(0, [math]::Min(100, [int]$percent))
    $barWidth = 20
    $filled = [math]::Floor($percent * $barWidth / 100)
    $empty  = $barWidth - $filled
    $arrow  = if ($filled -lt $barWidth) { ">" } else { "" }
    $bar    = "[" + ("=" * $filled) + $arrow + (" " * $empty) + "]"
    $line   = ("  {0} {1,3}% - {2}" -f $bar, $percent, $description)
    Write-Host ("`r" + $line + "  ") -NoNewline
}

function Finish-Progress {
    Write-Host ""
}

function Show-Box($title, $lines) {
    $maxLen = 0
    foreach ($line in $lines) {
        $displayLen = $line.Length
        if ($displayLen -gt $maxLen) { $maxLen = $displayLen }
    }
    $titleLen = $title.Length
    if ($titleLen -gt $maxLen) { $maxLen = $titleLen }
    $innerWidth = $maxLen + 4

    Write-Host ""
    Write-Host ("+" + ("-" * $innerWidth) + "+") -ForegroundColor Cyan
    $tPad = $innerWidth - $title.Length - 2
    Write-Host ("| " + $title + (" " * $tPad) + "|") -ForegroundColor Cyan
    Write-Host ("+" + ("=" * $innerWidth) + "+") -ForegroundColor Cyan
    foreach ($line in $lines) {
        $color = "White"
        if ($line -match "^\[OK\]")  { $color = "Green" }
        elseif ($line -match "^\[FAIL\]") { $color = "Red" }
        elseif ($line -match "^\[INFO\]") { $color = "Yellow" }
        $lPad = $innerWidth - $line.Length - 2
        Write-Host ("| " + $line + (" " * $lPad) + "|") -ForegroundColor $color
    }
    Write-Host ("+" + ("-" * $innerWidth) + "+") -ForegroundColor Cyan
}

# ============================================================
# Environment Detection Functions
# ============================================================

function Test-Environment {
    $results = @()

    # OS Detection
    $osInfo = "Windows"
    if ($PSVersionTable.OS) {
        $osInfo = $PSVersionTable.OS.ToString()
    } elseif ([System.Environment]::OSVersion) {
        $osInfo = [System.Environment]::OSVersion.ToString()
    }
    $results += @{ Name = "Operating System"; Value = $osInfo; Status = "OK" }

    # Git Detection
    $gitVersion = $null
    try { $gitVersion = & git --version 2>$null } catch {}
    if ($gitVersion) {
        $results += @{ Name = "Git"; Value = $gitVersion.ToString().Trim(); Status = "OK" }
    } else {
        $results += @{ Name = "Git"; Value = "Not installed"; Status = "FAIL" }
    }

    # PowerShell Version
    $psVer = $PSVersionTable.PSVersion.ToString()
    $results += @{ Name = "PowerShell"; Value = $psVer; Status = "OK" }

    # Node.js (optional)
    $nodeVersion = $null
    try { $nodeVersion = & node --version 2>$null } catch {}
    if ($nodeVersion) {
        $results += @{ Name = "Node.js"; Value = "$($nodeVersion.ToString().Trim()) (optional)"; Status = "OK" }
    } else {
        $results += @{ Name = "Node.js"; Value = "Not installed (optional)"; Status = "INFO" }
    }

    # Network Connectivity (skipped by default)
    $results += @{ Name = "Network"; Value = "Not checked (skipped)"; Status = "INFO" }

    # Existing DevFlow version detection
    $traeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"
    $existingInit  = Join-Path $traeSkillsDir "devflow-init\SKILL.md"
    if (Test-Path $existingInit) {
        $results += @{ Name = "Existing DevFlow"; Value = "Installed (version unknown)"; Status = "INFO" }
    } else {
        $results += @{ Name = "Existing DevFlow"; Value = "Not installed"; Status = "INFO" }
    }

    return $results
}

function Show-EnvironmentResults($results) {
    $boxLines = @()
    foreach ($r in $results) {
        $tag = switch ($r.Status) {
            "OK"   { "[OK]" }
            "FAIL" { "[FAIL]" }
            default { "[INFO]" }
        }
        $boxLines += ("{0}  {1}: {2}" -f $tag, $r.Name, $r.Value)
    }
    Show-Box "Environment Detection" $boxLines
}

# ============================================================
# Branch Strategy Selection
# ============================================================

function Select-BranchStrategy {
    Write-Host ""
    Write-Host "  Please select a branch strategy:" -ForegroundColor White
    Write-Host ""
    Write-Host "    [1] git-flow         (Recommended, for formal projects)" -ForegroundColor White
    Write-Host "    [2] feature-branch  (For agile teams)" -ForegroundColor White
    Write-Host "    [3] trunk-based      (For continuous deployment)" -ForegroundColor White
    Write-Host ""

    $validChoices = @("1", "2", "3")
    do {
        Write-Host "  Enter option [1-3]: " -NoNewline -ForegroundColor White
        $choice = Read-Host
    } while ($choice -notin $validChoices)

    $selected = switch ($choice) {
        "1" { "git-flow" }
        "2" { "feature-branch" }
        "3" { "trunk-based" }
    }
    return $selected
}

# ============================================================
# Utility: Ask to continue
# ============================================================

function Confirm-Continue($prompt) {
    $input = Read-Host "  $prompt (Enter to continue, Q to quit)"
    if ($input -eq "q" -or $input -eq "Q") {
        return $false
    }
    return $true
}

# ============================================================
# Step 1/5: Welcome
# ============================================================

Write-Banner "DevFlow Plugin Installer v$Version"

Write-Host ""
Write-Host "  This wizard will install DevFlow into your project." -ForegroundColor White
Write-Host "  DevFlow provides engineering-grade development workflow" -ForegroundColor DarkGray
Write-Host "  management with 6-phase control and 26 professional skills." -ForegroundColor DarkGray

$packageInfo = @(
    "Version:     v$Version",
    "Skills:      $SkillCount (3 Orchestrator + 3 L1 + 6 L2 + 14 L3)",
    "Templates:   $TemplateCount document templates",
    "License:     MIT"
)
Show-Box "Package Information" $packageInfo

Write-Host ""
if (-not (Confirm-Continue "Press Enter to start installation")) {
    Write-Host ""
    Write-Host "  Installation cancelled by user." -ForegroundColor Yellow
    Read-Host "`n  Press Enter to exit"
    exit 0
}

# ============================================================
# Step 2/5: Environment Detection
# ============================================================

Write-SectionHeader 2 5 "Environment Detection"

$envResults = Test-Environment
Show-EnvironmentResults $envResults

# Check for critical failures (e.g., Git missing)
$criticalFail = $false
foreach ($r in $envResults) {
    if ($r.Status -eq "FAIL" -and $r.Name -eq "Git") {
        $criticalFail = $true
    }
}

if ($criticalFail) {
    Write-Host ""
    Write-Fail "Git is required for DevFlow but was not detected."
    Write-Host "  Please install Git from https://git-scm.com and re-run this installer." -ForegroundColor Yellow
    Write-Host ""
    $force = Read-Host "  Continue anyway? (y/N)"
    if ($force -ne "y" -and $force -ne "Y") {
        Write-Host ""
        Write-Host "  Installation cancelled." -ForegroundColor Yellow
        Read-Host "`n  Press Enter to exit"
        exit 1
    }
}

if (-not (Confirm-Continue "Press Enter to continue")) {
    Write-Host "  Installation cancelled by user." -ForegroundColor Yellow
    Read-Host "`n  Press Enter to exit"
    exit 0
}

# ============================================================
# Step 3/5: Configuration Guide
# ============================================================

Write-SectionHeader 3 5 "Configuration Guide"

# --- Project Path ---
Write-SubSection "Project Directory"

$defaultPath = (Get-Location).Path
Write-Host ""
Write-Host "  Enter the path to your project directory:" -ForegroundColor White
Write-Host "  (The .devflow folder will be created here)"
Write-Host "  Default: $defaultPath" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Project path: " -NoNewline -ForegroundColor White
$projectPath = Read-Host

if (-not $projectPath) {
    $projectPath = $defaultPath
}

# Validate and create directory
if (-not (Test-Path $projectPath)) {
    Write-Host ""
    Write-Warn "Directory does not exist: $projectPath"
    $create = Read-Host "  Create directory? (Y/n)"
    if ($create -eq "" -or $create -eq "Y" -or $create -eq "y") {
        try {
            New-Item -ItemType Directory -Path $projectPath -Force | Out-Null
            Write-Success "Created directory: $projectPath"
        } catch {
            Write-Fail "Failed to create directory: $_"
            Read-Host "`n  Press Enter to exit"
            exit 1
        }
    } else {
        Write-Host ""
        Write-Host "  Installation cancelled." -ForegroundColor Yellow
        Read-Host "`n  Press Enter to exit"
        exit 1
    }
}

$projectPath = (Resolve-Path $projectPath).Path
$devflowDir  = Join-Path $projectPath ".devflow"

# Check if .devflow already exists (backup and overwrite)
if (Test-Path $devflowDir) {
    Write-Host ""
    Write-Warn ".devflow already exists at: $devflowDir"
    $overwrite = Read-Host "  Overwrite? (y/N)"
    if ($overwrite -eq "y" -or $overwrite -eq "Y") {
        try {
            # Create timestamped backup of existing .devflow
            $timestamp   = Get-Date -Format "yyyyMMdd_HHmmss"
            $backupDir  = $devflowDir + ".bak-" + $timestamp
            Copy-Item -Path $devflowDir -Destination $backupDir -Recurse -Force
            Remove-Item -Path $devflowDir -Recurse -Force
            Write-Success "Backed up existing .devflow to: $backupDir"
            Write-Success "Removed existing .devflow"
        } catch {
            Write-Fail "Failed to backup/remove existing .devflow: $_"
            Read-Host "`n  Press Enter to exit"
            exit 1
        }
    } else {
        Write-Host ""
        Write-Host "  Installation cancelled." -ForegroundColor Yellow
        Read-Host "`n  Press Enter to exit"
        exit 1
    }
}

Write-Success "Target directory: $projectPath"

# --- Branch Strategy ---
Write-SubSection "Branch Strategy"
$branchStrategy = Select-BranchStrategy
Write-Host ""
Write-Success "Selected branch strategy: $branchStrategy"

# --- Remote Repository ---
Write-SubSection "Remote Repository (Optional)"

Write-Host ""
Write-Host "  Git origin remote URL (Enter to skip):" -ForegroundColor White
Write-Host "  URL: " -NoNewline -ForegroundColor White
$originUrl = Read-Host

Write-Host "  Git backup remote URL (Enter to skip):" -ForegroundColor White
Write-Host "  URL: " -NoNewline -ForegroundColor White
$backupUrl = Read-Host

if ($originUrl) {
    Write-Success "Origin remote: $originUrl"
} else {
    Write-Info "Origin remote: (skipped)"
}

if ($backupUrl) {
    Write-Success "Backup remote: $backupUrl"
} else {
    Write-Info "Backup remote: (skipped)"
}

# --- Project Name Detection ---
Write-SubSection "Project Name Detection"

$projectName = ""
$packageJson = Join-Path $projectPath "package.json"
if (Test-Path $packageJson) {
    try {
        $pkgRaw = [System.IO.File]::ReadAllText($packageJson, [System.Text.Encoding]::UTF8)
        $pkg    = $pkgRaw | ConvertFrom-Json
        $projectName = $pkg.name
    } catch {}
}

if (-not $projectName -and (Test-Path (Join-Path $projectPath ".git"))) {
    try {
        $remote = & git -C $projectPath remote get-url origin 2>$null
        if ($remote) {
            $projectName = ($remote -split '/')[-1] -replace '\.git$', ''
        }
    } catch {}
}

if (-not $projectName) {
    $projectName = (Get-Item $projectPath).Name
}
Write-Success "Project name: $projectName"

# --- Confirm Configuration ---
Write-Host ""
$configSummary = @(
    "Project:        $projectName",
    "Path:           $projectPath",
    "Branch Strategy: $branchStrategy",
    "Origin:         $(if ($originUrl) { $originUrl } else { '(none)' })",
    "Backup:         $(if ($backupUrl) { $backupUrl } else { '(none)' })"
)
Show-Box "Configuration Summary" $configSummary

if (-not (Confirm-Continue "Press Enter to start installation")) {
    Write-Host "  Installation cancelled by user." -ForegroundColor Yellow
    Read-Host "`n  Press Enter to exit"
    exit 0
}

# ============================================================
# Step 4/5: Installation Execution
# ============================================================

Write-SectionHeader 4 5 "Installation Execution"

# --- 4a: Copy Plugin Files ---
Write-SubSection "Copying Plugin Files"

$excludeFiles = @("install.ps1", "install.bat")
$items        = Get-ChildItem -Path $PluginDir
$copyItems    = $items | Where-Object { $excludeFiles -notcontains $_.Name }
$totalCopy    = @($copyItems).Count
$copyIndex    = 0

Write-Host ""
Write-Host ("  Total items to copy: $totalCopy") -ForegroundColor DarkGray
Write-Host ""

foreach ($item in $copyItems) {
    $copyIndex++
    $dst = Join-Path $devflowDir $item.Name

    # Overall progress: plugin copy occupies 0-35%
    $overallPercent = [math]::Floor($copyIndex * 35 / $totalCopy)
    Write-ProgressBar $overallPercent ("Copying ($copyIndex/$totalCopy) $($item.Name)")

    try {
        if ($item.PSIsContainer) {
            Copy-Item -Path $item.FullName -Destination $dst -Recurse -Force -ErrorAction Stop
        } else {
            Copy-Item -Path $item.FullName -Destination $dst -Force -ErrorAction Stop
        }
        $script:installSuccess++
    } catch {
        Write-Host ""
        Write-Fail "Failed to copy: $($item.Name) - $_"
        $script:installFail++
        $script:failedItems += "Copy: $($item.Name)"
    }
}

Finish-Progress
Write-Host ("  Plugin files copied: $copyIndex/$totalCopy") -ForegroundColor DarkGray

# --- 4b: Install Skills to TRAE Work ---
Write-SubSection "Installing Skills to TRAE Work"

$TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"
$sortedSkills  = $skillMap.Keys | Sort-Object
$totalSkills   = @($sortedSkills).Count
$skillIndex    = 0

Write-Host ""
Write-Host ("  Total skills to install: $totalSkills") -ForegroundColor DarkGray
Write-Host ""

foreach ($skill in $sortedSkills) {
    $skillIndex++
    $src = Join-Path $devflowDir $skillMap[$skill]
    $dst = Join-Path $TraeSkillsDir "$skill\SKILL.md"

    # Overall progress: skills occupy 35-90%
    $overallPercent = 35 + [math]::Floor($skillIndex * 55 / $totalSkills)
    Write-ProgressBar $overallPercent ("Installing ($skillIndex/$totalSkills) $skill")

    try {
        if (Test-Path $src) {
            # Backup existing skill
            if (Test-Path $dst) {
                $timestamp = Get-Date -Format "yyyyMMddHHmmss"
                $bakPath   = "$dst.bak-$timestamp"
                Copy-Item $dst $bakPath -Force -ErrorAction Stop
            }
            # Ensure destination directory exists
            $dstDir = Split-Path $dst -Parent
            if (-not (Test-Path $dstDir)) {
                New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
            }
            Copy-Item $src $dst -Force -ErrorAction Stop
            $script:installSuccess++
        } else {
            Write-Host ""
            Write-Warn "Skill source not found: $skill"
            $script:installSkip++
        }
    } catch {
        Write-Host ""
        Write-Fail "Failed to install skill: $skill - $_"
        $script:installFail++
        $script:failedItems += "Skill: $skill"
    }
}

Finish-Progress
$skillSucceeded = $totalSkills - $script:installSkip
Write-Host ("  Skills installed: $skillSucceeded/$totalSkills") -ForegroundColor DarkGray

# --- 4c: Generate Configuration Files ---
Write-SubSection "Generating Configuration"

# Overall progress: config occupies 90-100%
Write-Host ""
Write-ProgressBar 92 "Creating .devflow directory"

try {
    New-Item -ItemType Directory -Path $devflowDir -Force | Out-Null
    $script:installSuccess++
} catch {
    Write-Host ""
    Write-Fail "Failed to create .devflow directory: $_"
    $script:installFail++
    $script:failedItems += "Create .devflow directory"
}

Finish-Progress

# Generate config.json
Write-ProgressBar 95 "Generating config.json"
try {
    $config = @{
        project        = $projectName
        devflowVersion = $Version
        branchStrategy = $branchStrategy
        remote         = @{
            origin = if ($originUrl) { $originUrl } else { "" }
            backup = if ($backupUrl) { $backupUrl } else { "" }
        }
        backup         = @{
            type     = "git-mirror"
            schedule = @{
                bundle           = "weekly"
                bundleRetention  = 4
                dbDump           = "daily"
                dbRetention      = 90
            }
        }
    }
    $configPath = Join-Path $devflowDir "config.json"
    $config | ConvertTo-Json -Depth 4 | Set-Content $configPath -Encoding UTF8
    $script:installSuccess++
} catch {
    Write-Host ""
    Write-Fail "Failed to generate config.json: $_"
    $script:installFail++
    $script:failedItems += "Generate config.json"
}

Finish-Progress

# Generate state.json
Write-ProgressBar 98 "Generating state.json"
try {
    $state = @{
        project           = $projectName
        version           = ""
        currentPhase      = "step_0_planning"
        completedPhases   = @()
        currentDocuments  = @{}
        auditResults      = @{}
    }
    $statePath = Join-Path $devflowDir "state.json"
    $state | ConvertTo-Json -Depth 4 | Set-Content $statePath -Encoding UTF8
    $script:installSuccess++
} catch {
    Write-Host ""
    Write-Fail "Failed to generate state.json: $_"
    $script:installFail++
    $script:failedItems += "Generate state.json"
}

Finish-Progress

Write-ProgressBar 100 "Installation complete"
Finish-Progress

Write-Success "config.json generated"
Write-Success "state.json generated"

# ============================================================
# Step 5/5: Result Summary
# ============================================================

Write-SectionHeader 5 5 "Result Summary"

# --- Verification ---
Write-SubSection "Installation Verification"

$verificationLines = @()
$checkPaths = @(
    @{ Name = "Plugin directory (.devflow)"; Path = $devflowDir },
    @{ Name = "Config file (config.json)";  Path = $configPath },
    @{ Name = "State file (state.json)";    Path = $statePath },
    @{ Name = "Skill: devflow-init";        Path = (Join-Path $TraeSkillsDir "devflow-init\SKILL.md") },
    @{ Name = "Skill: devflow-phase-manager"; Path = (Join-Path $TraeSkillsDir "devflow-phase-manager\SKILL.md") },
    @{ Name = "Skill: project-development-workflow"; Path = (Join-Path $TraeSkillsDir "project-development-workflow\SKILL.md") }
)

foreach ($check in $checkPaths) {
    if (Test-Path $check.Path) {
        $verificationLines += ("[OK]   " + $check.Name)
    } else {
        $verificationLines += ("[FAIL] " + $check.Name)
    }
}

Show-Box "Verification Results" $verificationLines

# --- Final Summary ---
Write-Host ""

$totalOps = $script:installSuccess + $script:installFail + $script:installSkip

$summaryLines = @(
    ("Version:           v" + $Version),
    ("Project:           " + $projectName),
    ("Project Path:      " + $projectPath),
    ("Plugin Path:       " + $devflowDir),
    ("TRAE Skills Dir:   " + $TraeSkillsDir),
    ("Branch Strategy:   " + $branchStrategy),
    "",
    "Installation Results:",
    ("  Succeeded:       " + $script:installSuccess),
    ("  Failed:          " + $script:installFail),
    ("  Skipped:         " + $script:installSkip),
    ("  Total Skills:    " + $totalSkills + " registered"),
    ""
)

if ($script:installFail -eq 0) {
    $summaryLines += "Status: SUCCESS"
    $summaryLines += "All components installed successfully."
} elseif ($script:installFail -le 3) {
    $summaryLines += "Status: PARTIAL SUCCESS"
    $summaryLines += "Some components failed. Check details above."
} else {
    $summaryLines += "Status: FAILURE"
    $summaryLines += "Multiple components failed. Review errors above."
}

# Append failed items if any
if ($script:failedItems.Count -gt 0) {
    $summaryLines += ""
    $summaryLines += "Failed items:"
    foreach ($fi in $script:failedItems) {
        $summaryLines += ("  - " + $fi)
    }
}

Show-Box "Installation Summary" $summaryLines

# --- Next Steps ---
Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "    1. Open TRAE and invoke the skill: devflow-init" -ForegroundColor DarkGray
Write-Host "    2. Or run '.\update.ps1' in $devflowDir to update skills" -ForegroundColor DarkGray
Write-Host "    3. Edit .devflow\config.json to adjust settings" -ForegroundColor DarkGray
Write-Host "    4. For reconfiguration, run: setup.ps1" -ForegroundColor DarkGray
Write-Host ""
Write-Host "  Documentation: docs\DevFlow-*.md" -ForegroundColor DarkGray
Write-Host ""
Read-Host "  Press Enter to exit"
