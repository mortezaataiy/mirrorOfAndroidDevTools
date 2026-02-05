# 02-install-component.ps1 - Install Android Build Tools
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
Initialize-Logger -ComponentName "BuildTools-Install"

Write-InfoLog "Starting Android Build Tools installation" "BuildTools"

# Configuration variables
$buildToolsFileName = "build-tools-33.0.2.zip"
$buildToolsVersion = "33.0.2"
$extractedBuildToolsFolder = "extracted_build-tools-33.0.2"
$buildToolsFilePath = Join-Path $DownloadPath $buildToolsFileName
$extractedBuildToolsPath = Join-Path $DownloadPath $extractedBuildToolsFolder

# Run prerequisites check
Write-InfoLog "Running prerequisites check..." "BuildTools"
$prerequisiteScript = Join-Path $PSScriptRoot "01-check-prerequisites.ps1"
& $prerequisiteScript -DownloadPath $DownloadPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Prerequisites check failed" "BuildTools"
    exit 1
}

# Determine Android SDK path
$androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
if (-not $androidSdkRoot) {
    Write-ErrorLog "ANDROID_SDK_ROOT environment variable not found" "BuildTools"
    exit 1
}

# Set install path if not provided
if (-not $InstallPath) {
    $buildToolsDir = Join-Path $androidSdkRoot "build-tools"
    $InstallPath = Join-Path $buildToolsDir $buildToolsVersion
}

Write-InfoLog "Build Tools will be installed to: $InstallPath" "BuildTools"

# Create build-tools directory if it doesn't exist
$buildToolsDir = Split-Path $InstallPath -Parent
if (-not (Test-Path $buildToolsDir)) {
    New-Item -ItemType Directory -Path $buildToolsDir -Force | Out-Null
    Write-InfoLog "Created build-tools directory: $buildToolsDir" "BuildTools"
}

# Extract Build Tools if not already extracted
if (-not (Test-Path $extractedBuildToolsPath) -or $Force) {
    Write-InfoLog "Extracting Build Tools file: $buildToolsFilePath" "BuildTools"
    
    if (Test-Path $extractedBuildToolsPath) {
        Remove-Item $extractedBuildToolsPath -Recurse -Force
    }
    
    # Create extraction directory
    New-Item -ItemType Directory -Path $extractedBuildToolsPath -Force | Out-Null
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($buildToolsFilePath, $extractedBuildToolsPath)
        Write-InfoLog "Build Tools extracted successfully" "BuildTools"
    } catch {
        Write-ErrorLog "Failed to extract Build Tools: $($_.Exception.Message)" "BuildTools"
        exit 1
    }
}

# Find Build Tools main folder
$buildToolsSubFolders = Get-ChildItem $extractedBuildToolsPath -Directory
if ($buildToolsSubFolders.Count -eq 0) {
    Write-ErrorLog "No directories found in extracted Build Tools folder" "BuildTools"
    exit 1
}

$buildToolsSourcePath = $buildToolsSubFolders[0].FullName
Write-InfoLog "Build Tools source path: $buildToolsSourcePath" "BuildTools"

# Copy Build Tools files
if (-not (Test-Path $InstallPath) -or $Force) {
    if (Test-Path $InstallPath) {
        Remove-Item $InstallPath -Recurse -Force
    }
    
    Write-InfoLog "Copying Build Tools to final destination..." "BuildTools"
    try {
        Copy-Item $buildToolsSourcePath $InstallPath -Recurse -Force
        Write-InfoLog "Build Tools copied successfully" "BuildTools"
    } catch {
        Write-ErrorLog "Failed to copy Build Tools: $($_.Exception.Message)" "BuildTools"
        exit 1
    }
}

# Test installation by checking key executables
$keyExecutables = @("aapt.exe", "dx.bat", "zipalign.exe", "apksigner.bat")
$missingExecutables = @()

foreach ($exe in $keyExecutables) {
    $exePath = Join-Path $InstallPath $exe
    if (-not (Test-Path $exePath)) {
        $missingExecutables += $exe
    }
}

if ($missingExecutables.Count -gt 0) {
    Write-ErrorLog "Missing key executables: $($missingExecutables -join ', ')" "BuildTools"
    exit 1
}

# Test AAPT
$aaptExe = Join-Path $InstallPath "aapt.exe"
if (Test-Path $aaptExe) {
    try {
        Write-InfoLog "Testing AAPT installation..." "BuildTools"
        $aaptVersion = & $aaptExe version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InfoLog "AAPT version test successful" "BuildTools"
            $versionLine = $aaptVersion | Where-Object { $_ -match "Android Asset Packaging Tool" } | Select-Object -First 1
            if ($versionLine) {
                Write-InfoLog "AAPT version: $versionLine" "BuildTools"
            }
        } else {
            Write-WarningLog "AAPT version test failed with exit code: $LASTEXITCODE" "BuildTools"
        }
    } catch {
        Write-WarningLog "Failed to test AAPT: $($_.Exception.Message)" "BuildTools"
    }
}

# Test DX (if available)
$dxBat = Join-Path $InstallPath "dx.bat"
if (Test-Path $dxBat) {
    try {
        Write-InfoLog "Testing DX installation..." "BuildTools"
        $dxVersion = & $dxBat --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InfoLog "DX version test successful" "BuildTools"
            $versionLine = $dxVersion | Where-Object { $_ -match "dx" } | Select-Object -First 1
            if ($versionLine) {
                Write-InfoLog "DX version: $versionLine" "BuildTools"
            }
        } else {
            Write-WarningLog "DX version test failed with exit code: $LASTEXITCODE" "BuildTools"
        }
    } catch {
        Write-WarningLog "Failed to test DX: $($_.Exception.Message)" "BuildTools"
    }
}

Write-InfoLog "Android Build Tools installation completed successfully" "BuildTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Android Build Tools installed successfully!" -ForegroundColor Green
    Write-Host "Build Tools version $buildToolsVersion are now available" -ForegroundColor Yellow
    Write-Host "Location: $InstallPath" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "Installation completed with some errors" -ForegroundColor Yellow
    exit 1
}