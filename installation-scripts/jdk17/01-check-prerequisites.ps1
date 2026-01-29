# 01-check-prerequisites.ps1 - Check JDK 17 Prerequisites
param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "JDK17-Prerequisites"

Write-InfoLog "Starting JDK 17 prerequisites check" "JDK17"

# Configuration variables
$jdkFileName = "jdk-17.zip"
$minimumSizeBytes = 100MB

# Check system architecture
Write-InfoLog "Checking system architecture..." "JDK17"
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -ne "AMD64") {
    Write-ErrorLog "Unsupported system architecture. Expected: AMD64, Found: $architecture" "JDK17"
    exit 1
}
Write-InfoLog "System architecture is suitable: $architecture" "JDK17"

# Check Windows version
Write-InfoLog "Checking Windows version..." "JDK17"
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-ErrorLog "Unsupported Windows version. Windows 10 or higher required" "JDK17"
    exit 1
}
Write-InfoLog "Windows version is suitable: $($osVersion.ToString())" "JDK17"

# Determine full JDK file path
$jdkFilePath = Join-Path $DownloadPath $jdkFileName

Write-InfoLog "Checking JDK file existence: $jdkFilePath" "JDK17"

# Check JDK file existence
if (-not (Test-FileExists $jdkFilePath "JDK17")) {
    Write-ErrorLog "JDK file not found: $jdkFilePath" "JDK17"
    exit 1
}

# Check JDK file size
if (-not (Test-FileSize $jdkFilePath $minimumSizeBytes "JDK17")) {
    Write-ErrorLog "JDK file size is smaller than expected" "JDK17"
    exit 1
}

# Check ZIP file integrity
if (-not (Test-ZipFileIntegrity $jdkFilePath "JDK17")) {
    Write-ErrorLog "JDK ZIP file is not valid" "JDK17"
    exit 1
}

Write-InfoLog "All JDK 17 prerequisites are met" "JDK17"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Ready to install JDK 17" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errors found in prerequisites check" -ForegroundColor Red
    exit 1
}
