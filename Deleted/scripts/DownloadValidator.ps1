# Download Validator
# Responsible for validating download links and downloaded files

# Test download link accessibility
function Test-DownloadLink {
    param(
        [string]$Url,
        [int64]$MinSize = 1MB
    )
    
    Write-Host "🔗 Testing download link: $Url" -ForegroundColor Yellow
    
    try {
        $response = Invoke-WebRequest -Uri $Url -Method Head -TimeoutSec 30
        $contentLength = 0
        
        if ($response.Headers.'Content-Length') {
            $contentLength = [int64]$response.Headers.'Content-Length'[0]
        }
        
        $result = @{
            Valid = $true
            Size = $contentLength
            ContentType = $response.Headers.'Content-Type'[0]
            StatusCode = $response.StatusCode
        }
        
        if ($contentLength -gt 0 -and $contentLength -lt $MinSize) {
            Write-Warning "⚠️ File is smaller than expected: $([math]::Round($contentLength/1MB, 2)) MB"
        }
        
        Write-Host "✅ Link is valid - Size: $([math]::Round($contentLength/1MB, 2)) MB" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "❌ Error testing link: $($_.Exception.Message)"
        return @{
            Valid = $false
            Error = $_.Exception.Message
            Size = 0
            ContentType = ""
            StatusCode = 0
        }
    }
}

# Download file with validation
function Download-FileWithValidation {
    param(
        [string]$Url,
        [string]$OutputPath,
        [int]$MaxRetries = 3
    )
    
    Write-Host "⬇️ Starting download: $Url" -ForegroundColor Yellow
    
    $attempt = 1
    while ($attempt -le $MaxRetries) {
        try {
            Write-Host "📥 Attempt $attempt of $MaxRetries..." -ForegroundColor Cyan
            
            # Create directory if it doesn't exist
            $directory = Split-Path $OutputPath -Parent
            if (-not (Test-Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
            
            # Download file
            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -TimeoutSec 300
            
            # Check if file exists
            if (Test-Path $OutputPath) {
                $fileSize = (Get-Item $OutputPath).Length
                Write-Host "✅ Download successful - Size: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Green
                
                return @{
                    Success = $true
                    FilePath = $OutputPath
                    FileSize = $fileSize
                    Attempts = $attempt
                }
            }
            else {
                throw "File was not downloaded"
            }
        }
        catch {
            Write-Warning "⚠️ Attempt $attempt failed: $($_.Exception.Message)"
            
            if ($attempt -eq $MaxRetries) {
                Write-Error "❌ Download failed after $MaxRetries attempts"
                return @{
                    Success = $false
                    Error = $_.Exception.Message
                    Attempts = $attempt
                }
            }
            
            $attempt++
            Start-Sleep -Seconds (2 * $attempt) # Exponential backoff
        }
    }
}

# Test ZIP file integrity
function Test-ZipFileIntegrity {
    param([string]$FilePath)
    
    Write-Host "🗜️ Testing ZIP file integrity: $FilePath" -ForegroundColor Yellow
    
    try {
        # Test with .NET System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)
        $entryCount = $zip.Entries.Count
        $zip.Dispose()
        
        Write-Host "✅ ZIP file is valid - $entryCount internal files" -ForegroundColor Green
        return @{
            Valid = $true
            EntryCount = $entryCount
        }
    }
    catch {
        Write-Error "❌ ZIP file is corrupted: $($_.Exception.Message)"
        return @{
            Valid = $false
            Error = $_.Exception.Message
            EntryCount = 0
        }
    }
}

# Complete file validation
function Test-FileValidation {
    param(
        [string]$FilePath,
        [string]$FileType = "auto"
    )
    
    Write-Host "🔍 Complete file validation: $FilePath" -ForegroundColor Yellow
    
    if (-not (Test-Path $FilePath)) {
        return @{
            Valid = $false
            Error = "File does not exist"
        }
    }
    
    $fileInfo = Get-Item $FilePath
    $result = @{
        Valid = $true
        FileName = $fileInfo.Name
        FileSize = $fileInfo.Length
        Extension = $fileInfo.Extension
        LastWriteTime = $fileInfo.LastWriteTime
    }
    
    # Auto-detect file type
    if ($FileType -eq "auto") {
        $FileType = switch ($fileInfo.Extension.ToLower()) {
            ".zip" { "zip" }
            ".exe" { "exe" }
            ".msi" { "msi" }
            default { "unknown" }
        }
    }
    
    # Specific tests for each file type
    switch ($FileType) {
        "zip" {
            $zipTest = Test-ZipFileIntegrity -FilePath $FilePath
            $result.ZipValid = $zipTest.Valid
            $result.ZipEntryCount = $zipTest.EntryCount
            if (-not $zipTest.Valid) {
                $result.Valid = $false
                $result.Error = $zipTest.Error
            }
        }
        "exe" {
            # For EXE files, digital signature can be checked
            $result.FileType = "executable"
        }
    }
    
    if ($result.Valid) {
        Write-Host "✅ File is valid" -ForegroundColor Green
    }
    else {
        Write-Error "❌ File is invalid: $($result.Error)"
    }
    
    return $result
}

# Export functions
Export-ModuleMember -Function Test-DownloadLink, Download-FileWithValidation, Test-ZipFileIntegrity, Test-FileValidation