<#
.SYNOPSIS
    DevFlow Project Setup Wizard v2.4.0 - Interactive Initialization
.DESCRIPTION
    7-step interactive wizard for project initialization:
    Welcome -> Host Detection -> Project Name -> Interactive Config ->
    Phase Inference -> File Generation -> Skill Installation -> Summary.
    VR-002: Interactive Q&A, auto phase inference, enhanced config.
.NOTES
    File encoding: UTF-8 with BOM (PowerShell 5.1 compatible)
    No third-party dependencies.
#>

param(
    [string]$ProjectName = "",
    [ValidateSet("trunk-based", "github-flow", "git-flow", "feature-branch")]
    [string]$BranchStrategy = "git-flow",
    [switch]$InstallHook,
    [switch]$SkipConfig,
    [switch]$SkipSkills
)

$ErrorActionPreference = "Stop"

# ============================================================
# Initialize
# ============================================================

$ScriptDir = $PSScriptRoot
$ProjectRoot = (Get-Location).Path

# Read version from version.json (same directory as this script)
$VersionJsonPath = Join-Path $ScriptDir "version.json"
$DevFlowVersion = "2.4.0"
if (Test-Path $VersionJsonPath) {
    $raw = [System.IO.File]::ReadAllText($VersionJsonPath, [System.Text.Encoding]::UTF8)
    $versionInfo = $raw | ConvertFrom-Json
    $DevFlowVersion = $versionInfo.version
}

# ============================================================
# Skill Map (v2.4.0 - 23 skills, includes 4 new skills)
# ============================================================

$skillMap = @{
    # --- Orchestrator (3) ---
    "devflow-init"                        = "devflow-init\SKILL.md"
    "devflow-phase-manager"               = "devflow-phase-manager\SKILL.md"
    "devflow-project-config"              = "devflow-project-config\SKILL.md"
    # --- L1 - Workflow Foundation (3) ---
    "project-development-workflow"        = "skills\L1\project-development-workflow.md"
    "project-document-management"         = "skills\L1\project-document-management.md"
    "project-role-management"             = "skills\L1\project-role-management.md"
    # --- L2 - Stage Execution (6) ---
    "version-planning-stage-execution"     = "skills\L2\version-planning-stage-execution.md"
    "requirements-stage-execution"         = "skills\L2\requirements-stage-execution.md"
    "design-stage-execution"               = "skills\L2\design-stage-execution.md"
    "coding-stage-execution"               = "skills\L2\coding-stage-execution.md"
    "testing-stage-execution"              = "skills\L2\testing-stage-execution.md"
    "operations-stage-execution"           = "skills\L2\operations-stage-execution.md"
    # --- L3 - Engineering Standards (12) ---
    "project-coding-conventions"           = "skills\L3\project-coding-conventions.md"
    "code-static-quality-check"           = "skills\L3\code-static-quality-check.md"
    "code-logic-review"                   = "skills\L3\code-logic-review.md"
    "cicd-pipeline-management"            = "skills\L3\cicd-pipeline-management.md"
    "observability-standards"              = "skills\L3\observability-standards.md"
    "project-document-templates"           = "skills\L3\project-document-templates.md"
    "code-version-backup-management"       = "skills\L3\code-version-backup-management.md"
    "skill-md-writing-standards"           = "skills\L3\skill-md-writing-standards.md"
    # --- L3 - v2.4.0 New Skills (4) ---
    "prototype-coverage"                  = "skills\L3\prototype-coverage.md"
    "backend-coverage"                    = "skills\L3\backend-coverage.md"
    "api-contract-management"             = "skills\L3\api-contract-management.md"
    # --- L3 - v2.4.0 Phase 3 New Skills (3) ---
    "security-design-review"              = "skills\L3\security-design-review.md"
    "secure-coding-practices"             = "skills\L3\secure-coding-practices.md"
    "container-deployment"               = "skills\L3\container-deployment.md"
}

# ============================================================
# Helper Functions (consistent with install.ps1 style)
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

