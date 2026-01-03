# Simple Test Workflow Script
# اسکریپت ساده تست workflow

Write-Host "🧪 شروع تست GitHub Action Workflow" -ForegroundColor Cyan
Write-Host "📅 تاریخ: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

# بررسی وجود GitHub CLI
$ghPath = "C:\Program Files\GitHub CLI\gh.exe"
if (-not (Test-Path $ghPath)) {
    Write-Error "❌ GitHub CLI یافت نشد در مسیر: $ghPath"
    Write-Host "💡 لطفاً GitHub CLI را نصب کنید: https://cli.github.com/" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ GitHub CLI یافت شد" -ForegroundColor Green

try {
    # بررسی وضعیت احراز هویت
    Write-Host "🔐 بررسی احراز هویت GitHub..." -ForegroundColor Yellow
    $authResult = & $ghPath auth status 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ احراز هویت GitHub ناموفق است" -ForegroundColor Red
        Write-Host "💡 لطفاً با دستور زیر احراز هویت کنید:" -ForegroundColor Yellow
        Write-Host "gh auth login" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "✅ احراز هویت GitHub موفق است" -ForegroundColor Green
    
    # اجرای workflow
    Write-Host "🚀 اجرای workflow..." -ForegroundColor Cyan
    $runResult = & $ghPath workflow run "android-version-checker.yml" --field force_run=true 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ خطا در اجرای workflow: $runResult" -ForegroundColor Red
        exit 1
    }
    
    Write-Host "✅ Workflow با موفقیت شروع شد" -ForegroundColor Green
    
    # نمایش آخرین اجراها
    Write-Host "📋 آخرین اجراهای workflow:" -ForegroundColor Cyan
    & $ghPath run list --workflow="android-version-checker.yml" --limit=5
    
    # دریافت ID آخرین اجرا
    Write-Host "🔍 دریافت ID آخرین اجرا..." -ForegroundColor Yellow
    $runListOutput = & $ghPath run list --workflow="android-version-checker.yml" --limit=1 --json=databaseId 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $runData = $runListOutput | ConvertFrom-Json
        if ($runData -and $runData.databaseId) {
            $latestRunId = $runData.databaseId
            Write-Host "🆔 ID آخرین اجرا: $latestRunId" -ForegroundColor Yellow
            
            # پیشنهاد دستورات مفید
            Write-Host "💡 دستورات مفید:" -ForegroundColor Yellow
            Write-Host "  📊 مشاهده جزئیات: gh run view $latestRunId" -ForegroundColor Cyan
            Write-Host "  📥 دانلود artifacts: gh run download $latestRunId" -ForegroundColor Cyan
            Write-Host "  📜 مشاهده لاگ‌ها: gh run view $latestRunId --log" -ForegroundColor Cyan
        }
    }
    
    Write-Host "✅ تست workflow با موفقیت انجام شد" -ForegroundColor Green
}
catch {
    Write-Host "❌ خطا در تست workflow: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
finally {
    Write-Host "🏁 پایان تست" -ForegroundColor Cyan
}