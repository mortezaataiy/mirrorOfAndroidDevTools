# 01-check-prerequisites.ps1 - Check Build Tools Prerequisites
param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "BuildTools-Prerequisites"

Write-InfoLog "Starting Android Build Tools prerequisites check" "BuildTools"

# Configuration variables
$buildToolsFileName = "build-tools-33.0.2.zip"
$minimumSizeBytes = 30MB

# Check system architecture
Write-InfoLog "Checking system architecture..." "BuildTools"
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -ne "AMD64") {
    Write-ErrorLog "Unsupported system architecture. Expected: AMD64, Found: $architecture" "BuildTools"
    exit 1
}
Write-InfoLog "System architecture is suitable: $architecture" "BuildTools"

# Check Windows version
Write-InfoLog "Checking Windows version..." "BuildTools"
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-ErrorLog "Unsupported Windows version. Windows 10 or higher required" "BuildTools"
    exit 1
}
Write-InfoLog "Windows version is suitable: $($osVersion.ToString())" "BuildTools"

# Check Command Line Tools dependency
Write-InfoLog "Checking Android SDK Command Line Tools dependency..." "BuildTools"
$androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
if (-not $androidSdkRoot -or -not (Test-Path $androidSdkRoot)) {
    Write-ErrorLog "Android SDK not found. ANDROID_SDK_ROOT is not set or invalid: $androidSdkRoot" "BuildTools"
    Write-ErrorLog "Please install Android SDK Command Line Tools first" "BuildTools"
    exit 1
}

# Verify SDK Manager is available
$sdkManagerPath = Join-Path $androidSdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
if (-not (Test-Path $sdkManagerPath)) {
    Write-ErrorLog "SDK Manager not found: $sdkManagerPath" "BuildTools"
    Write-ErrorLog "Please install Android SDK Command Line Tools first" "BuildTools"
    exit 1
}

Write-InfoLog "Android SDK Command Line Tools dependency satisfied: $androidSdkRoot" "BuildTools"

# Determine full Build Tools file path
$buildToolsFilePath = Join-Path $DownloadPath $buildToolsFileName

Write-InfoLog "Checking Build Tools file existence: $buildToolsFilePath" "BuildTools"

# Check Build Tools file existence
if (-not (Test-FileExists $buildToolsFilePath "BuildTools")) {
    Write-ErrorLog "Build Tools file not found: $buildToolsFilePath" "BuildTools"
    exit 1
}

# Check Build Tools file size
if (-not (Test-FileSize $buildToolsFilePath $minimumSizeBytes "BuildTools")) {
    Write-ErrorLog "Build Tools file size is smaller than expected" "BuildTools"
    exit 1
}

# Check ZIP file integrity
if (-not (Test-ZipFileIntegrity $buildToolsFilePath "BuildTools")) {
    Write-ErrorLog "Build Tools ZIP file is not valid" "BuildTools"
    exit 1
}

Write-InfoLog "All Android Build Tools prerequisites are met" "BuildTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Ready to install Android Build Tools" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errors found in prerequisites check" -ForegroundColor Red
    exit 1
}