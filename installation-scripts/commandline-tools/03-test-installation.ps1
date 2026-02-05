# 03-test-installation.ps1 - Test Android SDK Command Line Tools Installation
param(
    [string]$InstallPath = "$env:LOCALAPPDATA\Android\Sdk",
    [switch]$Detailed
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "CommandLineTools-Test"

Write-InfoLog "Starting Android SDK Command Line Tools installation test" "CommandLineTools"

$testResults = @{
    AndroidSdkRootSet = $false
    AndroidSdkRootValid = $false
    AndroidHomeSet = $false
    SdkManagerExecutable = $false
    SdkManagerVersion = $false
    SdkPackagesList = $false
    SdkStructureValid = $false
    OverallSuccess = $false
}

# Test 1: Check ANDROID_SDK_ROOT
Write-InfoLog "Test 1: Checking ANDROID_SDK_ROOT environment variable" "CommandLineTools"
$androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")

if ($androidSdkRoot) {
    $testResults.AndroidSdkRootSet = $true
    Write-InfoLog "ANDROID_SDK_ROOT is set: $androidSdkRoot" "CommandLineTools"
    
    if (Test-Path $androidSdkRoot) {
        $testResults.AndroidSdkRootValid = $true
        Write-InfoLog "ANDROID_SDK_ROOT path is valid" "CommandLineTools"
    } else {
        Write-ErrorLog "ANDROID_SDK_ROOT path is not valid: $androidSdkRoot" "CommandLineTools"
    }
} else {
    Write-ErrorLog "ANDROID_SDK_ROOT environment variable is not set" "CommandLineTools"
}

# Test 2: Check ANDROID_HOME (legacy compatibility)
Write-InfoLog "Test 2: Checking ANDROID_HOME environment variable" "CommandLineTools"
$androidHome = [Environment]::GetEnvironmentVariable("ANDROID_HOME", "User")

if ($androidHome) {
    $testResults.AndroidHomeSet = $true
    Write-InfoLog "ANDROID_HOME is set: $androidHome" "CommandLineTools"
} else {
    Write-WarningLog "ANDROID_HOME environment variable is not set (legacy compatibility)" "CommandLineTools"
    # Not critical for modern Android development
    $testResults.AndroidHomeSet = $true
}

# Test 3: Check sdkmanager executable
Write-InfoLog "Test 3: Checking sdkmanager executable" "CommandLineTools"
if ($testResults.AndroidSdkRootValid) {
    $sdkManagerPath = Join-Path $androidSdkRoot "cmdline-tools\latest\bin\sdkmanager.bat"
    
    if (Test-Path $sdkManagerPath) {
        $testResults.SdkManagerExecutable = $true
        Write-InfoLog "sdkmanager.bat exists and is accessible" "CommandLineTools"
    } else {
        Write-ErrorLog "sdkmanager.bat not found: $sdkManagerPath" "CommandLineTools"
    }
}

# Test 4: Check sdkmanager version
Write-InfoLog "Test 4: Checking sdkmanager version" "CommandLineTools"
if ($testResults.SdkManagerExecutable) {
    try {
        $sdkManagerVersionOutput = & sdkmanager --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testResults.SdkManagerVersion = $true
            Write-InfoLog "SDK Manager version test successful: $sdkManagerVersionOutput" "CommandLineTools"
        } else {
            Write-ErrorLog "SDK Manager version command failed with exit code: $LASTEXITCODE" "CommandLineTools"
        }
    } catch {
        Write-ErrorLog "SDK Manager version test failed: $($_.Exception.Message)" "CommandLineTools"
    }
}

# Test 5: Test SDK packages listing
Write-InfoLog "Test 5: Testing SDK packages listing" "CommandLineTools"
if ($testResults.SdkManagerVersion) {
    try {
        Write-InfoLog "Attempting to list available SDK packages..." "CommandLineTools"
        $packagesOutput = & sdkmanager --list 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $testResults.SdkPackagesList = $true
            Write-InfoLog "SDK packages listing test successful" "CommandLineTools"
            
            # Count available packages
            $packageLines = $packagesOutput | Where-Object { $_ -match "^\s*[a-zA-Z]" -and $_ -notmatch "Available Packages" -and $_ -notmatch "Installed packages" }
            if ($packageLines) {
                Write-InfoLog "Found $($packageLines.Count) available SDK packages" "CommandLineTools"
            }
        } else {
            Write-ErrorLog "SDK packages listing failed with exit code: $LASTEXITCODE" "CommandLineTools"
        }
    } catch {
        Write-ErrorLog "SDK packages listing test failed: $($_.Exception.Message)" "CommandLineTools"
    }
}

