# 02-install-component.ps1 - Install Gradle
param(
    [string]$DownloadPath = "..\..\downloaded",
    [string]$InstallPath = "$env:ProgramFiles\Gradle",
    [switch]$Force
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force
Import-Module "$commonPath\EnvironmentManager.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "Gradle-Install"

Write-InfoLog "Starting Gradle installation" "Gradle"

# Configuration variables
$gradleFileName = "gradle-8.0.2-bin.zip"
$extractedGradleFolder = "extracted_gradle-8.0.2"
$gradleFilePath = Join-Path $DownloadPath $gradleFileName
$extractedGradlePath = Join-Path $DownloadPath $extractedGradleFolder

# Run prerequisites check
Write-InfoLog "Running prerequisites check..." "Gradle"
$prerequisiteScript = Join-Path $PSScriptRoot "01-check-prerequisites.ps1"
& $prerequisiteScript -DownloadPath $DownloadPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Prerequisites check failed" "Gradle"
    exit 1
}

# Create install directory
if (-not (Test-Path $InstallPath)) {
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
    Write-InfoLog "Created install directory: $InstallPath" "Gradle"
}

# Extract Gradle if not already extracted
if (-not (Test-Path $extractedGradlePath) -or $Force) {
    Write-InfoLog "Extracting Gradle file: $gradleFilePath" "Gradle"
    
    if (Test-Path $extractedGradlePath) {
        Remove-Item $extractedGradlePath -Recurse -Force
    }
    
    # Create extraction directory
    New-Item -ItemType Directory -Path $extractedGradlePath -Force | Out-Null
    
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    
    try {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($gradleFilePath, $extractedGradlePath)
        Write-InfoLog "Gradle extracted successfully" "Gradle"
    } catch {
        Write-ErrorLog "Failed to extract Gradle: $($_.Exception.Message)" "Gradle"
        exit 1
    }
}

# Find Gradle main folder
$gradleSubFolders = Get-ChildItem $extractedGradlePath -Directory
if ($gradleSubFolders.Count -eq 0) {
    Write-ErrorLog "No directories found in extracted Gradle folder" "Gradle"
    exit 1
}

$gradleSourcePath = $gradleSubFolders[0].FullName
$gradleFolderName = $gradleSubFolders[0].Name
$gradleFinalPath = Join-Path $InstallPath $gradleFolderName

Write-InfoLog "Gradle source path: $gradleSourcePath" "Gradle"
Write-InfoLog "Gradle final path: $gradleFinalPath" "Gradle"

# Copy Gradle files
if (-not (Test-Path $gradleFinalPath) -or $Force) {
    if (Test-Path $gradleFinalPath) {
        Remove-Item $gradleFinalPath -Recurse -Force
    }
    
    Write-InfoLog "Copying Gradle files to final destination..." "Gradle"
    try {
        Copy-Item $gradleSourcePath $gradleFinalPath -Recurse -Force
        Write-InfoLog "Gradle files copied successfully" "Gradle"
    } catch {
        Write-ErrorLog "Failed to copy Gradle files: $($_.Exception.Message)" "Gradle"
        exit 1
    }
}

# Set GRADLE_HOME
Write-InfoLog "Setting GRADLE_HOME environment variable" "Gradle"
try {
    Set-EnvironmentVariable -Name "GRADLE_HOME" -Value $gradleFinalPath -Scope "User"
    Write-InfoLog "GRADLE_HOME set to: $gradleFinalPath" "Gradle"
} catch {
    Write-ErrorLog "Failed to set GRADLE_HOME: $($_.Exception.Message)" "Gradle"
    exit 1
}

# Add to PATH
$gradleBinPath = Join-Path $gradleFinalPath "bin"
Write-InfoLog "Adding Gradle to PATH: $gradleBinPath" "Gradle"

try {
    Add-ToPath -Path $gradleBinPath -Scope "User"
    Write-InfoLog "Gradle added to PATH successfully" "Gradle"
} catch {
    Write-ErrorLog "Failed to add Gradle to PATH: $($_.Exception.Message)" "Gradle"
    exit 1
}

# Test installation
$env:GRADLE_HOME = $gradleFinalPath
$env:PATH = $env:PATH + ";" + $gradleBinPath

$gradleExe = Join-Path $gradleFinalPath "bin\gradle.bat"
if (Test-Path $gradleExe) {
    try {
        Write-InfoLog "Testing Gradle installation..." "Gradle"
        $gradleVersion = & $gradleExe -v 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-InfoLog "Gradle version test successful" "Gradle"
            # Extract version line
            $versionLine = $gradleVersion | Where-Object { $_ -match "Gradle" } | Select-Object -First 1
            if ($versionLine) {
                Write-InfoLog "Gradle version: $versionLine" "Gradle"
            }
        } else {
            Write-ErrorLog "Gradle version test failed with exit code: $LASTEXITCODE" "Gradle"
        }
    } catch {
        Write-ErrorLog "Failed to test Gradle installation: $($_.Exception.Message)" "Gradle"
    }
} else {
    Write-ErrorLog "Gradle executable not found: $gradleExe" "Gradle"
    exit 1
}

Write-InfoLog "Gradle installation completed successfully" "Gradle"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Gradle installed successfully!" -ForegroundColor Green
    Write-Host "Please restart PowerShell to apply environment changes" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "Installation completed with some errors" -ForegroundColor Yellow
    exit 1
}