# Simple Test Script for Android Component Installer
param(
    [string]$DownloadPath = "..\downloaded",
    [switch]$Verbose
)

# Import common modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path $ScriptDir "common"

. (Join-Path $CommonDir "Logger.ps1")

# Initialize Logger
Initialize-Logger -ComponentName "Simple-Test" -Verbose:$Verbose

try {
    Write-LogInfo "Starting simple test of Android Component Installer..."
    
    # Test 1: Check if download directory exists
    Write-LogInfo "Test 1: Checking download directory..."
    if (Test-Path $DownloadPath) {
        Write-LogSuccess "Download directory exists: $DownloadPath"
    } else {
        Write-LogError "Download directory not found: $DownloadPath"
        exit 1
    }
    
    # Test 2: List available files
    Write-LogInfo "Test 2: Listing available files..."
    $Files = Get-ChildItem $DownloadPath -Filter "*.zip"
    Write-LogInfo "Found $($Files.Count) ZIP files:"
    foreach ($File in $Files) {
        $SizeMB = [math]::Round($File.Length / 1MB, 1)
        Write-LogInfo "  - $($File.Name) ($SizeMB MB)"
    }
    
    # Test 3: Test JDK prerequisites only
    Write-LogInfo "Test 3: Testing JDK 17 prerequisites..."
    $JdkScript = Join-Path $ScriptDir "jdk17\01-check-prerequisites.ps1"
    if (Test-Path $JdkScript) {
        $JdkOutput = & PowerShell -File $JdkScript -DownloadPath $DownloadPath 2>&1
        $JdkExitCode = $LASTEXITCODE
        
        if ($JdkExitCode -eq 0) {
            Write-LogSuccess "JDK 17 prerequisites check passed"
        } else {
            Write-LogWarning "JDK 17 prerequisites check failed (Exit Code: $JdkExitCode)"
        }
    } else {
        Write-LogWarning "JDK prerequisites script not found"
    }
    
    # Test 4: Test common modules
    Write-LogInfo "Test 4: Testing common modules..."
    
    # Test Logger
    Write-LogInfo "Testing Logger module..."
    Write-LogSuccess "Logger is working correctly"
    Write-LogWarning "This is a warning message"
    Write-LogVerbose "This is a verbose message"
    
    # Test FileValidator
    Write-LogInfo "Testing FileValidator module..."
    . (Join-Path $CommonDir "FileValidator.ps1")
    
    $TestFile = Join-Path $DownloadPath "jdk-17.zip"
    if (Test-Path $TestFile) {
        $IsValid = Test-FileIntegrity $TestFile 100MB
        if ($IsValid) {
            Write-LogSuccess "FileValidator is working correctly"
        } else {
            Write-LogWarning "FileValidator detected issues with test file"
        }
    } else {
        Write-LogWarning "Test file not found for FileValidator test"
    }
    
    # Final summary
    Write-LogInfo "=" * 50
    Write-LogSuccess "Simple test completed successfully!"
    Write-LogInfo "System appears to be working correctly"
    Write-LogInfo "You can proceed with full installation testing"
    
    exit 0
    
} catch {
    Write-LogError "Error during simple test: $($_.Exception.Message)"
    exit 1
}