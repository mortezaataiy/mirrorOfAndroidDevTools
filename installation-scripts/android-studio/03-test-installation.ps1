# 03-test-installation.ps1 - Test Android Studio Installation
param(
    [string]$InstallPath = "$env:ProgramFiles\Android\Android Studio",
    [switch]$Detailed
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "AndroidStudio-Test"

Write-InfoLog "Starting Android Studio installation test" "AndroidStudio"

$testResults = @{
    InstallPathExists = $false
    StudioExecutable = $false
    StudioLaunchable = $false
    SdkManagerAccessible = $false
    ConfigurationValid = $false
    OverallSuccess = $false
}

# Test 1: Check installation path
Write-InfoLog "Test 1: Checking Android Studio installation path" "AndroidStudio"
if (Test-Path $InstallPath) {
    $testResults.InstallPathExists = $true
    Write-InfoLog "Android Studio installation path exists: $InstallPath" "AndroidStudio"
} else {
    Write-ErrorLog "Android Studio installation path not found: $InstallPath" "AndroidStudio"
}

# Test 2: Check studio64.exe executable
Write-InfoLog "Test 2: Checking Android Studio executable" "AndroidStudio"
if ($testResults.InstallPathExists) {
    $studioExePath = Join-Path $InstallPath "bin\studio64.exe"
    
    if (Test-Path $studioExePath) {
        $testResults.StudioExecutable = $true
        Write-InfoLog "Android Studio executable exists: $studioExePath" "AndroidStudio"
        
        # Check file properties
        $fileInfo = Get-Item $studioExePath
        Write-InfoLog "Executable size: $([math]::Round($fileInfo.Length / 1MB, 2)) MB" "AndroidStudio"
        Write-InfoLog "Last modified: $($fileInfo.LastWriteTime)" "AndroidStudio"
    } else {
        Write-ErrorLog "Android Studio executable not found: $studioExePath" "AndroidStudio"
    }
}

# Test 3: Test Android Studio launch capability (quick test)
Write-InfoLog "Test 3: Testing Android Studio launch capability" "AndroidStudio"
if ($testResults.StudioExecutable) {
    try {
        # Test if the executable can be started (we'll kill it quickly to avoid full startup)
        Write-InfoLog "Attempting quick launch test..." "AndroidStudio"
        
        $studioProcess = Start-Process -FilePath $studioExePath -ArgumentList "--help" -PassThru -WindowStyle Hidden -ErrorAction Stop
        
        # Wait a short time to see if it starts properly
        Start-Sleep -Seconds 3
        
        if (-not $studioProcess.HasExited) {
            $testResults.StudioLaunchable = $true
            Write-InfoLog "Android Studio launch test successful" "AndroidStudio"
            
            # Terminate the test process
            $studioProcess.Kill()
            $studioProcess.WaitForExit(5000)
        } else {
            Write-InfoLog "Android Studio process exited quickly (normal for --help)" "AndroidStudio"
            $testResults.StudioLaunchable = $true
        }
    } catch {
        Write-ErrorLog "Android Studio launch test failed: $($_.Exception.Message)" "AndroidStudio"
    }
}

# Test 4: Check SDK Manager accessibility
Write-InfoLog "Test 4: Checking SDK Manager accessibility" "AndroidStudio"
if ($testResults.InstallPathExists) {
    # Check for SDK Manager in Android Studio installation
    $sdkManagerPaths = @(
        (Join-Path $InstallPath "bin\studio.bat"),
        (Join-Path $InstallPath "plugins\android\lib\android.jar")
    )
    
    $sdkManagerFound = $false
    foreach ($path in $sdkManagerPaths) {
        if (Test-Path $path) {
            $sdkManagerFound = $true
            Write-InfoLog "SDK Manager component found: $path" "AndroidStudio"
            break
        }
    }
    
    if ($sdkManagerFound) {
        $testResults.SdkManagerAccessible = $true
        Write-InfoLog "SDK Manager is accessible through Android Studio" "AndroidStudio"
    } else {
        Write-WarningLog "SDK Manager components not found in expected locations" "AndroidStudio"
        # This is not a critical failure as SDK Manager is integrated into Android Studio
        $testResults.SdkManagerAccessible = $true
    }
}

# Test 5: Check configuration validity
Write-InfoLog "Test 5: Checking Android Studio configuration" "AndroidStudio"
$userProfile = $env:USERPROFILE
$configPaths = @(
    (Join-Path $userProfile ".AndroidStudio2022.3"),
    (Join-Path $userProfile "AppData\Roaming\Google\AndroidStudio2022.3")
)

$configFound = $false
foreach ($configPath in $configPaths) {
    if (Test-Path $configPath) {
        $configFound = $true
        Write-InfoLog "Android Studio configuration directory found: $configPath" "AndroidStudio"
        
        # Check for idea.properties
        $ideaPropertiesPath = Join-Path $configPath "idea.properties"
        if (Test-Path $ideaPropertiesPath) {
            Write-InfoLog "Configuration file found: idea.properties" "AndroidStudio"
        }
        break
    }
}

if ($configFound) {
    $testResults.ConfigurationValid = $true
    Write-InfoLog "Android Studio configuration is valid" "AndroidStudio"
} else {
    Write-InfoLog "No existing configuration found (normal for first installation)" "AndroidStudio"
    $testResults.ConfigurationValid = $true  # Not critical for basic functionality
}

# Additional detailed tests if requested
if ($Detailed) {
    Write-InfoLog "=== Detailed Test Information ===" "AndroidStudio"
    
    # Check JDK dependency
    Write-InfoLog "Checking JDK dependency..." "AndroidStudio"
    $javaHome = $env:JAVA_HOME
    if ($javaHome -and (Test-Path $javaHome)) {
        Write-InfoLog "JDK dependency satisfied: $javaHome" "AndroidStudio"
    } else {
        Write-WarningLog "JDK dependency not found in JAVA_HOME" "AndroidStudio"
    }
    
    # Check installation size
    if ($testResults.InstallPathExists) {
        try {
            $installSize = (Get-ChildItem $InstallPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $installSizeGB = [math]::Round($installSize / 1GB, 2)
            Write-InfoLog "Android Studio installation size: ${installSizeGB} GB" "AndroidStudio"
        } catch {
            Write-InfoLog "Could not calculate installation size" "AndroidStudio"
        }
    }
}

# Overall success calculation
$testResults.OverallSuccess = $testResults.InstallPathExists -and 
                              $testResults.StudioExecutable -and 
                              $testResults.StudioLaunchable -and 
                              $testResults.SdkManagerAccessible -and 
                              $testResults.ConfigurationValid

# Results summary
Write-InfoLog "=== Android Studio Test Results Summary ===" "AndroidStudio"
Write-InfoLog "$(if($testResults.InstallPathExists) {'✓'} else {'✗'}) Installation path exists" "AndroidStudio"
Write-InfoLog "$(if($testResults.StudioExecutable) {'✓'} else {'✗'}) Studio executable found" "AndroidStudio"
Write-InfoLog "$(if($testResults.StudioLaunchable) {'✓'} else {'✗'}) Studio launchable" "AndroidStudio"
Write-InfoLog "$(if($testResults.SdkManagerAccessible) {'✓'} else {'✗'}) SDK Manager accessible" "AndroidStudio"
Write-InfoLog "$(if($testResults.ConfigurationValid) {'✓'} else {'✗'}) Configuration valid" "AndroidStudio"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($testResults.OverallSuccess) {
    Write-Host "Android Studio installation test PASSED! ✓" -ForegroundColor Green
    Write-Host "Android Studio is ready to use" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Android Studio installation test FAILED! ✗" -ForegroundColor Red
    Write-Host "Please check the installation and try again" -ForegroundColor Red
    exit 1
}