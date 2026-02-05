# FileValidator.ps1 - File Validation Functions
# Provides comprehensive file validation capabilities

function Test-FileExists {
    <#
    .SYNOPSIS
    Test if a file exists
    
    .PARAMETER FilePath
    Path to the file to check
    
    .PARAMETER ComponentName
    Name of the component for logging
    #>
    param(
        [string]$FilePath,
        [string]$ComponentName = ""
    )
    
    if (-not (Test-Path $FilePath)) {
        Write-LogError "File not found: $FilePath"
        return $false
    }
    
    Write-LogVerbose "File exists: $FilePath"
    return $true
}

function Test-FileSize {
    <#
    .SYNOPSIS
    Test if a file meets minimum size requirements
    
    .PARAMETER FilePath
    Path to the file to check
    
    .PARAMETER MinimumSizeBytes
    Minimum expected file size in bytes
    
    .PARAMETER ComponentName
    Name of the component for logging
    #>
    param(
        [string]$FilePath,
        [long]$MinimumSizeBytes,
        [string]$ComponentName = ""
    )
    
    if (-not (Test-FileExists $FilePath $ComponentName)) { 
        return $false 
    }
    
    $FileInfo = Get-Item $FilePath
    $FileSizeMB = [math]::Round($FileInfo.Length / 1MB, 1)
    $MinSizeMB = [math]::Round($MinimumSizeBytes / 1MB, 1)
    
    if ($FileInfo.Length -lt $MinimumSizeBytes) {
        Write-LogError "File size too small: $FileSizeMB MB (minimum: $MinSizeMB MB)"
        return $false
    }
    
    Write-LogVerbose "File size acceptable: $FileSizeMB MB"
    return $true
}

function Test-ZipFileIntegrity {
    <#
    .SYNOPSIS
    Test ZIP file integrity and readability
    
    .PARAMETER ZipFilePath
    Path to the ZIP file to validate
    
    .PARAMETER ComponentName
    Name of the component for logging
    #>
    param(
        [string]$ZipFilePath,
        [string]$ComponentName = ""
    )
    
    if (-not (Test-FileExists $ZipFilePath $ComponentName)) { 
        return $false 
    }
    
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $ZipFile = [System.IO.Compression.ZipFile]::OpenRead($ZipFilePath)
        $EntryCount = $ZipFile.Entries.Count
        $ZipFile.Dispose()
        
        if ($EntryCount -eq 0) {
            Write-LogError "ZIP file is empty or corrupted"
            return $false
        }
        
        Write-LogVerbose "ZIP file integrity verified: $EntryCount entries"
        return $true
        
    } catch {
        Write-LogError "ZIP file validation failed: $($_.Exception.Message)"
        return $false
    }
}

function Test-FileIntegrity {
    <#
    .SYNOPSIS
    Comprehensive file integrity test
    
    .PARAMETER FilePath
    Path to the file to validate
    
    .PARAMETER MinimumSizeBytes
    Optional minimum size requirement
    #>
    param(
        [string]$FilePath,
        [long]$MinimumSizeBytes = 0
    )
    
    # Check existence
    if (-not (Test-FileExists $FilePath)) {
        return $false
    }
    
    # Check size if specified
    if ($MinimumSizeBytes -gt 0) {
        if (-not (Test-FileSize $FilePath $MinimumSizeBytes)) {
            return $false
        }
    }
    
    # Check ZIP integrity if it's a ZIP file
    if ($FilePath -match "\.zip$") {
        if (-not (Test-ZipFileIntegrity $FilePath)) {
            return $false
        }
    }
    
    return $true
}