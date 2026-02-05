# تست نصب SDK Platforms
# این اسکریپت صحت نصب SDK Platforms را بررسی می‌کند

param(
    [switch]$Verbose
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path (Split-Path -Parent $ScriptDir) "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "SDK-Platforms-Test" -Verbose:$Verbose

try {
    Write-LogInfo "شروع تست نصب SDK Platforms..."
    
    # بررسی متغیر محیطی ANDROID_SDK_ROOT
    $AndroidSdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $AndroidSdkRoot) {
        $AndroidSdkRoot = $env:ANDROID_HOME
    }
    
    if (-not $AndroidSdkRoot) {
        Write-LogError "متغیر محیطی ANDROID_SDK_ROOT یا ANDROID_HOME تنظیم نشده است"
        exit 1
    }
    
    Write-LogInfo "Android SDK Root: $AndroidSdkRoot"
    
    # بررسی وجود پوشه platforms
    $PlatformsDir = Join-Path $AndroidSdkRoot "platforms"
    if (-not (Test-Path $PlatformsDir)) {
        Write-LogError "پوشه platforms یافت نشد: $PlatformsDir"
        exit 1
    }
    
    Write-LogSuccess "پوشه platforms یافت شد: $PlatformsDir"
    
    # لیست API levels مورد انتظار
    $ExpectedPlatforms = @(
        @{ Name = "android-33"; ApiLevel = "33" },
        @{ Name = "android-30"; ApiLevel = "30" },
        @{ Name = "android-27"; ApiLevel = "27" }
    )
    
    $FoundPlatforms = @()
    $MissingPlatforms = @()
    $TestResults = @{}
    
    # بررسی هر platform
    foreach ($Platform in $ExpectedPlatforms) {
        $PlatformDir = Join-Path $PlatformsDir $Platform.Name
        $TestResults[$Platform.Name] = @{
            "Exists" = $false
            "AndroidJar" = $false
            "SourceProperties" = $false
            "ApiLevel" = $false
        }
        
        Write-LogInfo "بررسی $($Platform.Name)..."
        
        if (Test-Path $PlatformDir) {
            Write-LogInfo "پوشه platform یافت شد: $PlatformDir"
            $TestResults[$Platform.Name]["Exists"] = $true
            
            # بررسی وجود android.jar
            $AndroidJarPath = Join-Path $PlatformDir "android.jar"
            if (Test-Path $AndroidJarPath) {
                Write-LogSuccess "android.jar یافت شد"
                $TestResults[$Platform.Name]["AndroidJar"] = $true
                
                # بررسی اندازه android.jar
                $AndroidJarSize = (Get-Item $AndroidJarPath).Length
                $AndroidJarSizeMB = [math]::Round($AndroidJarSize / 1MB, 2)
                Write-LogInfo "اندازه android.jar: $AndroidJarSizeMB MB"
                
                if ($AndroidJarSize -lt 1MB) {
                    Write-LogWarning "اندازه android.jar کمتر از حد انتظار است"
                }
            } else {
                Write-LogError "android.jar یافت نشد در: $AndroidJarPath"
            }
            
            # بررسی وجود source.properties
            $SourcePropsPath = Join-Path $PlatformDir "source.properties"
            if (Test-Path $SourcePropsPath) {
                Write-LogSuccess "source.properties یافت شد"
                $TestResults[$Platform.Name]["SourceProperties"] = $true
                
                # خواندن محتوای source.properties
                try {
                    $SourceContent = Get-Content $SourcePropsPath -Raw
                    Write-LogInfo "محتوای source.properties:"
                    $SourceContent -split "`n" | ForEach-Object {
                        if ($_.Trim()) {
                            Write-LogInfo "  $_"
                        }
                    }
                    
                    # بررسی API level در source.properties
                    if ($SourceContent -match "AndroidVersion\.ApiLevel\s*=\s*$($Platform.ApiLevel)") {
                        Write-LogSuccess "API Level $($Platform.ApiLevel) تأیید شد"
                        $TestResults[$Platform.Name]["ApiLevel"] = $true
                    } else {
                        Write-LogWarning "API Level در source.properties مطابقت ندارد"
                    }
                } catch {
                    Write-LogWarning "خطا در خواندن source.properties: $($_.Exception.Message)"
                }
            } else {
                Write-LogWarning "source.properties یافت نشد"
            }
            
            # محاسبه اندازه کل platform
            try {
                $PlatformSize = (Get-ChildItem -Path $PlatformDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
                $PlatformSizeMB = [math]::Round($PlatformSize / 1MB, 2)
                Write-LogInfo "اندازه کل platform: $PlatformSizeMB MB"
            } catch {
                Write-LogWarning "خطا در محاسبه اندازه platform: $($_.Exception.Message)"
            }
            
            $FoundPlatforms += $Platform.Name
        } else {
            Write-LogWarning "پوشه platform یافت نشد: $PlatformDir"
            $MissingPlatforms += $Platform.Name
        }
    }
    
    # تست دسترسی به SDK Manager
    Write-LogInfo "تست دسترسی به SDK Manager..."
    
    $SdkManagerPath = Join-Path $AndroidSdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
    if (Test-Path $SdkManagerPath) {
        try {
            Write-LogInfo "اجرای دستور: sdkmanager --list_installed"
            $SdkManagerOutput = & $SdkManagerPath --list_installed 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "SDK Manager با موفقیت اجرا شد"
                
                # بررسی platforms در خروجی SDK Manager
                $InstalledPlatforms = @()
                foreach ($Line in $SdkManagerOutput) {
                    if ($Line -match "platforms;android-(\d+)") {
                        $InstalledPlatforms += "android-$($Matches[1])"
                    }
                }
                
                if ($InstalledPlatforms.Count -gt 0) {
                    Write-LogSuccess "Platforms شناسایی شده توسط SDK Manager: $($InstalledPlatforms -join ', ')"
                } else {
                    Write-LogWarning "هیچ platform توسط SDK Manager شناسایی نشد"
                }
            } else {
                Write-LogWarning "SDK Manager با خطا اجرا شد (Exit Code: $LASTEXITCODE)"
            }
        } catch {
            Write-LogWarning "خطا در اجرای SDK Manager: $($_.Exception.Message)"
        }
    } else {
        Write-LogWarning "SDK Manager یافت نشد: $SdkManagerPath"
    }
    
    # گزارش نهایی
    Write-LogInfo "خلاصه تست SDK Platforms:"
    Write-LogInfo "Platforms یافت شده: $($FoundPlatforms.Count)"
    Write-LogInfo "Platforms مفقود: $($MissingPlatforms.Count)"
    
    if ($FoundPlatforms.Count -gt 0) {
        Write-LogSuccess "Platforms موجود: $($FoundPlatforms -join ', ')"
    }
    
    if ($MissingPlatforms.Count -gt 0) {
        Write-LogWarning "Platforms مفقود: $($MissingPlatforms -join ', ')"
    }
    
    # نمایش جزئیات تست
    Write-LogInfo "جزئیات تست هر platform:"
    foreach ($Platform in $ExpectedPlatforms) {
        $Results = $TestResults[$Platform.Name]
        $Status = if ($Results["Exists"] -and $Results["AndroidJar"]) { "موفق" } else { "ناموفق" }
        Write-LogInfo "$($Platform.Name): $Status"
        Write-LogInfo "  - وجود پوشه: $($Results['Exists'])"
        Write-LogInfo "  - android.jar: $($Results['AndroidJar'])"
        Write-LogInfo "  - source.properties: $($Results['SourceProperties'])"
        Write-LogInfo "  - API Level: $($Results['ApiLevel'])"
    }
    
    # تعیین وضعیت نهایی
    $SuccessfulPlatforms = 0
    foreach ($Platform in $ExpectedPlatforms) {
        $Results = $TestResults[$Platform.Name]
        if ($Results["Exists"] -and $Results["AndroidJar"]) {
            $SuccessfulPlatforms++
        }
    }
    
    if ($SuccessfulPlatforms -gt 0) {
        Write-LogSuccess "تست SDK Platforms موفقیت‌آمیز بود ($SuccessfulPlatforms از $($ExpectedPlatforms.Count) platform)"
        exit 0
    } else {
        Write-LogError "تست SDK Platforms ناموفق بود - هیچ platform معتبری یافت نشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در تست SDK Platforms: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}