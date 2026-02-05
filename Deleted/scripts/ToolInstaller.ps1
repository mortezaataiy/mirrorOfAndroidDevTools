# Tool Installer
# مسئول دانلود و نصب ابزارهای توسعه اندروید

# Import required modules
. "$PSScriptRoot\DownloadValidator.ps1"
. "$PSScriptRoot\ErrorHandler.ps1"

# تنظیمات پیش‌فرض
$Global:InstallConfig = @{
    BaseInstallPath = "C:\AndroidDevTools"
    TempDownloadPath = "$env:TEMP\AndroidDownloads"
    MaxRetries = 3
    TimeoutSeconds = 600
}

# ایجاد دایرکتوری‌های مورد نیاز
function Initialize-InstallDirectories {
    Write-ActivityLog -Message "ایجاد دایرکتوری‌های نصب..." -Level "INFO"
    
    $directories = @(
        $Global:InstallConfig.BaseInstallPath,
        $Global:InstallConfig.TempDownloadPath,
        "$($Global:InstallConfig.BaseInstallPath)\jdk",
        "$($Global:InstallConfig.BaseInstallPath)\gradle",
        "$($Global:InstallConfig.BaseInstallPath)\android-sdk",
        "$($Global:InstallConfig.BaseInstallPath)\platform-tools",
        "$($Global:InstallConfig.BaseInstallPath)\build-tools"
    )
    
    foreach ($dir in $directories) {
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
            Write-ActivityLog -Message "دایرکتوری ایجاد شد: $dir" -Level "SUCCESS"
        }
    }
}

# دانلود و نصب JDK
function Install-JDK {
    param([object]$JdkInfo)
    
    Write-ActivityLog -Message "شروع نصب JDK $($JdkInfo.Version)..." -Level "INFO"
    
    try {
        # تست لینک دانلود
        $linkTest = Test-DownloadLink -Url $JdkInfo.DownloadUrl -MinSize 100MB
        if (-not $linkTest.Valid) {
            throw "لینک دانلود JDK معتبر نیست: $($linkTest.Error)"
        }
        
        # دانلود فایل
        $fileName = "jdk-$($JdkInfo.Version).zip"
        $downloadPath = Join-Path $Global:InstallConfig.TempDownloadPath $fileName
        
        $downloadResult = Download-FileWithValidation -Url $JdkInfo.DownloadUrl -OutputPath $downloadPath -MaxRetries $Global:InstallConfig.MaxRetries
        
        if (-not $downloadResult.Success) {
            throw "دانلود JDK ناموفق بود: $($downloadResult.Error)"
        }
        
        # اعتبارسنجی فایل
        $fileValidation = Test-FileValidation -FilePath $downloadPath -FileType "zip"
        if (-not $fileValidation.Valid) {
            throw "فایل JDK معتبر نیست: $($fileValidation.Error)"
        }
        
        # استخراج فایل
        $installPath = Join-Path $Global:InstallConfig.BaseInstallPath "jdk"
        Write-ActivityLog -Message "استخراج JDK به $installPath..." -Level "INFO"
        
        Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
        
        # تنظیم متغیرهای محیطی
        $jdkPath = Get-ChildItem -Path $installPath -Directory | Select-Object -First 1
        if ($jdkPath) {
            $env:JAVA_HOME = $jdkPath.FullName
            $env:PATH = "$($jdkPath.FullName)\bin;$env:PATH"
            
            Write-ActivityLog -Message "JAVA_HOME تنظیم شد: $($jdkPath.FullName)" -Level "SUCCESS"
        }
        
        # پاک کردن فایل موقت
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        
        # به‌روزرسانی اطلاعات ابزار
        $JdkInfo.InstallPath = $jdkPath.FullName
        $JdkInfo.TestStatus = "installed"
        $JdkInfo.FileSize = $downloadResult.FileSize
        
        Write-ActivityLog -Message "JDK با موفقیت نصب شد" -Level "SUCCESS"
        return $true
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::InstallError) -ErrorMessage $_.Exception.Message -Context "JDK Installation"
        return $false
    }
}

