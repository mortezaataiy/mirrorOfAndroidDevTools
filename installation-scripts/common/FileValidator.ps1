# FileValidator.ps1 - Simple File Validation

function Test-FileExists {
    param([string]$FilePath, [string]$ComponentName = "")
    if (-not (Test-Path $FilePath)) {
        Write-ErrorLog "File not found: $FilePath" $ComponentName
        return $false
    }
    Write-InfoLog "File exists: $FilePath" $ComponentName
    return $true
}

function Test-FileSize {
    param([string]$FilePath, [long]$MinimumSizeBytes, [string]$ComponentName = "")
    if (-not (Test-FileExists $FilePath $ComponentName)) { return $false }
    
    $fileInfo = Get-Item $FilePath
    if ($fileInfo.Length -lt $MinimumSizeBytes) {
        Write-ErrorLog "File size too small: $($fileInfo.Length) bytes" $ComponentName
        return $false
    }
    Write-InfoLog "File size OK: $($fileInfo.Length) bytes" $ComponentName
    return $true
}

function Test-ZipFileIntegrity {
    param([string]$ZipFilePath, [string]$ComponentName = "")
    if (-not (Test-FileExists $ZipFilePath $ComponentName)) { return $false }
    
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($ZipFilePath)
        $entryCount = $zip.Entries.Count
        $zip.Dispose()
        
        if ($entryCount -eq 0) {
            Write-ErrorLog "ZIP file is empty" $ComponentName
            return $false
        }
        
        Write-InfoLog "ZIP file is valid with $entryCount entries" $ComponentName
        return $true
    }
    catch {
        Write-ErrorLog "ZIP file validation failed: $($_.Exception.Message)" $ComponentName
        return $false
    }
}

