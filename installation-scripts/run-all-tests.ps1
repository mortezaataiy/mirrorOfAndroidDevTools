# اجرای تمام تست‌ها
# این اسکریپت تمام اسکریپت‌های تست را اجرا می‌کند و گزارش جامع تولید می‌کند

param(
    [switch]$Verbose,
    [switch]$ContinueOnError,
    [string]$ReportPath = "test-report.html"
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path $ScriptDir "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "All-Tests" -Verbose:$Verbose

try {
    Write-LogInfo "شروع تست تمام کامپوننت‌های Android Development Tools..."
    
    # لیست کامپوننت‌ها
    $Components = @(
        @{ Name = "JDK 17"; Path = "jdk17\03-test-installation.ps1"; Required = $true },
        @{ Name = "Android Studio"; Path = "android-studio\03-test-installation.ps1"; Required = $true },
        @{ Name = "Gradle"; Path = "gradle\03-test-installation.ps1"; Required = $true },
        @{ Name = "Command Line Tools"; Path = "commandline-tools\03-test-installation.ps1"; Required = $true },
        @{ Name = "Platform Tools"; Path = "platform-tools\03-test-installation.ps1"; Required = $true },
        @{ Name = "Build Tools"; Path = "build-tools\03-test-installation.ps1"; Required = $false },
        @{ Name = "SDK Platforms"; Path = "sdk-platforms\03-test-installation.ps1"; Required = $false },
        @{ Name = "System Images"; Path = "system-images\03-test-installation.ps1"; Required = $false },
        @{ Name = "Repositories"; Path = "repositories\03-test-installation.ps1"; Required = $false }
    )
    
    $Results = @{}
    $SuccessCount = 0
    $FailureCount = 0
    $SkippedCount = 0
    $TotalStartTime = Get-Date
    
    Write-LogInfo "تست $($Components.Count) کامپوننت..."
    Write-LogInfo "=" * 60
    
    foreach ($Component in $Components) {
        $ComponentPath = Join-Path $ScriptDir $Component.Path
        
        Write-LogInfo "تست $($Component.Name)..."
        
        if (-not (Test-Path $ComponentPath)) {
            Write-LogWarning "اسکریپت تست یافت نشد: $ComponentPath"
            $Results[$Component.Name] = @{
                Status = "Skipped"
                Message = "اسکریپت یافت نشد"
                ExitCode = -1
                Required = $Component.Required
            }
            $SkippedCount++
            continue
        }
        
        try {
            # اجرای اسکریپت تست
            $StartTime = Get-Date
            
            if ($Verbose) {
                $Output = & PowerShell -File $ComponentPath -Verbose 2>&1
            } else {
                $Output = & PowerShell -File $ComponentPath 2>&1
            }
            
            $EndTime = Get-Date
            $Duration = ($EndTime - $StartTime).TotalSeconds
            $ExitCode = $LASTEXITCODE
            
            if ($ExitCode -eq 0) {
                Write-LogSuccess "$($Component.Name): تست موفق (مدت زمان: $([math]::Round($Duration, 1)) ثانیه)"
                $Results[$Component.Name] = @{
                    Status = "Success"
                    Message = "تست موفقیت‌آمیز"
                    ExitCode = $ExitCode
                    Duration = $Duration
                    Output = $Output
                    Required = $Component.Required
                }
                $SuccessCount++
            } else {
                $ErrorMessage = "تست ناموفق (Exit Code: $ExitCode)"
                if ($Component.Required) {
                    Write-LogError "$($Component.Name): $ErrorMessage"
                } else {
                    Write-LogWarning "$($Component.Name): $ErrorMessage (اختیاری)"
                }
                
                $Results[$Component.Name] = @{
                    Status = "Failed"
                    Message = $ErrorMessage
                    ExitCode = $ExitCode
                    Duration = $Duration
                    Output = $Output
                    Required = $Component.Required
                }
                $FailureCount++
                
                # اگر کامپوننت ضروری است و ContinueOnError فعال نیست، متوقف شو
                if ($Component.Required -and -not $ContinueOnError) {
                    Write-LogError "تست کامپوننت ضروری $($Component.Name) ناموفق بود. اجرا متوقف می‌شود."
                    Write-LogError "برای ادامه با وجود خطا از پارامتر -ContinueOnError استفاده کنید"
                    break
                }
            }
            
        } catch {
            Write-LogError "خطا در تست $($Component.Name): $($_.Exception.Message)"
            $Results[$Component.Name] = @{
                Status = "Error"
                Message = $_.Exception.Message
                ExitCode = -1
                Required = $Component.Required
            }
            $FailureCount++
            
            if ($Component.Required -and -not $ContinueOnError) {
                Write-LogError "خطا در تست کامپوننت ضروری $($Component.Name). اجرا متوقف می‌شود."
                break
            }
        }
        
        Write-LogInfo "-" * 40
    }
    
    $TotalEndTime = Get-Date
    $TotalDuration = ($TotalEndTime - $TotalStartTime).TotalMinutes
    
    # گزارش نهایی
    Write-LogInfo "=" * 60
    Write-LogInfo "خلاصه تست کامپوننت‌ها:"
    Write-LogInfo "موفق: $SuccessCount"
    Write-LogInfo "ناموفق: $FailureCount"
    Write-LogInfo "رد شده: $SkippedCount"
    Write-LogInfo "کل: $($Components.Count)"
    Write-LogInfo "مدت زمان کل: $([math]::Round($TotalDuration, 1)) دقیقه"
    
    # جزئیات نتایج
    Write-LogInfo ""
    Write-LogInfo "جزئیات نتایج:"
    foreach ($Component in $Components) {
        $Result = $Results[$Component.Name]
        if ($Result) {
            $StatusIcon = switch ($Result.Status) {
                "Success" { "✓" }
                "Failed" { "✗" }
                "Error" { "!" }
                "Skipped" { "-" }
                default { "?" }
            }
            
            $RequiredText = if ($Result.Required) { "(ضروری)" } else { "(اختیاری)" }
            Write-LogInfo "$StatusIcon $($Component.Name) $RequiredText : $($Result.Message)"
            
            if ($Result.Duration) {
                Write-LogInfo "    مدت زمان: $([math]::Round($Result.Duration, 1)) ثانیه"
            }
        }
    }
    
    # تولید گزارش HTML
    Write-LogInfo ""
    Write-LogInfo "تولید گزارش HTML: $ReportPath"
    
    $HtmlReport = @"
<!DOCTYPE html>
<html lang="fa" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>گزارش تست Android Development Tools</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h1 { color: #2c3e50; text-align: center; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        .summary { display: flex; justify-content: space-around; margin: 20px 0; }
        .summary-item { text-align: center; padding: 15px; border-radius: 8px; color: white; min-width: 100px; }
        .success { background-color: #27ae60; }
        .failure { background-color: #e74c3c; }
        .skipped { background-color: #95a5a6; }
        .total { background-color: #3498db; }
        .component { margin: 15px 0; padding: 15px; border: 1px solid #ddd; border-radius: 8px; }
        .component-header { display: flex; align-items: center; margin-bottom: 10px; }
        .status-icon { font-size: 20px; margin-left: 10px; }
        .success-icon { color: #27ae60; }
        .failure-icon { color: #e74c3c; }
        .error-icon { color: #f39c12; }
        .skipped-icon { color: #95a5a6; }
        .component-name { font-size: 18px; font-weight: bold; }
        .required { color: #e74c3c; font-size: 12px; }
        .optional { color: #95a5a6; font-size: 12px; }
        .details { background-color: #f8f9fa; padding: 10px; border-radius: 4px; margin-top: 10px; }
        .output { background-color: #2c3e50; color: #ecf0f1; padding: 10px; border-radius: 4px; font-family: 'Courier New', monospace; font-size: 12px; max-height: 200px; overflow-y: auto; white-space: pre-wrap; }
        .timestamp { text-align: center; color: #7f8c8d; margin-top: 20px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>گزارش تست Android Development Tools</h1>
        
        <div class="summary">
            <div class="summary-item success">
                <div style="font-size: 24px; font-weight: bold;">$SuccessCount</div>
                <div>موفق</div>
            </div>
            <div class="summary-item failure">
                <div style="font-size: 24px; font-weight: bold;">$FailureCount</div>
                <div>ناموفق</div>
            </div>
            <div class="summary-item skipped">
                <div style="font-size: 24px; font-weight: bold;">$SkippedCount</div>
                <div>رد شده</div>
            </div>
            <div class="summary-item total">
                <div style="font-size: 24px; font-weight: bold;">$($Components.Count)</div>
                <div>کل</div>
            </div>
        </div>
        
        <div style="text-align: center; margin: 20px 0;">
            <strong>مدت زمان کل: $([math]::Round($TotalDuration, 1)) دقیقه</strong>
        </div>
"@

    foreach ($Component in $Components) {
        $Result = $Results[$Component.Name]
        if ($Result) {
            $StatusIcon = switch ($Result.Status) {
                "Success" { "✓"; $IconClass = "success-icon" }
                "Failed" { "✗"; $IconClass = "failure-icon" }
                "Error" { "!"; $IconClass = "error-icon" }
                "Skipped" { "-"; $IconClass = "skipped-icon" }
                default { "?"; $IconClass = "skipped-icon" }
            }
            
            $RequiredClass = if ($Result.Required) { "required" } else { "optional" }
            $RequiredText = if ($Result.Required) { "ضروری" } else { "اختیاری" }
            
            $DurationText = if ($Result.Duration) { "$([math]::Round($Result.Duration, 1)) ثانیه" } else { "نامشخص" }
            
            $OutputHtml = ""
            if ($Result.Output -and $Result.Output.Count -gt 0) {
                $OutputText = ($Result.Output | Out-String).Trim()
                $OutputHtml = "<div class='output'>$([System.Web.HttpUtility]::HtmlEncode($OutputText))</div>"
            }
            
            $HtmlReport += @"
        <div class="component">
            <div class="component-header">
                <span class="status-icon $IconClass">$StatusIcon</span>
                <span class="component-name">$($Component.Name)</span>
                <span class="$RequiredClass">($RequiredText)</span>
            </div>
            <div class="details">
                <strong>وضعیت:</strong> $($Result.Message)<br>
                <strong>کد خروج:</strong> $($Result.ExitCode)<br>
                <strong>مدت زمان:</strong> $DurationText
            </div>
            $OutputHtml
        </div>
"@
        }
    }
    
    $HtmlReport += @"
        <div class="timestamp">
            گزارش تولید شده در: $(Get-Date -Format "yyyy/MM/dd HH:mm:ss")
        </div>
    </div>
</body>
</html>
"@

    # نوشتن گزارش HTML
    try {
        Add-Type -AssemblyName System.Web
        $HtmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
        Write-LogSuccess "گزارش HTML ذخیره شد: $ReportPath"
    } catch {
        Write-LogWarning "خطا در ذخیره گزارش HTML: $($_.Exception.Message)"
    }
    
    # بررسی کامپوننت‌های ضروری
    $RequiredComponents = $Components | Where-Object { $_.Required }
    $FailedRequired = @()
    
    foreach ($Required in $RequiredComponents) {
        $Result = $Results[$Required.Name]
        if ($Result -and $Result.Status -ne "Success") {
            $FailedRequired += $Required.Name
        }
    }
    
    if ($FailedRequired.Count -eq 0) {
        Write-LogSuccess "تمام تست‌های ضروری موفقیت‌آمیز بودند!"
        Write-LogInfo "سیستم Android Development Tools آماده استفاده است"
        
        # پیشنهادات نهایی
        Write-LogInfo ""
        Write-LogInfo "پیشنهادات:"
        Write-LogInfo "- برای ایجاد پروژه جدید از Android Studio استفاده کنید"
        Write-LogInfo "- برای کار با command line از gradle و adb استفاده کنید"
        Write-LogInfo "- گزارش کامل در فایل $ReportPath موجود است"
        
        exit 0
    } else {
        Write-LogError "تست کامپوننت‌های ضروری ناموفق: $($FailedRequired -join ', ')"
        Write-LogError "لطفاً مشکلات را برطرف کنید"
        
        # نمایش جزئیات خطاها
        foreach ($Failed in $FailedRequired) {
            $Result = $Results[$Failed]
            if ($Result -and $Result.Output) {
                Write-LogError "خطای $Failed :"
                $Result.Output | ForEach-Object { Write-LogError "  $_" }
            }
        }
        
        exit 1
    }
    
} catch {
    Write-LogError "خطا در اجرای تست‌ها: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}