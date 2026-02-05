# تست عملکرد آفلاین سیستم نصب Android Development Tools
# این اسکریپت تمام عملیات را بدون اتصال اینترنت تست می‌کند

param(
    [string]$DownloadPath = "downloaded",
    [switch]$Verbose,
    [string]$TestProjectPath = "OfflineTest"
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path $ScriptDir "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "Offline-Functionality-Test" -Verbose:$Verbose

function Test-NetworkConnectivity {
    <#
    .SYNOPSIS
    تست وضعیت اتصال اینترنت
    #>
    
    Write-LogInfo "بررسی وضعیت اتصال اینترنت..."
    
    try {
        # تست اتصال به چندین سرور معتبر
        $TestSites = @(
            "8.8.8.8",           # Google DNS
            "1.1.1.1",           # Cloudflare DNS
            "google.com",        # Google
            "microsoft.com"      # Microsoft
        )
        
        $ConnectedSites = 0
        
        foreach ($Site in $TestSites) {
            try {
                $Result = Test-NetConnection -ComputerName $Site -Port 80 -InformationLevel Quiet -WarningAction SilentlyContinue
                if ($Result) {
                    $ConnectedSites++
                }
            } catch {
                # در صورت خطا، سایت در دسترس نیست
            }
        }
        
        if ($ConnectedSites -gt 0) {
            Write-LogWarning "اتصال اینترنت فعال است ($ConnectedSites از $($TestSites.Count) سایت در دسترس)"
            Write-LogWarning "برای تست کامل آفلاین، لطفاً اتصال اینترنت را قطع کنید"
            return $true
        } else {
            Write-LogSuccess "اتصال اینترنت قطع است - محیط آفلاین تأیید شد"
            return $false
        }
        
    } catch {
        Write-LogSuccess "اتصال اینترنت قطع است - محیط آفلاین تأیید شد"
        return $false
    }
}

function Test-OfflineFileValidation {
    <#
    .SYNOPSIS
    تست اعتبارسنجی فایل‌ها بدون اتصال اینترنت
    #>
    
    Write-LogInfo "تست اعتبارسنجی فایل‌ها در حالت آفلاین..."
    
    # وارد کردن FileValidator
    . (Join-Path $CommonDir "FileValidator.ps1")
    
    # لیست فایل‌های مورد انتظار
    $ExpectedFiles = @(
        "jdk-17.zip",
        "gradle-8.0.2-bin.zip",
        "commandlinetools-win-latest.zip",
        "platform-tools.zip",
        "build-tools-33.0.2.zip",
        "sdk-platform-33.zip",
        "sdk-platform-30.zip",
        "sdk-platform-27.zip",
        "sysimage-google-apis-x86_64-33.zip",
        "android-m2repository.zip"
    )
    
    $ValidationResults = @{}
    
    foreach ($File in $ExpectedFiles) {
        $FilePath = Join-Path $DownloadPath $File
        
        if (Test-Path $FilePath) {
            Write-LogInfo "اعتبارسنجی فایل: $File"
            
            try {
                # تست یکپارچگی فایل
                $IsValid = Test-FileIntegrity -FilePath $FilePath
                $ValidationResults[$File] = $IsValid
                
                if ($IsValid) {
                    Write-LogSuccess "✓ فایل $File معتبر است"
                } else {
                    Write-LogError "✗ فایل $File معتبر نیست"
                }
                
            } catch {
                Write-LogError "خطا در اعتبارسنجی فایل $File : $($_.Exception.Message)"
                $ValidationResults[$File] = $false
            }
        } else {
            Write-LogWarning "فایل $File یافت نشد"
            $ValidationResults[$File] = $false
        }
    }
    
    return $ValidationResults
}

function Test-OfflineInstallation {
    <#
    .SYNOPSIS
    تست نصب کامپوننت‌ها بدون اتصال اینترنت
    #>
    
    Write-LogInfo "تست نصب کامپوننت‌ها در حالت آفلاین..."
    
    # اجرای اسکریپت بررسی پیش‌نیازها
    $CheckScript = Join-Path $ScriptDir "run-all-checks.ps1"
    if (Test-Path $CheckScript) {
        Write-LogInfo "اجرای بررسی پیش‌نیازها..."
        
        $CheckParams = @("-DownloadPath", $DownloadPath)
        if ($Verbose) { $CheckParams += "-Verbose" }
        
        $CheckOutput = & PowerShell -File $CheckScript @CheckParams 2>&1
        $CheckExitCode = $LASTEXITCODE
        
        if ($CheckExitCode -eq 0) {
            Write-LogSuccess "✓ بررسی پیش‌نیازها در حالت آفلاین موفق بود"
        } else {
            Write-LogError "✗ بررسی پیش‌نیازها در حالت آفلاین ناموفق بود"
            return $false
        }
    } else {
        Write-LogError "اسکریپت بررسی پیش‌نیازها یافت نشد"
        return $false
    }
    
    # اجرای اسکریپت نصب
    $InstallScript = Join-Path $ScriptDir "run-all-installations.ps1"
    if (Test-Path $InstallScript) {
        Write-LogInfo "اجرای نصب کامپوننت‌ها..."
        
        $InstallParams = @("-DownloadPath", $DownloadPath)
        if ($Verbose) { $InstallParams += "-Verbose" }
        
        $InstallOutput = & PowerShell -File $InstallScript @InstallParams 2>&1
        $InstallExitCode = $LASTEXITCODE
        
        if ($InstallExitCode -eq 0) {
            Write-LogSuccess "✓ نصب کامپوننت‌ها در حالت آفلاین موفق بود"
            return $true
        } else {
            Write-LogError "✗ نصب کامپوننت‌ها در حالت آفلاین ناموفق بود"
            return $false
        }
    } else {
        Write-LogError "اسکریپت نصب یافت نشد"
        return $false
    }
}

function Test-OfflineComponentTesting {
    <#
    .SYNOPSIS
    تست عملکرد کامپوننت‌ها بدون اتصال اینترنت
    #>
    
    Write-LogInfo "تست عملکرد کامپوننت‌ها در حالت آفلاین..."
    
    # اجرای اسکریپت تست
    $TestScript = Join-Path $ScriptDir "run-all-tests.ps1"
    if (Test-Path $TestScript) {
        Write-LogInfo "اجرای تست کامپوننت‌ها..."
        
        $TestParams = @()
        if ($Verbose) { $TestParams += "-Verbose" }
        
        $TestOutput = & PowerShell -File $TestScript @TestParams 2>&1
        $TestExitCode = $LASTEXITCODE
        
        if ($TestExitCode -eq 0) {
            Write-LogSuccess "✓ تست کامپوننت‌ها در حالت آفلاین موفق بود"
            return $true
        } else {
            Write-LogError "✗ تست کامپوننت‌ها در حالت آفلاین ناموفق بود"
            return $false
        }
    } else {
        Write-LogError "اسکریپت تست یافت نشد"
        return $false
    }
}

function Test-OfflineProjectCreation {
    <#
    .SYNOPSIS
    تست ایجاد پروژه Android بدون اتصال اینترنت
    #>
    
    Write-LogInfo "تست ایجاد پروژه Android در حالت آفلاین..."
    
    # حذف پروژه قبلی در صورت وجود
    if (Test-Path $TestProjectPath) {
        Write-LogInfo "حذف پروژه قبلی: $TestProjectPath"
        Remove-Item -Path $TestProjectPath -Recurse -Force
    }
    
    # بررسی دسترسی به ابزارهای مورد نیاز
    $ToolsAvailable = $true
    
    # تست Java
    try {
        $JavaVersion = & java -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogSuccess "✓ Java در دسترس است"
        } else {
            Write-LogError "✗ Java در دسترس نیست"
            $ToolsAvailable = $false
        }
    } catch {
        Write-LogError "✗ خطا در اجرای Java: $($_.Exception.Message)"
        $ToolsAvailable = $false
    }
    
    # تست Gradle
    try {
        $GradleVersion = & gradle -v 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogSuccess "✓ Gradle در دسترس است"
        } else {
            Write-LogError "✗ Gradle در دسترس نیست"
            $ToolsAvailable = $false
        }
    } catch {
        Write-LogError "✗ خطا در اجرای Gradle: $($_.Exception.Message)"
        $ToolsAvailable = $false
    }
    
    # تست Android SDK
    $AndroidSdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $AndroidSdkRoot) {
        $AndroidSdkRoot = $env:ANDROID_HOME
    }
    
    if ($AndroidSdkRoot -and (Test-Path $AndroidSdkRoot)) {
        Write-LogSuccess "✓ Android SDK در دسترس است: $AndroidSdkRoot"
    } else {
        Write-LogError "✗ Android SDK در دسترس نیست"
        $ToolsAvailable = $false
    }
    
    if (-not $ToolsAvailable) {
        Write-LogError "ابزارهای مورد نیاز برای ایجاد پروژه در دسترس نیستند"
        return $false
    }
    
    # ایجاد پروژه ساده Android
    try {
        New-Item -ItemType Directory -Path $TestProjectPath -Force | Out-Null
        Set-Location $TestProjectPath
        
        # ایجاد build.gradle ساده برای تست آفلاین
        $BuildGradleContent = @"
plugins {
    id 'java'
}

repositories {
    // استفاده از repository محلی در صورت امکان
    flatDir {
        dirs 'libs'
    }
}

dependencies {
    // وابستگی‌های محلی
}

task hello {
    doLast {
        println 'Hello World from Offline Android Project!'
    }
}
"@
        
        $BuildGradleContent | Out-File -FilePath "build.gradle" -Encoding UTF8
        Write-LogSuccess "✓ فایل build.gradle ایجاد شد"
        
        # تست اجرای task ساده
        Write-LogInfo "تست اجرای Gradle task..."
        $TaskOutput = & gradle hello 2>&1
        $TaskExitCode = $LASTEXITCODE
        
        if ($TaskExitCode -eq 0) {
            Write-LogSuccess "✓ اجرای Gradle task در حالت آفلاین موفق بود"
            return $true
        } else {
            Write-LogWarning "⚠ اجرای Gradle task با مشکل مواجه شد (ممکن است به دلیل عدم دسترسی به repository باشد)"
            Write-LogInfo "خروجی Gradle:"
            $TaskOutput | ForEach-Object { Write-LogInfo "  $_" }
            return $false
        }
        
    } catch {
        Write-LogError "خطا در ایجاد پروژه تست: $($_.Exception.Message)"
        return $false
        
    } finally {
        # بازگشت به پوشه اصلی
        try {
            Set-Location $ScriptDir
        } catch {}
    }
}

