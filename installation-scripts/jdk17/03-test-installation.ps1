# 03-test-installation.ps1 - Test JDK 17 Installation
param(
    [switch]$Detailed
)

# Import common modules
$commonPath = Split-Path $PSScriptRoot -Parent | Join-Path -ChildPath "common"
. "$commonPath\Logger.ps1"

Initialize-Logger -ComponentName "JDK17-Test"
Write-InfoLog "Starting JDK 17 installation test" "JDK17"

$testResults = @{
    JavaHomeSet = $false
    JavaHomeValid = $false
    JavaExecutable = $false
    JavacExecutable = $false
    OverallSuccess = $false
}

# Test 1: Check JAVA_HOME
Write-InfoLog "Test 1: Checking JAVA_HOME environment variable" "JDK17"
$javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")

if ($javaHome) {
    $testResults.JavaHomeSet = $true
    Write-InfoLog "JAVA_HOME is set: $javaHome" "JDK17"
    
    if (Test-Path $javaHome) {
        $testResults.JavaHomeValid = $true
        Write-InfoLog "JAVA_HOME path is valid" "JDK17"
    } else {
        Write-ErrorLog "JAVA_HOME path is not valid: $javaHome" "JDK17"
    }
} else {
    Write-ErrorLog "JAVA_HOME environment variable is not set" "JDK17"
}

# Test 2: Check java.exe
Write-InfoLog "Test 2: Checking java.exe executable" "JDK17"
if ($testResults.JavaHomeValid) {
    $javaExePath = Join-Path $javaHome "bin\java.exe"
    
    if (Test-Path $javaExePath) {
        $testResults.JavaExecutable = $true
        Write-InfoLog "java.exe exists and is accessible" "JDK17"
        
        try {
            $javaVersion = & $javaExePath -version 2>&1
            Write-InfoLog "Java version test successful: $($javaVersion[0])" "JDK17"
        }
        catch {
            Write-ErrorLog "Java execution test failed" "JDK17"
        }
    } else {
        Write-ErrorLog "java.exe not found or not accessible" "JDK17"
    }
}

# Test 3: Check javac.exe
Write-InfoLog "Test 3: Checking javac.exe executable" "JDK17"
if ($testResults.JavaHomeValid) {
    $javacExePath = Join-Path $javaHome "bin\javac.exe"
    
    if (Test-Path $javacExePath) {
        $testResults.JavacExecutable = $true
        Write-InfoLog "javac.exe exists and is accessible" "JDK17"
        
        try {
            $javacVersion = & $javacExePath -version 2>&1
            Write-InfoLog "Javac version test successful: $javacVersion" "JDK17"
        }
        catch {
            Write-ErrorLog "Javac execution test failed" "JDK17"
        }
    } else {
        Write-ErrorLog "javac.exe not found or not accessible" "JDK17"
    }
}

# Overall success
$testResults.OverallSuccess = $testResults.JavaHomeSet -and 
                              $testResults.JavaHomeValid -and 
                              $testResults.JavaExecutable -and 
                              $testResults.JavacExecutable

# Results summary
Write-InfoLog "=== JDK 17 Test Results Summary ===" "JDK17"
Write-InfoLog "$(if($testResults.JavaHomeSet) {''} else {''}) JAVA_HOME set" "JDK17"
Write-InfoLog "$(if($testResults.JavaHomeValid) {''} else {''}) JAVA_HOME path valid" "JDK17"
Write-InfoLog "$(if($testResults.JavaExecutable) {''} else {''}) java.exe executable" "JDK17"
Write-InfoLog "$(if($testResults.JavacExecutable) {''} else {''}) javac.exe executable" "JDK17"

if ($testResults.OverallSuccess) {
    Write-Host "JDK 17 installation test PASSED! " -ForegroundColor Green
    exit 0
} else {
    Write-Host "JDK 17 installation test FAILED! " -ForegroundColor Red
    exit 1
}
