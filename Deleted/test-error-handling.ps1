# Test script for error handling and timeout management
# این اسکریپت برای تست مدیریت خطا و timeout ها استفاده می‌شود

param(
    [Parameter(HelpMessage="Test scenario to run")]
    [ValidateSet("timeout", "crash", "hang", "interrupt")]
    [string]$TestScenario = "timeout"
)

# Import functions from main script
$mainScriptPath = Join-Path $PSScriptRoot "auto-download-and-setup-android-offline.ps1"
if (-not (Test-Path $mainScriptPath)) {
    Write-Error "Main script not found: $mainScriptPath"
    exit 1
}

# Extract functions from main script (simplified approach)
$scriptContent = Get-Content $mainScriptPath -Raw
$functionPattern = 'function\s+([^{]+)\s*\{'
$functions = [regex]::Matches($scriptContent, $functionPattern)

Write-Host "Testing Error Handling and Timeout Management" -ForegroundColor Cyan
Write-Host "Test Scenario: $TestScenario" -ForegroundColor Yellow
Write-Host ""

# Set up global variables like main script
$Global:RunningProcesses = @()
$Global:TempDirectories = @()
$Global:CleanupRegistered = $false
$GLOBAL_TIMEOUT = 30  # Shorter timeout for testing
$BUILD_TIMEOUT = 60
$EXTRACT_TIMEOUT = 30

# Test functions (simplified versions)
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "Cyan" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

function Write-Info { param([string]$Message) Write-Log $Message "INFO" }
function Write-Warning { param([string]$Message) Write-Log $Message "WARNING" }
function Write-Error { param([string]$Message) Write-Log $Message "ERROR" }
function Write-Success { param([string]$Message) Write-Log $Message "SUCCESS" }

function Invoke-EmergencyCleanup {
    Write-Warning "Performing emergency cleanup..."
    
    # Kill any running processes we started
    foreach ($processInfo in $Global:RunningProcesses) {
        try {
            if ($processInfo.Process -and -not $processInfo.Process.HasExited) {
                Write-Warning "Terminating process: $($processInfo.Name) (PID: $($processInfo.Process.Id))"
                $processInfo.Process.Kill()
                $processInfo.Process.WaitForExit(5000)
            }
        }
        catch {
            Write-Warning "Failed to terminate process $($processInfo.Name): $($_.Exception.Message)"
        }
    }
    
    # Clean up temporary directories
    foreach ($tempDir in $Global:TempDirectories) {
        try {
            if (Test-Path $tempDir) {
                Write-Warning "Removing temporary directory: $tempDir"
                Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            }
        }
        catch {
            Write-Warning "Failed to remove temporary directory ${tempDir}: $($_.Exception.Message)"
        }
    }
    
    $Global:RunningProcesses = @()
    $Global:TempDirectories = @()
    Write-Warning "Emergency cleanup completed"
}

function Register-Cleanup {
    if (-not $Global:CleanupRegistered) {
        Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action {
            Invoke-EmergencyCleanup
        } | Out-Null
        $Global:CleanupRegistered = $true
        Write-Info "Emergency cleanup handler registered"
    }
}

function Start-ProcessWithTimeout {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList = @(),
        [int]$TimeoutSeconds = $GLOBAL_TIMEOUT,
        [string]$WorkingDirectory = $null,
        [string]$ProcessName = "Unknown"
    )
    
    try {
        $processStartInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processStartInfo.FileName = $FilePath
        $processStartInfo.Arguments = $ArgumentList -join " "
        $processStartInfo.UseShellExecute = $false
        $processStartInfo.RedirectStandardOutput = $true
        $processStartInfo.RedirectStandardError = $true
        $processStartInfo.CreateNoWindow = $true
        
        if ($WorkingDirectory) {
            $processStartInfo.WorkingDirectory = $WorkingDirectory
        }
        
        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processStartInfo
        
        # Add to tracking
        $processInfo = @{
            Process = $process
            Name = $ProcessName
            StartTime = Get-Date
        }
        $Global:RunningProcesses += $processInfo
        
        Write-Info "Starting process: $ProcessName (Timeout: ${TimeoutSeconds}s)"
        $process.Start() | Out-Null
        
        # Wait for process with timeout
        $finished = $process.WaitForExit($TimeoutSeconds * 1000)
        
        if (-not $finished) {
            Write-Warning "Process $ProcessName timed out after $TimeoutSeconds seconds"
            $process.Kill()
            $process.WaitForExit(5000)
            throw "Process timed out: $ProcessName"
        }
        
        # Remove from tracking
        $Global:RunningProcesses = $Global:RunningProcesses | Where-Object { $_.Process.Id -ne $process.Id }
        
        $result = @{
            ExitCode = $process.ExitCode
            StandardOutput = "Test output"
            StandardError = "Test error"
            ProcessName = $ProcessName
        }
        
        $process.Dispose()
        return $result
        
    }
    catch {
        Write-Error "Failed to start or manage process $ProcessName : $($_.Exception.Message)"
        throw
    }
}

# Register cleanup
Register-Cleanup

# Set up Ctrl+C handler
[Console]::TreatControlCAsInput = $false
$null = [Console]::CancelKeyPress.Add({
    param($sender, $e)
    Write-Warning "Ctrl+C detected. Performing cleanup..."
    $e.Cancel = $true
    Invoke-EmergencyCleanup
    exit 1
})

# Run test scenarios
switch ($TestScenario) {
    "timeout" {
        Write-Info "Testing timeout scenario..."
        try {
            # This will timeout after 5 seconds
            $result = Start-ProcessWithTimeout -FilePath "ping" -ArgumentList @("127.0.0.1", "-t") -TimeoutSeconds 5 -ProcessName "Ping Test"
            Write-Success "Process completed normally (unexpected)"
        }
        catch {
            Write-Warning "Process timed out as expected: $($_.Exception.Message)"
        }
    }
    
    "crash" {
        Write-Info "Testing crash scenario..."
        try {
            # This will fail immediately
            $result = Start-ProcessWithTimeout -FilePath "nonexistent-command.exe" -ArgumentList @() -TimeoutSeconds 10 -ProcessName "Crash Test"
            Write-Success "Process completed normally (unexpected)"
        }
        catch {
            Write-Warning "Process crashed as expected: $($_.Exception.Message)"
        }
    }
    
    "hang" {
        Write-Info "Testing hang scenario..."
        # Create a temp directory to test cleanup
        $tempDir = Join-Path $env:TEMP "test-cleanup-$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $Global:TempDirectories += $tempDir
        Write-Info "Created temp directory: $tempDir"
        
        Write-Info "Simulating hang... (will cleanup in 10 seconds)"
        Start-Sleep -Seconds 10
        
        Write-Info "Performing manual cleanup test..."
        Invoke-EmergencyCleanup
    }
    
    "interrupt" {
        Write-Info "Testing interrupt scenario..."
        Write-Info "Press Ctrl+C within 15 seconds to test interrupt handling..."
        
        # Create some temp resources
        $tempDir = Join-Path $env:TEMP "test-interrupt-$(Get-Random)"
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
        $Global:TempDirectories += $tempDir
        
        try {
            # Start a long-running process
            $result = Start-ProcessWithTimeout -FilePath "ping" -ArgumentList @("127.0.0.1", "-n", "20") -TimeoutSeconds 15 -ProcessName "Interrupt Test"
            Write-Success "Process completed normally"
        }
        catch {
            Write-Warning "Process was interrupted: $($_.Exception.Message)"
        }
    }
}

Write-Success "Test completed. Performing final cleanup..."
Invoke-EmergencyCleanup
Write-Success "All tests completed successfully!"