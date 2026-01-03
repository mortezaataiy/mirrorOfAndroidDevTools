# Test Workflow Script
# اسکریپت تست workflow توسط GitHub CLI

param(
    [switch]$WaitForCompletion,
    [int]$TimeoutMinutes = 60
)

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
    $authStatus = & $ghPath auth status 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ احراز هویت GitHub ناموفق است"
        Write-Host "💡 لطفاً با دستور زیر احراز هویت کنید:" -ForegroundColor Yellow
        Write-Host "gh auth login" -ForegroundColor Cyan
        exit 1
    }
    
    Write-Host "✅ احراز هویت GitHub موفق است" -ForegroundColor Green
    
    # اجرای workflow
    Write-Host "🚀 اجرای workflow..." -ForegroundColor Cyan
    $runResult = & $ghPath workflow run "android-version-checker.yml" --field force_run=true 2>&1
    
    if ($LASTEXITCODE -ne 0) {
        Write-Error "❌ خطا در اجرای workflow: $runResult"
        exit 1
    }
    
    Write-Host "✅ Workflow با موفقیت شروع شد" -ForegroundColor Green
    
    # انتظار برای تکمیل (اختیاری)
    if ($WaitForCompletion) {
        Write-Host "⏳ انتظار برای تکمیل workflow..." -ForegroundColor Yellow
        Write-Host "⏱️ حداکثر انتظار: $TimeoutMinutes دقیقه" -ForegroundColor Yellow
        
        $startTime = Get-Date
        $timeoutTime = $startTime.AddMinutes($TimeoutMinutes)
        
        do {
            Start-Sleep -Seconds 30
            
            # دریافت آخرین اجرا
            $runs = & $ghPath run list --workflow="android-version-checker.yml" --limit=1 --json=status,conclusion,createdAt,url 2>&1 | ConvertFrom-Json
            
            if ($runs -and $runs.Count -gt 0) {
                $latestRun = $runs[0]
                $status = $latestRun.status
                $conclusion = $latestRun.conclusion
                
                Write-Host "📊 وضعیت فعلی: $status" -ForegroundColor Cyan
                
                if ($status -eq "completed") {
                    if ($conclusion -eq "success") {
                        Write-Host "🎉 Workflow با موفقیت تکمیل شد!" -ForegroundColor Green
                        Write-Host "🔗 لینک: $($latestRun.url)" -ForegroundColor Blue
                        break
                    }
                    if ($conclusion -eq "failure") {
                        Write-Host "❌ Workflow با خطا تکمیل شد" -ForegroundColor Red
                        Write-Host "🔗 لینک: $($latestRun.url)" -ForegroundColor Blue
                        break
                    }
                    if ($conclusion -ne "success" -and $conclusion -ne "failure") {
                        Write-Host "⚠️ Workflow تکمیل شد با وضعیت: $conclusion" -ForegroundColor Yellow
                        Write-Host "🔗 لینک: $($latestRun.url)" -ForegroundColor Blue
                        break
                    }
                }
            }
            
            $currentTime = Get-Date
            if ($currentTime -gt $timeoutTime) {
                Write-Host "⏰ زمان انتظار تمام شد" -ForegroundColor Yellow
                break
            }
            
        } while ($true)
    }
    
    # نمایش آخرین اجراها
    Write-Host "📋 آخرین اجراهای workflow:" -ForegroundColor Cyan
    & $ghPath run list --workflow="android-version-checker.yml" --limit=5
    
    # دریافت ID آخرین اجرا
    $latestRunId = & $ghPath run list --workflow="android-version-checker.yml" --limit=1 --json=databaseId 2>&1 | ConvertFrom-Json | Select-Object -ExpandProperty databaseId
    
    if ($latestRunId) {
        Write-Host "🆔 ID آخرین اجرا: $latestRunId" -ForegroundColor Yellow
        
        # پیشنهاد دستورات مفید
        Write-Host "💡 دستورات مفید:" -ForegroundColor Yellow
        Write-Host "  📊 مشاهده جزئیات: gh run view $latestRunId" -ForegroundColor Cyan
        Write-Host "  📥 دانلود artifacts: gh run download $latestRunId" -ForegroundColor Cyan
        Write-Host "  📜 مشاهده لاگ‌ها: gh run view $latestRunId --log" -ForegroundColor Cyan
        
        # تلاش برای دانلود artifacts (اختیاری)
        $downloadChoice = Read-Host "آیا می‌خواهید artifacts را دانلود کنید؟ (y/N)"
        if ($downloadChoice -eq "y" -or $downloadChoice -eq "Y") {
            Write-Host "📥 دانلود artifacts..." -ForegroundColor Cyan
            
            $downloadResult = & $ghPath run download $latestRunId 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host "✅ Artifacts با موفقیت دانلود شدند" -ForegroundColor Green
                
                # نمایش فایل‌های دانلود شده
                if (Test-Path "android-version-check-results") {
                    Write-Host "📁 فایل‌های دانلود شده:" -ForegroundColor Yellow
                    Get-ChildItem "android-version-check-results" -Recurse | ForEach-Object {
                        Write-Host "  📄 $($_.FullName)" -ForegroundColor White
                    }
                    
                    # بررسی فایل YAML
                    $yamlFile = Get-ChildItem "android-version-check-results" -Filter "*.yml" -Recurse | Select-Object -First 1
                    if ($yamlFile) {
                        Write-Host "📋 محتوای فایل YAML:" -ForegroundColor Cyan
                        Get-Content $yamlFile.FullName | Select-Object -First 20
                        if ((Get-Content $yamlFile.FullName).Count -gt 20) {
                            Write-Host "... (ادامه در فایل)" -ForegroundColor Gray
                        }
                    }
                    
                    # بررسی گزارش خلاصه
                    $summaryFile = Get-ChildItem "android-version-check-results" -Filter "summary-report.md" -Recurse | Select-Object -First 1
                    if ($summaryFile) {
                        Write-Host "📊 گزارش خلاصه:" -ForegroundColor Cyan
                        Get-Content $summaryFile.FullName
                    }
                }
            } else {
                Write-Host "⚠️ خطا در دانلود artifacts: $downloadResult" -ForegroundColor Yellow
            }
        }
    }
    
    Write-Host "✅ تست workflow با موفقیت انجام شد" -ForegroundColor Green
}
catch {
    Write-Error "❌ خطا در تست workflow: $($_.Exception.Message)"
    exit 1
}
finally {
    Write-Host "🏁 پایان تست" -ForegroundColor Cyan
}