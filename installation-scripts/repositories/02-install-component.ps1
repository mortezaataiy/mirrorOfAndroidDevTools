# نصب Repositories
# این اسکریپت Android و Google Maven Repositories را از فایل‌های دانلود شده نصب می‌کند

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
Initialize-Logger -ComponentName "Repositories-Install" -Verbose:$Verbose

try {
    Write-LogInfo "شروع نصب Repositories..."
    
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
        
        $InstallPath = Join-Path $AndroidSdkRoot "extras"
    }
    
    Write-LogInfo "مسیر نصب: $InstallPath"
    
    # ایجاد پوشه extras در صورت عدم وجود
    if (-not (Test-Path $InstallPath)) {
        Write-LogInfo "ایجاد پوشه extras: $InstallPath"
        New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    }
    
    # بررسی وجود پوشه دانلود
    $DownloadFullPath = Resolve-Path $DownloadPath -ErrorAction SilentlyContinue
    if (-not $DownloadFullPath) {
        Write-LogError "پوشه دانلود یافت نشد: $DownloadPath"
        exit 1
    }
    
    # لیست فایل‌های Repository
    $RepositoryFiles = @(
        @{ 
            File = "android-m2repository.zip"
            Name = "Android Support Repository"
            TargetDir = "android\m2repository"
        },
        @{ 
            File = "google-m2repository.zip"
            Name = "Google Repository"
            TargetDir = "google\m2repository"
        }
    )
    
    $InstalledRepositories = @()
    $FailedRepositories = @()
    
    foreach ($Repository in $RepositoryFiles) {
        $SourceFile = Join-Path $DownloadFullPath $Repository.File
        $RepositoryDir = Join-Path $InstallPath $Repository.TargetDir
        
        if (-not (Test-Path $SourceFile)) {
            Write-LogWarning "فایل یافت نشد، رد می‌شود: $($Repository.File)"
            continue
        }
        
        Write-LogInfo "نصب $($Repository.Name) از $($Repository.File)..."
        
        try {
            # اعتبارسنجی فایل
            $ValidationResult = Test-FileIntegrity -FilePath $SourceFile -MinSizeBytes (50 * 1024 * 1024)
            if (-not $ValidationResult.IsValid) {
                Write-LogError "فایل $($Repository.File) معتبر نیست: $($ValidationResult.ErrorMessage)"
                $FailedRepositories += $Repository.Name
                continue
            }
            
            # حذف نصب قبلی در صورت وجود
            if (Test-Path $RepositoryDir) {
                Write-LogInfo "حذف نصب قبلی: $RepositoryDir"
                Remove-Item -Path $RepositoryDir -Recurse -Force
            }
            
            # ایجاد ساختار پوشه‌ها
            $ParentDir = Split-Path -Parent $RepositoryDir
            if (-not (Test-Path $ParentDir)) {
                New-Item -ItemType Directory -Path $ParentDir -Force | Out-Null
            }
            
            # ایجاد پوشه موقت برای استخراج
            $TempDir = Join-Path $env:TEMP "repository-$(Get-Random)"
            New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
            
            Write-LogInfo "استخراج فایل به پوشه موقت: $TempDir"
            
            # استخراج فایل ZIP
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            [System.IO.Compression.ZipFile]::ExtractToDirectory($SourceFile, $TempDir)
            
            # یافتن پوشه اصلی repository (ممکن است در زیرپوشه باشد)
            $ExtractedItems = Get-ChildItem -Path $TempDir
            $RepositorySourceDir = $null
            
            # جستجو برای پوشه حاوی m2repository
            foreach ($Item in $ExtractedItems) {
                if ($Item.PSIsContainer) {
                    # جستجو مستقیم برای m2repository
                    $M2RepoPath = Join-Path $Item.FullName "m2repository"
                    if (Test-Path $M2RepoPath) {
                        $RepositorySourceDir = $M2RepoPath
                        break
                    }
                    
                    # جستجو در زیرپوشه‌ها
                    $SubItems = Get-ChildItem -Path $Item.FullName -Directory -ErrorAction SilentlyContinue
                    foreach ($SubItem in $SubItems) {
                        if ($SubItem.Name -eq "m2repository") {
                            $RepositorySourceDir = $SubItem.FullName
                            break
                        }
                        
                        # جستجو در سطح بعدی
                        $M2RepoPath = Join-Path $SubItem.FullName "m2repository"
                        if (Test-Path $M2RepoPath) {
                            $RepositorySourceDir = $M2RepoPath
                            break
                        }
                    }
                    if ($RepositorySourceDir) { break }
                }
            }
            
            # اگر m2repository یافت نشد، کل پوشه اول را در نظر بگیر
            if (-not $RepositorySourceDir -and $ExtractedItems.Count -gt 0) {
                $FirstItem = $ExtractedItems[0]
                if ($FirstItem.PSIsContainer) {
                    $RepositorySourceDir = $FirstItem.FullName
                    Write-LogWarning "پوشه m2repository یافت نشد، استفاده از پوشه اول: $RepositorySourceDir"
                }
            }
            
            if (-not $RepositorySourceDir) {
                Write-LogError "پوشه repository معتبر در فایل استخراج شده یافت نشد"
                $FailedRepositories += $Repository.Name
                continue
            }
            
            Write-LogInfo "کپی فایل‌ها از $RepositorySourceDir به $RepositoryDir"
            
            # کپی فایل‌ها به مقصد نهایی
            Copy-Item -Path $RepositorySourceDir -Destination $RepositoryDir -Recurse -Force
            
            # بررسی نصب موفق
            if (Test-Path $RepositoryDir) {
                # بررسی وجود فایل‌های Maven
                $PomFiles = Get-ChildItem -Path $RepositoryDir -Filter "*.pom" -Recurse | Select-Object -First 5
                $JarFiles = Get-ChildItem -Path $RepositoryDir -Filter "*.jar" -Recurse | Select-Object -First 5
                
                if ($PomFiles.Count -gt 0 -or $JarFiles.Count -gt 0) {
                    Write-LogSuccess "نصب $($Repository.Name) موفقیت‌آمیز بود"
                    $InstalledRepositories += $Repository.Name
                    
                    # نمایش اطلاعات نصب شده
                    $RepositorySize = (Get-ChildItem -Path $RepositoryDir -Recurse -File | Measure-Object -Property Length -Sum).Sum
                    $RepositorySizeMB = [math]::Round($RepositorySize / 1MB, 2)
                    Write-LogInfo "اندازه نصب شده: $RepositorySizeMB MB"
                    
                    # شمارش فایل‌های مختلف
                    $PomCount = (Get-ChildItem -Path $RepositoryDir -Filter "*.pom" -Recurse).Count
                    $JarCount = (Get-ChildItem -Path $RepositoryDir -Filter "*.jar" -Recurse).Count
                    $AarCount = (Get-ChildItem -Path $RepositoryDir -Filter "*.aar" -Recurse).Count
                    
                    Write-LogInfo "فایل‌های نصب شده: $PomCount POM, $JarCount JAR, $AarCount AAR"
                    
                    # بررسی source.properties
                    $SourcePropsPath = Join-Path $RepositoryDir "source.properties"
                    if (Test-Path $SourcePropsPath) {
                        try {
                            $SourceContent = Get-Content $SourcePropsPath -Raw
                            Write-LogInfo "اطلاعات Repository:"
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
                    Write-LogError "فایل‌های Maven در مسیر نهایی یافت نشد"
                    $FailedRepositories += $Repository.Name
                }
            } else {
                Write-LogError "پوشه repository در مسیر نهایی ایجاد نشد"
                $FailedRepositories += $Repository.Name
            }
            
            # پاک‌سازی پوشه موقت
            if (Test-Path $TempDir) {
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
            
        } catch {
            Write-LogError "خطا در نصب $($Repository.Name): $($_.Exception.Message)"
            $FailedRepositories += $Repository.Name
            
            # پاک‌سازی در صورت خطا
            if (Test-Path $TempDir) {
                Remove-Item -Path $TempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
    }
    
    # گزارش نهایی
    Write-LogInfo "خلاصه نصب Repositories:"
    Write-LogInfo "نصب شده: $($InstalledRepositories.Count) repository"
    if ($InstalledRepositories.Count -gt 0) {
        Write-LogSuccess "Repositories نصب شده: $($InstalledRepositories -join ', ')"
    }
    
    if ($FailedRepositories.Count -gt 0) {
        Write-LogWarning "Repositories ناموفق: $($FailedRepositories -join ', ')"
    }
    
    if ($InstalledRepositories.Count -gt 0) {
        Write-LogSuccess "نصب Repositories با موفقیت تکمیل شد"
        exit 0
    } else {
        Write-LogError "هیچ repository نصب نشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در نصب Repositories: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}