# دانلود و نصب Gradle
function Install-Gradle {
    param([object]$GradleInfo)
    
    Write-ActivityLog -Message "شروع نصب Gradle $($GradleInfo.Version)..." -Level "INFO"
    
    try {
        # تست لینک دانلود
        $linkTest = Test-DownloadLink -Url $GradleInfo.DownloadUrl -MinSize 50MB
        if (-not $linkTest.Valid) {
            throw "لینک دانلود Gradle معتبر نیست: $($linkTest.Error)"
        }
        
        # دانلود فایل
        $fileName = "gradle-$($GradleInfo.Version).zip"
        $downloadPath = Join-Path $Global:InstallConfig.TempDownloadPath $fileName
        
        $downloadResult = Download-FileWithValidation -Url $GradleInfo.DownloadUrl -OutputPath $downloadPath -MaxRetries $Global:InstallConfig.MaxRetries
        
        if (-not $downloadResult.Success) {
            throw "دانلود Gradle ناموفق بود: $($downloadResult.Error)"
        }
        
        # اعتبارسنجی فایل
        $fileValidation = Test-FileValidation -FilePath $downloadPath -FileType "zip"
        if (-not $fileValidation.Valid) {
            throw "فایل Gradle معتبر نیست: $($fileValidation.Error)"
        }
        
        # استخراج فایل
        $installPath = Join-Path $Global:InstallConfig.BaseInstallPath "gradle"
        Write-ActivityLog -Message "استخراج Gradle به $installPath..." -Level "INFO"
        
        Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
        
        # تنظیم متغیرهای محیطی
        $gradlePath = Get-ChildItem -Path $installPath -Directory | Select-Object -First 1
        if ($gradlePath) {
            $env:GRADLE_HOME = $gradlePath.FullName
            $env:PATH = "$($gradlePath.FullName)\bin;$env:PATH"
            
            Write-ActivityLog -Message "GRADLE_HOME تنظیم شد: $($gradlePath.FullName)" -Level "SUCCESS"
        }
        
        # پاک کردن فایل موقت
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        
        # به‌روزرسانی اطلاعات ابزار
        $GradleInfo.InstallPath = $gradlePath.FullName
        $GradleInfo.TestStatus = "installed"
        $GradleInfo.FileSize = $downloadResult.FileSize
        
        Write-ActivityLog -Message "Gradle با موفقیت نصب شد" -Level "SUCCESS"
        return $true
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::InstallError) -ErrorMessage $_.Exception.Message -Context "Gradle Installation"
        return $false
    }
}

# دانلود و نصب Android SDK Command Line Tools
function Install-AndroidCmdlineTools {
    param([object]$CmdlineInfo)
    
    Write-ActivityLog -Message "شروع نصب Android Command Line Tools..." -Level "INFO"
    
    try {
        # تست لینک دانلود
        $linkTest = Test-DownloadLink -Url $CmdlineInfo.DownloadUrl -MinSize 50MB
        if (-not $linkTest.Valid) {
            throw "لینک دانلود Android Command Line Tools معتبر نیست: $($linkTest.Error)"
        }
        
        # دانلود فایل
        $fileName = "commandlinetools-win-latest.zip"
        $downloadPath = Join-Path $Global:InstallConfig.TempDownloadPath $fileName
        
        $downloadResult = Download-FileWithValidation -Url $CmdlineInfo.DownloadUrl -OutputPath $downloadPath -MaxRetries $Global:InstallConfig.MaxRetries
        
        if (-not $downloadResult.Success) {
            throw "دانلود Android Command Line Tools ناموفق بود: $($downloadResult.Error)"
        }
        
        # اعتبارسنجی فایل
        $fileValidation = Test-FileValidation -FilePath $downloadPath -FileType "zip"
        if (-not $fileValidation.Valid) {
            throw "فایل Android Command Line Tools معتبر نیست: $($fileValidation.Error)"
        }
        
        # استخراج فایل
        $installPath = Join-Path $Global:InstallConfig.BaseInstallPath "android-sdk"
        Write-ActivityLog -Message "استخراج Android Command Line Tools به $installPath..." -Level "INFO"
        
        Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
        
        # تنظیم متغیرهای محیطی
        $env:ANDROID_HOME = $installPath
        $env:ANDROID_SDK_ROOT = $installPath
        $cmdlineToolsPath = Join-Path $installPath "cmdline-tools\latest\bin"
        $env:PATH = "$cmdlineToolsPath;$env:PATH"
        
        Write-ActivityLog -Message "ANDROID_HOME تنظیم شد: $installPath" -Level "SUCCESS"
        
        # پاک کردن فایل موقت
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        
        # به‌روزرسانی اطلاعات ابزار
        $CmdlineInfo.InstallPath = $installPath
        $CmdlineInfo.TestStatus = "installed"
        $CmdlineInfo.FileSize = $downloadResult.FileSize
        
        Write-ActivityLog -Message "Android Command Line Tools با موفقیت نصب شد" -Level "SUCCESS"
        return $true
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::InstallError) -ErrorMessage $_.Exception.Message -Context "Android Command Line Tools Installation"
        return $false
    }
}

