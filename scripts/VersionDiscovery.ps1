# Version Discovery Service
# مسئول شناسایی آخرین ورژن‌های ابزارهای اندروید

# تعریف انواع داده‌ای
class ToolInfo {
    [string]$Name
    [string]$Version
    [string]$DownloadUrl
    [int64]$FileSize
    [string]$FileType
    [string]$InstallPath
    [string]$TestStatus
    [datetime]$TestDate
    [string[]]$Compatibility
    
    ToolInfo([string]$name) {
        $this.Name = $name
        $this.TestDate = Get-Date
        $this.TestStatus = "pending"
    }
}

# شناسایی آخرین ورژن JDK 17
function Get-LatestJDK17Version {
    Write-Host "🔍 شناسایی آخرین ورژن JDK 17..." -ForegroundColor Yellow
    
    try {
        # استفاده از Adoptium API برای دریافت اطلاعات ورژن
        $versionApiUrl = "https://api.adoptium.net/v3/info/available_releases"
        $versionResponse = Invoke-RestMethod -Uri $versionApiUrl -Method Get
        
        # پیدا کردن آخرین ورژن JDK 17
        $jdk17Versions = $versionResponse.available_lts_releases | Where-Object { $_ -eq 17 }
        
        if ($jdk17Versions) {
            # دریافت جزئیات آخرین release
            $releaseApiUrl = "https://api.adoptium.net/v3/info/release_versions?release_type=ga&version=[17,18)"
            $releaseResponse = Invoke-RestMethod -Uri $releaseApiUrl -Method Get
            
            $latestJdk17 = $releaseResponse.versions | Where-Object { $_ -like "17.*" } | Sort-Object -Descending | Select-Object -First 1
            
            if ($latestJdk17) {
                # دریافت لینک دانلود مستقیم
                $downloadApiUrl = "https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse?project=jdk"
                
                $jdkInfo = [ToolInfo]::new("JDK")
                $jdkInfo.Version = $latestJdk17
                $jdkInfo.DownloadUrl = $downloadApiUrl
                $jdkInfo.FileType = "zip"
                
                Write-Host "✅ JDK 17 ورژن $latestJdk17 پیدا شد" -ForegroundColor Green
                return $jdkInfo
            }
        }
        
        throw "هیچ ورژن JDK 17 پیدا نشد"
    }
    catch {
        Write-Error "خطا در شناسایی JDK 17: $($_.Exception.Message)"
        # Fallback به لینک مستقیم
        try {
            $jdkInfo = [ToolInfo]::new("JDK")
            $jdkInfo.Version = "17-latest"
            $jdkInfo.DownloadUrl = "https://download.java.net/java/GA/jdk17.0.2/dfd4a8d0985749f896bed50d7138ee7f/8/GPL/openjdk-17.0.2_windows-x64_bin.zip"
            $jdkInfo.FileType = "zip"
            
            Write-Host "⚠️ استفاده از لینک پیش‌فرض JDK 17" -ForegroundColor Yellow
            return $jdkInfo
        }
        catch {
            return $null
        }
    }
}

# شناسایی آخرین ورژن Gradle
function Get-LatestGradleVersion {
    Write-Host "🔍 شناسایی آخرین ورژن Gradle..." -ForegroundColor Yellow
    
    try {
        # استفاده از Gradle API
        $apiUrl = "https://services.gradle.org/versions/current"
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get
        
        if ($response.version) {
            $gradleInfo = [ToolInfo]::new("Gradle")
            $gradleInfo.Version = $response.version
            $gradleInfo.DownloadUrl = $response.downloadUrl
            $gradleInfo.FileType = "zip"
            
            Write-Host "✅ Gradle ورژن $($response.version) پیدا شد" -ForegroundColor Green
            return $gradleInfo
        }
        else {
            throw "اطلاعات Gradle دریافت نشد"
        }
    }
    catch {
        Write-Error "خطا در شناسایی Gradle: $($_.Exception.Message)"
        return $null
    }
}

