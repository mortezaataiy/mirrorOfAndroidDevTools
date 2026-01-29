# Logger.ps1 - Simple Log Management
$Global:LogFile = ""

function Initialize-Logger {
    param([string]$ComponentName = "General")
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $Global:LogFile = "logs/$ComponentName_$timestamp.log"
    if (-not (Test-Path "logs")) { New-Item -ItemType Directory -Path "logs" -Force | Out-Null }
    Write-Host "Logger initialized for $ComponentName" -ForegroundColor Green
}

function Write-InfoLog {
    param([string]$Message, [string]$Component = "")
    $logEntry = "[INFO] [$Component] $Message"
    Write-Host $logEntry -ForegroundColor Green
    if ($Global:LogFile) { Add-Content -Path $Global:LogFile -Value $logEntry }
}

function Write-ErrorLog {
    param([string]$Message, [string]$Component = "")
    $logEntry = "[ERROR] [$Component] $Message"
    Write-Host $logEntry -ForegroundColor Red
    if ($Global:LogFile) { Add-Content -Path $Global:LogFile -Value $logEntry }
}

function Get-LogSummary {
    return @{ LogFile = $Global:LogFile; ErrorCount = 0; InfoCount = 0 }
}

