# DevFlow v2.3.1 技能安装脚本
# 运行方式：在 PowerShell 中执行本脚本

$ErrorActionPreference = "Stop"

$src = "c:\Users\zkja\.trae-cn\work\6a40c3ee98c0cf99f2bbbb67\devflow-download\devflow-plugin"
$dst = "$env:USERPROFILE\.trae-cn\skills"

$files = @(
    @{src="skills\L1\project-development-workflow.md";   name="project-development-workflow"}
    @{src="skills\L1\project-document-management.md";    name="project-document-management"}
    @{src="skills\L1\project-role-management.md";        name="project-role-management"}
    @{src="skills\L2\version-planning-stage-execution.md"; name="version-planning-stage-execution"}
    @{src="skills\L2\requirements-stage-execution.md";   name="requirements-stage-execution"}
    @{src="skills\L2\design-stage-execution.md";         name="design-stage-execution"}
    @{src="skills\L2\coding-stage-execution.md";         name="coding-stage-execution"}
    @{src="skills\L2\testing-stage-execution.md";        name="testing-stage-execution"}
    @{src="skills\L2\operations-stage-execution.md";     name="operations-stage-execution"}
    @{src="skills\L3\project-coding-conventions.md";     name="project-coding-conventions"}
    @{src="skills\L3\code-static-quality-check.md";      name="code-static-quality-check"}
    @{src="skills\L3\code-logic-review.md";              name="code-logic-review"}
    @{src="skills\L3\cicd-pipeline-management.md";       name="cicd-pipeline-management"}
    @{src="skills\L3\observability-standards.md";        name="observability-standards"}
    @{src="skills\L3\project-document-templates.md";     name="project-document-templates"}
    @{src="skills\L3\code-version-backup-management.md"; name="code-version-backup-management"}
    @{src="devflow-init\SKILL.md";                       name="devflow-init"}
    @{src="devflow-phase-manager\SKILL.md";              name="devflow-phase-manager"}
    @{src="devflow-project-config\SKILL.md";             name="devflow-project-config"}
)

Write-Host "=== DevFlow v2.3.1 技能安装 ===" -ForegroundColor Cyan
Write-Host "源目录: $src"
Write-Host "目标目录: $dst"
Write-Host ""

$okCount = 0
$errCount = 0
foreach ($f in $files) {
    $targetDir = Join-Path $dst $f.name
    $srcFile = Join-Path $src $f.src
    $destFile = Join-Path $targetDir "SKILL.md"
    
    try {
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        Copy-Item -Path $srcFile -Destination $destFile -Force
        Write-Host "[OK] $($f.name)" -ForegroundColor Green
        $okCount++
    } catch {
        Write-Host "[ERR] $($f.name): $_" -ForegroundColor Red
        $errCount++
    }
}

Write-Host ""
Write-Host "安装完成：$okCount 成功, $errCount 失败" -ForegroundColor $(if ($errCount -gt 0) { "Yellow" } else { "Green" })
