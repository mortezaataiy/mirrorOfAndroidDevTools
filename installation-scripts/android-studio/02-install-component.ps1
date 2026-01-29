# 02-install-component.ps1 - Install Android Studio
param(
    [string]$DownloadPath = "..\..\downloaded",
    [string]$InstallPath = "$env:ProgramFiles\Android\Android Studio",
    [switch]$Force
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force
Import-Module "$commonPath\FileValidator.ps1" -Force
Import-Module "$commonPath\EnvironmentManager.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "AndroidStudio-Install"

Write-InfoLog "Starting Android Studio installation" "AndroidStudio"

# Configuration variables
$androidStudioFileName = "android-studio-2022.3.1.20-windows.exe"
$androidStudioFilePath = Join-Path $DownloadPath $androidStudioFileName

# Run prerequisites check
Write-InfoLog "Running prerequisites check..." "AndroidStudio"
$prerequisiteScript = Join-Path $PSScriptRoot "01-check-prerequisites.ps1"
& $prerequisiteScript -DownloadPath $DownloadPath
if ($LASTEXITCODE -ne 0) {
    Write-ErrorLog "Prerequisites check failed" "AndroidStudio"
    exit 1
}

# Check if Android Studio is already installed
if ((Test-Path $InstallPath) -and -not $Force) {
    Write-InfoLog "Android Studio appears to be already installed at: $InstallPath" "AndroidStudio"
    Write-InfoLog "Use -Force parameter to reinstall" "AndroidStudio"
    
    # Verify existing installation
    $studioExe = Join-Path $InstallPath "bin\studio64.exe"
    if (Test-Path $studioExe) {
        Write-InfoLog "Existing Android Studio installation verified" "AndroidStudio"
        Write-Host "Android Studio is already installed!" -ForegroundColor Green
        exit 0
    } else {
        Write-InfoLog "Existing installation appears incomplete, proceeding with installation" "AndroidStudio"
    }
}

# Prepare installation directory
$installDir = Split-Path $InstallPath -Parent
if (-not (Test-Path $installDir)) {
    Write-InfoLog "Creating installation directory: $installDir" "AndroidStudio"
    New-Item -ItemType Directory -Path $installDir -Force | Out-Null
}

# Create silent installation configuration
$tempDir = [System.IO.Path]::GetTempPath()
$configFile = Join-Path $tempDir "android-studio-install.config"

Write-InfoLog "Creating silent installation configuration..." "AndroidStudio"
$configContent = @"
# Android Studio Silent Installation Configuration
mode=silent
dir=$InstallPath
"@

Set-Content -Path $configFile -Value $configContent -Encoding UTF8
Write-InfoLog "Configuration file created: $configFile" "AndroidStudio"

# Execute silent installation
Write-InfoLog "Starting Android Studio silent installation..." "AndroidStudio"
Write-InfoLog "This may take several minutes, please wait..." "AndroidStudio"

try {
    $installProcess = Start-Process -FilePath $androidStudioFilePath -ArgumentList "/S", "/CONFIG=$configFile" -Wait -PassThru -NoNewWindow
    
    if ($installProcess.ExitCode -eq 0) {
        Write-InfoLog "Android Studio installation completed successfully" "AndroidStudio"
    } else {
        Write-ErrorLog "Android Studio installation failed with exit code: $($installProcess.ExitCode)" "AndroidStudio"
        exit 1
    }
} catch {
    Write-ErrorLog "Failed to execute Android Studio installer: $($_.Exception.Message)" "AndroidStudio"
    exit 1
} finally {
    # Clean up configuration file
    if (Test-Path $configFile) {
        Remove-Item $configFile -Force
        Write-InfoLog "Cleaned up configuration file" "AndroidStudio"
    }
}

# Verify installation
Write-InfoLog "Verifying Android Studio installation..." "AndroidStudio"
$studioExe = Join-Path $InstallPath "bin\studio64.exe"
if (-not (Test-Path $studioExe)) {
    Write-ErrorLog "Android Studio executable not found after installation: $studioExe" "AndroidStudio"
    exit 1
}

# Set up initial configuration
Write-InfoLog "Setting up initial Android Studio configuration..." "AndroidStudio"

# Create Android Studio settings directory
$userProfile = $env:USERPROFILE
$androidStudioConfigDir = Join-Path $userProfile ".AndroidStudio2022.3"
if (-not (Test-Path $androidStudioConfigDir)) {
    New-Item -ItemType Directory -Path $androidStudioConfigDir -Force | Out-Null
    Write-InfoLog "Created Android Studio config directory: $androidStudioConfigDir" "AndroidStudio"
}

# Create basic idea.properties for offline setup
$ideaPropertiesPath = Join-Path $androidStudioConfigDir "idea.properties"
$ideaPropertiesContent = @"
# Android Studio IDE Properties
# Disable automatic updates and online features for offline setup
ide.updates.enabled=false
ide.plugins.repository.url=
ide.plugins.host=
"@

Set-Content -Path $ideaPropertiesPath -Value $ideaPropertiesContent -Encoding UTF8
Write-InfoLog "Created basic idea.properties for offline setup" "AndroidStudio"

# Add Android Studio to PATH (optional, for command line access)
$studioBinPath = Join-Path $InstallPath "bin"
Write-InfoLog "Adding Android Studio to PATH: $studioBinPath" "AndroidStudio"

try {
    Add-ToPath -Path $studioBinPath -Scope "User"
    Write-InfoLog "Android Studio added to PATH successfully" "AndroidStudio"
} catch {
    Write-WarningLog "Failed to add Android Studio to PATH: $($_.Exception.Message)" "AndroidStudio"
    Write-InfoLog "Android Studio can still be launched from Start Menu" "AndroidStudio"
}

Write-InfoLog "Android Studio installation and configuration completed successfully" "AndroidStudio"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($logSummary.ErrorCount -eq 0) {
    Write-Host "Android Studio installed successfully!" -ForegroundColor Green
    Write-Host "You can launch Android Studio from the Start Menu or run: studio64.exe" -ForegroundColor Yellow
    Write-Host "Please restart PowerShell to apply PATH changes" -ForegroundColor Yellow
    exit 0
} else {
    Write-Host "Installation completed with some warnings" -ForegroundColor Yellow
    exit 0
}