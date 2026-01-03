# Workflow Test Script
Write-Host "Testing GitHub Workflow" -ForegroundColor Cyan

$ghPath = "C:\Program Files\GitHub CLI\gh.exe"

if (Test-Path $ghPath) {
    Write-Host "GitHub CLI found" -ForegroundColor Green
    
    Write-Host "Running workflow..." -ForegroundColor Yellow
    & $ghPath workflow run "android-version-checker.yml" --field force_run=true
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "Workflow started successfully" -ForegroundColor Green
        
        Write-Host "Recent runs:" -ForegroundColor Yellow
        & $ghPath run list --workflow="android-version-checker.yml" --limit=3
    } else {
        Write-Host "Failed to start workflow" -ForegroundColor Red
    }
} else {
    Write-Host "GitHub CLI not found at: $ghPath" -ForegroundColor Red
    Write-Host "Please install GitHub CLI from: https://cli.github.com/" -ForegroundColor Yellow
}