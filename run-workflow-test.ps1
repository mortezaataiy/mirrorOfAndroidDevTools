# Run Workflow Test
Write-Host "🧪 تست اجرای workflow" -ForegroundColor Cyan

$ghPath = "C:\Program Files\GitHub CLI\gh.exe"

if (Test-Path $ghPath) {
    Write-Host "✅ GitHub CLI یافت شد" -ForegroundColor Green
    
    Write-Host "🚀 اجرای workflow..." -ForegroundColor Yellow
    & $ghPath workflow run "android-version-checker.yml" --field force_run=true
    
    Write-Host "📋 لیست اجراها:" -ForegroundColor Yellow
    & $ghPath run list --workflow="android-version-checker.yml" --limit=3
    
    Write-Host "✅ تست تکمیل شد" -ForegroundColor Green
} else {
    Write-Host "❌ GitHub CLI یافت نشد" -ForegroundColor Red
}