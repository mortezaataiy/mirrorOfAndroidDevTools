# تست نصب System Images
# این اسکریپت صحت نصب System Images را بررسی می‌کند

param(
    [switch]$Verbose
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path (Split-Path -Parent $ScriptDir) "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "System-Images-Test" -Verbose:$Verbose

try {
    Write-LogInfo "شروع تست نصب System Images..."
    
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
    
    # بررسی وجود پوشه system-images
    $SystemImagesDir = Join-Path $AndroidSdkRoot "system-images"
    if (-not (Test-Path $SystemImagesDir)) {
        Write-LogError "پوشه system-images یافت نشد: $SystemImagesDir"
        exit 1
    }
    
    Write-LogSuccess "پوشه system-images یافت شد: $SystemImagesDir"
    
    # لیست System Images مورد انتظار
    $ExpectedImages = @(
        @{ 
            Path = "android-33\google_apis\x86_64"
            ApiLevel = "33"
            Target = "google_apis"
            Arch = "x86_64"
            Name = "Google APIs x86_64 API 33"
        }
    )
    
    $FoundImages = @()
    $MissingImages = @()
    $TestResults = @{}
    
    # بررسی هر system image
    foreach ($Image in $ExpectedImages) {
        $ImageDir = Join-Path $SystemImagesDir $Image.Path
        $TestResults[$Image.Name] = @{
            "Exists" = $false
            "SystemImg" = $false
            "UserDataImg" = $false
            "SourceProperties" = $false
            "Size" = 0
        }
        
        Write-LogInfo "بررسی $($Image.Name)..."
        
        if (Test-Path $ImageDir) {
            Write-LogInfo "پوشه system image یافت شد: $ImageDir"
            $TestResults[$Image.Name]["Exists"] = $true
            
            # بررسی وجود system.img
            $SystemImgPath = Join-Path $ImageDir "system.img"
            if (Test-Path $SystemImgPath) {
                Write-LogSuccess "system.img یافت شد"
                $TestResults[$Image.Name]["SystemImg"] = $true
                
                # بررسی اندازه system.img
                $SystemImgSize = (Get-Item $SystemImgPath).Length
                $SystemImgSizeMB = [math]::Round($SystemImgSize / 1MB, 2)
                Write-LogInfo "اندازه system.img: $SystemImgSizeMB MB"
                
                if ($SystemImgSize -lt 100MB) {
                    Write-LogWarning "اندازه system.img کمتر از حد انتظار است"
                }
            } else {
                Write-LogWarning "system.img یافت نشد در: $SystemImgPath"
            }
            
            # بررسی وجود userdata.img
            $UserDataImgPath = Join-Path $ImageDir "userdata.img"
            if (Test-Path $UserDataImgPath) {
                Write-LogSuccess "userdata.img یافت شد"
                $TestResults[$Image.Name]["UserDataImg"] = $true
                
                # بررسی اندازه userdata.img
                $UserDataImgSize = (Get-Item $UserDataImgPath).Length
                $UserDataImgSizeMB = [math]::Round($UserDataImgSize / 1MB, 2)
                Write-LogInfo "اندازه userdata.img: $UserDataImgSizeMB MB"
            } else {
                Write-LogWarning "userdata.img یافت نشد در: $UserDataImgPath"
            }
            
            # بررسی وجود source.properties
            $SourcePropsPath = Join-Path $ImageDir "source.properties"
            if (Test-Path $SourcePropsPath) {
                Write-LogSuccess "source.properties یافت شد"
                $TestResults[$Image.Name]["SourceProperties"] = $true
                
                # خواندن محتوای source.properties
                try {
                    $SourceContent = Get-Content $SourcePropsPath -Raw
                    Write-LogInfo "محتوای source.properties:"
                    $SourceContent -split "`n" | ForEach-Object {
                        if ($_.Trim()) {
                            Write-LogInfo "  $_"
                        }
                    }
                } catch {
                    Write-LogWarning "خطا در خواندن source.properties: $($_.Exception.Message)"
                }
            } else {
                Write-LogWarning "source.properties یافت نشد"
            }
            
            # محاسبه اندازه کل system image
            try {
                $ImageSize = (Get-ChildItem -Path $ImageDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
                $ImageSizeGB = [math]::Round($ImageSize / 1GB, 2)
                $TestResults[$Image.Name]["Size"] = $ImageSizeGB
                Write-LogInfo "اندازه کل system image: $ImageSizeGB GB"
            } catch {
                Write-LogWarning "خطا در محاسبه اندازه system image: $($_.Exception.Message)"
            }
            
            # لیست فایل‌های موجود
            try {
                $ImageFiles = Get-ChildItem -Path $ImageDir -File | Select-Object -ExpandProperty Name
                Write-LogInfo "فایل‌های موجود: $($ImageFiles -join ', ')"
            } catch {
                Write-LogWarning "خطا در لیست کردن فایل‌ها: $($_.Exception.Message)"
            }
            
            $FoundImages += $Image.Name
        } else {
            Write-LogWarning "پوشه system image یافت نشد: $ImageDir"
            $MissingImages += $Image.Name
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
                
                # بررسی system images در خروجی SDK Manager
                $InstalledSystemImages = @()
                foreach ($Line in $SdkManagerOutput) {
                    if ($Line -match "system-images;android-(\d+);([^;]+);([^;]+)") {
                        $InstalledSystemImages += "android-$($Matches[1]);$($Matches[2]);$($Matches[3])"
                    }
                }
                
                if ($InstalledSystemImages.Count -gt 0) {
                    Write-LogSuccess "System Images شناسایی شده توسط SDK Manager: $($InstalledSystemImages -join ', ')"
                } else {
                    Write-LogWarning "هیچ system image توسط SDK Manager شناسایی نشد"
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
    
    # تست ایجاد AVD ساده (اختیاری)
    Write-LogInfo "تست ایجاد AVD ساده..."
    
    $AvdManagerPath = Join-Path $AndroidSdkRoot "cmdline-tools\latest\bin\avdmanager.bat"
    if (Test-Path $AvdManagerPath) {
        try {
            # لیست AVD های موجود
            Write-LogInfo "اجرای دستور: avdmanager list avd"
            $AvdListOutput = & $AvdManagerPath list avd 2>&1
            
            if ($LASTEXITCODE -eq 0) {
                Write-LogSuccess "AVD Manager با موفقیت اجرا شد"
                
                # نمایش AVD های موجود
                $AvdCount = 0
                foreach ($Line in $AvdListOutput) {
                    if ($Line -match "Name:\s+(.+)") {
                        $AvdCount++
                        Write-LogInfo "AVD موجود: $($Matches[1])"
                    }
                }
                
                if ($AvdCount -eq 0) {
                    Write-LogInfo "هیچ AVD موجود نیست"
                } else {
                    Write-LogInfo "تعداد AVD های موجود: $AvdCount"
                }
            } else {
                Write-LogWarning "AVD Manager با خطا اجرا شد (Exit Code: $LASTEXITCODE)"
            }
        } catch {
            Write-LogWarning "خطا در اجرای AVD Manager: $($_.Exception.Message)"
        }
    } else {
        Write-LogWarning "AVD Manager یافت نشد: $AvdManagerPath"
    }
    
    # گزارش نهایی
    Write-LogInfo "خلاصه تست System Images:"
    Write-LogInfo "System Images یافت شده: $($FoundImages.Count)"
    Write-LogInfo "System Images مفقود: $($MissingImages.Count)"
    
    if ($FoundImages.Count -gt 0) {
        Write-LogSuccess "System Images موجود: $($FoundImages -join ', ')"
    }
    
    if ($MissingImages.Count -gt 0) {
        Write-LogWarning "System Images مفقود: $($MissingImages -join ', ')"
    }
    
    # نمایش جزئیات تست
    Write-LogInfo "جزئیات تست هر system image:"
    foreach ($Image in $ExpectedImages) {
        $Results = $TestResults[$Image.Name]
        $Status = if ($Results["Exists"] -and ($Results["SystemImg"] -or $Results["UserDataImg"])) { "موفق" } else { "ناموفق" }
        Write-LogInfo "$($Image.Name): $Status"
        Write-LogInfo "  - وجود پوشه: $($Results['Exists'])"
        Write-LogInfo "  - system.img: $($Results['SystemImg'])"
        Write-LogInfo "  - userdata.img: $($Results['UserDataImg'])"
        Write-LogInfo "  - source.properties: $($Results['SourceProperties'])"
        Write-LogInfo "  - اندازه: $($Results['Size']) GB"
    }
    
    # تعیین وضعیت نهایی
    $SuccessfulImages = 0
    foreach ($Image in $ExpectedImages) {
        $Results = $TestResults[$Image.Name]
        if ($Results["Exists"] -and ($Results["SystemImg"] -or $Results["UserDataImg"])) {
            $SuccessfulImages++
        }
    }
    
    if ($SuccessfulImages -gt 0) {
        Write-LogSuccess "تست System Images موفقیت‌آمیز بود ($SuccessfulImages از $($ExpectedImages.Count) system image)"
        exit 0
    } else {
        Write-LogError "تست System Images ناموفق بود - هیچ system image معتبری یافت نشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در تست System Images: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}