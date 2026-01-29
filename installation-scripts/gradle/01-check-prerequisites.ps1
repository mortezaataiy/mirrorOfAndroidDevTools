# 01-check-prerequisites.ps1 - Check Gradle Prerequisites
param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "Gradle-Prerequisites"

Write-InfoLog "Starting Gradle prerequisites check" "Gradle"

# Configuration variables
$gradleFileName = "gradle-8.0.2-bin.zip"
$minimumSizeBytes = 50MB

# Check system architecture
Write-InfoLog "Checking system architecture..." "Gradle"
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -ne "AMD64") {
    Write-ErrorLog "Unsupported system architecture. Expected: AMD64, Found: $architecture" "Gradle"
    exit 1
}
Write-InfoLog "System architecture is suitable: $architecture" "Gradle"

# Check Windows version
Write-InfoLog "Checking Windows version..." "Gradle"
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-ErrorLog "Unsupported Windows version. Windows 10 or higher required" "Gradle"
    exit 1
}
Write-InfoLog "Windows version is suitable: $($osVersion.ToString())" "Gradle"

# Check JDK dependency
Write-InfoLog "Checking JDK dependency..." "Gradle"
$javaHome = $env:JAVA_HOME
if (-not $javaHome -or -not (Test-Path $javaHome)) {
    Write-ErrorLog "JDK not found. JAVA_HOME is not set or invalid: $javaHome" "Gradle"
    Write-ErrorLog "Please install JDK 17 first using the JDK installation script" "Gradle"
    exit 1
}

# Verify Java version
try {
    $javaVersion = & "$javaHome\bin\java.exe" -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Java executable not working properly" "Gradle"
        exit 1
    }
    Write-InfoLog "JDK dependency satisfied: $($javaVersion[0])" "Gradle"
} catch {
    Write-ErrorLog "Failed to verify Java installation: $($_.Exception.Message)" "Gradle"
    exit 1
}

# Determine full Gradle file path
$gradleFilePath = Join-Path $DownloadPath $gradleFileName

Write-InfoLog "Checking Gradle file existence: $gradleFilePath" "Gradle"

# Check Gradle file existence
if (-not (Test-FileExists $gradleFilePath "Gradle")) {
    Write-ErrorLog "Gradle file not found: $gradleFilePath" "Gradle"
    exit 1
}

# Check Gradle file size
if (-not (Test-FileSize $gradleFilePath $minimumSizeBytes "Gradle")) {
    Write-ErrorLog "Gradle file size is smaller than expected" "Gradle"
    exit 1
}

# Check ZIP file integrity
if (-not (Test-ZipFileIntegrity $gradleFilePath "Gradle")) {
    Write-ErrorLog "Gradle ZIP file is not valid" "Gradle"
    exit 1
}

Write-InfoLog "All Gradle prerequisites are met" "Gradle"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Ready to install Gradle" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errors found in prerequisites check" -ForegroundColor Red
    exit 1
}