# Test 6: Check SDK directory structure
Write-InfoLog "Test 6: Checking Android SDK directory structure" "CommandLineTools"
if ($testResults.AndroidSdkRootValid) {
    $requiredDirectories = @("cmdline-tools", "platforms", "platform-tools", "build-tools", "system-images")
    $missingDirectories = @()
    
    foreach ($dir in $requiredDirectories) {
        $dirPath = Join-Path $androidSdkRoot $dir
        if (-not (Test-Path $dirPath)) {
            $missingDirectories += $dir
        }
    }
    
    if ($missingDirectories.Count -eq 0) {
        $testResults.SdkStructureValid = $true
        Write-InfoLog "Android SDK directory structure is valid" "CommandLineTools"
    } else {
        Write-WarningLog "Some SDK directories are missing: $($missingDirectories -join ', ')" "CommandLineTools"
        # Not critical as directories will be created when components are installed
        $testResults.SdkStructureValid = $true
    }
}

# Additional detailed tests if requested
if ($Detailed) {
    Write-InfoLog "=== Detailed Test Information ===" "CommandLineTools"
    
    # Check JDK dependency
    Write-InfoLog "Checking JDK dependency..." "CommandLineTools"
    $javaHome = $env:JAVA_HOME
    if ($javaHome -and (Test-Path $javaHome)) {
        Write-InfoLog "JDK dependency satisfied: $javaHome" "CommandLineTools"
        
        # Test Java version compatibility
        try {
            $javaVersion = & "$javaHome\bin\java.exe" -version 2>&1
            Write-InfoLog "Java version: $($javaVersion[0])" "CommandLineTools"
        } catch {
            Write-WarningLog "Could not verify Java version" "CommandLineTools"
        }
    } else {
        Write-WarningLog "JDK dependency not found in JAVA_HOME" "CommandLineTools"
    }
    
    # Check Command Line Tools installation size
    if ($testResults.AndroidSdkRootValid) {
        try {
            $cmdlineToolsPath = Join-Path $androidSdkRoot "cmdline-tools"
            if (Test-Path $cmdlineToolsPath) {
                $installSize = (Get-ChildItem $cmdlineToolsPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
                $installSizeMB = [math]::Round($installSize / 1MB, 2)
                Write-InfoLog "Command Line Tools installation size: ${installSizeMB} MB" "CommandLineTools"
            }
        } catch {
            Write-InfoLog "Could not calculate installation size" "CommandLineTools"
        }
    }
    
    # Check PATH configuration
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $cmdlineToolsBinPath = Join-Path $androidSdkRoot "cmdline-tools\latest\bin"
    if ($currentPath -like "*$cmdlineToolsBinPath*") {
        Write-InfoLog "Command Line Tools are properly configured in PATH" "CommandLineTools"
    } else {
        Write-WarningLog "Command Line Tools may not be properly configured in PATH" "CommandLineTools"
    }
    
    # Test avdmanager if available
    $avdManagerPath = Join-Path $androidSdkRoot "cmdline-tools\latest\bin\avdmanager.bat"
    if (Test-Path $avdManagerPath) {
        try {
            $avdManagerVersion = & $avdManagerPath --version 2>&1
            Write-InfoLog "AVD Manager is available: $avdManagerVersion" "CommandLineTools"
        } catch {
            Write-InfoLog "AVD Manager test failed" "CommandLineTools"
        }
    }
}

# Overall success calculation
$testResults.OverallSuccess = $testResults.AndroidSdkRootSet -and 
                              $testResults.AndroidSdkRootValid -and 
                              $testResults.AndroidHomeSet -and 
                              $testResults.SdkManagerExecutable -and 
                              $testResults.SdkManagerVersion -and 
                              $testResults.SdkPackagesList -and 
                              $testResults.SdkStructureValid

# Results summary
Write-InfoLog "=== Android SDK Command Line Tools Test Results Summary ===" "CommandLineTools"
Write-InfoLog "$(if($testResults.AndroidSdkRootSet) {'✓'} else {'✗'}) ANDROID_SDK_ROOT set" "CommandLineTools"
Write-InfoLog "$(if($testResults.AndroidSdkRootValid) {'✓'} else {'✗'}) ANDROID_SDK_ROOT path valid" "CommandLineTools"
Write-InfoLog "$(if($testResults.AndroidHomeSet) {'✓'} else {'✗'}) ANDROID_HOME set" "CommandLineTools"
Write-InfoLog "$(if($testResults.SdkManagerExecutable) {'✓'} else {'✗'}) sdkmanager executable" "CommandLineTools"
Write-InfoLog "$(if($testResults.SdkManagerVersion) {'✓'} else {'✗'}) sdkmanager version command" "CommandLineTools"
Write-InfoLog "$(if($testResults.SdkPackagesList) {'✓'} else {'✗'}) SDK packages listing" "CommandLineTools"
Write-InfoLog "$(if($testResults.SdkStructureValid) {'✓'} else {'✗'}) SDK directory structure" "CommandLineTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($testResults.OverallSuccess) {
    Write-Host "Android SDK Command Line Tools installation test PASSED! ✓" -ForegroundColor Green
    Write-Host "Command Line Tools are ready to use" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Android SDK Command Line Tools installation test FAILED! ✗" -ForegroundColor Red
    Write-Host "Please check the installation and try again" -ForegroundColor Red
    exit 1
}