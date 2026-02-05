# بررسی پیش‌نیازهای Repositories
# این اسکریپت پیش‌نیازهای لازم برای نصب Android و Google Maven Repositories را بررسی می‌کند

param(
    [string]$DownloadPath = "downloaded",
    [switch]$Verbose
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path (Split-Path -Parent $ScriptDir) "common"

. (Join-Path $CommonDir "Logger.ps1")
. (Join-Path $CommonDir "FileValidator.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "Repositories-Prerequisites" -Verbose:$Verbose

try {
    Write-LogInfo "شروع بررسی پیش‌نیازهای Repositories..."
    
    # بررسی وجود پوشه دانلود
    $DownloadFullPath = Resolve-Path $DownloadPath -ErrorAction SilentlyContinue
    if (-not $DownloadFullPath) {
        Write-LogError "پوشه دانلود یافت نشد: $DownloadPath"
        exit 1
    }
    
    Write-LogInfo "پوشه دانلود یافت شد: $DownloadFullPath"
    
    # لیست فایل‌های Repository مورد انتظار
    $ExpectedRepositories = @(
        "android-m2repository.zip"
    )
    
    $MissingFiles = @()
    $ValidFiles = @()
    
    # بررسی وجود فایل‌های Repository
    foreach ($RepoFile in $ExpectedRepositories) {
        $FilePath = Join-Path $DownloadFullPath $RepoFile
        
        if (Test-Path $FilePath) {
            Write-LogInfo "فایل یافت شد: $RepoFile"
            
            # اعتبارسنجی فایل (Repositories معمولاً بزرگ هستند - حداقل 50MB)
            $ValidationResult = Test-FileIntegrity -FilePath $FilePath -MinSizeBytes (50 * 1024 * 1024) # حداقل 50MB
            
            if ($ValidationResult.IsValid) {
                Write-LogSuccess "فایل $RepoFile معتبر است"
                $ValidFiles += $RepoFile
                
                # نمایش اندازه فایل
                $FileSize = (Get-Item $FilePath).Length
                $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
                Write-LogInfo "اندازه فایل: $FileSizeMB MB"
            } else {
                Write-LogWarning "فایل $RepoFile معتبر نیست: $($ValidationResult.ErrorMessage)"
                $MissingFiles += $RepoFile
            }
        } else {
            Write-LogWarning "فایل یافت نشد: $RepoFile"
            $MissingFiles += $RepoFile
        }
    }
    
    # بررسی فایل‌های اضافی که ممکن است موجود باشند
    $OptionalRepositories = @(
        "google-m2repository.zip"
    )
    
    foreach ($OptionalRepo in $OptionalRepositories) {
        $FilePath = Join-Path $DownloadFullPath $OptionalRepo
        
        if (Test-Path $FilePath) {
            Write-LogInfo "فایل اختیاری یافت شد: $OptionalRepo"
            
            $ValidationResult = Test-FileIntegrity -FilePath $FilePath -MinSizeBytes (50 * 1024 * 1024)
            
            if ($ValidationResult.IsValid) {
                Write-LogSuccess "فایل اختیاری $OptionalRepo معتبر است"
                $ValidFiles += $OptionalRepo
                
                $FileSize = (Get-Item $FilePath).Length
                $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
                Write-LogInfo "اندازه فایل: $FileSizeMB MB"
            } else {
                Write-LogWarning "فایل اختیاری $OptionalRepo معتبر نیست: $($ValidationResult.ErrorMessage)"
            }
        } else {
            Write-LogInfo "فایل اختیاری موجود نیست: $OptionalRepo"
        }
    }
    
    # بررسی نصب Command Line Tools (وابستگی)
    Write-LogInfo "بررسی نصب Command Line Tools..."
    
    $AndroidSdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $AndroidSdkRoot) {
        $AndroidSdkRoot = $env:ANDROID_HOME
    }
    
    if (-not $AndroidSdkRoot) {
        Write-LogError "متغیر محیطی ANDROID_SDK_ROOT یا ANDROID_HOME تنظیم نشده است"
        Write-LogError "ابتدا Command Line Tools را نصب کنید"
        exit 1
    }
    
    $SdkManagerPath = Join-Path $AndroidSdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
    if (-not (Test-Path $SdkManagerPath)) {
        Write-LogError "SDK Manager یافت نشد در مسیر: $SdkManagerPath"
        Write-LogError "ابتدا Command Line Tools را نصب کنید"
        exit 1
    }
    
    Write-LogSuccess "Command Line Tools نصب شده است"
    
    # بررسی وجود پوشه extras در SDK
    $ExtrasDir = Join-Path $AndroidSdkRoot "extras"
    if (-not (Test-Path $ExtrasDir)) {
        Write-LogInfo "پوشه extras وجود ندارد و ایجاد خواهد شد: $ExtrasDir"
    } else {
        Write-LogInfo "پوشه extras موجود است: $ExtrasDir"
        
        # بررسی repositories موجود
        $AndroidRepoDir = Join-Path $ExtrasDir "android\m2repository"
        $GoogleRepoDir = Join-Path $ExtrasDir "google\m2repository"
        
        if (Test-Path $AndroidRepoDir) {
            Write-LogInfo "Android M2Repository قبلاً نصب شده است"
        }
        
        if (Test-Path $GoogleRepoDir) {
            Write-LogInfo "Google M2Repository قبلاً نصب شده است"
        }
    }
    
    # بررسی فضای دیسک
    try {
        $Drive = (Get-Item $AndroidSdkRoot).PSDrive
        $FreeSpace = $Drive.Free
        $FreeSpaceGB = [math]::Round($FreeSpace / 1GB, 2)
        
        Write-LogInfo "فضای آزاد دیسک: $FreeSpaceGB GB"
        
        if ($FreeSpaceGB -lt 2) {
            Write-LogWarning "فضای دیسک کم است. حداقل 2GB فضای آزاد توصیه می‌شود"
        } else {
            Write-LogSuccess "فضای دیسک کافی است"
        }
    } catch {
        Write-LogWarning "خطا در بررسی فضای دیسک: $($_.Exception.Message)"
    }
    
    # گزارش نهایی
    if ($MissingFiles.Count -eq 0 -and $ValidFiles.Count -gt 0) {
        Write-LogSuccess "تمام پیش‌نیازهای Repositories برآورده شده است"
        Write-LogInfo "فایل‌های معتبر: $($ValidFiles -join ', ')"
        Write-LogInfo "آماده برای نصب Repositories"
        exit 0
    } elseif ($ValidFiles.Count -gt 0) {
        Write-LogWarning "برخی فایل‌های repository موجود است اما برخی مفقود هستند"
        Write-LogInfo "فایل‌های معتبر: $($ValidFiles -join ', ')"
        Write-LogWarning "فایل‌های مفقود: $($MissingFiles -join ', ')"
        Write-LogInfo "نصب با فایل‌های موجود ادامه خواهد یافت"
        exit 0
    } else {
        Write-LogError "هیچ فایل repository معتبری یافت نشد"
        Write-LogError "فایل‌های مفقود یا نامعتبر: $($MissingFiles -join ', ')"
        Write-LogError "لطفاً حداقل یک فایل repository را دانلود کنید"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در بررسی پیش‌نیازهای Repositories: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}