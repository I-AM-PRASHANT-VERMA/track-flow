# Local presubmit: runs the same checks as the CI gate, in the same order. Run before every push.
#   pwsh -File scripts\presubmit.ps1            (format check is reported, not blocking until the format commit lands)
#   pwsh -File scripts\presubmit.ps1 -Strict    (exactly what CI enforces)
param([switch]$Strict)
$ErrorActionPreference = 'Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)

function Step([string]$name, [scriptblock]$body, [bool]$blocking = $true) {
  Write-Host "== $name" -ForegroundColor Cyan
  & $body
  if ($LASTEXITCODE -ne 0) {
    if ($blocking) { Write-Host "FAILED: $name" -ForegroundColor Red; exit $LASTEXITCODE }
    Write-Host "WARN (not blocking yet): $name" -ForegroundColor Yellow
  }
}

Step 'format'   { dart format --output=none --set-exit-if-changed lib test tool } $Strict.IsPresent
Step 'analyze'  { flutter analyze --no-pub }
Step 'tests'    { flutter test --no-pub --coverage }
Step 'coverage' { dart run tool/coverage_gate.dart coverage/lcov.info tool/coverage_threshold.txt }
Write-Host 'presubmit OK' -ForegroundColor Green
