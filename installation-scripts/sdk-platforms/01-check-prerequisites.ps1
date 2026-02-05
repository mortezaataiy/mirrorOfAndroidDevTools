# بررسی پیش‌نیازهای SDK Platforms
# این اسکریپت پیش‌نیازهای لازم برای نصب SDK Platforms را بررسی می‌کند

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
Initialize-Logger -ComponentName "SDK-Platforms-Prerequisites" -Verbose:$Verbose

try {
    Write-LogInfo "شروع بررسی پیش‌نیازهای SDK Platforms..."
    
    # بررسی وجود پوشه دانلود
    $DownloadFullPath = Resolve-Path $DownloadPath -ErrorAction SilentlyContinue
    if (-not $DownloadFullPath) {
        Write-LogError "پوشه دانلود یافت نشد: $DownloadPath"
        exit 1
    }
    
    Write-LogInfo "پوشه دانلود یافت شد: $DownloadFullPath"
    
    # لیست فایل‌های SDK Platform مورد انتظار
    $ExpectedPlatforms = @(
        "sdk-platform-33.zip",
        "sdk-platform-30.zip", 
        "sdk-platform-27.zip"
    )
    
    $MissingFiles = @()
    $ValidFiles = @()
    
    # بررسی وجود فایل‌های SDK Platform
    foreach ($PlatformFile in $ExpectedPlatforms) {
        $FilePath = Join-Path $DownloadFullPath $PlatformFile
        
        if (Test-Path $FilePath) {
            Write-LogInfo "فایل یافت شد: $PlatformFile"
            
            # اعتبارسنجی فایل
            $ValidationResult = Test-FileIntegrity -FilePath $FilePath -MinSizeBytes (25 * 1024 * 1024) # حداقل 25MB
            
            if ($ValidationResult.IsValid) {
                Write-LogSuccess "فایل $PlatformFile معتبر است"
                $ValidFiles += $PlatformFile
            } else {
                Write-LogWarning "فایل $PlatformFile معتبر نیست: $($ValidationResult.ErrorMessage)"
                $MissingFiles += $PlatformFile
            }
        } else {
            Write-LogWarning "فایل یافت نشد: $PlatformFile"
            $MissingFiles += $PlatformFile
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
    
    # بررسی وجود پوشه platforms در SDK
    $PlatformsDir = Join-Path $AndroidSdkRoot "platforms"
    if (-not (Test-Path $PlatformsDir)) {
        Write-LogInfo "پوشه platforms وجود ندارد و ایجاد خواهد شد: $PlatformsDir"
    } else {
        Write-LogInfo "پوشه platforms موجود است: $PlatformsDir"
    }
    
    # گزارش نهایی
    if ($MissingFiles.Count -eq 0) {
        Write-LogSuccess "تمام پیش‌نیازهای SDK Platforms برآورده شده است"
        Write-LogInfo "فایل‌های معتبر: $($ValidFiles -join ', ')"
        Write-LogInfo "آماده برای نصب SDK Platforms"
        exit 0
    } else {
        Write-LogError "برخی پیش‌نیازها برآورده نشده است"
        Write-LogError "فایل‌های مفقود یا نامعتبر: $($MissingFiles -join ', ')"
        Write-LogError "لطفاً فایل‌های مفقود را دانلود کنید"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در بررسی پیش‌نیازهای SDK Platforms: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}