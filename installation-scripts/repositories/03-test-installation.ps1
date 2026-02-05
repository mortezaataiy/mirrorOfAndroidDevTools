# تست نصب Repositories
# این اسکریپت صحت نصب Android و Google Maven Repositories را بررسی می‌کند

param(
    [switch]$Verbose
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path (Split-Path -Parent $ScriptDir) "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "Repositories-Test" -Verbose:$Verbose

try {
    Write-LogInfo "شروع تست نصب Repositories..."
    
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
    
    # بررسی وجود پوشه extras
    $ExtrasDir = Join-Path $AndroidSdkRoot "extras"
    if (-not (Test-Path $ExtrasDir)) {
        Write-LogError "پوشه extras یافت نشد: $ExtrasDir"
        exit 1
    }
    
    Write-LogSuccess "پوشه extras یافت شد: $ExtrasDir"
    
    # لیست Repositories مورد انتظار
    $ExpectedRepositories = @(
        @{ 
            Name = "Android Support Repository"
            Path = "android\m2repository"
            ShortName = "android-m2repo"
        },
        @{ 
            Name = "Google Repository"
            Path = "google\m2repository"
            ShortName = "google-m2repo"
        }
    )
    
    $FoundRepositories = @()
    $MissingRepositories = @()
    $TestResults = @{}
    
    # بررسی هر repository
    foreach ($Repository in $ExpectedRepositories) {
        $RepositoryDir = Join-Path $ExtrasDir $Repository.Path
        $TestResults[$Repository.ShortName] = @{
            "Exists" = $false
            "HasPomFiles" = $false
            "HasJarFiles" = $false
            "HasAarFiles" = $false
            "SourceProperties" = $false
            "Size" = 0
            "FileCount" = 0
        }
        
        Write-LogInfo "بررسی $($Repository.Name)..."
        
        if (Test-Path $RepositoryDir) {
            Write-LogInfo "پوشه repository یافت شد: $RepositoryDir"
            $TestResults[$Repository.ShortName]["Exists"] = $true
            
            # بررسی وجود فایل‌های POM
            $PomFiles = Get-ChildItem -Path $RepositoryDir -Filter "*.pom" -Recurse -ErrorAction SilentlyContinue
            if ($PomFiles.Count -gt 0) {
                Write-LogSuccess "فایل‌های POM یافت شد: $($PomFiles.Count) فایل"
                $TestResults[$Repository.ShortName]["HasPomFiles"] = $true
            } else {
                Write-LogWarning "هیچ فایل POM یافت نشد"
            }
            
            # بررسی وجود فایل‌های JAR
            $JarFiles = Get-ChildItem -Path $RepositoryDir -Filter "*.jar" -Recurse -ErrorAction SilentlyContinue
            if ($JarFiles.Count -gt 0) {
                Write-LogSuccess "فایل‌های JAR یافت شد: $($JarFiles.Count) فایل"
                $TestResults[$Repository.ShortName]["HasJarFiles"] = $true
            } else {
                Write-LogWarning "هیچ فایل JAR یافت نشد"
            }
            
            # بررسی وجود فایل‌های AAR
            $AarFiles = Get-ChildItem -Path $RepositoryDir -Filter "*.aar" -Recurse -ErrorAction SilentlyContinue
            if ($AarFiles.Count -gt 0) {
                Write-LogSuccess "فایل‌های AAR یافت شد: $($AarFiles.Count) فایل"
                $TestResults[$Repository.ShortName]["HasAarFiles"] = $true
            } else {
                Write-LogInfo "فایل‌های AAR یافت نشد (طبیعی برای برخی repositories)"
            }
            
            # بررسی وجود source.properties
            $SourcePropsPath = Join-Path $RepositoryDir "source.properties"
            if (Test-Path $SourcePropsPath) {
                Write-LogSuccess "source.properties یافت شد"
                $TestResults[$Repository.ShortName]["SourceProperties"] = $true
                
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
            
            # محاسبه اندازه کل repository
            try {
                $AllFiles = Get-ChildItem -Path $RepositoryDir -Recurse -File -ErrorAction SilentlyContinue
                $RepositorySize = ($AllFiles | Measure-Object -Property Length -Sum).Sum
                $RepositorySizeMB = [math]::Round($RepositorySize / 1MB, 2)
                $TestResults[$Repository.ShortName]["Size"] = $RepositorySizeMB
                $TestResults[$Repository.ShortName]["FileCount"] = $AllFiles.Count
                Write-LogInfo "اندازه کل repository: $RepositorySizeMB MB"
                Write-LogInfo "تعداد کل فایل‌ها: $($AllFiles.Count)"
            } catch {
                Write-LogWarning "خطا در محاسبه اندازه repository: $($_.Exception.Message)"
            }
            
            # نمونه‌ای از کتابخانه‌های موجود
            try {
                Write-LogInfo "نمونه‌ای از کتابخانه‌های موجود:"
                $SampleLibraries = Get-ChildItem -Path $RepositoryDir -Directory -ErrorAction SilentlyContinue | Select-Object -First 5
                foreach ($Library in $SampleLibraries) {
                    $SubDirs = Get-ChildItem -Path $Library.FullName -Directory -ErrorAction SilentlyContinue | Select-Object -First 3
                    if ($SubDirs.Count -gt 0) {
                        Write-LogInfo "  $($Library.Name): $($SubDirs.Name -join ', ')"
                    } else {
                        Write-LogInfo "  $($Library.Name)"
                    }
                }
            } catch {
                Write-LogWarning "خطا در لیست کردن کتابخانه‌ها: $($_.Exception.Message)"
            }
            
            $FoundRepositories += $Repository.Name
        } else {
            Write-LogWarning "پوشه repository یافت نشد: $RepositoryDir"
            $MissingRepositories += $Repository.Name
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
                
                # بررسی repositories در خروجی SDK Manager
                $InstalledExtras = @()
                foreach ($Line in $SdkManagerOutput) {
                    if ($Line -match "extras;") {
                        $InstalledExtras += $Line.Trim()
                    }
                }
                
                if ($InstalledExtras.Count -gt 0) {
                    Write-LogSuccess "Extras شناسایی شده توسط SDK Manager:"
                    foreach ($Extra in $InstalledExtras) {
                        Write-LogInfo "  $Extra"
                    }
                } else {
                    Write-LogWarning "هیچ extra توسط SDK Manager شناسایی نشد"
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
    
    # تست دسترسی به Maven artifacts (نمونه)
    Write-LogInfo "تست دسترسی به Maven artifacts..."
    
    # تست دسترسی به کتابخانه‌های معروف
    $TestArtifacts = @(
        @{ Group = "com.android.support"; Artifact = "appcompat-v7"; Repository = "android" },
        @{ Group = "com.google.android.gms"; Artifact = "play-services"; Repository = "google" }
    )
    
    foreach ($Artifact in $TestArtifacts) {
        $RepoPath = if ($Artifact.Repository -eq "android") { "android\m2repository" } else { "google\m2repository" }
        $ArtifactPath = Join-Path $ExtrasDir "$RepoPath\$($Artifact.Group -replace '\.', '\')\$($Artifact.Artifact)"
        
        if (Test-Path $ArtifactPath) {
            Write-LogSuccess "کتابخانه $($Artifact.Group):$($Artifact.Artifact) یافت شد"
            
            # لیست نسخه‌های موجود
            $Versions = Get-ChildItem -Path $ArtifactPath -Directory -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
            if ($Versions.Count -gt 0) {
                Write-LogInfo "نسخه‌های موجود: $($Versions -join ', ')"
            }
        } else {
            Write-LogInfo "کتابخانه $($Artifact.Group):$($Artifact.Artifact) یافت نشد (ممکن است در نسخه جدیدتر موجود نباشد)"
        }
    }
    
    # گزارش نهایی
    Write-LogInfo "خلاصه تست Repositories:"
    Write-LogInfo "Repositories یافت شده: $($FoundRepositories.Count)"
    Write-LogInfo "Repositories مفقود: $($MissingRepositories.Count)"
    
    if ($FoundRepositories.Count -gt 0) {
        Write-LogSuccess "Repositories موجود: $($FoundRepositories -join ', ')"
    }
    
    if ($MissingRepositories.Count -gt 0) {
        Write-LogWarning "Repositories مفقود: $($MissingRepositories -join ', ')"
    }
    
    # نمایش جزئیات تست
    Write-LogInfo "جزئیات تست هر repository:"
    foreach ($Repository in $ExpectedRepositories) {
        $Results = $TestResults[$Repository.ShortName]
        $Status = if ($Results["Exists"] -and ($Results["HasPomFiles"] -or $Results["HasJarFiles"])) { "موفق" } else { "ناموفق" }
        Write-LogInfo "$($Repository.Name): $Status"
        Write-LogInfo "  - وجود پوشه: $($Results['Exists'])"
        Write-LogInfo "  - فایل‌های POM: $($Results['HasPomFiles'])"
        Write-LogInfo "  - فایل‌های JAR: $($Results['HasJarFiles'])"
        Write-LogInfo "  - فایل‌های AAR: $($Results['HasAarFiles'])"
        Write-LogInfo "  - source.properties: $($Results['SourceProperties'])"
        Write-LogInfo "  - اندازه: $($Results['Size']) MB"
        Write-LogInfo "  - تعداد فایل‌ها: $($Results['FileCount'])"
    }
    
    # تعیین وضعیت نهایی
    $SuccessfulRepositories = 0
    foreach ($Repository in $ExpectedRepositories) {
        $Results = $TestResults[$Repository.ShortName]
        if ($Results["Exists"] -and ($Results["HasPomFiles"] -or $Results["HasJarFiles"])) {
            $SuccessfulRepositories++
        }
    }
    
    if ($SuccessfulRepositories -gt 0) {
        Write-LogSuccess "تست Repositories موفقیت‌آمیز بود ($SuccessfulRepositories از $($ExpectedRepositories.Count) repository)"
        exit 0
    } else {
        Write-LogError "تست Repositories ناموفق بود - هیچ repository معتبری یافت نشد"
        exit 1
    }
    
} catch {
    Write-LogError "خطا در تست Repositories: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    exit 1
}