# شناسایی آخرین ورژن Android Command Line Tools
function Get-LatestAndroidCmdlineTools {
    Write-Host "🔍 شناسایی آخرین ورژن Android Command Line Tools..." -ForegroundColor Yellow
    
    try {
        # لینک ثابت Google برای آخرین ورژن
        $downloadUrl = "https://dl.google.com/android/repository/commandlinetools-win-latest.zip"
        
        $cmdlineInfo = [ToolInfo]::new("AndroidCmdlineTools")
        $cmdlineInfo.Version = "latest"
        $cmdlineInfo.DownloadUrl = $downloadUrl
        $cmdlineInfo.FileType = "zip"
        
        Write-Host "✅ Android Command Line Tools (latest) پیدا شد" -ForegroundColor Green
        return $cmdlineInfo
    }
    catch {
        Write-Error "خطا در شناسایی Android Command Line Tools: $($_.Exception.Message)"
        return $null
    }
}

# شناسایی آخرین ورژن Platform Tools
function Get-LatestPlatformTools {
    Write-Host "🔍 شناسایی آخرین ورژن Platform Tools..." -ForegroundColor Yellow
    
    try {
        # لینک ثابت Google برای آخرین ورژن
        $downloadUrl = "https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        
        $platformInfo = [ToolInfo]::new("PlatformTools")
        $platformInfo.Version = "latest"
        $platformInfo.DownloadUrl = $downloadUrl
        $platformInfo.FileType = "zip"
        
        Write-Host "✅ Platform Tools (latest) پیدا شد" -ForegroundColor Green
        return $platformInfo
    }
    catch {
        Write-Error "خطا در شناسایی Platform Tools: $($_.Exception.Message)"
        return $null
    }
}

# شناسایی آخرین ورژن Build Tools
function Get-LatestBuildTools {
    Write-Host "🔍 شناسایی آخرین ورژن Build Tools..." -ForegroundColor Yellow
    
    try {
        # استفاده از لینک‌های مستقیم Google برای Build Tools
        # معمولاً آخرین ورژن Build Tools با API level جدید همراه است
        $buildToolsVersions = @(
            @{ Version = "34.0.0"; Url = "https://dl.google.com/android/repository/build-tools_r34-windows.zip" },
            @{ Version = "33.0.2"; Url = "https://dl.google.com/android/repository/build-tools_r33.0.2-windows.zip" },
            @{ Version = "33.0.1"; Url = "https://dl.google.com/android/repository/build-tools_r33.0.1-windows.zip" }
        )
        
        # تست اولین ورژن موجود
        foreach ($version in $buildToolsVersions) {
            try {
                $testResponse = Invoke-WebRequest -Uri $version.Url -Method Head -TimeoutSec 10
                if ($testResponse.StatusCode -eq 200) {
                    $buildToolsInfo = [ToolInfo]::new("BuildTools")
                    $buildToolsInfo.Version = $version.Version
                    $buildToolsInfo.DownloadUrl = $version.Url
                    $buildToolsInfo.FileType = "zip"
                    
                    Write-Host "✅ Build Tools ورژن $($version.Version) پیدا شد" -ForegroundColor Green
                    return $buildToolsInfo
                }
            }
            catch {
                continue
            }
        }
        
        throw "هیچ ورژن Build Tools در دسترس پیدا نشد"
    }
    catch {
        Write-Error "خطا در شناسایی Build Tools: $($_.Exception.Message)"
        return $null
    }
}

# تابع اصلی برای شناسایی تمام ابزارها
function Get-AllLatestVersions {
    Write-Host "🚀 شروع شناسایی آخرین ورژن‌های ابزارهای اندروید..." -ForegroundColor Cyan
    
    $tools = @()
    
    # شناسایی JDK
    $jdk = Get-LatestJDK17Version
    if ($jdk) { $tools += $jdk }
    
    # شناسایی Gradle
    $gradle = Get-LatestGradleVersion
    if ($gradle) { $tools += $gradle }
    
    # شناسایی Android Command Line Tools
    $cmdline = Get-LatestAndroidCmdlineTools
    if ($cmdline) { $tools += $cmdline }
    
    # شناسایی Platform Tools
    $platform = Get-LatestPlatformTools
    if ($platform) { $tools += $platform }
    
    # شناسایی Build Tools
    $buildTools = Get-LatestBuildTools
    if ($buildTools) { $tools += $buildTools }
    
    Write-Host "✅ شناسایی $($tools.Count) ابزار کامل شد" -ForegroundColor Green
    return $tools
}

# Export functions
Export-ModuleMember -Function Get-LatestJDK17Version, Get-LatestGradleVersion, Get-LatestAndroidCmdlineTools, Get-LatestPlatformTools, Get-LatestBuildTools, Get-AllLatestVersions