# اجرای اصلی اسکریپت
try {
    Write-LogInfo "شروع تست عملکرد آفلاین Android Development Tools..."
    Write-LogInfo "این تست تأیید می‌کند که تمام عملیات بدون اتصال اینترنت قابل انجام است"
    
    $StartTime = Get-Date
    $TestResults = @{}
    
    # مرحله 1: بررسی وضعیت اتصال اینترنت
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 1: بررسی وضعیت اتصال اینترنت"
    Write-LogInfo "=" * 60
    
    $HasInternet = Test-NetworkConnectivity
    $TestResults["NetworkDisconnected"] = -not $HasInternet
    
    # مرحله 2: تست اعتبارسنجی فایل‌ها
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 2: تست اعتبارسنجی فایل‌ها"
    Write-LogInfo "=" * 60
    
    $ValidationResults = Test-OfflineFileValidation
    $AllFilesValid = ($ValidationResults.Values | Where-Object { $_ -eq $false }).Count -eq 0
    $TestResults["FileValidation"] = $AllFilesValid
    
    # مرحله 3: تست نصب آفلاین
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 3: تست نصب آفلاین"
    Write-LogInfo "=" * 60
    
    $InstallationSuccess = Test-OfflineInstallation
    $TestResults["OfflineInstallation"] = $InstallationSuccess
    
    # مرحله 4: تست عملکرد کامپوننت‌ها
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 4: تست عملکرد کامپوننت‌ها"
    Write-LogInfo "=" * 60
    
    $ComponentTestSuccess = Test-OfflineComponentTesting
    $TestResults["ComponentTesting"] = $ComponentTestSuccess
    
    # مرحله 5: تست ایجاد پروژه
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 5: تست ایجاد پروژه"
    Write-LogInfo "=" * 60
    
    $ProjectCreationSuccess = Test-OfflineProjectCreation
    $TestResults["ProjectCreation"] = $ProjectCreationSuccess
    
    $EndTime = Get-Date
    $TotalDuration = ($EndTime - $StartTime).TotalMinutes
    
    # گزارش نهایی
    Write-LogInfo "=" * 60
    Write-LogInfo "خلاصه تست عملکرد آفلاین:"
    Write-LogInfo "مدت زمان کل: $([math]::Round($TotalDuration, 1)) دقیقه"
    Write-LogInfo "=" * 60
    
    $SuccessCount = 0
    $TotalTests = $TestResults.Count
    
    foreach ($TestName in $TestResults.Keys) {
        $Result = $TestResults[$TestName]
        if ($Result) {
            Write-LogSuccess "✓ $TestName"
            $SuccessCount++
        } else {
            Write-LogError "✗ $TestName"
        }
    }
    
    Write-LogInfo "نتیجه کلی: $SuccessCount از $TotalTests تست موفق"
    
    if ($SuccessCount -eq $TotalTests) {
        Write-LogSuccess "🎉 تمام تست‌های آفلاین با موفقیت انجام شد!"
        Write-LogSuccess "سیستم کاملاً بدون اتصال اینترنت قابل استفاده است"
        exit 0
    } else {
        $FailedTests = $TotalTests - $SuccessCount
        Write-LogWarning "⚠ $FailedTests تست ناموفق بود"
        Write-LogWarning "سیستم ممکن است برای عملکرد کامل آفلاین نیاز به بررسی بیشتر داشته باشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در تست عملکرد آفلاین: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    
    # بازگشت به پوشه اصلی در صورت خطا
    try {
        Set-Location $ScriptDir
    } catch {}
    
    exit 1
}