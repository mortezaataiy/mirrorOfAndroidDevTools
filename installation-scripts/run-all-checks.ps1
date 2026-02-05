# Run all prerequisite checks
# This script runs all prerequisite check scripts

param(
    [string]$DownloadPath = "downloaded",
    [switch]$Verbose,
    [switch]$ContinueOnError
)

# Import common modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path $ScriptDir "common"

. (Join-Path $CommonDir "Logger.ps1")

# Setup logger
Initialize-Logger -ComponentName "All-Prerequisites-Check" -Verbose:$Verbose

try {
    Write-LogInfo "Starting prerequisite checks for Android Development Tools..."
    Write-LogInfo "Download path: $DownloadPath"
    
    # List of components in dependency order
    $Components = @(
        @{ Name = "JDK 17"; Path = "jdk17\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Android Studio"; Path = "android-studio\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Gradle"; Path = "gradle\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Command Line Tools"; Path = "commandline-tools\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Platform Tools"; Path = "platform-tools\01-check-prerequisites.ps1"; Required = $true },
        @{ Name = "Build Tools"; Path = "build-tools\01-check-prerequisites.ps1"; Required = $false },
        @{ Name = "SDK Platforms"; Path = "sdk-platforms\01-check-prerequisites.ps1"; Required = $false },
        @{ Name = "System Images"; Path = "system-images\01-check-prerequisites.ps1"; Required = $false },
        @{ Name = "Repositories"; Path = "repositories\01-check-prerequisites.ps1"; Required = $false }
    )
    
    $Results = @{}
    $SuccessCount = 0
    $FailureCount = 0
    $SkippedCount = 0
    
    Write-LogInfo "Checking $($Components.Count) components..."
    Write-LogInfo "=" * 60
    
    foreach ($Component in $Components) {
        $ComponentPath = Join-Path $ScriptDir $Component.Path
        
        Write-LogInfo "Checking $($Component.Name)..."
        
        if (-not (Test-Path $ComponentPath)) {
            Write-LogWarning "Check script not found: $ComponentPath"
            $Results[$Component.Name] = @{
                Status = "Skipped"
                Message = "Script not found"
                ExitCode = -1
            }
            $SkippedCount++
            continue
        }
        
        try {
            # Run check script
            $StartTime = Get-Date
            
            if ($Verbose) {
                $Output = & PowerShell -File $ComponentPath -DownloadPath $DownloadPath -Verbose 2>&1
            } else {
                $Output = & PowerShell -File $ComponentPath -DownloadPath $DownloadPath 2>&1
            }
            
            $EndTime = Get-Date
            $Duration = ($EndTime - $StartTime).TotalSeconds
            $ExitCode = $LASTEXITCODE
            
            if ($ExitCode -eq 0) {
                Write-LogSuccess "$($Component.Name): Success (Duration: $([math]::Round($Duration, 1)) seconds)"
                $Results[$Component.Name] = @{
                    Status = "Success"
                    Message = "All prerequisites met"
                    ExitCode = $ExitCode
                    Duration = $Duration
                }
                $SuccessCount++
            } else {
                $ErrorMessage = "Failed (Exit Code: $ExitCode)"
                if ($Component.Required) {
                    Write-LogError "$($Component.Name): $ErrorMessage"
                } else {
                    Write-LogWarning "$($Component.Name): $ErrorMessage (Optional)"
                }
                
                $Results[$Component.Name] = @{
                    Status = "Failed"
                    Message = $ErrorMessage
                    ExitCode = $ExitCode
                    Duration = $Duration
                    Output = $Output
                }
                $FailureCount++
                
                # If required component fails and ContinueOnError is not set, stop
                if ($Component.Required -and -not $ContinueOnError) {
                    Write-LogError "Required component $($Component.Name) failed. Stopping execution."
                    Write-LogError "Use -ContinueOnError parameter to continue despite errors"
                    break
                }
            }
            
        } catch {
            Write-LogError "Error checking $($Component.Name): $($_.Exception.Message)"
            $Results[$Component.Name] = @{
                Status = "Error"
                Message = $_.Exception.Message
                ExitCode = -1
            }
            $FailureCount++
            
            if ($Component.Required -and -not $ContinueOnError) {
                Write-LogError "Error in required component $($Component.Name). Stopping execution."
                break
            }
        }
        
        Write-LogInfo "-" * 40
    }
    
    # Final report
    Write-LogInfo "=" * 60
    Write-LogInfo "Prerequisites Check Summary:"
    Write-LogInfo "Success: $SuccessCount"
    Write-LogInfo "Failed: $FailureCount"
    Write-LogInfo "Skipped: $SkippedCount"
    Write-LogInfo "Total: $($Components.Count)"
    
    # Detailed results
    Write-LogInfo ""
    Write-LogInfo "Detailed Results:"
    foreach ($Component in $Components) {
        $Result = $Results[$Component.Name]
        if ($Result) {
            $StatusIcon = switch ($Result.Status) {
                "Success" { "[OK]" }
                "Failed" { "[FAIL]" }
                "Error" { "[ERROR]" }
                "Skipped" { "[SKIP]" }
                default { "[?]" }
            }
            
            $RequiredText = if ($Component.Required) { "(Required)" } else { "(Optional)" }
            Write-LogInfo "$StatusIcon $($Component.Name) $RequiredText : $($Result.Message)"
            
            if ($Result.Duration) {
                Write-LogInfo "    Duration: $([math]::Round($Result.Duration, 1)) seconds"
            }
        }
    }
    
    # Check required components
    $RequiredComponents = $Components | Where-Object { $_.Required }
    $FailedRequired = @()
    
    foreach ($Required in $RequiredComponents) {
        $Result = $Results[$Required.Name]
        if ($Result -and $Result.Status -ne "Success") {
            $FailedRequired += $Required.Name
        }
    }
    
    if ($FailedRequired.Count -eq 0) {
        Write-LogSuccess "All required components are ready!"
        Write-LogInfo "You can start installation by running: .\run-all-installations.ps1"
        exit 0
    } else {
        Write-LogError "Failed required components: $($FailedRequired -join ', ')"
        Write-LogError "Please fix the issues and try again"
        
        # Show error details
        foreach ($Failed in $FailedRequired) {
            $Result = $Results[$Failed]
            if ($Result -and $Result.Output) {
                Write-LogError "Error details for $Failed :"
                $Result.Output | ForEach-Object { Write-LogError "  $_" }
            }
        }
        
        exit 1
    }
    
} catch {
    Write-LogError "Error running prerequisite checks: $($_.Exception.Message)"
    Write-LogError "Error details: $($_.Exception.StackTrace)"
    exit 1
}