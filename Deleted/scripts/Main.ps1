# Main Script - Android Version Compatibility Checker
# اسکریپت اصلی برای بررسی سازگاری ورژن‌های اندروید

param(
    [string]$OutputPath = ".",
    [switch]$SkipInstall,
    [switch]$SkipBuild,
    [switch]$Verbose
)

# تنظیم verbose logging
if ($Verbose) {
    $VerbosePreference = "Continue"
}

# Import all required modules
Write-Host "شروع بررسی سازگاری ورژن‌های اندروید" -ForegroundColor Cyan
Write-Host "تاریخ: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow

try {
    # Import modules
    Write-Host "بارگذاری ماژول‌ها..." -ForegroundColor Yellow
    . "$PSScriptRoot\ErrorHandler.ps1"
    . "$PSScriptRoot\VersionDiscovery.ps1"
    . "$PSScriptRoot\DownloadValidator.ps1"
    . "$PSScriptRoot\ToolInstaller.ps1"
    . "$PSScriptRoot\HelloWorldBuilder.ps1"
    . "$PSScriptRoot\YamlDatabaseManager.ps1"
    
    Write-ActivityLog -Message "تمام ماژول‌ها بارگذاری شدند" -Level "SUCCESS"
    
    # مرحله 1: شناسایی ورژن‌ها
    Write-ActivityLog -Message "=== مرحله 1: شناسایی ورژن‌ها ===" -Level "INFO"
    $tools = Get-AllLatestVersions
    
    if ($tools.Count -eq 0) {
        throw "هیچ ابزاری شناسایی نشد"
    }
    
    Write-ActivityLog -Message "$($tools.Count) ابزار شناسایی شد" -Level "SUCCESS"
    
    # مرحله 2: اعتبارسنجی لینک‌ها
    Write-ActivityLog -Message "=== مرحله 2: اعتبارسنجی لینک‌ها ===" -Level "INFO"
    $validationResults = @{}
    $validCount = 0
    
    foreach ($tool in $tools) {
        Write-ActivityLog -Message "تست لینک $($tool.Name)..." -Level "INFO"
        
        $validation = Test-DownloadLink -Url $tool.DownloadUrl -MinSize 1MB
        $validationResults[$tool.Name] = $validation
        
        if ($validation.Valid) {
            Write-ActivityLog -Message "$($tool.Name) - لینک معتبر" -Level "SUCCESS"
            $validCount++
        }
        else {
            Write-ActivityLog -Message "$($tool.Name) - لینک نامعتبر: $($validation.Error)" -Level "ERROR"
        }
    }
    
    Write-ActivityLog -Message "$validCount از $($tools.Count) لینک معتبر است" -Level "INFO"
    
    if ($validCount -eq 0) {
        throw "هیچ لینک معتبری پیدا نشد"
    }
    
    # مرحله 3: نصب ابزارها (اختیاری)
    $installSuccess = $true
    if (-not $SkipInstall) {
        Write-ActivityLog -Message "=== مرحله 3: نصب ابزارها ===" -Level "INFO"
        
        # فیلتر کردن ابزارهای معتبر
        $validTools = $tools | Where-Object { $validationResults[$_.Name].Valid }
        
        if ($validTools.Count -gt 0) {
            $installSuccess = Install-AllTools -Tools $validTools
            
            if ($installSuccess) {
                Write-ActivityLog -Message "تمام ابزارها با موفقیت نصب شدند" -Level "SUCCESS"
            }
            else {
                Write-ActivityLog -Message "برخی ابزارها نصب نشدند" -Level "WARNING"
            }
        }
        else {
            Write-ActivityLog -Message "هیچ ابزار معتبری برای نصب وجود ندارد" -Level "WARNING"
            $installSuccess = $false
        }
    }
    else {
        Write-ActivityLog -Message "نصب ابزارها رد شد (SkipInstall)" -Level "INFO"
    }
    
    # مرحله 4: ایجاد و بیلد Hello World (اختیاری)
    $buildSuccess = $false
    $buildResult = $null
    
    if (-not $SkipBuild -and $installSuccess) {
        Write-ActivityLog -Message "=== مرحله 4: ایجاد و بیلد Hello World ===" -Level "INFO"
        
        try {
            $projectDir = Join-Path $OutputPath "HelloWorldProjects"
            $projectResult = New-CompleteHelloWorldProject -ProjectPath $projectDir
            
            if ($projectResult.Success) {
                Write-ActivityLog -Message "پروژه Hello World با موفقیت ایجاد و بیلد شد" -Level "SUCCESS"
                $buildSuccess = $true
                $buildResult = $projectResult.BuildResult
                
                if ($buildResult.ApkPath -and (Test-Path $buildResult.ApkPath)) {
                    $apkSize = (Get-Item $buildResult.ApkPath).Length
                    Write-ActivityLog -Message "فایل APK تولید شد: $([math]::Round($apkSize/1MB, 2)) MB" -Level "SUCCESS"
                }
            }
            else {
                Write-ActivityLog -Message "بیلد Hello World ناموفق بود: $($projectResult.Error)" -Level "ERROR"
            }
        }
        catch {
            Write-ActivityLog -Message "خطا در بیلد Hello World: $($_.Exception.Message)" -Level "ERROR"
        }
    }
    else {
        if ($SkipBuild) {
            Write-ActivityLog -Message "بیلد Hello World رد شد (SkipBuild)" -Level "INFO"
        }
        else {
            Write-ActivityLog -Message "بیلد Hello World رد شد (نصب ناموفق)" -Level "WARNING"
        }
    }
    
    # مرحله 5: به‌روزرسانی پایگاه داده
    Write-ActivityLog -Message "=== مرحله 5: به‌روزرسانی پایگاه داده ===" -Level "INFO"
    
    try {
        $updateResult = Update-VersionDatabase -Tools $tools -OutputPath $OutputPath -HelloWorldBuildSuccess $buildSuccess
        
        if ($updateResult.Success) {
            Write-ActivityLog -Message "پایگاه داده با موفقیت به‌روزرسانی شد" -Level "SUCCESS"
            Write-ActivityLog -Message "فایل ذخیره شد: $($updateResult.FilePath)" -Level "INFO"
        }
        else {
            Write-ActivityLog -Message "خطا در به‌روزرسانی پایگاه داده: $($updateResult.Error)" -Level "ERROR"
        }
    }
    catch {
        Write-ActivityLog -Message "خطا در به‌روزرسانی پایگاه داده: $($_.Exception.Message)" -Level "ERROR"
    }
    
    # مرحله 6: تولید گزارش نهایی
    Write-ActivityLog -Message "=== مرحله 6: گزارش نهایی ===" -Level "INFO"
    
    $summary = @{
        ExecutionDate = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        TotalTools = $tools.Count
        ValidLinks = $validCount
        InstallationSuccess = $installSuccess
        HelloWorldBuildSuccess = $buildSuccess
        DatabaseUpdated = $updateResult.Success
        Tools = @()
    }
    
    foreach ($tool in $tools) {
        $toolSummary = @{
            Name = $tool.Name
            Version = $tool.Version
            DownloadUrl = $tool.DownloadUrl
            LinkValid = $validationResults[$tool.Name].Valid
            InstallStatus = $tool.TestStatus
            InstallPath = $tool.InstallPath
        }
        $summary.Tools += $toolSummary
    }
    
    # ذخیره گزارش JSON
    $summaryPath = Join-Path $OutputPath "execution-summary.json"
    $summary | ConvertTo-Json -Depth 3 | Out-File -FilePath $summaryPath -Encoding UTF8
    Write-ActivityLog -Message "گزارش اجرا ذخیره شد: $summaryPath" -Level "SUCCESS"
    
    # نمایش خلاصه نهایی
    Write-ActivityLog -Message "=== خلاصه نهایی ===" -Level "INFO"
    Write-ActivityLog -Message "ابزارهای شناسایی شده: $($tools.Count)" -Level "SUCCESS"
    Write-ActivityLog -Message "لینک‌های معتبر: $validCount" -Level "SUCCESS"
    
    $installStatusText = if ($installSuccess) { "موفق" } else { "ناموفق" }
    $installStatusLevel = if ($installSuccess) { "SUCCESS" } else { "ERROR" }
    Write-ActivityLog -Message "نصب ابزارها: $installStatusText" -Level $installStatusLevel
    
    $buildStatusText = if ($buildSuccess) { "موفق" } else { "ناموفق" }
    $buildStatusLevel = if ($buildSuccess) { "SUCCESS" } else { "ERROR" }
    Write-ActivityLog -Message "بیلد Hello World: $buildStatusText" -Level $buildStatusLevel
    
    $dbStatusText = if ($updateResult.Success) { "موفق" } else { "ناموفق" }
    $dbStatusLevel = if ($updateResult.Success) { "SUCCESS" } else { "ERROR" }
    Write-ActivityLog -Message "به‌روزرسانی پایگاه داده: $dbStatusText" -Level $dbStatusLevel
    
    # نمایش خلاصه خطاها
    Show-ErrorSummary
    Show-ActivitySummary
    
    # ذخیره لاگ‌ها
    $logPath = Join-Path $OutputPath "logs"
    Save-LogsToFile -OutputPath $logPath
    
    Write-ActivityLog -Message "اجرا با موفقیت کامل شد!" -Level "SUCCESS"
    
    # تعیین exit code
    if ($buildSuccess -or $SkipBuild) {
        exit 0
    }
    else {
        exit 1
    }
}
catch {
    Write-ActivityLog -Message "خطای کلی در اجرا: $($_.Exception.Message)" -Level "ERROR"
    Handle-Error -ErrorType ([ErrorType]::ConfigurationError) -ErrorMessage $_.Exception.Message -Context "Main Execution"
    
    # ذخیره لاگ‌های خطا
    $logPath = Join-Path $OutputPath "logs"
    Save-LogsToFile -OutputPath $logPath
    
    Show-ErrorSummary
    exit 1
}
finally {
    Write-Host "پایان اجرا" -ForegroundColor Cyan
}