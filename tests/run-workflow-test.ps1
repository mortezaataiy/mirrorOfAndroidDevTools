# Run Workflow Test
Write-Host "🧪 Running workflow test" -ForegroundColor Cyan

$ghPath = "C:\Program Files\GitHub CLI\gh.exe"

if (Test-Path $ghPath) {
    Write-Host "✅ GitHub CLI found" -ForegroundColor Green
    
    Write-Host "🚀 Running workflow..." -ForegroundColor Yellow
    & $ghPath workflow run "android-version-checker.yml" --field force_run=true
    
    Write-Host "📋 Run list:" -ForegroundColor Yellow
    & $ghPath run list --workflow="android-version-checker.yml" --limit=3
    
    Write-Host "✅ Test completed" -ForegroundColor Green
} else {
    Write-Host "❌ GitHub CLI not found" -ForegroundColor Red
}