function Show-Box($title, $lines) {
    $maxLen = 0
    foreach ($line in $lines) {
        if ($line.Length -gt $maxLen) { $maxLen = $line.Length }
    }
    if ($title.Length -gt $maxLen) { $maxLen = $title.Length }
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
        if ($lPad -lt 0) { $lPad = 0 }
        Write-Host ("| " + $line + (" " * $lPad) + "|") -ForegroundColor $color
    }
    Write-Host ("+" + ("-" * $innerWidth) + "+") -ForegroundColor Cyan
}

function Confirm-Continue($prompt) {
    $input = Read-Host "  $prompt (Enter to continue, Q to quit)"
    if ($input -eq "q" -or $input -eq "Q") {
        return $false
    }
    return $true
}

function Read-MenuChoice($prompt, $options, $default) {
    # $options: array of @{ Key="1"; Label="Option A" }
    Write-Host ""
    Write-Host "  $prompt" -ForegroundColor White
    Write-Host ""
    foreach ($opt in $options) {
        $defaultTag = ""
        if ($opt.Key -eq $default) { $defaultTag = " (default)" }
        Write-Host ("    [" + $opt.Key + "] " + $opt.Value + $defaultTag) -ForegroundColor White
    }
    Write-Host ""

    $validKeys = $options | ForEach-Object { $_.Key }
    do {
        Write-Host "  Enter option [$($validKeys -join '/')]: " -NoNewline -ForegroundColor White
        $choice = Read-Host
        if ([string]::IsNullOrWhiteSpace($choice) -and $default) {
            $choice = $default
        }
    } while ($choice -notin $validKeys)

    return $choice
}

# ============================================================
# Step 1/7: Welcome
# ============================================================

Write-Banner "DevFlow Project Setup Wizard v$DevFlowVersion"

Write-Host ""
Write-Host "  This wizard will initialize DevFlow for your project." -ForegroundColor White
Write-Host "  DevFlow provides engineering-grade development workflow" -ForegroundColor DarkGray
Write-Host "  management with 6-phase control and 26 professional skills." -ForegroundColor DarkGray

$welcomeInfo = @(
    "Version:       v$DevFlowVersion",
    "Skills:        $($skillMap.Count) registered",
    "Current Dir:   $ProjectRoot"
)
Show-Box "Setup Information" $welcomeInfo

