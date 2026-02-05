# بررسی پیش‌نیازهای System Images
# این اسکریپت پیش‌نیازهای لازم برای نصب System Images را بررسی می‌کند

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
Initialize-Logger -ComponentName "System-Images-Prerequisites" -Verbose:$Verbose

try {
    Write-LogInfo "شروع بررسی پیش‌نیازهای System Images..."
    
    # بررسی وجود پوشه دانلود
    $DownloadFullPath = Resolve-Path $DownloadPath -ErrorAction SilentlyContinue
    if (-not $DownloadFullPath) {
        Write-LogError "پوشه دانلود یافت نشد: $DownloadPath"
        exit 1
    }
    
    Write-LogInfo "پوشه دانلود یافت شد: $DownloadFullPath"
    
    # لیست فایل‌های System Image مورد انتظار
    $ExpectedImages = @(
        "sysimage-google-apis-x86_64-33.zip"
    )
    
    $MissingFiles = @()
    $ValidFiles = @()
    
    # بررسی وجود فایل‌های System Image
    foreach ($ImageFile in $ExpectedImages) {
        $FilePath = Join-Path $DownloadFullPath $ImageFile
        
        if (Test-Path $FilePath) {
            Write-LogInfo "فایل یافت شد: $ImageFile"
            
            # اعتبارسنجی فایل (System Images معمولاً بزرگ هستند - حداقل 500MB)
            $ValidationResult = Test-FileIntegrity -FilePath $FilePath -MinSizeBytes (500 * 1024 * 1024) # حداقل 500MB
            
            if ($ValidationResult.IsValid) {
                Write-LogSuccess "فایل $ImageFile معتبر است"
                $ValidFiles += $ImageFile
                
                # نمایش اندازه فایل
                $FileSize = (Get-Item $FilePath).Length
                $FileSizeMB = [math]::Round($FileSize / 1MB, 2)
                Write-LogInfo "اندازه فایل: $FileSizeMB MB"
            } else {
                Write-LogWarning "فایل $ImageFile معتبر نیست: $($ValidationResult.ErrorMessage)"
                $MissingFiles += $ImageFile
            }
        } else {
            Write-LogWarning "فایل یافت نشد: $ImageFile"
            $MissingFiles += $ImageFile
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
    
    # بررسی وجود پوشه system-images در SDK
    $SystemImagesDir = Join-Path $AndroidSdkRoot "system-images"
    if (-not (Test-Path $SystemImagesDir)) {
        Write-LogInfo "پوشه system-images وجود ندارد و ایجاد خواهد شد: $SystemImagesDir"
    } else {
        Write-LogInfo "پوشه system-images موجود است: $SystemImagesDir"
    }
    
    # بررسی فضای دیسک (System Images فضای زیادی نیاز دارند)
    try {
        $Drive = (Get-Item $AndroidSdkRoot).PSDrive
        $FreeSpace = $Drive.Free
        $FreeSpaceGB = [math]::Round($FreeSpace / 1GB, 2)
        
        Write-LogInfo "فضای آزاد دیسک: $FreeSpaceGB GB"
        
        if ($FreeSpaceGB -lt 5) {
            Write-LogWarning "فضای دیسک کم است. حداقل 5GB فضای آزاد توصیه می‌شود"
        } else {
            Write-LogSuccess "فضای دیسک کافی است"
        }
    } catch {
        Write-LogWarning "خطا در بررسی فضای دیسک: $($_.Exception.Message)"
    }
    
    # بررسی معماری سیستم
    $Architecture = $env:PROCESSOR_ARCHITECTURE
    Write-LogInfo "معماری سیستم: $Architecture"
    
    if ($Architecture -ne "AMD64") {
        Write-LogWarning "System Images x86_64 ممکن است روی معماری $Architecture کار نکند"
    } else {
        Write-LogSuccess "معماری سیستم سازگار است"
    }
    
    # گزارش نهایی
    if ($MissingFiles.Count -eq 0) {
        Write-LogSuccess "تمام پیش‌نیازهای System Images برآورده شده است"
        Write-LogInfo "فایل‌های معتبر: $($ValidFiles -join ', ')"
        Write-LogInfo "آماده برای نصب System Images"
        exit 0
    } else {
        Write-LogError "برخی پیش‌نیازها برآورده نشده است"
        Write-LogError "فایل‌های مفقود یا نامعتبر: $($MissingFiles -join ', ')"
        Write-LogError "لطفاً فایل‌های مفقود را دانلود کنید"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در بررسی پیش‌نیازهای System Images: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}