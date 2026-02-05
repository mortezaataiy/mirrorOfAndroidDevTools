# اجرای تمام بررسی‌های پیش‌نیازها
# این اسکریپت تمام اسکریپت‌های بررسی پیش‌نیازها را اجرا می‌کند

param(
    [string]$DownloadPath = "downloaded",
    [switch]$Verbose,
    [switch]$ContinueOnError
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path $ScriptDir "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "All-Prerequisites-Check" -Verbose:$Verbose

try {
    Write-LogInfo "شروع بررسی تمام پیش‌نیازهای Android Development Tools..."
    Write-LogInfo "مسیر فایل‌های دانلود شده: $DownloadPath"
    
    # لیست کامپوننت‌ها به ترتیب وابستگی
    $Components = @(
        @{ Name = "JDK 17"; Path = "jdk17\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Android Studio"; Path = "android-studio\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Gradle"; Path = "gradle\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Command Line Tools"; Path = "commandline-tools\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Platform Tools"; Path = "platform-tools\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Build Tools"; Path = "build-tools\01-check-prerequisites.ps1"; Required = $false },
        @{ Name = "SDK Platforms"; Path = "sdk-platforms\01-check-prerequisites.ps1"; Required = $false },
        @{ Name = "System Images"; Path = "system-images\01-check-prerequisites.ps1"; Required = $false },
        @{ Name = "Repositories"; Path = "repositories\01-check-prerequisites.ps1"; Required = $false }
    )
    
    $Results = @{}
    $SuccessCount = 0
    $FailureCount = 0
    $SkippedCount = 0
    
    Write-LogInfo "بررسی $($Components.Count) کامپوننت..."
    Write-LogInfo "=" * 60
    
    foreach ($Component in $Components) {
        $ComponentPath = Join-Path $ScriptDir $Component.Path
        
        Write-LogInfo "بررسی $($Component.Name)..."
        
        if (-not (Test-Path $ComponentPath)) {
            Write-LogWarning "اسکریپت بررسی یافت نشد: $ComponentPath"
            $Results[$Component.Name] = @{
                Status = "Skipped"
                Message = "اسکریپت یافت نشد"
                ExitCode = -1
            }
            $SkippedCount++
            continue
        }
        
        try {
            # اجرای اسکریپت بررسی
            $StartTime = Get-Date
            
            if ($Verbose) {
                $Output = & PowerShell -File $ComponentPath -DownloadPath $DownloadPath -Verbose 2>&1
            } else {
                $Output = & PowerShell -File $ComponentPath -DownloadPath $DownloadPath 2>&1
            }
            
            $EndTime = Get-Date
            $Duration = ($EndTime - $StartTime).TotalSeconds
            $ExitCode = $LASTEXITCODE
            
            if ($ExitCode -eq 0) {
                Write-LogSuccess "$($Component.Name): موفق (مدت زمان: $([math]::Round($Duration, 1)) ثانیه)"
                $Results[$Component.Name] = @{
                    Status = "Success"
                    Message = "تمام پیش‌نیازها برآورده شده"
                    ExitCode = $ExitCode
                    Duration = $Duration
                }
                $SuccessCount++
            } else {
                $ErrorMessage = "ناموفق (Exit Code: $ExitCode)"
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
                }
                $FailureCount++
                
                # اگر کامپوننت ضروری است و ContinueOnError فعال نیست، متوقف شو
                if ($Component.Required -and -not $ContinueOnError) {
                    Write-LogError "کامپوننت ضروری $($Component.Name) ناموفق بود. اجرا متوقف می‌شود."
                    Write-LogError "برای ادامه با وجود خطا از پارامتر -ContinueOnError استفاده کنید"
                    break
                }
            }
            
        } catch {
            Write-LogError "خطا در اجرای بررسی $($Component.Name): $($_.Exception.Message)"
            $Results[$Component.Name] = @{
                Status = "Error"
                Message = $_.Exception.Message
                ExitCode = -1
            }
            $FailureCount++
            
            if ($Component.Required -and -not $ContinueOnError) {
                Write-LogError "خطا در کامپوننت ضروری $($Component.Name). اجرا متوقف می‌شود."
                break
            }
        }
        
        Write-LogInfo "-" * 40
    }
    
    # گزارش نهایی
    Write-LogInfo "=" * 60
    Write-LogInfo "خلاصه بررسی پیش‌نیازها:"
    Write-LogInfo "موفق: $SuccessCount"
    Write-LogInfo "ناموفق: $FailureCount"
    Write-LogInfo "رد شده: $SkippedCount"
    Write-LogInfo "کل: $($Components.Count)"
    
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
            
            $RequiredText = if ($Component.Required) { "(ضروری)" } else { "(اختیاری)" }
            Write-LogInfo "$StatusIcon $($Component.Name) $RequiredText : $($Result.Message)"
            
            if ($Result.Duration) {
                Write-LogInfo "    مدت زمان: $([math]::Round($Result.Duration, 1)) ثانیه"
            }
        }
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
        Write-LogSuccess "تمام کامپوننت‌های ضروری آماده هستند!"
        Write-LogInfo "می‌توانید نصب را شروع کنید با اجرای: .\run-all-installations.ps1"
        exit 0
    } else {
        Write-LogError "کامپوننت‌های ضروری ناموفق: $($FailedRequired -join ', ')"
        Write-LogError "لطفاً مشکلات را برطرف کنید و مجدداً تلاش کنید"
        
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
    Write-LogError "خطا در اجرای بررسی‌های پیش‌نیاز: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}