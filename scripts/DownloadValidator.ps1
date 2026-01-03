# Download Validator
# مسئول اعتبارسنجی لینک‌های دانلود و فایل‌های دانلود شده

# تست دسترسی به لینک دانلود
function Test-DownloadLink {
    param(
        [string]$Url,
        [int64]$MinSize = 1MB
    )
    
    Write-Host "🔗 تست لینک دانلود: $Url" -ForegroundColor Yellow
    
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
            Write-Warning "⚠️ فایل کوچک‌تر از حد مورد انتظار است: $([math]::Round($contentLength/1MB, 2)) MB"
        }
        
        Write-Host "✅ لینک معتبر است - اندازه: $([math]::Round($contentLength/1MB, 2)) MB" -ForegroundColor Green
        return $result
    }
    catch {
        Write-Error "❌ خطا در تست لینک: $($_.Exception.Message)"
        return @{
            Valid = $false
            Error = $_.Exception.Message
            Size = 0
            ContentType = ""
            StatusCode = 0
        }
    }
}

# دانلود فایل با اعتبارسنجی
function Download-FileWithValidation {
    param(
        [string]$Url,
        [string]$OutputPath,
        [int]$MaxRetries = 3
    )
    
    Write-Host "⬇️ شروع دانلود: $Url" -ForegroundColor Yellow
    
    $attempt = 1
    while ($attempt -le $MaxRetries) {
        try {
            Write-Host "📥 تلاش $attempt از $MaxRetries..." -ForegroundColor Cyan
            
            # ایجاد دایرکتوری در صورت عدم وجود
            $directory = Split-Path $OutputPath -Parent
            if (-not (Test-Path $directory)) {
                New-Item -ItemType Directory -Path $directory -Force | Out-Null
            }
            
            # دانلود فایل
            Invoke-WebRequest -Uri $Url -OutFile $OutputPath -TimeoutSec 300
            
            # بررسی وجود فایل
            if (Test-Path $OutputPath) {
                $fileSize = (Get-Item $OutputPath).Length
                Write-Host "✅ دانلود موفق - اندازه: $([math]::Round($fileSize/1MB, 2)) MB" -ForegroundColor Green
                
                return @{
                    Success = $true
                    FilePath = $OutputPath
                    FileSize = $fileSize
                    Attempts = $attempt
                }
            }
            else {
                throw "فایل دانلود نشد"
            }
        }
        catch {
            Write-Warning "⚠️ تلاش $attempt ناموفق: $($_.Exception.Message)"
            
            if ($attempt -eq $MaxRetries) {
                Write-Error "❌ دانلود پس از $MaxRetries تلاش ناموفق بود"
                return @{
                    Success = $false
                    Error = $_.Exception.Message
                    Attempts = $attempt
                }
            }
            
            $attempt++
            Start-Sleep -Seconds (2 * $attempt) # تأخیر تصاعدی
        }
    }
}

# تست یکپارچگی فایل ZIP
function Test-ZipFileIntegrity {
    param([string]$FilePath)
    
    Write-Host "🗜️ تست یکپارچگی فایل ZIP: $FilePath" -ForegroundColor Yellow
    
    try {
        # تست با .NET System.IO.Compression
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $zip = [System.IO.Compression.ZipFile]::OpenRead($FilePath)
        $entryCount = $zip.Entries.Count
        $zip.Dispose()
        
        Write-Host "✅ فایل ZIP معتبر است - $entryCount فایل داخلی" -ForegroundColor Green
        return @{
            Valid = $true
            EntryCount = $entryCount
        }
    }
    catch {
        Write-Error "❌ فایل ZIP خراب است: $($_.Exception.Message)"
        return @{
            Valid = $false
            Error = $_.Exception.Message
            EntryCount = 0
        }
    }
}

# اعتبارسنجی کامل فایل
function Test-FileValidation {
    param(
        [string]$FilePath,
        [string]$FileType = "auto"
    )
    
    Write-Host "🔍 اعتبارسنجی کامل فایل: $FilePath" -ForegroundColor Yellow
    
    if (-not (Test-Path $FilePath)) {
        return @{
            Valid = $false
            Error = "فایل وجود ندارد"
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
    
    # تشخیص نوع فایل
    if ($FileType -eq "auto") {
        $FileType = switch ($fileInfo.Extension.ToLower()) {
            ".zip" { "zip" }
            ".exe" { "exe" }
            ".msi" { "msi" }
            default { "unknown" }
        }
    }
    
    # تست‌های خاص برای هر نوع فایل
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
            # برای فایل‌های EXE می‌توان امضای دیجیتال را بررسی کرد
            $result.FileType = "executable"
        }
    }
    
    if ($result.Valid) {
        Write-Host "✅ فایل معتبر است" -ForegroundColor Green
    }
    else {
        Write-Error "❌ فایل نامعتبر است: $($result.Error)"
    }
    
    return $result
}

# Export functions
Export-ModuleMember -Function Test-DownloadLink, Download-FileWithValidation, Test-ZipFileIntegrity, Test-FileValidation