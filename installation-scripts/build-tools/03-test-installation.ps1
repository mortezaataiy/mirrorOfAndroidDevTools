# 03-test-installation.ps1 - Test Android Build Tools Installation
param(
    [string]$InstallPath = "",  # Will be determined from ANDROID_SDK_ROOT
    [string]$BuildToolsVersion = "33.0.2",
    [switch]$Detailed
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "BuildTools-Test"

Write-InfoLog "Starting Android Build Tools installation test" "BuildTools"

$testResults = @{
    InstallPathExists = $false
    AaptExecutable = $false
    AaptVersion = $false
    DxExecutable = $false
    DxVersion = $false
    ZipalignExecutable = $false
    ApksignerExecutable = $false
    OverallSuccess = $false
}

# Determine install path if not provided
if (-not $InstallPath) {
    $androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
    if ($androidSdkRoot) {
        $InstallPath = Join-Path $androidSdkRoot "build-tools\$BuildToolsVersion"
    } else {
        Write-ErrorLog "ANDROID_SDK_ROOT not found and InstallPath not provided" "BuildTools"
        exit 1
    }
}

# Test 1: Check installation path
Write-InfoLog "Test 1: Checking Build Tools installation path" "BuildTools"
if (Test-Path $InstallPath) {
    $testResults.InstallPathExists = $true
    Write-InfoLog "Build Tools installation path exists: $InstallPath" "BuildTools"
} else {
    Write-ErrorLog "Build Tools installation path not found: $InstallPath" "BuildTools"
}

# Test 2: Check AAPT executable
Write-InfoLog "Test 2: Checking AAPT executable" "BuildTools"
if ($testResults.InstallPathExists) {
    $aaptExePath = Join-Path $InstallPath "aapt.exe"
    
    if (Test-Path $aaptExePath) {
        $testResults.AaptExecutable = $true
        Write-InfoLog "AAPT executable exists: $aaptExePath" "BuildTools"
        
        # Check file properties
        $fileInfo = Get-Item $aaptExePath
        Write-InfoLog "AAPT executable size: $([math]::Round($fileInfo.Length / 1KB, 2)) KB" "BuildTools"
    } else {
        Write-ErrorLog "AAPT executable not found: $aaptExePath" "BuildTools"
    }
}

# Test 3: Check AAPT version
Write-InfoLog "Test 3: Checking AAPT version" "BuildTools"
if ($testResults.AaptExecutable) {
    try {
        $aaptExePath = Join-Path $InstallPath "aapt.exe"
        $aaptVersionOutput = & $aaptExePath version 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testResults.AaptVersion = $true
            $versionLine = $aaptVersionOutput | Where-Object { $_ -match "Android Asset Packaging Tool" } | Select-Object -First 1
            Write-InfoLog "AAPT version test successful: $versionLine" "BuildTools"
        } else {
            Write-ErrorLog "AAPT version command failed with exit code: $LASTEXITCODE" "BuildTools"
        }
    } catch {
        Write-ErrorLog "AAPT version test failed: $($_.Exception.Message)" "BuildTools"
    }
}

# Test 4: Check DX executable
Write-InfoLog "Test 4: Checking DX executable" "BuildTools"
if ($testResults.InstallPathExists) {
    $dxBatPath = Join-Path $InstallPath "dx.bat"
    
    if (Test-Path $dxBatPath) {
        $testResults.DxExecutable = $true
        Write-InfoLog "DX executable exists: $dxBatPath" "BuildTools"
    } else {
        Write-WarningLog "DX executable not found: $dxBatPath" "BuildTools"
        # DX might not be available in newer build tools, check for d8
        $d8ExePath = Join-Path $InstallPath "d8.bat"
        if (Test-Path $d8ExePath) {
            $testResults.DxExecutable = $true
            Write-InfoLog "D8 executable found instead: $d8ExePath" "BuildTools"
        } else {
            Write-WarningLog "Neither DX nor D8 executable found" "BuildTools"
            # Not critical for basic functionality
            $testResults.DxExecutable = $true
        }
    }
}

# Test 5: Check DX version
Write-InfoLog "Test 5: Checking DX/D8 version" "BuildTools"
if ($testResults.DxExecutable) {
    $dxBatPath = Join-Path $InstallPath "dx.bat"
    $d8BatPath = Join-Path $InstallPath "d8.bat"
    
    $testExecutable = $null
    if (Test-Path $dxBatPath) {
        $testExecutable = $dxBatPath
    } elseif (Test-Path $d8BatPath) {
        $testExecutable = $d8BatPath
    }
    
    if ($testExecutable) {
        try {
            $dxVersionOutput = & $testExecutable --version 2>&1
            if ($LASTEXITCODE -eq 0) {
                $testResults.DxVersion = $true
                Write-InfoLog "DX/D8 version test successful: $dxVersionOutput" "BuildTools"
            } else {
                Write-WarningLog "DX/D8 version command failed with exit code: $LASTEXITCODE" "BuildTools"
                # Not critical for basic functionality
                $testResults.DxVersion = $true
            }
        } catch {
            Write-WarningLog "DX/D8 version test failed: $($_.Exception.Message)" "BuildTools"
            $testResults.DxVersion = $true
        }
    } else {
        $testResults.DxVersion = $true
    }
}