# دانلود و نصب Platform Tools
function Install-PlatformTools {
    param([object]$PlatformInfo)
    
    Write-ActivityLog -Message "شروع نصب Platform Tools..." -Level "INFO"
    
    try {
        # تست لینک دانلود
        $linkTest = Test-DownloadLink -Url $PlatformInfo.DownloadUrl -MinSize 5MB
        if (-not $linkTest.Valid) {
            throw "لینک دانلود Platform Tools معتبر نیست: $($linkTest.Error)"
        }
        
        # دانلود فایل
        $fileName = "platform-tools-latest-windows.zip"
        $downloadPath = Join-Path $Global:InstallConfig.TempDownloadPath $fileName
        
        $downloadResult = Download-FileWithValidation -Url $PlatformInfo.DownloadUrl -OutputPath $downloadPath -MaxRetries $Global:InstallConfig.MaxRetries
        
        if (-not $downloadResult.Success) {
            throw "دانلود Platform Tools ناموفق بود: $($downloadResult.Error)"
        }
        
        # اعتبارسنجی فایل
        $fileValidation = Test-FileValidation -FilePath $downloadPath -FileType "zip"
        if (-not $fileValidation.Valid) {
            throw "فایل Platform Tools معتبر نیست: $($fileValidation.Error)"
        }
        
        # استخراج فایل
        $installPath = Join-Path $Global:InstallConfig.BaseInstallPath "platform-tools"
        Write-ActivityLog -Message "استخراج Platform Tools به $installPath..." -Level "INFO"
        
        Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
        
        # تنظیم متغیرهای محیطی
        $platformToolsPath = Join-Path $installPath "platform-tools"
        $env:PATH = "$platformToolsPath;$env:PATH"
        
        Write-ActivityLog -Message "Platform Tools به PATH اضافه شد: $platformToolsPath" -Level "SUCCESS"
        
        # پاک کردن فایل موقت
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        
        # به‌روزرسانی اطلاعات ابزار
        $PlatformInfo.InstallPath = $platformToolsPath
        $PlatformInfo.TestStatus = "installed"
        $PlatformInfo.FileSize = $downloadResult.FileSize
        
        Write-ActivityLog -Message "Platform Tools با موفقیت نصب شد" -Level "SUCCESS"
        return $true
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::InstallError) -ErrorMessage $_.Exception.Message -Context "Platform Tools Installation"
        return $false
    }
}

