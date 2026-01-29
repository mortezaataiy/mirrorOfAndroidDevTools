# 03-test-installation.ps1 - Test Gradle Installation
param(
    [switch]$Detailed
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
Import-Module "$commonPath\Logger.ps1" -Force

# Initialize Logger
Initialize-Logger -ComponentName "Gradle-Test"

Write-InfoLog "Starting Gradle installation test" "Gradle"

$testResults = @{
    GradleHomeSet = $false
    GradleHomeValid = $false
    GradleExecutable = $false
    GradleVersion = $false
    SimpleProjectTest = $false
    OverallSuccess = $false
}

# Test 1: Check GRADLE_HOME
Write-InfoLog "Test 1: Checking GRADLE_HOME environment variable" "Gradle"
$gradleHome = [Environment]::GetEnvironmentVariable("GRADLE_HOME", "User")

if ($gradleHome) {
    $testResults.GradleHomeSet = $true
    Write-InfoLog "GRADLE_HOME is set: $gradleHome" "Gradle"
    
    if (Test-Path $gradleHome) {
        $testResults.GradleHomeValid = $true
        Write-InfoLog "GRADLE_HOME path is valid" "Gradle"
    } else {
        Write-ErrorLog "GRADLE_HOME path is not valid: $gradleHome" "Gradle"
    }
} else {
    Write-ErrorLog "GRADLE_HOME environment variable is not set" "Gradle"
}

# Test 2: Check gradle executable
Write-InfoLog "Test 2: Checking gradle executable" "Gradle"
if ($testResults.GradleHomeValid) {
    $gradleExePath = Join-Path $gradleHome "bin\gradle.bat"
    
    if (Test-Path $gradleExePath) {
        $testResults.GradleExecutable = $true
        Write-InfoLog "gradle.bat exists and is accessible" "Gradle"
    } else {
        Write-ErrorLog "gradle.bat not found: $gradleExePath" "Gradle"
    }
}

# Test 3: Check gradle version
Write-InfoLog "Test 3: Checking gradle version" "Gradle"
if ($testResults.GradleExecutable) {
    try {
        $gradleVersionOutput = & gradle -v 2>&1
        if ($LASTEXITCODE -eq 0) {
            $testResults.GradleVersion = $true
            $versionLine = $gradleVersionOutput | Where-Object { $_ -match "Gradle" } | Select-Object -First 1
            Write-InfoLog "Gradle version test successful: $versionLine" "Gradle"
        } else {
            Write-ErrorLog "Gradle version command failed with exit code: $LASTEXITCODE" "Gradle"
        }
    } catch {
        Write-ErrorLog "Gradle version test failed: $($_.Exception.Message)" "Gradle"
    }
}

# Test 4: Test simple project creation
Write-InfoLog "Test 4: Testing simple project creation" "Gradle"
if ($testResults.GradleVersion) {
    $tempProjectPath = Join-Path $env:TEMP "gradle-test-project-$(Get-Date -Format 'yyyyMMddHHmmss')"
    
    try {
        # Create temporary directory
        New-Item -ItemType Directory -Path $tempProjectPath -Force | Out-Null
        Push-Location $tempProjectPath
        
        Write-InfoLog "Creating test project in: $tempProjectPath" "Gradle"
        
        # Initialize gradle project
        $initOutput = & gradle init --type basic --dsl groovy --project-name test-project --quiet 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            $testResults.SimpleProjectTest = $true
            Write-InfoLog "Simple project creation test successful" "Gradle"
            
            # Test gradle wrapper
            if (Test-Path "gradlew.bat") {
                Write-InfoLog "Gradle wrapper created successfully" "Gradle"
                
                # Test wrapper execution
                $wrapperTest = & .\gradlew.bat tasks --quiet 2>&1
                if ($LASTEXITCODE -eq 0) {
                    Write-InfoLog "Gradle wrapper execution test successful" "Gradle"
                } else {
                    Write-WarningLog "Gradle wrapper execution test failed" "Gradle"
                }
            }
        } else {
            Write-ErrorLog "Simple project creation failed with exit code: $LASTEXITCODE" "Gradle"
            Write-ErrorLog "Output: $initOutput" "Gradle"
        }
    } catch {
        Write-ErrorLog "Simple project test failed: $($_.Exception.Message)" "Gradle"
    } finally {
        # Clean up
        Pop-Location
        if (Test-Path $tempProjectPath) {
            try {
                Remove-Item $tempProjectPath -Recurse -Force
                Write-InfoLog "Cleaned up test project directory" "Gradle"
            } catch {
                Write-WarningLog "Failed to clean up test project directory: $($_.Exception.Message)" "Gradle"
            }
        }
    }
}

