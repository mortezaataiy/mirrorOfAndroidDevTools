# 01-check-prerequisites.ps1 - Check Command Line Tools Prerequisites
param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "CommandLineTools-Prerequisites"

Write-InfoLog "Starting Android SDK Command Line Tools prerequisites check" "CommandLineTools"

# Configuration variables
$commandLineToolsFileName = "commandlinetools-win-latest.zip"
$minimumSizeBytes = 50MB

# Check system architecture
Write-InfoLog "Checking system architecture..." "CommandLineTools"
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -ne "AMD64") {
    Write-ErrorLog "Unsupported system architecture. Expected: AMD64, Found: $architecture" "CommandLineTools"
    exit 1
}
Write-InfoLog "System architecture is suitable: $architecture" "CommandLineTools"

# Check Windows version
Write-InfoLog "Checking Windows version..." "CommandLineTools"
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-ErrorLog "Unsupported Windows version. Windows 10 or higher required" "CommandLineTools"
    exit 1
}
Write-InfoLog "Windows version is suitable: $($osVersion.ToString())" "CommandLineTools"

# Check JDK dependency
Write-InfoLog "Checking JDK dependency..." "CommandLineTools"
$javaHome = $env:JAVA_HOME
if (-not $javaHome -or -not (Test-Path $javaHome)) {
    Write-ErrorLog "JDK not found. JAVA_HOME is not set or invalid: $javaHome" "CommandLineTools"
    Write-ErrorLog "Please install JDK 17 first using the JDK installation script" "CommandLineTools"
    exit 1
}

# Verify Java version
try {
    $javaVersion = & "$javaHome\bin\java.exe" -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Java executable not working properly" "CommandLineTools"
        exit 1
    }
    Write-InfoLog "JDK dependency satisfied: $($javaVersion[0])" "CommandLineTools"
} catch {
    Write-ErrorLog "Failed to verify Java installation: $($_.Exception.Message)" "CommandLineTools"
    exit 1
}

# Determine full Command Line Tools file path
$commandLineToolsFilePath = Join-Path $DownloadPath $commandLineToolsFileName

Write-InfoLog "Checking Command Line Tools file existence: $commandLineToolsFilePath" "CommandLineTools"

# Check Command Line Tools file existence
if (-not (Test-FileExists $commandLineToolsFilePath "CommandLineTools")) {
    Write-ErrorLog "Command Line Tools file not found: $commandLineToolsFilePath" "CommandLineTools"
    exit 1
}

# Check Command Line Tools file size
if (-not (Test-FileSize $commandLineToolsFilePath $minimumSizeBytes "CommandLineTools")) {
    Write-ErrorLog "Command Line Tools file size is smaller than expected" "CommandLineTools"
    exit 1
}

# Check ZIP file integrity
if (-not (Test-ZipFileIntegrity $commandLineToolsFilePath "CommandLineTools")) {
    Write-ErrorLog "Command Line Tools ZIP file is not valid" "CommandLineTools"
    exit 1
}

Write-InfoLog "All Android SDK Command Line Tools prerequisites are met" "CommandLineTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Ready to install Android SDK Command Line Tools" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errors found in prerequisites check" -ForegroundColor Red
    exit 1
}