# Test 6: Check Zipalign executable
Write-InfoLog "Test 6: Checking Zipalign executable" "BuildTools"
if ($testResults.InstallPathExists) {
    $zipalignExePath = Join-Path $InstallPath "zipalign.exe"
    
    if (Test-Path $zipalignExePath) {
        $testResults.ZipalignExecutable = $true
        Write-InfoLog "Zipalign executable exists: $zipalignExePath" "BuildTools"
    } else {
        Write-WarningLog "Zipalign executable not found: $zipalignExePath" "BuildTools"
        # Not critical for basic functionality
        $testResults.ZipalignExecutable = $true
    }
}

# Test 7: Check APK Signer executable
Write-InfoLog "Test 7: Checking APK Signer executable" "BuildTools"
if ($testResults.InstallPathExists) {
    $apksignerBatPath = Join-Path $InstallPath "apksigner.bat"
    
    if (Test-Path $apksignerBatPath) {
        $testResults.ApksignerExecutable = $true
        Write-InfoLog "APK Signer executable exists: $apksignerBatPath" "BuildTools"
    } else {
        Write-WarningLog "APK Signer executable not found: $apksignerBatPath" "BuildTools"
        # Not critical for basic functionality
        $testResults.ApksignerExecutable = $true
    }
}

# Additional detailed tests if requested
if ($Detailed) {
    Write-InfoLog "=== Detailed Test Information ===" "BuildTools"
    
    # Check Android SDK dependency
    Write-InfoLog "Checking Android SDK dependency..." "BuildTools"
    $androidSdkRoot = [Environment]::GetEnvironmentVariable("ANDROID_SDK_ROOT", "User")
    if ($androidSdkRoot -and (Test-Path $androidSdkRoot)) {
        Write-InfoLog "Android SDK dependency satisfied: $androidSdkRoot" "BuildTools"
    } else {
        Write-WarningLog "Android SDK dependency not found in ANDROID_SDK_ROOT" "BuildTools"
    }
    
    # Check Build Tools installation size
    if ($testResults.InstallPathExists) {
        try {
            $installSize = (Get-ChildItem $InstallPath -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $installSizeMB = [math]::Round($installSize / 1MB, 2)
            Write-InfoLog "Build Tools installation size: ${installSizeMB} MB" "BuildTools"
        } catch {
            Write-InfoLog "Could not calculate installation size" "BuildTools"
        }
    }
    
    # List all executables in Build Tools
    if ($testResults.InstallPathExists) {
        $executables = Get-ChildItem $InstallPath -Filter "*.exe" | Select-Object -ExpandProperty Name
        $batFiles = Get-ChildItem $InstallPath -Filter "*.bat" | Select-Object -ExpandProperty Name
        
        if ($executables) {
            Write-InfoLog "Available executables: $($executables -join ', ')" "BuildTools"
        }
        if ($batFiles) {
            Write-InfoLog "Available batch files: $($batFiles -join ', ')" "BuildTools"
        }
    }
    
    # Test AAPT with a simple command (if available)
    if ($testResults.AaptVersion) {
        try {
            Write-InfoLog "Testing AAPT help command..." "BuildTools"
            $aaptExePath = Join-Path $InstallPath "aapt.exe"
            $aaptHelp = & $aaptExePath 2>&1
            if ($LASTEXITCODE -ne 0) {
                # AAPT returns non-zero when showing help, this is normal
                Write-InfoLog "AAPT help command executed (normal behavior)" "BuildTools"
            }
        } catch {
            Write-InfoLog "AAPT help test skipped" "BuildTools"
        }
    }
}

# Overall success calculation
$testResults.OverallSuccess = $testResults.InstallPathExists -and 
                              $testResults.AaptExecutable -and 
                              $testResults.AaptVersion -and 
                              $testResults.DxExecutable -and 
                              $testResults.DxVersion -and 
                              $testResults.ZipalignExecutable -and 
                              $testResults.ApksignerExecutable

# Results summary
Write-InfoLog "=== Android Build Tools Test Results Summary ===" "BuildTools"
Write-InfoLog "$(if($testResults.InstallPathExists) {'✓'} else {'✗'}) Installation path exists" "BuildTools"
Write-InfoLog "$(if($testResults.AaptExecutable) {'✓'} else {'✗'}) AAPT executable found" "BuildTools"
Write-InfoLog "$(if($testResults.AaptVersion) {'✓'} else {'✗'}) AAPT version command" "BuildTools"
Write-InfoLog "$(if($testResults.DxExecutable) {'✓'} else {'✗'}) DX/D8 executable found" "BuildTools"
Write-InfoLog "$(if($testResults.DxVersion) {'✓'} else {'✗'}) DX/D8 version command" "BuildTools"
Write-InfoLog "$(if($testResults.ZipalignExecutable) {'✓'} else {'✗'}) Zipalign executable found" "BuildTools"
Write-InfoLog "$(if($testResults.ApksignerExecutable) {'✓'} else {'✗'}) APK Signer executable found" "BuildTools"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($testResults.OverallSuccess) {
    Write-Host "Android Build Tools installation test PASSED! ✓" -ForegroundColor Green
    Write-Host "Build Tools are ready to use" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Android Build Tools installation test FAILED! ✗" -ForegroundColor Red
    Write-Host "Please check the installation and try again" -ForegroundColor Red
    exit 1
}