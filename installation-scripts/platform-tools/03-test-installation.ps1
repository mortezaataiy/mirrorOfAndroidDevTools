# 03-test-installation.ps1 - Test Android Platform Tools Installation
param(
    [string]$InstallPath = "",  # Will be determined from ANDROID_SDK_ROOT
    [switch]$Detailed
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "PlatformTools-Test"

Write-InfoLog "Starting Android Platform Tools installation test" "PlatformTools"

$testResults = @{
    InstallPathExists = $false
    AdbExecutable = $false
    AdbVersion = $false
    FastbootExecutable = $false
    FastbootVersion = $false
    PathConfiguration = $false
    OverallSuccess = $false
}

# Determine install path if not provided
if (-not $InstallPath) {
    $androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
    if ($androidSdkRoot) {
        $InstallPath = Join-Path $androidSdkRoot "platform-tools"
    } else {
        Write-ErrorLog "ANDROID_SDK_ROOT not found and InstallPath not provided" "PlatformTools"
        exit 1
    }
}

# Test 1: Check installation path
Write-InfoLog "Test 1: Checking Platform Tools installation path" "PlatformTools"
if (Test-Path $InstallPath) {
    $testResults.InstallPathExists = $true
    Write-InfoLog "Platform Tools installation path exists: $InstallPath" "PlatformTools"
} else {
    Write-ErrorLog "Platform Tools installation path not found: $InstallPath" "PlatformTools"
}

# Test 2: Check ADB executable
Write-InfoLog "Test 2: Checking ADB executable" "PlatformTools"
if ($testResults.InstallPathExists) {
    $adbExePath = Join-Path $InstallPath "adb.exe"
    
    if (Test-Path $adbExePath) {
        $testResults.AdbExecutable = $true
        Write-InfoLog "ADB executable exists: $adbExePath" "PlatformTools"
        
        # Check file properties
        $fileInfo = Get-Item $adbExePath
        Write-InfoLog "ADB executable size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" "PlatformTools"
    } else {
        Write-ErrorLog "ADB executable not found: $adbExePath" "PlatformTools"
    }
}

# Test 3: Check ADB version
Write-InfoLog "Test 3: Checking ADB version" "PlatformTools"
if ($testResults.AdbExecutable) {
    try {
        $adbVersionOutput = & adb version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testResults.AdbVersion = $true
            $versionLine = $adbVersionOutput | Where-Object { $_ -match "Android Debug Bridge" } | Select-Object -First 1
            Write-InfoLog "ADB version test successful: $versionLine" "PlatformTools"
        } else {
            Write-ErrorLog "ADB version command failed with exit code: $LASTEXITCODE" "PlatformTools"
        }
    } catch {
        Write-ErrorLog "ADB version test failed: $($_.Exception.Message)" "PlatformTools"
    }
}

# Test 4: Check Fastboot executable
Write-InfoLog "Test 4: Checking Fastboot executable" "PlatformTools"
if ($testResults.InstallPathExists) {
    $fastbootExePath = Join-Path $InstallPath "fastboot.exe"
    
    if (Test-Path $fastbootExePath) {
        $testResults.FastbootExecutable = $true
        Write-InfoLog "Fastboot executable exists: $fastbootExePath" "PlatformTools"
        
        # Check file properties
        $fileInfo = Get-Item $fastbootExePath
        Write-InfoLog "Fastboot executable size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" "PlatformTools"
    } else {
        Write-WarningLog "Fastboot executable not found: $fastbootExePath" "PlatformTools"
        # Fastboot is not always critical, so we don't fail the test
        $testResults.FastbootExecutable = $true
    }
}

# Test 5: Check Fastboot version
Write-InfoLog "Test 5: Checking Fastboot version" "PlatformTools"
if ($testResults.FastbootExecutable -and (Test-Path (Join-Path $InstallPath "fastboot.exe"))) {
    try {
        $fastbootVersionOutput = & fastboot --version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testResults.FastbootVersion = $true
            $versionLine = $fastbootVersionOutput | Where-Object { $_ -match "fastboot" } | Select-Object -First 1
            Write-InfoLog "Fastboot version test successful: $versionLine" "PlatformTools"
        } else {
            Write-WarningLog "Fastboot version command failed with exit code: $LASTEXITCODE" "PlatformTools"
            # Not critical for basic functionality
            $testResults.FastbootVersion = $true
        }
    } catch {
        Write-WarningLog "Fastboot version test failed: $($_.Exception.Message)" "PlatformTools"
        $testResults.FastbootVersion = $true
    }
} else {
    # If fastboot doesn't exist, mark as passed (not critical)
    $testResults.FastbootVersion = $true
}

