# 02-install-component.ps1 - Install Android Platform Tools
param(
    [string]$DownloadPath = "..\..\downloaded",
    [string]$InstallPath = "",  # Will be determined from ANDROID_SDK_ROOT
    [switch]$Force
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force
Import-Module "$commonPath\EnvironmentManager.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "PlatformTools-Install"

Write-InfoLog "Starting Android Platform Tools installation" "PlatformTools"

# Configuration variables
$platformToolsFileName = "platform-tools.zip"
$extractedPlatformToolsFolder = "extracted_platform-tools"
$platformToolsFilePath = Join-Path $DownloadPath $platformToolsFileName
$extractedPlatformToolsPath = Join-Path $DownloadPath $extractedPlatformToolsFolder

# Run prerequisites check
Write-InfoLog "Running prerequisites check..." "PlatformTools"
$prerequisiteScript = Join-Path $PSScriptRoot "01-check-prerequisites.ps1"
& $prerequisiteScript -DownloadPath $DownloadPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Prerequisites check failed" "PlatformTools"
    exit 1
}

# Determine Android SDK path
$androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
if (-not $androidSdkRoot) {
    Write-ErrorLog "ANDROID_SDK_ROOT environment variable not found" "PlatformTools"
    exit 1
}

# Set install path if not provided
if (-not $InstallPath) {
    $InstallPath = Join-Path $androidSdkRoot "platform-tools"
}

Write-InfoLog "Platform Tools will be installed to: $InstallPath" "PlatformTools"

# Extract Platform Tools if not already extracted
if (-not (Test-Path $extractedPlatformToolsPath) -or $Force) {
    Write-InfoLog "Extracting Platform Tools file: $platformToolsFilePath" "PlatformTools"
    
    if (Test-Path $extractedPlatformToolsPath) {
        Remove-Item $extractedPlatformToolsPath -Recurse -Force
    }
    
    # Create extraction directory
    New-Item -ItemType Directory -Path $extractedPlatformToolsPath -Force | Out-Null
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($platformToolsFilePath, $extractedPlatformToolsPath)
        Write-InfoLog "Platform Tools extracted successfully" "PlatformTools"
    } catch {
        Write-ErrorLog "Failed to extract Platform Tools: $($_.Exception.Message)" "PlatformTools"
        exit 1
    }
}

# Find Platform Tools main folder
$platformToolsSourcePath = Join-Path $extractedPlatformToolsPath "platform-tools"
if (-not (Test-Path $platformToolsSourcePath)) {
    Write-ErrorLog "platform-tools folder not found in extracted content" "PlatformTools"
    exit 1
}

# Copy Platform Tools files
if (-not (Test-Path $InstallPath) -or $Force) {
    if (Test-Path $InstallPath) {
        Remove-Item $InstallPath -Recurse -Force
    }
    
    Write-InfoLog "Copying Platform Tools to final destination..." "PlatformTools"
    try {
        Copy-Item $platformToolsSourcePath $InstallPath -Recurse -Force
        Write-InfoLog "Platform Tools copied successfully" "PlatformTools"
    } catch {
        Write-ErrorLog "Failed to copy Platform Tools: $($_.Exception.Message)" "PlatformTools"
        exit 1
    }
}

# Add Platform Tools to PATH
Write-InfoLog "Adding Platform Tools to PATH: $InstallPath" "PlatformTools"

try {
    Add-ToPath -Path $InstallPath -Scope "User"
    Write-InfoLog "Platform Tools added to PATH successfully" "PlatformTools"
} catch {
    Write-ErrorLog "Failed to add Platform Tools to PATH: $($_.Exception.Message)" "PlatformTools"
    exit 1
}

# Test installation
$env:PATH = $env:PATH + ";" + $InstallPath

# Test ADB
$adbExe = Join-Path $InstallPath "adb.exe"
if (Test-Path $adbExe) {
    try {
        Write-InfoLog "Testing ADB installation..." "PlatformTools"
        $adbVersion = & $adbExe version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InfoLog "ADB version test successful" "PlatformTools"
            $versionLine = $adbVersion | Where-Object { $_ -match "Android Debug Bridge" } | Select-Object -First 1
            if ($versionLine) {
                Write-InfoLog "ADB version: $versionLine" "PlatformTools"
            }
        } else {
            Write-WarningLog "ADB version test failed with exit code: $LASTEXITCODE" "PlatformTools"
        }
    } catch {
        Write-WarningLog "Failed to test ADB: $($_.Exception.Message)" "PlatformTools"
    }
} else {
    Write-ErrorLog "ADB executable not found: $adbExe" "PlatformTools"
    exit 1
}

# Test Fastboot
$fastbootExe = Join-Path $InstallPath "fastboot.exe"
if (Test-Path $fastbootExe) {
    try {
        Write-InfoLog "Testing Fastboot installation..." "PlatformTools"
        $fastbootVersion = & $fastbootExe --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InfoLog "Fastboot version test successful" "PlatformTools"
            $versionLine = $fastbootVersion | Where-Object { $_ -match "fastboot" } | Select-Object -First 1
            if ($versionLine) {
                Write-InfoLog "Fastboot version: $versionLine" "PlatformTools"
            }
        } else {
            Write-WarningLog "Fastboot version test failed with exit code: $LASTEXITCODE" "PlatformTools"
        }
    } catch {
        Write-WarningLog "Failed to test Fastboot: $($_.Exception.Message)" "PlatformTools"
    }
} else {
    Write-WarningLog "Fastboot executable not found: $fastbootExe" "PlatformTools"
}

Write-InfoLog "Android Platform Tools installation completed successfully" "PlatformTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Android Platform Tools installed successfully!" -ForegroundColor Green
    Write-Host "ADB and Fastboot are now available" -ForegroundColor Yellow
    Write-Host "Please restart PowerShell to apply PATH changes" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "Installation completed with some errors" -ForegroundColor Yellow
    exit 1
}