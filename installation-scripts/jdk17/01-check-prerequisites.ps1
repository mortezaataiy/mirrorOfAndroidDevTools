# Check JDK 17 Prerequisites
# This script checks all prerequisites for JDK 17 installation

param(
    [string]$DownloadPath = "..\..\downloaded",
    [switch]$Verbose
)

# Import common modules
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path (Split-Path -Parent $ScriptDir) "common"

. (Join-Path $CommonDir "Logger.ps1")
. (Join-Path $CommonDir "FileValidator.ps1")

# Initialize Logger
Initialize-Logger -ComponentName "JDK17-Prerequisites" -Verbose:$Verbose

try {
    Write-LogInfo "Starting JDK 17 prerequisites check..."
    
    # Configuration
    $JdkFileName = "jdk-17.zip"
    $MinimumSizeBytes = 100MB
    
    # Check system architecture
    Write-LogInfo "Checking system architecture..."
    $Architecture = $env:PROCESSOR_ARCHITECTURE
    if ($Architecture -ne "AMD64") {
        Write-LogError "Unsupported system architecture. Expected: AMD64, Found: $Architecture"
        exit 1
    }
    Write-LogSuccess "System architecture is compatible: $Architecture"
    
    # Check Windows version
    Write-LogInfo "Checking Windows version..."
    $OSVersion = [System.Environment]::OSVersion.Version
    if ($OSVersion.Major -lt 10) {
        Write-LogError "Unsupported Windows version. Windows 10 or higher required. Found: $($OSVersion.ToString())"
        exit 1
    }
    Write-LogSuccess "Windows version is compatible: $($OSVersion.ToString())"
    
    # Check JDK file
    $JdkFilePath = Join-Path $DownloadPath $JdkFileName
    Write-LogInfo "Checking JDK file: $JdkFilePath"
    
    if (-not (Test-Path $JdkFilePath)) {
        Write-LogError "JDK file not found: $JdkFilePath"
        Write-LogError "Please ensure the JDK 17 ZIP file is downloaded to the correct location"
        exit 1
    }
    
    # Check file size
    $FileSize = (Get-Item $JdkFilePath).Length
    if ($FileSize -lt $MinimumSizeBytes) {
        Write-LogError "JDK file size ($([math]::Round($FileSize/1MB, 1)) MB) is smaller than expected minimum ($([math]::Round($MinimumSizeBytes/1MB, 1)) MB)"
        exit 1
    }
    Write-LogSuccess "JDK file size is acceptable: $([math]::Round($FileSize/1MB, 1)) MB"
    
    # Test ZIP file integrity
    Write-LogInfo "Testing ZIP file integrity..."
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $FullPath = Resolve-Path $JdkFilePath
        $ZipFile = [System.IO.Compression.ZipFile]::OpenRead($FullPath.Path)
        $EntryCount = $ZipFile.Entries.Count
        $ZipFile.Dispose()
        
        if ($EntryCount -eq 0) {
            Write-LogError "ZIP file appears to be empty or corrupted"
            exit 1
        }
        
        Write-LogSuccess "ZIP file integrity verified: $EntryCount entries found"
        
    } catch {
        Write-LogError "Failed to read ZIP file: $($_.Exception.Message)"
        exit 1
    }
    
    # Check available disk space
    Write-LogInfo "Checking available disk space..."
    $InstallDrive = "C:"
    $DriveInfo = Get-WmiObject -Class Win32_LogicalDisk | Where-Object { $_.DeviceID -eq $InstallDrive }
    $FreeSpaceGB = [math]::Round($DriveInfo.FreeSpace / 1GB, 1)
    $RequiredSpaceGB = 2.0  # JDK 17 requires about 2GB
    
    if ($FreeSpaceGB -lt $RequiredSpaceGB) {
        Write-LogError "Insufficient disk space. Required: $RequiredSpaceGB GB, Available: $FreeSpaceGB GB"
        exit 1
    }
    Write-LogSuccess "Sufficient disk space available: $FreeSpaceGB GB free"
    
    Write-LogSuccess "All JDK 17 prerequisites are satisfied!"
    Write-LogInfo "Ready to proceed with JDK 17 installation"
    
    exit 0
    
} catch {
    Write-LogError "Error during prerequisites check: $($_.Exception.Message)"
    exit 1
}