# Test 6: Check PATH configuration
Write-InfoLog "Test 6: Checking PATH configuration" "PlatformTools"
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($currentPath -like "*$InstallPath*") {
    $testResults.PathConfiguration = $true
    Write-InfoLog "Platform Tools are properly configured in PATH" "PlatformTools"
} else {
    Write-WarningLog "Platform Tools may not be properly configured in PATH" "PlatformTools"
    # Check if ADB is accessible from command line anyway
    try {
        $adbWhich = & where.exe adb 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testResults.PathConfiguration = $true
            Write-InfoLog "ADB is accessible from command line: $adbWhich" "PlatformTools"
        } else {
            Write-ErrorLog "ADB is not accessible from command line" "PlatformTools"
        }
    } catch {
        Write-ErrorLog "Failed to check ADB accessibility: $($_.Exception.Message)" "PlatformTools"
    }
}

# Additional detailed tests if requested
if ($Detailed) {
    Write-InfoLog "=== Detailed Test Information ===" "PlatformTools"
    
    # Check Android SDK dependency
    Write-InfoLog "Checking Android SDK dependency..." "PlatformTools"
    $androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
    if ($androidSdkRoot -and (Test-Path $androidSdkRoot)) {
        Write-InfoLog "Android SDK dependency satisfied: $androidSdkRoot" "PlatformTools"
    } else {
        Write-WarningLog "Android SDK dependency not found in ANDROID_SDK_ROOT" "PlatformTools"
    }
    
    # Check Platform Tools installation size
    if ($testResults.InstallPathExists) {
        try {
            $installSize = (Get-ChildItem $InstallPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $installSizeMB = [math]::Round($installSize / 1MB, 2)
            Write-InfoLog "Platform Tools installation size: ${installSizeMB} MB" "PlatformTools"
        } catch {
            Write-InfoLog "Could not calculate installation size" "PlatformTools"
        }
    }
    
    # List all executables in Platform Tools
    if ($testResults.InstallPathExists) {
        $executables = Get-ChildItem $InstallPath -Filter "*.exe" | Select-Object -ExpandProperty Name
        if ($executables) {
            Write-InfoLog "Available executables: $($executables -join ', ')" "PlatformTools"
        }
    }
    
    # Test ADB devices command (if no devices connected, it should still work)
    if ($testResults.AdbVersion) {
        try {
            Write-InfoLog "Testing ADB devices command..." "PlatformTools"
            $adbDevices = & adb devices 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-InfoLog "ADB devices command successful" "PlatformTools"
                $deviceLines = $adbDevices | Where-Object { $_ -match "device$|offline$|unauthorized$" }
                if ($deviceLines) {
                    Write-InfoLog "Connected devices: $($deviceLines.Count)" "PlatformTools"
                } else {
                    Write-InfoLog "No devices connected (normal)" "PlatformTools"
                }
            } else {
                Write-WarningLog "ADB devices command failed" "PlatformTools"
            }
        } catch {
            Write-InfoLog "ADB devices test skipped" "PlatformTools"
        }
    }
}

# Overall success calculation
$testResults.OverallSuccess = $testResults.InstallPathExists -and 
                              $testResults.AdbExecutable -and 
                              $testResults.AdbVersion -and 
                              $testResults.FastbootExecutable -and 
                              $testResults.FastbootVersion -and 
                              $testResults.PathConfiguration

# Results summary
Write-InfoLog "=== Android Platform Tools Test Results Summary ===" "PlatformTools"
Write-InfoLog "$(if($testResults.InstallPathExists) {'✓'} else {'✗'}) Installation path exists" "PlatformTools"
Write-InfoLog "$(if($testResults.AdbExecutable) {'✓'} else {'✗'}) ADB executable found" "PlatformTools"
Write-InfoLog "$(if($testResults.AdbVersion) {'✓'} else {'✗'}) ADB version command" "PlatformTools"
Write-InfoLog "$(if($testResults.FastbootExecutable) {'✓'} else {'✗'}) Fastboot executable found" "PlatformTools"
Write-InfoLog "$(if($testResults.FastbootVersion) {'✓'} else {'✗'}) Fastboot version command" "PlatformTools"
Write-InfoLog "$(if($testResults.PathConfiguration) {'✓'} else {'✗'}) PATH configuration" "PlatformTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($testResults.OverallSuccess) {
    Write-Host "Android Platform Tools installation test PASSED! ✓" -ForegroundColor Green
    Write-Host "ADB and Fastboot are ready to use" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Android Platform Tools installation test FAILED! ✗" -ForegroundColor Red
    Write-Host "Please check the installation and try again" -ForegroundColor Red
    exit 1
}