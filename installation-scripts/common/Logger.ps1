# Logger.ps1 - Logging System for Android Component Installer
# Provides comprehensive logging functionality with multiple log levels

# Global variables
$Global:LoggerConfig = @{
    LogFile = ""
    ComponentName = ""
    VerboseMode = $false
    LogLevel = "INFO"
}

function Initialize-Logger {
    <#
    .SYNOPSIS
    Initialize the logging system
    
    .PARAMETER ComponentName
    Name of the component being logged
    
    .PARAMETER Verbose
    Enable verbose logging
    #>
    param(
        [string]$ComponentName = "General",
        [switch]$Verbose
    )
    
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $Global:LoggerConfig.LogFile = "logs\$ComponentName`_$timestamp.log"
    $Global:LoggerConfig.ComponentName = $ComponentName
    $Global:LoggerConfig.VerboseMode = $Verbose
    
    # Create logs directory if it doesn't exist
    if (-not (Test-Path "logs")) { 
        New-Item -ItemType Directory -Path "logs" -Force | Out-Null 
    }
    
    Write-Host "[INIT] Logger initialized for $ComponentName" -ForegroundColor Cyan
    Write-LogEntry "INFO" "Logger initialized for component: $ComponentName"
}

function Write-LogEntry {
    <#
    .SYNOPSIS
    Write a log entry with timestamp
    #>
    param(
        [string]$Level,
        [string]$Message
    )
    
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] [$($Global:LoggerConfig.ComponentName)] $Message"
    
    if ($Global:LoggerConfig.LogFile) {
        Add-Content -Path $Global:LoggerConfig.LogFile -Value $logEntry -Encoding UTF8
    }
}

function Write-LogInfo {
    <#
    .SYNOPSIS
    Write an info log message
    #>
    param([string]$Message)
    
    Write-Host "[INFO] $Message" -ForegroundColor White
    Write-LogEntry "INFO" $Message
}

function Write-LogSuccess {
    <#
    .SYNOPSIS
    Write a success log message
    #>
    param([string]$Message)
    
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
    Write-LogEntry "SUCCESS" $Message
}

function Write-LogWarning {
    <#
    .SYNOPSIS
    Write a warning log message
    #>
    param([string]$Message)
    
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
    Write-LogEntry "WARNING" $Message
}

function Write-LogError {
    <#
    .SYNOPSIS
    Write an error log message
    #>
    param([string]$Message)
    
    Write-Host "[ERROR] $Message" -ForegroundColor Red
    Write-LogEntry "ERROR" $Message
}

function Write-LogVerbose {
    <#
    .SYNOPSIS
    Write a verbose log message (only if verbose mode is enabled)
    #>
    param([string]$Message)
    
    if ($Global:LoggerConfig.VerboseMode) {
        Write-Host "[VERBOSE] $Message" -ForegroundColor Gray
        Write-LogEntry "VERBOSE" $Message
    }
}

function Get-LogSummary {
    <#
    .SYNOPSIS
    Get logging summary information
    #>
    return @{
        LogFile = $Global:LoggerConfig.LogFile
        ComponentName = $Global:LoggerConfig.ComponentName
        VerboseMode = $Global:LoggerConfig.VerboseMode
    }
}