Write-Host ""
if (-not (Confirm-Continue "Press Enter to start setup")) {
    Write-Host ""
    Write-Host "  Setup cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 2/7: Host Detection
# ============================================================

Write-SectionHeader 2 7 "Host Environment Detection"

$HostType = "unknown"
if ($env:TRAE_IDE -or (Test-Path "$env:USERPROFILE\.trae-cn")) {
    $HostType = "TRAE"
} elseif (Test-Path ".git") {
    $HostType = "generic"
}

$hostInfo = @(
    ("[OK]   Host: $HostType"),
    ("[OK]   PowerShell: $($PSVersionTable.PSVersion)")
)
$gitVersion = $null
try { $gitVersion = & git --version 2>$null } catch {}
if ($gitVersion) {
    $hostInfo += ("[OK]   Git: $($gitVersion.ToString().Trim())")
} else {
    $hostInfo += ("[INFO] Git: not detected")
}
if ($HostType -eq "TRAE") {
    $hostInfo += ("[OK]   TRAE skills dir: $env:USERPROFILE\.trae-cn\skills")
}

Show-Box "Environment" $hostInfo

Write-Host ""
Write-Success "Host detected: $HostType"

if (-not (Confirm-Continue "Press Enter to continue")) {
    Write-Host "  Setup cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 3/7: Project Name Detection
# ============================================================

Write-SectionHeader 3 7 "Project Name Detection"

if (-not $ProjectName) {
    if (Test-Path "package.json") {
        $pkgRaw = [System.IO.File]::ReadAllText("package.json", [System.Text.Encoding]::UTF8)
        $pkg = $pkgRaw | ConvertFrom-Json
        $ProjectName = $pkg.name
        Write-Info "Detected from package.json"
    } elseif (Test-Path ".git") {
        $remote = git remote get-url origin 2>$null
        if ($remote) {
            $ProjectName = ($remote -split '/')[-1] -replace '\.git$', ''
            Write-Info "Detected from Git remote URL"
        }
    }
    if (-not $ProjectName) {
        $ProjectName = (Get-Item .).Name
        Write-Info "Using directory name as project name"
    }
}

Write-Success "Project name: $ProjectName"

# Ask user to confirm or override
Write-Host ""
$overrideName = Read-Host "  Project name [Enter to keep '$ProjectName']"
if ($overrideName) {
    $ProjectName = $overrideName
    Write-Success "Project name updated: $ProjectName"
}

if (-not (Confirm-Continue "Press Enter to continue")) {
    Write-Host "  Setup cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 4/7: Interactive Configuration (VR-002)
# ============================================================

Write-SectionHeader 4 7 "Interactive Project Configuration"

# --- 4a: Project Type ---
Write-SubSection "Project Type"

$projectTypeOptions = @(
    @{ Key = "1"; Value = "Web" },
    @{ Key = "2"; Value = "Mobile" },
    @{ Key = "3"; Value = "Backend Service" },
    @{ Key = "4"; Value = "Library / SDK" },
    @{ Key = "5"; Value = "Tool / CLI" },
    @{ Key = "6"; Value = "Other" }
)

# Auto-detect project type hints
$autoProjectHint = ""
if (Test-Path "package.json") { $autoProjectHint = "1" }
elseif (Test-Path "pom.xml" -or Test-Path "build.gradle" -or Test-Path "go.mod") { $autoProjectHint = "3" }
elseif (Test-Path "Cargo.toml" -or Test-Path "setup.py" -or Test-Path "pyproject.toml") { $autoProjectHint = "4" }

$defaultProjectType = if ($autoProjectHint) { $autoProjectHint } else { "1" }
$projectTypeChoice = Read-MenuChoice "Select project type:" $projectTypeOptions $defaultProjectType

$projectType = switch ($projectTypeChoice) {
    "1" { "web" }
    "2" { "mobile" }
    "3" { "backend" }
    "4" { "library" }
    "5" { "cli" }
    "6" { "other" }
}
Write-Success "Project type: $projectType"

# --- 4b: Development Mode ---
Write-SubSection "Development Mode"

$devModeOptions = @(
    @{ Key = "1"; Value = "Agile (recommended)" },
    @{ Key = "2"; Value = "Waterfall" },
    @{ Key = "3"; Value = "Hybrid" }
)
$devModeChoice = Read-MenuChoice "Select development mode:" $devModeOptions "1"

$developmentMode = switch ($devModeChoice) {
    "1" { "agile" }
    "2" { "waterfall" }
    "3" { "hybrid" }
}
Write-Success "Development mode: $developmentMode"

# --- 4c: Team Size ---
Write-SubSection "Team Size"

$teamSizeOptions = @(
    @{ Key = "1"; Value = "Personal (1 person)" },
    @{ Key = "2"; Value = "Small team (2-5 people)" },
    @{ Key = "3"; Value = "Large team (6+ people)" }
)
$teamSizeChoice = Read-MenuChoice "Select team size:" $teamSizeOptions "1"

$teamSize = switch ($teamSizeChoice) {
    "1" { "solo" }
    "2" { "small" }
    "3" { "large" }
}
Write-Success "Team size: $teamSize"

# --- 4d: Branch Strategy (override if non-default via param) ---
Write-SubSection "Branch Strategy"

$branchOptions = @(
    @{ Key = "1"; Value = "git-flow (recommended)" },
    @{ Key = "2"; Value = "feature-branch" },
    @{ Key = "3"; Value = "trunk-based" }
)
$branchDefault = switch ($BranchStrategy) {
    "git-flow"       { "1" }
    "feature-branch" { "2" }
    "trunk-based"    { "3" }
    default          { "1" }
}
$branchChoice = Read-MenuChoice "Select branch strategy:" $branchOptions $branchDefault

$BranchStrategy = switch ($branchChoice) {
    "1" { "git-flow" }
    "2" { "feature-branch" }
    "3" { "trunk-based" }
}
Write-Success "Branch strategy: $BranchStrategy"

# --- 4e: Remote Repository ---
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

# --- 4f: Configuration Summary ---
Write-Host ""
$configSummaryLines = @(
    "Project:          $ProjectName",
    "Project Type:     $projectType",
    "Development Mode: $developmentMode",
    "Team Size:        $teamSize",
    "Branch Strategy:  $BranchStrategy",
    "Origin:           $(if ($originUrl) { $originUrl } else { '(none)' })",
    "Backup:           $(if ($backupUrl) { $backupUrl } else { '(none)' })"
)
Show-Box "Configuration Summary" $configSummaryLines

if (-not (Confirm-Continue "Press Enter to continue")) {
    Write-Host "  Setup cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 5/7: Auto Phase Inference (VR-002)
# ============================================================

Write-SectionHeader 5 7 "Project Phase Inference"

Write-Host ""
Write-Host "  Analyzing project structure to infer current development phase..." -ForegroundColor DarkGray

$inferredPhase = "step_0_planning"
$phaseName     = "Step 0 Version Planning"
$inferenceLines = @()

# --- Check .devflow/state.json ---
$stateJsonPath = Join-Path ".devflow" "state.json"
if (Test-Path $stateJsonPath) {
    try {
        $stateRaw = [System.IO.File]::ReadAllText($stateJsonPath, [System.Text.Encoding]::UTF8)
        $existingState = $stateRaw | ConvertFrom-Json
        if ($existingState.currentPhase) {
            $inferredPhase = $existingState.currentPhase
            $phaseLabel = switch ($inferredPhase) {
                "step_0_planning"             { "Step 0 Version Planning" }
                "step_1_requirements"          { "Step 1 Requirements Analysis" }
                "step_2_design"               { "Step 2 Design" }
                "step_3_coding"               { "Step 3 Coding" }
                "step_4_testing"              { "Step 4 Testing" }
                "step_5_operations"           { "Step 5 Operations" }
                default                       { $inferredPhase }
            }
            $inferenceLines += "[INFO] Detected .devflow/state.json -> Phase: $inferredPhase"
        }
    } catch {
        $inferenceLines += "[WARN] Found .devflow/state.json but failed to parse"
    }
} else {
    $inferenceLines += "[INFO] No .devflow/state.json detected"
}

# --- Check doc/version/ ---
if (Test-Path "doc\version" -or Test-Path "docs\version") {
    $inferenceLines += "[INFO] Detected doc/version/ directory -> Step 0+ in progress"
    if ($inferredPhase -eq "step_0_planning") {
        $inferredPhase = "step_0_planning"
        $phaseName = "Step 0 Version Planning"
    }
} else {
    $inferenceLines += "[INFO] No doc/version/ directory detected"
}

# --- Check doc/requirements/ ---
if (Test-Path "doc\requirements" -or Test-Path "docs\requirements") {
    $inferenceLines += "[INFO] Detected doc/requirements/ directory -> Step 1+ confirmed"
    if ($inferredPhase -eq "step_0_planning") {
        $inferredPhase = "step_1_requirements"
    }
    $phaseName = "Step 1 Requirements Analysis"
} else {
    $inferenceLines += "[INFO] No doc/requirements/ directory detected"
}

# --- Check doc/design/ ---
if (Test-Path "doc\design" -or Test-Path "docs\design") {
    $inferenceLines += "[INFO] Detected doc/design/ directory -> Step 2+ confirmed"
    if ($inferredPhase -eq "step_0_planning" -or $inferredPhase -eq "step_1_requirements") {
        $inferredPhase = "step_2_design"
    }
    $phaseName = "Step 2 Design"
} else {
    $inferenceLines += "[INFO] No doc/design/ directory detected -> Design phase not yet started"
}

# --- Check src/ or code directories ---
$codeDirs = @("src", "lib", "app", "pkg", "cmd", "internal")
$hasCodeDir = $false
foreach ($dir in $codeDirs) {
    if (Test-Path $dir) {
        $hasCodeDir = $true
        $inferenceLines += "[INFO] Detected $dir/ directory -> Step 3+ in progress"
        break
    }
}
if (-not $hasCodeDir) {
    # Also check for code files in root
    $codeFiles = Get-ChildItem -File -ErrorAction SilentlyContinue | Where-Object {
        $_.Extension -match '\.(js|ts|py|go|java|rb|rs|cpp|c|cs|php|swift|kt)$'
    }
    if ($codeFiles) {
        $hasCodeDir = $true
        $inferenceLines += "[INFO] Detected source code files in root -> Step 3+ in progress"
    }
}
if ($hasCodeDir) {
    if ($inferredPhase -eq "step_0_planning" -or $inferredPhase -eq "step_1_requirements" -or $inferredPhase -eq "step_2_design") {
        $inferredPhase = "step_3_coding"
    }
    $phaseName = "Step 3 Coding"
}

# --- Check test/ ---
if (Test-Path "test" -or Test-Path "tests" -or Test-Path "__tests__" -or Test-Path "spec") {
    $inferenceLines += "[INFO] Detected test directory -> Step 4+ in progress"
    if ($inferredPhase -eq "step_0_planning" -or $inferredPhase -eq "step_1_requirements" -or $inferredPhase -eq "step_2_design" -or $inferredPhase -eq "step_3_coding") {
        $inferredPhase = "step_4_testing"
    }
    $phaseName = "Step 4 Testing"
} else {
    $inferenceLines += "[INFO] No test directory detected"
}

# --- Check Git branches ---
if (Test-Path ".git") {
    try {
        $branches = & git branch -a 2>$null
        $hasRelease = $false
        $hasMain = $false
        if ($branches) {
            foreach ($line in $branches) {
                if ($line -match "release/" -or $line -match "remotes/origin/release/") {
                    $hasRelease = $true
                }
                if ($line -match "^\*\s*main$" -or $line -match "^\*\s*master$" -or $line -match "remotes/origin/main$" -or $line -match "remotes/origin/master$") {
                    $hasMain = $true
                }
            }
        }
        if ($hasRelease) {
            $inferenceLines += "[INFO] Detected release/ branch -> Step 5 (Operations) likely"
            $inferredPhase = "step_5_operations"
            $phaseName = "Step 5 Operations"
        } elseif ($hasMain) {
            $inferenceLines += "[INFO] Detected main/master branch -> Project under active development"
        } else {
            $inferenceLines += "[INFO] Git repository detected but no protected branches found"
        }
    } catch {
        $inferenceLines += "[INFO] Could not inspect Git branches"
    }
}

# Normalize phase name from inferredPhase
$phaseName = switch ($inferredPhase) {
    "step_0_planning"    { "Step 0 Version Planning" }
    "step_1_requirements" { "Step 1 Requirements Analysis" }
    "step_2_design"      { "Step 2 Design" }
    "step_3_coding"      { "Step 3 Coding" }
    "step_4_testing"     { "Step 4 Testing" }
    "step_5_operations"  { "Step 5 Operations" }
    default              { $inferredPhase }
}

# --- Display inference results ---
Write-Host ""
Write-Host ("=" * 56) -ForegroundColor Cyan
Write-Host ("  Project Phase Inference") -ForegroundColor Cyan
Write-Host ("=" * 56) -ForegroundColor Cyan
foreach ($line in $inferenceLines) {
    if ($line -match "^\[INFO\]") {
        Write-Host ("  [INFO] " + ($line -replace '^\[INFO\] ', '')) -ForegroundColor Blue
    } elseif ($line -match "^\[WARN\]") {
        Write-Host ("  [WARN] " + ($line -replace '^\[WARN\] ', '')) -ForegroundColor Yellow
    }
}
Write-Host ("-" * 56) -ForegroundColor Cyan
Write-Host ("  Inference result: Current phase -> $phaseName") -ForegroundColor Green
Write-Host ("=" * 56) -ForegroundColor Cyan

# Ask user to confirm or override inferred phase
Write-Host ""
Write-Host "  Accept inferred phase or select manually?" -ForegroundColor White
Write-Host ""

$phaseOverrideOptions = @(
    @{ Key = "0"; Value = "Accept inferred: $phaseName" },
    @{ Key = "1"; Value = "Step 0 - Version Planning" },
    @{ Key = "2"; Value = "Step 1 - Requirements Analysis" },
    @{ Key = "3"; Value = "Step 2 - Design" },
    @{ Key = "4"; Value = "Step 3 - Coding" },
    @{ Key = "5"; Value = "Step 4 - Testing" },
    @{ Key = "6"; Value = "Step 5 - Operations" }
)
$phaseChoice = Read-MenuChoice "Select project phase:" $phaseOverrideOptions "0"

if ($phaseChoice -ne "0") {
    $inferredPhase = switch ($phaseChoice) {
        "1" { "step_0_planning" }
        "2" { "step_1_requirements" }
        "3" { "step_2_design" }
        "4" { "step_3_coding" }
        "5" { "step_4_testing" }
        "6" { "step_5_operations" }
    }
    $phaseName = switch ($phaseChoice) {
        "1" { "Step 0 Version Planning" }
        "2" { "Step 1 Requirements Analysis" }
        "3" { "Step 2 Design" }
        "4" { "Step 3 Coding" }
        "5" { "Step 4 Testing" }
        "6" { "Step 5 Operations" }
    }
    Write-Success "Phase overridden to: $phaseName"
} else {
    Write-Success "Phase accepted: $phaseName"
}

if (-not (Confirm-Continue "Press Enter to continue")) {
    Write-Host "  Setup cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 6/7: File Generation
# ============================================================

Write-SectionHeader 6 7 "Configuration File Generation"

# --- 6a: Create .devflow directory ---
Write-SubSection "Creating .devflow Directory"

$DevFlowDir = ".devflow"
if (Test-Path $DevFlowDir) {
    Write-Info "Directory .devflow already exists"
} else {
    New-Item -ItemType Directory -Path $DevFlowDir -Force | Out-Null
    Write-Success "Created: $DevFlowDir"
}

# --- 6b: Generate config.json (VR-002 enhanced) ---
Write-SubSection "Generating config.json"

if (-not $SkipConfig) {
    $config = @{
        project        = $ProjectName
        devflowVersion = $DevFlowVersion
        branchStrategy = $BranchStrategy
        projectType    = $projectType
        developmentMode = $developmentMode
        teamSize       = $teamSize
        remote         = @{
            origin = if ($originUrl) { $originUrl } else { "" }
            backup = if ($backupUrl) { $backupUrl } else { "" }
        }
        backup         = @{
            type     = "git-mirror"
            schedule = @{
                bundle          = "weekly"
                bundleRetention = 4
                dbDump          = "daily"
                dbRetention     = 90
            }
        }
    }

    $configPath = Join-Path $DevFlowDir "config.json"
    $config | ConvertTo-Json -Depth 4 | Set-Content $configPath -Encoding UTF8
    Write-Success "Created: $configPath"
} else {
    Write-Info "config.json generation skipped (-SkipConfig)"
}

# --- 6c: Generate state.json ---
Write-SubSection "Generating state.json"

# Build completedPhases based on inferred phase
$completedPhases = @()
$phaseOrder = @(
    "step_0_planning",
    "step_1_requirements",
    "step_2_design",
    "step_3_coding",
    "step_4_testing",
    "step_5_operations"
)
$phaseIndex = [array]::IndexOf($phaseOrder, $inferredPhase)
for ($i = 0; $i -lt $phaseIndex; $i++) {
    $completedPhases += $phaseOrder[$i]
}

$state = @{
    project          = $ProjectName
    version          = ""
    currentPhase     = $inferredPhase
    completedPhases  = $completedPhases
    currentDocuments = @{}
    auditResults     = @{}
}
$statePath = Join-Path $DevFlowDir "state.json"
$state | ConvertTo-Json -Depth 4 | Set-Content $statePath -Encoding UTF8
Write-Success "Created: $statePath"
Write-Success "Initial phase set to: $inferredPhase ($phaseName)"

# Verify generated files
Write-Host ""
$genVerify = @()
if (Test-Path $configPath) {
    $genVerify += "[OK]   config.json"
} else {
    $genVerify += "[FAIL] config.json"
}
if (Test-Path $statePath) {
    $genVerify += "[OK]   state.json"
} else {
    $genVerify += "[FAIL] state.json"
}
Show-Box "File Generation" $genVerify

if (-not (Confirm-Continue "Press Enter to continue")) {
    Write-Host "  Setup cancelled by user." -ForegroundColor Yellow
    exit 0
}

# ============================================================
# Step 7/7: Install Skills to TRAE
# ============================================================

Write-SectionHeader 7 7 "Install DevFlow Skills to TRAE"

if ($SkipSkills -or $HostType -ne "TRAE") {
    if ($HostType -ne "TRAE") {
        Write-Info "TRAE host not detected, skill installation skipped"
    } else {
        Write-Info "Skill installation skipped (-SkipSkills)"
    }
} else {
    Write-SubSection "Installing Skills"

    $TraeSkillsDir = "$env:USERPROFILE\.trae-cn\skills"
    $sortedSkills  = $skillMap.Keys | Sort-Object
    $totalSkills   = @($sortedSkills).Count
    $skillOk       = 0
    $skillFail     = 0
    $skillSkip     = 0

    Write-Host ""
    Write-Host ("  Total skills to install: $totalSkills") -ForegroundColor DarkGray
    Write-Host ""

    foreach ($skill in $sortedSkills) {
        $src = Join-Path $ScriptDir $skillMap[$skill]
        $dst = Join-Path $TraeSkillsDir "$skill\SKILL.md"

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
                $skillOk++
                Write-Success "Installed: $skill"
            } else {
                $skillSkip++
                Write-Warn "Skill source not found: $skill"
            }
        } catch {
            $skillFail++
            Write-Fail "Failed to install: $skill - $_"
        }
    }

    Write-Host ""
    Write-Host ("  Results: $skillOk succeeded, $skillFail failed, $skillSkip skipped") -ForegroundColor DarkGray
}

# ============================================================
# Install Git Hook (optional)
# ============================================================

if ($InstallHook -and (Test-Path ".git")) {
    Write-SubSection "Installing Git Post-Push Hook"
    $hookDir = ".git\hooks"
    $hookPath = Join-Path $hookDir "post-push"
    $hookContent = @'
#!/bin/bash
# DevFlow auto-backup hook
if git remote | grep -q backup; then
    echo "[DevFlow] Pushing mirror to backup remote..."
    git push --mirror backup
    git push --tags backup
fi
'@
    Set-Content $hookPath $hookContent -Encoding UTF8
    Write-Success "Installed: $hookPath"
}

# ============================================================
# Final Summary
# ============================================================

Write-Banner "Setup Complete"

$summaryLines = @(
    "Project:           $ProjectName",
    "DevFlow Version:   v$DevFlowVersion",
    "",
    "Configuration:",
    "  Project Type:     $projectType",
    "  Development Mode: $developmentMode",
    "  Team Size:        $teamSize",
    "  Branch Strategy:  $BranchStrategy",
    "  Inferred Phase:   $phaseName",
    "",
    "Generated Files:",
    "  config.json      .devflow\config.json",
    "  state.json       .devflow\state.json"
)

if (-not $SkipSkills -and $HostType -eq "TRAE") {
    $summaryLines += ""
    $summaryLines += "Skills:           Installed to TRAE skills directory"
}
if ($InstallHook -and (Test-Path ".git")) {
    $summaryLines += "Git Hook:         post-push installed"
}

Show-Box "Setup Summary" $summaryLines

Write-Host ""
Write-Host "  Next steps:" -ForegroundColor White
Write-Host ""
Write-Host "    1. Open TRAE and invoke the skill: devflow-init" -ForegroundColor DarkGray
Write-Host "    2. Edit .devflow\config.json to adjust settings" -ForegroundColor DarkGray
Write-Host "    3. Run '.\update.ps1' to update skills when new versions are available" -ForegroundColor DarkGray
Write-Host "    4. Start development from inferred phase: $phaseName" -ForegroundColor DarkGray
Write-Host ""
