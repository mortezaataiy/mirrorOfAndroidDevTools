# Error Handler and Logging System
# Responsible for error management and logging

# Define error types
enum ErrorType {
    NetworkError
    FileError
    InstallError
    BuildError
    ValidationError
    ConfigurationError
}

# Error information class
class ErrorInfo {
    [datetime]$Timestamp
    [ErrorType]$Type
    [string]$Message
    [string]$Context
    [string]$ActionTaken
    [hashtable]$Details
    
    ErrorInfo([ErrorType]$type, [string]$message, [string]$context) {
        $this.Timestamp = Get-Date
        $this.Type = $type
        $this.Message = $message
        $this.Context = $context
        $this.Details = @{}
    }
}

# Global variables for storing logs
$Global:ErrorLog = @()
$Global:ActivityLog = @()

# General logging function
function Write-ActivityLog {
    param(
        [string]$Message,
        [string]$Level = "INFO",
        [string]$Context = ""
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = @{
        Timestamp = $timestamp
        Level = $Level
        Message = $Message
        Context = $Context
    }
    
    $Global:ActivityLog += $logEntry
    
    # Display in console with appropriate color
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        "INFO" { "White" }
        default { "Gray" }
    }
    
    $prefix = switch ($Level) {
        "ERROR" { "❌" }
        "WARNING" { "⚠️" }
        "SUCCESS" { "✅" }
        "INFO" { "ℹ️" }
        default { "📝" }
    }
    
    Write-Host "$prefix [$timestamp] $Message" -ForegroundColor $color
}

# Error management with appropriate strategy
function Handle-Error {
    param(
        [ErrorType]$ErrorType,
        [string]$ErrorMessage,
        [string]$Context = "",
        [hashtable]$Details = @{}
    )
    
    $errorInfo = [ErrorInfo]::new($ErrorType, $ErrorMessage, $Context)
    $errorInfo.Details = $Details
    
    Write-ActivityLog -Message "Error occurred: $ErrorMessage" -Level "ERROR" -Context $Context
    
    switch ($ErrorType) {
        ([ErrorType]::NetworkError) {
            $errorInfo.ActionTaken = "Retry up to 3 times"
            Write-ActivityLog -Message "Network error - preparing for retry" -Level "WARNING"
        }
        ([ErrorType]::FileError) {
            $errorInfo.ActionTaken = "Stop process and report error"
            Write-ActivityLog -Message "File error - process will be stopped" -Level "ERROR"
        }
        ([ErrorType]::InstallError) {
            $errorInfo.ActionTaken = "Check dependencies and retry"
            Write-ActivityLog -Message "Install error - checking prerequisites" -Level "WARNING"
        }
        ([ErrorType]::BuildError) {
            $errorInfo.ActionTaken = "Display compile error details"
            Write-ActivityLog -Message "Build error - displaying details" -Level "ERROR"
        }
        ([ErrorType]::ValidationError) {
            $errorInfo.ActionTaken = "Re-check input parameters"
            Write-ActivityLog -Message "Validation error - checking inputs" -Level "WARNING"
        }
        ([ErrorType]::ConfigurationError) {
            $errorInfo.ActionTaken = "Reset settings to default"
            Write-ActivityLog -Message "Configuration error - resetting settings" -Level "WARNING"
        }
    }
    
    $Global:ErrorLog += $errorInfo
    return $errorInfo
}

# Retry operation
function Retry-Operation {
    param(
        [scriptblock]$Operation,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 2,
        [string]$OperationName = "operation"
    )
    
    $attempt = 1
    while ($attempt -le $MaxAttempts) {
        try {
            Write-ActivityLog -Message "Attempt $attempt of $MaxAttempts for $OperationName" -Level "INFO"
            
            $result = & $Operation
            
            Write-ActivityLog -Message "$OperationName completed successfully" -Level "SUCCESS"
            return $result
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-ActivityLog -Message "Attempt $attempt failed: $errorMsg" -Level "WARNING"
            
            if ($attempt -eq $MaxAttempts) {
                Handle-Error -ErrorType ([ErrorType]::NetworkError) -ErrorMessage "Operation failed after $MaxAttempts attempts: $errorMsg" -Context $OperationName
                throw $_
            }
            
            $attempt++
            if ($DelaySeconds -gt 0) {
                Write-ActivityLog -Message "Waiting $DelaySeconds seconds before retry..." -Level "INFO"
                Start-Sleep -Seconds $DelaySeconds
            }
        }
    }
}

# Show error summary
function Show-ErrorSummary {
    Write-ActivityLog -Message "=== Error Summary ===" -Level "INFO"
    
    if ($Global:ErrorLog.Count -eq 0) {
        Write-ActivityLog -Message "No errors occurred" -Level "SUCCESS"
        return
    }
    
    $errorGroups = $Global:ErrorLog | Group-Object Type
    foreach ($group in $errorGroups) {
        Write-ActivityLog -Message "$($group.Name): $($group.Count) errors" -Level "WARNING"
    }
    
    Write-ActivityLog -Message "Total errors: $($Global:ErrorLog.Count)" -Level "ERROR"
}

# Show activity summary
function Show-ActivitySummary {
    Write-ActivityLog -Message "=== Activity Summary ===" -Level "INFO"
    
    $levelGroups = $Global:ActivityLog | Group-Object Level
    foreach ($group in $levelGroups) {
        $color = switch ($group.Name) {
            "ERROR" { "Red" }
            "WARNING" { "Yellow" }
            "SUCCESS" { "Green" }
            default { "White" }
        }
        Write-Host "$($group.Name): $($group.Count)" -ForegroundColor $color
    }
}

# Save logs to file
function Save-LogsToFile {
    param([string]$OutputPath = "logs")
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    
    # Save activity log
    $activityLogPath = Join-Path $OutputPath "activity-$timestamp.json"
    $Global:ActivityLog | ConvertTo-Json -Depth 3 | Out-File -FilePath $activityLogPath -Encoding UTF8
    
    # Save error log
    if ($Global:ErrorLog.Count -gt 0) {
        $errorLogPath = Join-Path $OutputPath "errors-$timestamp.json"
        $Global:ErrorLog | ConvertTo-Json -Depth 3 | Out-File -FilePath $errorLogPath -Encoding UTF8
    }
    
    Write-ActivityLog -Message "Logs saved to $OutputPath" -Level "SUCCESS"
}

# Clear logs
function Clear-Logs {
    $Global:ErrorLog = @()
    $Global:ActivityLog = @()
    Write-Host "🧹 Logs cleared" -ForegroundColor Green
}

# Export functions
Export-ModuleMember -Function Write-ActivityLog, Handle-Error, Retry-Operation, Show-ErrorSummary, Show-ActivitySummary, Save-LogsToFile, Clear-Logs