# Additional detailed tests if requested
if ($Detailed) {
    Write-InfoLog "=== Detailed Test Information ===" "Gradle"
    
    # Check JDK dependency
    Write-InfoLog "Checking JDK dependency..." "Gradle"
    $javaHome = $env:JAVA_HOME
    if ($javaHome -and (Test-Path $javaHome)) {
        Write-InfoLog "JDK dependency satisfied: $javaHome" "Gradle"
        
        # Test Java version compatibility
        try {
            $javaVersion = & "$javaHome\bin\java.exe" -version 2>&1
            Write-InfoLog "Java version: $($javaVersion[0])" "Gradle"
        } catch {
            Write-WarningLog "Could not verify Java version" "Gradle"
        }
    } else {
        Write-WarningLog "JDK dependency not found in JAVA_HOME" "Gradle"
    }
    
    # Check Gradle installation size
    if ($testResults.GradleHomeValid) {
        try {
            $installSize = (Get-ChildItem $gradleHome -Recurse -File | Measure-Object -Property Length -Sum).Sum
            $installSizeMB = [math]::Round($installSize / 1MB, 2)
            Write-InfoLog "Gradle installation size: ${installSizeMB} MB" "Gradle"
        } catch {
            Write-InfoLog "Could not calculate installation size" "Gradle"
        }
    }
    
    # Check PATH configuration
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $gradleBinPath = Join-Path $gradleHome "bin"
    if ($currentPath -like "*$gradleBinPath*") {
        Write-InfoLog "Gradle is properly configured in PATH" "Gradle"
    } else {
        Write-WarningLog "Gradle may not be properly configured in PATH" "Gradle"
    }
}

# Overall success calculation
$testResults.OverallSuccess = $testResults.GradleHomeSet -and 
                              $testResults.GradleHomeValid -and 
                              $testResults.GradleExecutable -and 
                              $testResults.GradleVersion -and 
                              $testResults.SimpleProjectTest

# Results summary
Write-InfoLog "=== Gradle Test Results Summary ===" "Gradle"
Write-InfoLog "$(if($testResults.GradleHomeSet) {'✓'} else {'✗'}) GRADLE_HOME set" "Gradle"
Write-InfoLog "$(if($testResults.GradleHomeValid) {'✓'} else {'✗'}) GRADLE_HOME path valid" "Gradle"
Write-InfoLog "$(if($testResults.GradleExecutable) {'✓'} else {'✗'}) gradle executable" "Gradle"
Write-InfoLog "$(if($testResults.GradleVersion) {'✓'} else {'✗'}) gradle version command" "Gradle"
Write-InfoLog "$(if($testResults.SimpleProjectTest) {'✓'} else {'✗'}) simple project creation" "Gradle"

# Display log summary
$logSummary = Get-LogSummary
Write-Host "Log file: $($logSummary.LogFile)" -ForegroundColor Gray
Write-Host "Error count: $($logSummary.ErrorCount)" -ForegroundColor $(if($logSummary.ErrorCount -gt 0) {"Red"} else {"Green"})

if ($testResults.OverallSuccess) {
    Write-Host "Gradle installation test PASSED! ✓" -ForegroundColor Green
    Write-Host "Gradle is ready to use" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Gradle installation test FAILED! ✗" -ForegroundColor Red
    Write-Host "Please check the installation and try again" -ForegroundColor Red
    exit 1
}