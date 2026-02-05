# 02-install-component.ps1 - Install Android SDK Command Line Tools
param(
    [string]$DownloadPath = "..\..\downloaded",
    [string]$InstallPath = "$env:LOCALAPPDATA\Android\Sdk",
    [switch]$Force
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force
Import-Module "$commonPath\EnvironmentManager.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "CommandLineTools-Install"

Write-InfoLog "Starting Android SDK Command Line Tools installation" "CommandLineTools"

# Configuration variables
$commandLineToolsFileName = "commandlinetools-win-latest.zip"
$extractedCommandLineToolsFolder = "extracted_commandlinetools-win-latest"
$commandLineToolsFilePath = Join-Path $DownloadPath $commandLineToolsFileName
$extractedCommandLineToolsPath = Join-Path $DownloadPath $extractedCommandLineToolsFolder

# Run prerequisites check
Write-InfoLog "Running prerequisites check..." "CommandLineTools"
$prerequisiteScript = Join-Path $PSScriptRoot "01-check-prerequisites.ps1"
& $prerequisiteScript -DownloadPath $DownloadPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Prerequisites check failed" "CommandLineTools"
    exit 1
}

# Create Android SDK directory structure
Write-InfoLog "Creating Android SDK directory structure..." "CommandLineTools"
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-InfoLog "Created Android SDK directory: $InstallPath" "CommandLineTools"
}

# Create cmdline-tools directory
$cmdlineToolsPath = Join-Path $InstallPath "cmdline-tools"
if (-not (Test-Path $cmdlineToolsPath)) {
    New-Item -ItemType Directory -Path $cmdlineToolsPath -Force | Out-Null
    Write-InfoLog "Created cmdline-tools directory: $cmdlineToolsPath" "CommandLineTools"
}

# Extract Command Line Tools if not already extracted
if (-not (Test-Path $extractedCommandLineToolsPath) -or $Force) {
    Write-InfoLog "Extracting Command Line Tools file: $commandLineToolsFilePath" "CommandLineTools"
    
    if (Test-Path $extractedCommandLineToolsPath) {
        Remove-Item $extractedCommandLineToolsPath -Recurse -Force
    }
    
    # Create extraction directory
    New-Item -ItemType Directory -Path $extractedCommandLineToolsPath -Force | Out-Null
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($commandLineToolsFilePath, $extractedCommandLineToolsPath)
        Write-InfoLog "Command Line Tools extracted successfully" "CommandLineTools"
    } catch {
        Write-ErrorLog "Failed to extract Command Line Tools: $($_.Exception.Message)" "CommandLineTools"
        exit 1
    }
}

# Find Command Line Tools main folder
$cmdlineToolsSourcePath = Join-Path $extractedCommandLineToolsPath "cmdline-tools"
if (-not (Test-Path $cmdlineToolsSourcePath)) {
    Write-ErrorLog "cmdline-tools folder not found in extracted content" "CommandLineTools"
    exit 1
}

# Create latest version directory (required by Android SDK structure)
$latestPath = Join-Path $cmdlineToolsPath "latest"

# Copy Command Line Tools files
if (-not (Test-Path $latestPath) -or $Force) {
    if (Test-Path $latestPath) {
        Remove-Item $latestPath -Recurse -Force
    }
    
    Write-InfoLog "Copying Command Line Tools to final destination..." "CommandLineTools"
    try {
        Copy-Item $cmdlineToolsSourcePath $latestPath -Recurse -Force
        Write-InfoLog "Command Line Tools copied successfully" "CommandLineTools"
    } catch {
        Write-ErrorLog "Failed to copy Command Line Tools: $($_.Exception.Message)" "CommandLineTools"
        exit 1
    }
}

# Set ANDROID_SDK_ROOT
Write-InfoLog "Setting ANDROID_SDK_ROOT environment variable" "CommandLineTools"
try {
    Set-EnvironmentVariable -Name "ANDROID_SDK_ROOT" -Value $InstallPath -Scope "User"
    Write-InfoLog "ANDROID_SDK_ROOT set to: $InstallPath" "CommandLineTools"
} catch {
    Write-ErrorLog "Failed to set ANDROID_SDK_ROOT: $($_.Exception.Message)" "CommandLineTools"
    exit 1
}

# Set ANDROID_HOME (legacy compatibility)
Write-InfoLog "Setting ANDROID_HOME environment variable" "CommandLineTools"
try {
    Set-EnvironmentVariable -Name "ANDROID_HOME" -Value $InstallPath -Scope "User"
    Write-InfoLog "ANDROID_HOME set to: $InstallPath" "CommandLineTools"
} catch {
    Write-ErrorLog "Failed to set ANDROID_HOME: $($_.Exception.Message)" "CommandLineTools"
    exit 1
}

# Add Command Line Tools to PATH
$cmdlineToolsBinPath = Join-Path $latestPath "bin"
Write-InfoLog "Adding Command Line Tools to PATH: $cmdlineToolsBinPath" "CommandLineTools"

try {
    Add-ToPath -Path $cmdlineToolsBinPath -Scope "User"
    Write-InfoLog "Command Line Tools added to PATH successfully" "CommandLineTools"
} catch {
    Write-ErrorLog "Failed to add Command Line Tools to PATH: $($_.Exception.Message)" "CommandLineTools"
    exit 1
}

# Test installation
$env:ANDROID_SDK_ROOT = $InstallPath
$env:ANDROID_HOME = $InstallPath
$env:PATH = $env:PATH + ";" + $cmdlineToolsBinPath

$sdkManagerExe = Join-Path $cmdlineToolsBinPath "sdkmanager.bat"
if (Test-Path $sdkManagerExe) {
    try {
        Write-InfoLog "Testing Command Line Tools installation..." "CommandLineTools"
        $sdkManagerVersion = & $sdkManagerExe --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InfoLog "SDK Manager version test successful" "CommandLineTools"
            Write-InfoLog "SDK Manager version: $sdkManagerVersion" "CommandLineTools"
        } else {
            Write-WarningLog "SDK Manager version test failed with exit code: $LASTEXITCODE" "CommandLineTools"
        }
    } catch {
        Write-WarningLog "Failed to test SDK Manager: $($_.Exception.Message)" "CommandLineTools"
    }
} else {
    Write-ErrorLog "SDK Manager executable not found: $sdkManagerExe" "CommandLineTools"
    exit 1
}

# Create basic SDK structure directories
Write-InfoLog "Creating basic Android SDK structure..." "CommandLineTools"
$sdkDirectories = @("platforms", "platform-tools", "build-tools", "system-images", "sources", "extras")

foreach ($dir in $sdkDirectories) {
    $dirPath = Join-Path $InstallPath $dir
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
        Write-InfoLog "Created SDK directory: $dir" "CommandLineTools"
    }
}

Write-InfoLog "Android SDK Command Line Tools installation completed successfully" "CommandLineTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Android SDK Command Line Tools installed successfully!" -ForegroundColor Green
    Write-Host "SDK Location: $InstallPath" -ForegroundColor Yellow
    Write-Host "Please restart PowerShell to apply environment changes" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "Installation completed with some errors" -ForegroundColor Yellow
    exit 1
}