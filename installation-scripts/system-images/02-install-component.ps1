# نصب System Images
# این اسکریپت System Images را از فایل‌های دانلود شده نصب می‌کند

param(
    [string]$DownloadPath = "downloaded",
    [string]$InstallPath = "",
    [switch]$Verbose
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path (Split-Path -Parent $ScriptDir) "common"

. (Join-Path $CommonDir "Logger.ps1")
. (Join-Path $CommonDir "FileValidator.ps1")
. (Join-Path $CommonDir "EnvironmentManager.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "System-Images-Install" -Verbose:$Verbose

try {
    Write-LogInfo "شروع نصب System Images..."
    
    # تعیین مسیر نصب
    if ([string]::IsNullOrEmpty($InstallPath)) {
        $AndroidSdkRoot = $env:ANDROID_SDK_ROOT
        if (-not $AndroidSdkRoot) {
            $AndroidSdkRoot = $env:ANDROID_HOME
        }
        
        if (-not $AndroidSdkRoot) {
            Write-LogError "متغیر محیطی ANDROID_SDK_ROOT یا ANDROID_HOME تنظیم نشده است"
            Write-LogError "ابتدا Command Line Tools را نصب کنید"
            exit 1
        }
        
        $InstallPath = Join-Path $AndroidSdkRoot "system-images"
    }
    
    Write-LogInfo "مسیر نصب: $InstallPath"
    
    # ایجاد پوشه system-images در صورت عدم وجود
    if (-not (Test-Path $InstallPath)) {
        Write-LogInfo "ایجاد پوشه system-images: $InstallPath"
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # بررسی وجود پوشه دانلود
    $DownloadFullPath = Resolve-Path $DownloadPath -ErrorAction SilentlyContinue
    if (-not $DownloadFullPath) {
        Write-LogError "پوشه دانلود یافت نشد: $DownloadPath"
        exit 1
    }
    
    # لیست فایل‌های System Image
    $ImageFiles = @(
        @{ 
            File = "sysimage-google-apis-x86_64-33.zip"
            ApiLevel = "33"
            Target = "google_apis"
            Arch = "x86_64"
            Path = "android-33\google_apis\x86_64"
        }
    )
    
    $InstalledImages = @()
    $FailedImages = @()
    
    foreach ($Image in $ImageFiles) {
        $SourceFile = Join-Path $DownloadFullPath $Image.File
        $ImageDir = Join-Path $InstallPath $Image.Path
        
        if (-not (Test-Path $SourceFile)) {
            Write-LogWarning "فایل یافت نشد، رد می‌شود: $($Image.File)"
            continue
        }
        
        Write-LogInfo "نصب System Image $($Image.Target) API $($Image.ApiLevel) ($($Image.Arch)) از $($Image.File)..."
        
        try {
            # اعتبارسنجی فایل
            $ValidationResult = Test-FileIntegrity -FilePath $SourceFile -MinSizeBytes (500 * 1024 * 1024)
            if (-not $ValidationResult.IsValid) {
                Write-LogError "فایل $($Image.File) معتبر نیست: $($ValidationResult.ErrorMessage)"
                $FailedImages += $Image.File
                continue
            }
            
            # حذف نصب قبلی در صورت وجود
            if (Test-Path $ImageDir) {
                Write-LogInfo "حذف نصب قبلی: $ImageDir"
                Remove-Item -Path $ImageDir -Recurse -Force
            }
            
            # ایجاد ساختار پوشه‌ها
            $ParentDir = Split-Path -Parent $ImageDir
            if (-not (Test-Path $ParentDir)) {
                New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
            }
            
            # ایجاد پوشه موقت برای استخراج
            $TempDir = Join-Path $env:TEMP "system-image-$($Image.ApiLevel)-$(Get-Random)"
            New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
            
            Write-LogInfo "استخراج فایل به پوشه موقت: $TempDir"
            Write-LogInfo "این عملیات ممکن است چند دقیقه طول بکشد..."
            
            # استخراج فایل ZIP
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($SourceFile, $TempDir)
            
            # یافتن پوشه اصلی system image (ممکن است در زیرپوشه باشد)
            $ExtractedItems = Get-ChildItem -Path $TempDir
            $ImageSourceDir = $null
            
            # جستجو برای پوشه حاوی فایل‌های system image
            foreach ($Item in $ExtractedItems) {
                if ($Item.PSIsContainer) {
                    # جستجو برای فایل‌های مشخصه system image
                    $SystemImgPath = Join-Path $Item.FullName "system.img"
                    $UserDataImgPath = Join-Path $Item.FullName "userdata.img"
                    
                    if ((Test-Path $SystemImgPath) -or (Test-Path $UserDataImgPath)) {
                        $ImageSourceDir = $Item.FullName
                        break
                    }
                    
                    # جستجو در زیرپوشه‌ها
                    $SubItems = Get-ChildItem -Path $Item.FullName -Directory -ErrorAction SilentlyContinue
                    foreach ($SubItem in $SubItems) {
                        $SystemImgPath = Join-Path $SubItem.FullName "system.img"
                        $UserDataImgPath = Join-Path $SubItem.FullName "userdata.img"
                        
                        if ((Test-Path $SystemImgPath) -or (Test-Path $UserDataImgPath)) {
                            $ImageSourceDir = $SubItem.FullName
                            break
                        }
                        
                        # جستجو در سطح بعدی
                        $SubSubItems = Get-ChildItem -Path $SubItem.FullName -Directory -ErrorAction SilentlyContinue
                        foreach ($SubSubItem in $SubSubItems) {
                            $SystemImgPath = Join-Path $SubSubItem.FullName "system.img"
                            $UserDataImgPath = Join-Path $SubSubItem.FullName "userdata.img"
                            
                            if ((Test-Path $SystemImgPath) -or (Test-Path $UserDataImgPath)) {
                                $ImageSourceDir = $SubSubItem.FullName
                                break
                            }
                        }
                        if ($ImageSourceDir) { break }
                    }
                    if ($ImageSourceDir) { break }
                }
            }
            
            if (-not $ImageSourceDir) {
                Write-LogError "پوشه system image معتبر در فایل استخراج شده یافت نشد"
                $FailedImages += $Image.File
                continue
            }
            
            Write-LogInfo "کپی فایل‌ها از $ImageSourceDir به $ImageDir"
            
            # کپی فایل‌ها به مقصد نهایی
            Copy-Item -Path $ImageSourceDir -Destination $ImageDir -Recurse -Force
            
            # بررسی نصب موفق
            $SystemImgFinal = Join-Path $ImageDir "system.img"
            $UserDataImgFinal = Join-Path $ImageDir "userdata.img"
            $SourcePropsFinal = Join-Path $ImageDir "source.properties"
            
            if ((Test-Path $SystemImgFinal) -or (Test-Path $UserDataImgFinal)) {
                Write-LogSuccess "نصب System Image موفقیت‌آمیز بود"
                $InstalledImages += $Image.File
                
                # نمایش اطلاعات نصب شده
                $ImageSize = (Get-ChildItem -Path $ImageDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
                $ImageSizeGB = [math]::Round($ImageSize / 1GB, 2)
                Write-LogInfo "اندازه نصب شده: $ImageSizeGB GB"
                
                # نمایش فایل‌های موجود
                $ImageFiles = Get-ChildItem -Path $ImageDir -File | Select-Object -ExpandProperty Name
                Write-LogInfo "فایل‌های نصب شده: $($ImageFiles -join ', ')"
                
                # بررسی source.properties
                if (Test-Path $SourcePropsFinal) {
                    try {
                        $SourceContent = Get-Content $SourcePropsFinal -Raw
                        Write-LogInfo "اطلاعات System Image:"
                        $SourceContent -split "`n" | ForEach-Object {
                            if ($_.Trim() -and $_ -match "=") {
                                Write-LogInfo "  $_"
                            }
                        }
                    } catch {
                        Write-LogWarning "خطا در خواندن source.properties: $($_.Exception.Message)"
                    }
                }
            } else {
                Write-LogError "فایل‌های system image در مسیر نهایی یافت نشد"
                $FailedImages += $Image.File
            }
            
            # پاک‌سازی پوشه موقت
            if (Test-Path $TempDir) {
                Write-LogInfo "پاک‌سازی فایل‌های موقت..."
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            
        } catch {
            Write-LogError "خطا در نصب $($Image.File): $($_.Exception.Message)"
            $FailedImages += $Image.File
            
            # پاک‌سازی در صورت خطا
            if (Test-Path $TempDir) {
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    # گزارش نهایی
    Write-LogInfo "خلاصه نصب System Images:"
    Write-LogInfo "نصب شده: $($InstalledImages.Count) system image"
    if ($InstalledImages.Count -gt 0) {
        Write-LogSuccess "System Images نصب شده: $($InstalledImages -join ', ')"
    }
    
    if ($FailedImages.Count -gt 0) {
        Write-LogWarning "System Images ناموفق: $($FailedImages -join ', ')"
    }
    
    if ($InstalledImages.Count -gt 0) {
        Write-LogSuccess "نصب System Images با موفقیت تکمیل شد"
        exit 0
    } else {
        Write-LogError "هیچ system image نصب نشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در نصب System Images: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}