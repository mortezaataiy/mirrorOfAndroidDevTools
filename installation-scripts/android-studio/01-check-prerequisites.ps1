# 01-check-prerequisites.ps1 - Check Android Studio Prerequisites
param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "AndroidStudio-Prerequisites"

Write-InfoLog "Starting Android Studio prerequisites check" "AndroidStudio"

# Configuration variables
$androidStudioFileName = "android-studio-2022.3.1.20-windows.exe"
$minimumSizeBytes = 800MB  # Android Studio installer is typically large
$minimumDiskSpaceGB = 4    # Minimum disk space required for installation

# Check system architecture
Write-InfoLog "Checking system architecture..." "AndroidStudio"
$architecture = $env:PROCESSOR_ARCHITECTURE
if ($architecture -ne "AMD64") {
    Write-ErrorLog "Unsupported system architecture. Expected: AMD64, Found: $architecture" "AndroidStudio"
    exit 1
}
Write-InfoLog "System architecture is suitable: $architecture" "AndroidStudio"

# Check Windows version
Write-InfoLog "Checking Windows version..." "AndroidStudio"
$osVersion = [System.Environment]::OSVersion.Version
if ($osVersion.Major -lt 10) {
    Write-ErrorLog "Unsupported Windows version. Windows 10 or higher required" "AndroidStudio"
    exit 1
}
Write-InfoLog "Windows version is suitable: $($osVersion.ToString())" "AndroidStudio"

# Check available disk space
Write-InfoLog "Checking available disk space..." "AndroidStudio"
$drive = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq "C:" }
$availableSpaceGB = [math]::Round($drive.FreeSpace / 1GB, 2)
if ($availableSpaceGB -lt $minimumDiskSpaceGB) {
    Write-ErrorLog "Insufficient disk space. Required: ${minimumDiskSpaceGB}GB, Available: ${availableSpaceGB}GB" "AndroidStudio"
    exit 1
}
Write-InfoLog "Sufficient disk space available: ${availableSpaceGB}GB" "AndroidStudio"

# Check JDK dependency
Write-InfoLog "Checking JDK dependency..." "AndroidStudio"
$javaHome = $env:JAVA_HOME
if (-not $javaHome -or -not (Test-Path $javaHome)) {
    Write-ErrorLog "JDK not found. JAVA_HOME is not set or invalid: $javaHome" "AndroidStudio"
    Write-ErrorLog "Please install JDK 17 first using the JDK installation script" "AndroidStudio"
    exit 1
}

# Verify Java version
try {
    $javaVersion = & "$javaHome\bin\java.exe" -version 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-ErrorLog "Java executable not working properly" "AndroidStudio"
        exit 1
    }
    Write-InfoLog "JDK dependency satisfied: $($javaVersion[0])" "AndroidStudio"
} catch {
    Write-ErrorLog "Failed to verify Java installation: $($_.Exception.Message)" "AndroidStudio"
    exit 1
}

# Determine full Android Studio file path
$androidStudioFilePath = Join-Path $DownloadPath $androidStudioFileName

Write-InfoLog "Checking Android Studio file existence: $androidStudioFilePath" "AndroidStudio"

# Check Android Studio file existence
if (-not (Test-FileExists $androidStudioFilePath "AndroidStudio")) {
    Write-ErrorLog "Android Studio file not found: $androidStudioFilePath" "AndroidStudio"
    exit 1
}

# Check Android Studio file size
if (-not (Test-FileSize $androidStudioFilePath $minimumSizeBytes "AndroidStudio")) {
    Write-ErrorLog "Android Studio file size is smaller than expected" "AndroidStudio"
    exit 1
}

# Check if file is a valid executable
Write-InfoLog "Verifying Android Studio executable..." "AndroidStudio"
$fileInfo = Get-Item $androidStudioFilePath
if ($fileInfo.Extension -ne ".exe") {
    Write-ErrorLog "Android Studio file is not a valid executable: $($fileInfo.Extension)" "AndroidStudio"
    exit 1
}

# Basic executable validation (check PE header)
try {
    $bytes = [System.IO.File]::ReadAllBytes($androidStudioFilePath)
    if ($bytes.Length -lt 2 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
        Write-ErrorLog "Android Studio file does not have valid PE executable header" "AndroidStudio"
        exit 1
    }
    Write-InfoLog "Android Studio executable file is valid" "AndroidStudio"
} catch {
    Write-ErrorLog "Failed to validate Android Studio executable: $($_.Exception.Message)" "AndroidStudio"
    exit 1
}

Write-InfoLog "All Android Studio prerequisites are met" "AndroidStudio"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Ready to install Android Studio" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Errors found in prerequisites check" -ForegroundColor Red
    exit 1
}