# دانلود و نصب Build Tools
function Install-BuildTools {
    param([object]$BuildToolsInfo)
    
    Write-ActivityLog -Message "شروع نصب Build Tools $($BuildToolsInfo.Version)..." -Level "INFO"
    
    try {
        # تست لینک دانلود
        $linkTest = Test-DownloadLink -Url $BuildToolsInfo.DownloadUrl -MinSize 30MB
        if (-not $linkTest.Valid) {
            throw "لینک دانلود Build Tools معتبر نیست: $($linkTest.Error)"
        }
        
        # دانلود فایل
        $fileName = "build-tools-$($BuildToolsInfo.Version).zip"
        $downloadPath = Join-Path $Global:InstallConfig.TempDownloadPath $fileName
        
        $downloadResult = Download-FileWithValidation -Url $BuildToolsInfo.DownloadUrl -OutputPath $downloadPath -MaxRetries $Global:InstallConfig.MaxRetries
        
        if (-not $downloadResult.Success) {
            throw "دانلود Build Tools ناموفق بود: $($downloadResult.Error)"
        }
        
        # اعتبارسنجی فایل
        $fileValidation = Test-FileValidation -FilePath $downloadPath -FileType "zip"
        if (-not $fileValidation.Valid) {
            throw "فایل Build Tools معتبر نیست: $($fileValidation.Error)"
        }
        
        # استخراج فایل
        $installPath = Join-Path $Global:InstallConfig.BaseInstallPath "build-tools"
        Write-ActivityLog -Message "استخراج Build Tools به $installPath..." -Level "INFO"
        
        Expand-Archive -Path $downloadPath -DestinationPath $installPath -Force
        
        # تنظیم متغیرهای محیطی
        $buildToolsPath = Join-Path $installPath $BuildToolsInfo.Version
        $env:PATH = "$buildToolsPath;$env:PATH"
        
        Write-ActivityLog -Message "Build Tools به PATH اضافه شد: $buildToolsPath" -Level "SUCCESS"
        
        # پاک کردن فایل موقت
        Remove-Item $downloadPath -Force -ErrorAction SilentlyContinue
        
        # به‌روزرسانی اطلاعات ابزار
        $BuildToolsInfo.InstallPath = $buildToolsPath
        $BuildToolsInfo.TestStatus = "installed"
        $BuildToolsInfo.FileSize = $downloadResult.FileSize
        
        Write-ActivityLog -Message "Build Tools با موفقیت نصب شد" -Level "SUCCESS"
        return $true
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::InstallError) -ErrorMessage $_.Exception.Message -Context "Build Tools Installation"
        return $false
    }
}

# نصب تمام ابزارها
function Install-AllTools {
    param([array]$Tools)
    
    Write-ActivityLog -Message "شروع نصب تمام ابزارها..." -Level "INFO"
    
    # ایجاد دایرکتوری‌ها
    Initialize-InstallDirectories
    
    $successCount = 0
    $totalCount = $Tools.Count
    
    foreach ($tool in $Tools) {
        Write-ActivityLog -Message "نصب $($tool.Name)..." -Level "INFO"
        
        $installResult = switch ($tool.Name) {
            "JDK" { Install-JDK -JdkInfo $tool }
            "Gradle" { Install-Gradle -GradleInfo $tool }
            "AndroidCmdlineTools" { Install-AndroidCmdlineTools -CmdlineInfo $tool }
            "PlatformTools" { Install-PlatformTools -PlatformInfo $tool }
            "BuildTools" { Install-BuildTools -BuildToolsInfo $tool }
            default { 
                Write-ActivityLog -Message "نوع ابزار ناشناخته: $($tool.Name)" -Level "WARNING"
                $false
            }
        }
        
        if ($installResult) {
            $successCount++
        }
    }
    
    Write-ActivityLog -Message "نصب کامل شد: $successCount از $totalCount ابزار" -Level "SUCCESS"
    
    # نمایش خلاصه متغیرهای محیطی
    Show-EnvironmentSummary
    
    return $successCount -eq $totalCount
}

# نمایش خلاصه متغیرهای محیطی
function Show-EnvironmentSummary {
    Write-ActivityLog -Message "=== خلاصه متغیرهای محیطی ===" -Level "INFO"
    
    $envVars = @(
        @{ Name = "JAVA_HOME"; Value = $env:JAVA_HOME },
        @{ Name = "GRADLE_HOME"; Value = $env:GRADLE_HOME },
        @{ Name = "ANDROID_HOME"; Value = $env:ANDROID_HOME },
        @{ Name = "ANDROID_SDK_ROOT"; Value = $env:ANDROID_SDK_ROOT }
    )
    
    foreach ($envVar in $envVars) {
        if ($envVar.Value) {
            Write-ActivityLog -Message "$($envVar.Name): $($envVar.Value)" -Level "SUCCESS"
        }
        else {
            Write-ActivityLog -Message "$($envVar.Name): تنظیم نشده" -Level "WARNING"
        }
    }
}

# Export functions
Export-ModuleMember -Function Initialize-InstallDirectories, Install-JDK, Install-Gradle, Install-AndroidCmdlineTools, Install-PlatformTools, Install-BuildTools, Install-AllTools, Show-EnvironmentSummary