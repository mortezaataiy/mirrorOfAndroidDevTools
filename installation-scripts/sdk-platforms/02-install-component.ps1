# نصب SDK Platforms
# این اسکریپت SDK Platforms را از فایل‌های دانلود شده نصب می‌کند

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
Initialize-Logger -ComponentName "SDK-Platforms-Install" -Verbose:$Verbose

try {
    Write-LogInfo "شروع نصب SDK Platforms..."
    
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
        
        $InstallPath = Join-Path $AndroidSdkRoot "platforms"
    }
    
    Write-LogInfo "مسیر نصب: $InstallPath"
    
    # ایجاد پوشه platforms در صورت عدم وجود
    if (-not (Test-Path $InstallPath)) {
        Write-LogInfo "ایجاد پوشه platforms: $InstallPath"
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # بررسی وجود پوشه دانلود
    $DownloadFullPath = Resolve-Path $DownloadPath -ErrorAction SilentlyContinue
    if (-not $DownloadFullPath) {
        Write-LogError "پوشه دانلود یافت نشد: $DownloadPath"
        exit 1
    }
    
    # لیست فایل‌های SDK Platform
    $PlatformFiles = @(
        @{ File = "sdk-platform-33.zip"; ApiLevel = "33"; Name = "android-33" },
        @{ File = "sdk-platform-30.zip"; ApiLevel = "30"; Name = "android-30" },
        @{ File = "sdk-platform-27.zip"; ApiLevel = "27"; Name = "android-27" }
    )
    
    $InstalledPlatforms = @()
    $FailedPlatforms = @()
    
    foreach ($Platform in $PlatformFiles) {
        $SourceFile = Join-Path $DownloadFullPath $Platform.File
        $PlatformDir = Join-Path $InstallPath $Platform.Name
        
        if (-not (Test-Path $SourceFile)) {
            Write-LogWarning "فایل یافت نشد، رد می‌شود: $($Platform.File)"
            continue
        }
        
        Write-LogInfo "نصب $($Platform.Name) از $($Platform.File)..."
        
        try {
            # اعتبارسنجی فایل
            $ValidationResult = Test-FileIntegrity -FilePath $SourceFile -MinSizeBytes (25 * 1024 * 1024)
            if (-not $ValidationResult.IsValid) {
                Write-LogError "فایل $($Platform.File) معتبر نیست: $($ValidationResult.ErrorMessage)"
                $FailedPlatforms += $Platform.Name
                continue
            }
            
            # حذف نصب قبلی در صورت وجود
            if (Test-Path $PlatformDir) {
                Write-LogInfo "حذف نصب قبلی: $PlatformDir"
                Remove-Item -Path $PlatformDir -Recurse -Force
            }
            
            # ایجاد پوشه موقت برای استخراج
            $TempDir = Join-Path $env:TEMP "sdk-platform-$($Platform.ApiLevel)-$(Get-Random)"
            New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
            
            Write-LogInfo "استخراج فایل به پوشه موقت: $TempDir"
            
            # استخراج فایل ZIP
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($SourceFile, $TempDir)
            
            # یافتن پوشه اصلی platform (ممکن است در زیرپوشه باشد)
            $ExtractedItems = Get-ChildItem -Path $TempDir
            $PlatformSourceDir = $null
            
            # جستجو برای پوشه حاوی android.jar
            foreach ($Item in $ExtractedItems) {
                if ($Item.PSIsContainer) {
                    $AndroidJarPath = Join-Path $Item.FullName "android.jar"
                    if (Test-Path $AndroidJarPath) {
                        $PlatformSourceDir = $Item.FullName
                        break
                    }
                    
                    # جستجو در زیرپوشه‌ها
                    $SubItems = Get-ChildItem -Path $Item.FullName -Directory
                    foreach ($SubItem in $SubItems) {
                        $AndroidJarPath = Join-Path $SubItem.FullName "android.jar"
                        if (Test-Path $AndroidJarPath) {
                            $PlatformSourceDir = $SubItem.FullName
                            break
                        }
                    }
                    if ($PlatformSourceDir) { break }
                }
            }
            
            if (-not $PlatformSourceDir) {
                Write-LogError "پوشه platform معتبر در فایل استخراج شده یافت نشد"
                $FailedPlatforms += $Platform.Name
                continue
            }
            
            Write-LogInfo "کپی فایل‌ها از $PlatformSourceDir به $PlatformDir"
            
            # کپی فایل‌ها به مقصد نهایی
            Copy-Item -Path $PlatformSourceDir -Destination $PlatformDir -Recurse -Force
            
            # بررسی نصب موفق
            $AndroidJarFinal = Join-Path $PlatformDir "android.jar"
            if (Test-Path $AndroidJarFinal) {
                Write-LogSuccess "نصب $($Platform.Name) موفقیت‌آمیز بود"
                $InstalledPlatforms += $Platform.Name
                
                # نمایش اطلاعات نصب شده
                $PlatformSize = (Get-ChildItem -Path $PlatformDir -Recurse | Measure-Object -Property Length -Sum).Sum
                $PlatformSizeMB = [math]::Round($PlatformSize / 1MB, 2)
                Write-LogInfo "اندازه نصب شده: $PlatformSizeMB MB"
            } else {
                Write-LogError "فایل android.jar در مسیر نهایی یافت نشد"
                $FailedPlatforms += $Platform.Name
            }
            
            # پاک‌سازی پوشه موقت
            if (Test-Path $TempDir) {
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            
        } catch {
            Write-LogError "خطا در نصب $($Platform.Name): $($_.Exception.Message)"
            $FailedPlatforms += $Platform.Name
            
            # پاک‌سازی در صورت خطا
            if (Test-Path $TempDir) {
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    # گزارش نهایی
    Write-LogInfo "خلاصه نصب SDK Platforms:"
    Write-LogInfo "نصب شده: $($InstalledPlatforms.Count) platform"
    if ($InstalledPlatforms.Count -gt 0) {
        Write-LogSuccess "Platforms نصب شده: $($InstalledPlatforms -join ', ')"
    }
    
    if ($FailedPlatforms.Count -gt 0) {
        Write-LogWarning "Platforms ناموفق: $($FailedPlatforms -join ', ')"
    }
    
    if ($InstalledPlatforms.Count -gt 0) {
        Write-LogSuccess "نصب SDK Platforms با موفقیت تکمیل شد"
        exit 0
    } else {
        Write-LogError "هیچ platform نصب نشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در نصب SDK Platforms: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}