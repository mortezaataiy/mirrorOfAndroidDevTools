# 02-install-component.ps1 - Install JDK 17
param(
    [string]$DownloadPath = "downloaded",
    [string]$InstallPath = "$env:ProgramFiles\Java",
    [switch]$Force
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
. "$commonPath\Logger.ps1"
. "$commonPath\FileValidator.ps1"

Initialize-Logger -ComponentName "JDK17-Install"
Write-InfoLog "Starting JDK 17 installation" "JDK17"

# Configuration
$jdkFileName = "jdk-17.zip"
$extractedJdkFolder = "extracted_jdk-17"
$jdkFilePath = Join-Path $DownloadPath $jdkFileName
$extractedJdkPath = Join-Path $DownloadPath $extractedJdkFolder

# Run prerequisites check
Write-InfoLog "Running prerequisites check..." "JDK17"
$prerequisiteScript = Join-Path $PSScriptRoot "01-check-prerequisites.ps1"
& $prerequisiteScript -DownloadPath $DownloadPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Prerequisites check failed" "JDK17"
    exit 1
}

# Create install directory
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-InfoLog "Created install directory: $InstallPath" "JDK17"
}

# Extract JDK if not already extracted
if (-not (Test-Path $extractedJdkPath) -or $Force) {
    Write-InfoLog "Extracting JDK file: $jdkFilePath" "JDK17"
    
    if (Test-Path $extractedJdkPath) {
        Remove-Item $extractedJdkPath -Recurse -Force
    }
    
    # Create extraction directory
    New-Item -ItemType Directory -Path $extractedJdkPath -Force | Out-Null
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    # First extraction
    [System.IO.Compression.ZipFile]::ExtractToDirectory($jdkFilePath, $extractedJdkPath)
    
    # Check if we got another ZIP file (nested ZIP)
    $innerZipPath = Join-Path $extractedJdkPath "jdk-17.zip"
    if (Test-Path $innerZipPath) {
        Write-InfoLog "Found nested ZIP, extracting inner content..." "JDK17"
        
        # Remove the inner ZIP after extracting it
        [System.IO.Compression.ZipFile]::ExtractToDirectory($innerZipPath, $extractedJdkPath)
        Remove-Item $innerZipPath -Force
    }
    
    Write-InfoLog "JDK extracted successfully" "JDK17"
}

# Find JDK main folder
$jdkSubFolders = Get-ChildItem $extractedJdkPath -Directory
$jdkSourcePath = $jdkSubFolders[0].FullName
$jdkFolderName = $jdkSubFolders[0].Name
$jdkFinalPath = Join-Path $InstallPath $jdkFolderName

Write-InfoLog "JDK source path: $jdkSourcePath" "JDK17"
Write-InfoLog "JDK final path: $jdkFinalPath" "JDK17"

# Copy JDK files
if (-not (Test-Path $jdkFinalPath) -or $Force) {
    if (Test-Path $jdkFinalPath) {
        Remove-Item $jdkFinalPath -Recurse -Force
    }
    
    Write-InfoLog "Copying JDK files to final destination..." "JDK17"
    Copy-Item $jdkSourcePath $jdkFinalPath -Recurse -Force
    Write-InfoLog "JDK files copied successfully" "JDK17"
}

# Set JAVA_HOME
Write-InfoLog "Setting JAVA_HOME environment variable" "JDK17"
[Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkFinalPath, "User")

# Add to PATH
$jdkBinPath = Join-Path $jdkFinalPath "bin"
Write-InfoLog "Adding JDK to PATH: $jdkBinPath" "JDK17"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -notlike "*$jdkBinPath*") {
    $newPath = $currentPath + ";" + $jdkBinPath
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
}

# Test installation
$env:JAVA_HOME = $jdkFinalPath
$env:PATH = $env:PATH + ";" + $jdkBinPath

$javaExe = Join-Path $jdkFinalPath "bin\java.exe"
$javaVersion = & $javaExe -version 2>&1
Write-InfoLog "Java version: $($javaVersion[0])" "JDK17"

Write-InfoLog "JDK 17 installation completed successfully" "JDK17"
Write-Host "JDK 17 installed successfully!" -ForegroundColor Green
Write-Host "Please restart PowerShell to apply environment changes" -ForegroundColor Yellow
