# 01-check-prerequisites.ps1 - Check Platform Tools Prerequisites
param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "PlatformTools-Prerequisites"

Write-InfoLog "Starting Android Platform Tools prerequisites check" "PlatformTools"

# Configuration variables
$platformToolsFileName = "platform-tools.zip"
$minimumSizeBytes = 5MB

# Check system architecture
Write-InfoLog "Checking system architecture..." "PlatformTools"
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -ne "AMD64") {
    Write-ErrorLog "Unsupported system architecture. Expected: AMD64, Found: $architecture" "PlatformTools"
    exit 1
}
Write-InfoLog "System architecture is suitable: $architecture" "PlatformTools"

# Check Windows version
Write-InfoLog "Checking Windows version..." "PlatformTools"
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-ErrorLog "Unsupported Windows version. Windows 10 or higher required" "PlatformTools"
    exit 1
}
Write-InfoLog "Windows version is suitable: $($osVersion.ToString())" "PlatformTools"

# Check Command Line Tools dependency
Write-InfoLog "Checking Android SDK Command Line Tools dependency..." "PlatformTools"
$androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
if (-not $androidSdkRoot -or -not (Test-Path $androidSdkRoot)) {
    Write-ErrorLog "Android SDK not found. ANDROID_SDK_ROOT is not set or invalid: $androidSdkRoot" "PlatformTools"
    Write-ErrorLog "Please install Android SDK Command Line Tools first" "PlatformTools"
    exit 1
}

# Verify SDK Manager is available
$sdkManagerPath = Join-Path $androidSdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
if (-not (Test-Path $sdkManagerPath)) {
    Write-ErrorLog "SDK Manager not found: $sdkManagerPath" "PlatformTools"
    Write-ErrorLog "Please install Android SDK Command Line Tools first" "PlatformTools"
    exit 1
}

Write-InfoLog "Android SDK Command Line Tools dependency satisfied: $androidSdkRoot" "PlatformTools"

# Determine full Platform Tools file path
$platformToolsFilePath = Join-Path $DownloadPath $platformToolsFileName

Write-InfoLog "Checking Platform Tools file existence: $platformToolsFilePath" "PlatformTools"

# Check Platform Tools file existence
if (-not (Test-FileExists $platformToolsFilePath "PlatformTools")) {
    Write-ErrorLog "Platform Tools file not found: $platformToolsFilePath" "PlatformTools"
    exit 1
}

# Check Platform Tools file size
if (-not (Test-FileSize $platformToolsFilePath $minimumSizeBytes "PlatformTools")) {
    Write-ErrorLog "Platform Tools file size is smaller than expected" "PlatformTools"
    exit 1
}

# Check ZIP file integrity
if (-not (Test-ZipFileIntegrity $platformToolsFilePath "PlatformTools")) {
    Write-ErrorLog "Platform Tools ZIP file is not valid" "PlatformTools"
    exit 1
}

Write-InfoLog "All Android Platform Tools prerequisites are met" "PlatformTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Ready to install Android Platform Tools" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errors found in prerequisites check" -ForegroundColor Red
    exit 1
}