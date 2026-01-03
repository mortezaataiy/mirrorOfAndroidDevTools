# YAML Database Manager
# مسئول مدیریت فایل پایگاه داده ورژن‌ها

# Import required modules
. "$PSScriptRoot\ErrorHandler.ps1"

# تنظیمات پایگاه داده
$Global:DatabaseConfig = @{
    OutputFileName = "android-tools-versions.yml"
    BackupEnabled = $true
    MaxBackups = 5
}

# تبدیل hashtable به YAML
function ConvertTo-Yaml {
    param(
        [hashtable]$InputObject,
        [int]$Depth = 0
    )
    
    $indent = "  " * $Depth
    $yaml = ""
    
    foreach ($key in $InputObject.Keys) {
        $value = $InputObject[$key]
        
        if ($value -is [hashtable]) {
            $yaml += "$indent$key:`n"
            $yaml += ConvertTo-Yaml -InputObject $value -Depth ($Depth + 1)
        }
        elseif ($value -is [array]) {
            $yaml += "$indent$key:`n"
            foreach ($item in $value) {
                if ($item -is [hashtable]) {
                    $yaml += "$indent- `n"
                    $yaml += ConvertTo-Yaml -InputObject $item -Depth ($Depth + 1)
                }
                else {
                    $yaml += "$indent- $item`n"
                }
            }
        }
        elseif ($value -is [string]) {
            # Escape special characters in strings
            $escapedValue = $value -replace '"', '\"'
            if ($value -match '[\s:]' -or $value -match '^[0-9]') {
                $yaml += "$indent$key: `"$escapedValue`"`n"
            }
            else {
                $yaml += "$indent$key: $escapedValue`n"
            }
        }
        elseif ($value -is [bool]) {
            $yaml += "$indent$key: $($value.ToString().ToLower())`n"
        }
        elseif ($value -eq $null) {
            $yaml += "$indent$key: null`n"
        }
        else {
            $yaml += "$indent$key: $value`n"
        }
    }
    
    return $yaml
}

# تبدیل YAML به hashtable (ساده)
function ConvertFrom-Yaml {
    param([string]$YamlContent)
    
    $result = @{}
    $lines = $YamlContent -split "`n"
    $currentPath = @()
    
    foreach ($line in $lines) {
        $line = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($line) -or $line.StartsWith("#")) {
            continue
        }
        
        if ($line -match '^(\s*)([^:]+):\s*(.*)$') {
            $indent = $matches[1].Length
            $key = $matches[2].Trim()
            $value = $matches[3].Trim()
            
            # Adjust current path based on indentation
            $level = $indent / 2
            if ($level -lt $currentPath.Count) {
                $currentPath = $currentPath[0..($level-1)]
            }
            
            # Navigate to the correct nested level
            $current = $result
            foreach ($pathKey in $currentPath) {
                if (-not $current.ContainsKey($pathKey)) {
                    $current[$pathKey] = @{}
                }
                $current = $current[$pathKey]
            }
            
            if ([string]::IsNullOrWhiteSpace($value)) {
                # This is a parent key
                $current[$key] = @{}
                $currentPath += $key
            }
            else {
                # This is a value
                if ($value -eq "null") {
                    $current[$key] = $null
                }
                elseif ($value -eq "true") {
                    $current[$key] = $true
                }
                elseif ($value -eq "false") {
                    $current[$key] = $false
                }
                elseif ($value -match '^\d+$') {
                    $current[$key] = [int]$value
                }
                elseif ($value.StartsWith('"') -and $value.EndsWith('"')) {
                    $current[$key] = $value.Substring(1, $value.Length - 2)
                }
                else {
                    $current[$key] = $value
                }
            }
        }
    }
    
    return $result
}

# خواندن فایل YAML موجود
function Read-VersionDatabase {
    param([string]$FilePath)
    
    Write-ActivityLog -Message "خواندن پایگاه داده ورژن‌ها از $FilePath..." -Level "INFO"
    
    try {
        if (Test-Path $FilePath) {
            $yamlContent = Get-Content -Path $FilePath -Raw -Encoding UTF8
            $database = ConvertFrom-Yaml -YamlContent $yamlContent
            
            Write-ActivityLog -Message "پایگاه داده با موفقیت خوانده شد" -Level "SUCCESS"
            return $database
        }
        else {
            Write-ActivityLog -Message "فایل پایگاه داده وجود ندارد - ایجاد پایگاه داده جدید" -Level "INFO"
            return @{}
        }
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::FileError) -ErrorMessage $_.Exception.Message -Context "Database Read"
        return @{}
    }
}

# ایجاد پشتیبان از فایل موجود
function New-DatabaseBackup {
    param([string]$FilePath)
    
    if (-not (Test-Path $FilePath)) {
        return
    }
    
    try {
        $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
        $backupPath = "$FilePath.backup-$timestamp"
        
        Copy-Item -Path $FilePath -Destination $backupPath -Force
        Write-ActivityLog -Message "پشتیبان ایجاد شد: $backupPath" -Level "SUCCESS"
        
        # پاک کردن پشتیبان‌های قدیمی
        $backupFiles = Get-ChildItem -Path (Split-Path $FilePath) -Filter "*.backup-*" | Sort-Object LastWriteTime -Descending
        if ($backupFiles.Count -gt $Global:DatabaseConfig.MaxBackups) {
            $filesToDelete = $backupFiles | Select-Object -Skip $Global:DatabaseConfig.MaxBackups
            foreach ($file in $filesToDelete) {
                Remove-Item $file.FullName -Force
                Write-ActivityLog -Message "پشتیبان قدیمی حذف شد: $($file.Name)" -Level "INFO"
            }
        }
    }
    catch {
        Write-ActivityLog -Message "خطا در ایجاد پشتیبان: $($_.Exception.Message)" -Level "WARNING"
    }
}

# به‌روزرسانی پایگاه داده ورژن‌ها
function Update-VersionDatabase {
    param(
        [array]$Tools,
        [string]$OutputPath = ".",
        [hashtable]$TestResults = @{},
        [bool]$HelloWorldBuildSuccess = $false
    )
    
    Write-ActivityLog -Message "به‌روزرسانی پایگاه داده ورژن‌ها..." -Level "INFO"
    
    try {
        $filePath = Join-Path $OutputPath $Global:DatabaseConfig.OutputFileName
        
        # خواندن پایگاه داده موجود
        $existingDatabase = Read-VersionDatabase -FilePath $filePath
        
        # ایجاد پشتیبان
        if ($Global:DatabaseConfig.BackupEnabled) {
            New-DatabaseBackup -FilePath $filePath
        }
        
        # ایجاد ساختار جدید پایگاه داده
        $newDatabase = @{
            metadata = @{
                last_updated = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
                tested_on = "windows-latest"
                test_result = if ($HelloWorldBuildSuccess) { "success" } else { "failed" }
                hello_world_build = $HelloWorldBuildSuccess
                total_tools = $Tools.Count
                successful_installs = ($Tools | Where-Object { $_.TestStatus -eq "installed" }).Count
            }
            tools = @{}
        }
        
        # حفظ اطلاعات قبلی در صورت وجود
        if ($existingDatabase.ContainsKey("tools")) {
            $newDatabase.tools = $existingDatabase.tools.Clone()
        }
        
        # به‌روزرسانی اطلاعات ابزارها
        foreach ($tool in $Tools) {
            $toolKey = $tool.Name.ToLower()
            
            $toolInfo = @{
                name = $tool.Name
                version = $tool.Version
                download_url = $tool.DownloadUrl
                file_type = $tool.FileType
                file_size = if ($tool.FileSize) { $tool.FileSize } else { 0 }
                install_path = if ($tool.InstallPath) { $tool.InstallPath } else { "" }
                test_status = $tool.TestStatus
                test_date = $tool.TestDate.ToString("yyyy-MM-dd HH:mm:ss")
                last_successful_test = ""
            }
            
            # حفظ تاریخ آخرین تست موفق
            if ($existingDatabase.ContainsKey("tools") -and $existingDatabase.tools.ContainsKey($toolKey)) {
                $existingTool = $existingDatabase.tools[$toolKey]
                if ($existingTool.ContainsKey("last_successful_test")) {
                    $toolInfo.last_successful_test = $existingTool.last_successful_test
                }
            }
            
            # به‌روزرسانی تاریخ آخرین تست موفق
            if ($tool.TestStatus -eq "installed") {
                $toolInfo.last_successful_test = $tool.TestDate.ToString("yyyy-MM-dd HH:mm:ss")
            }
            
            # اضافه کردن جزئیات خطا در صورت وجود
            if ($TestResults.ContainsKey($tool.Name) -and $TestResults[$tool.Name].ContainsKey("Error")) {
                $toolInfo.error_details = $TestResults[$tool.Name].Error
            }
            
            $newDatabase.tools[$toolKey] = $toolInfo
        }
        
        # اضافه کردن آمار کلی
        $newDatabase.statistics = @{
            total_tests_run = if ($existingDatabase.ContainsKey("statistics")) { $existingDatabase.statistics.total_tests_run + 1 } else { 1 }
            successful_tests = if ($HelloWorldBuildSuccess -and $existingDatabase.ContainsKey("statistics")) { $existingDatabase.statistics.successful_tests + 1 } elseif ($HelloWorldBuildSuccess) { 1 } elseif ($existingDatabase.ContainsKey("statistics")) { $existingDatabase.statistics.successful_tests } else { 0 }
            last_success_date = if ($HelloWorldBuildSuccess) { Get-Date -Format "yyyy-MM-dd HH:mm:ss" } elseif ($existingDatabase.ContainsKey("statistics")) { $existingDatabase.statistics.last_success_date } else { "" }
        }
        
        # تبدیل به YAML و ذخیره
        $yamlContent = ConvertTo-Yaml -InputObject $newDatabase
        $yamlContent | Out-File -FilePath $filePath -Encoding UTF8
        
        Write-ActivityLog -Message "پایگاه داده در $filePath ذخیره شد" -Level "SUCCESS"
        
        # نمایش خلاصه تغییرات
        Show-DatabaseSummary -Database $newDatabase
        
        return @{
            Success = $true
            FilePath = $filePath
            ToolsCount = $Tools.Count
            SuccessfulInstalls = $newDatabase.metadata.successful_installs
        }
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::FileError) -ErrorMessage $_.Exception.Message -Context "Database Update"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# نمایش خلاصه پایگاه داده
function Show-DatabaseSummary {
    param([hashtable]$Database)
    
    Write-ActivityLog -Message "=== خلاصه پایگاه داده ===" -Level "INFO"
    
    if ($Database.ContainsKey("metadata")) {
        $metadata = $Database.metadata
        Write-ActivityLog -Message "آخرین به‌روزرسانی: $($metadata.last_updated)" -Level "INFO"
        Write-ActivityLog -Message "نتیجه تست: $($metadata.test_result)" -Level "INFO"
        Write-ActivityLog -Message "بیلد Hello World: $($metadata.hello_world_build)" -Level "INFO"
        Write-ActivityLog -Message "تعداد ابزارها: $($metadata.total_tools)" -Level "INFO"
        Write-ActivityLog -Message "نصب‌های موفق: $($metadata.successful_installs)" -Level "INFO"
    }
    
    if ($Database.ContainsKey("tools")) {
        Write-ActivityLog -Message "--- جزئیات ابزارها ---" -Level "INFO"
        foreach ($toolKey in $Database.tools.Keys) {
            $tool = $Database.tools[$toolKey]
            $status = if ($tool.test_status -eq "installed") { "✅" } else { "❌" }
            Write-ActivityLog -Message "$status $($tool.name) v$($tool.version) - $($tool.test_status)" -Level "INFO"
        }
    }
    
    if ($Database.ContainsKey("statistics")) {
        $stats = $Database.statistics
        Write-ActivityLog -Message "--- آمار کلی ---" -Level "INFO"
        Write-ActivityLog -Message "تعداد کل تست‌ها: $($stats.total_tests_run)" -Level "INFO"
        Write-ActivityLog -Message "تست‌های موفق: $($stats.successful_tests)" -Level "INFO"
        if ($stats.last_success_date) {
            Write-ActivityLog -Message "آخرین موفقیت: $($stats.last_success_date)" -Level "INFO"
        }
    }
}

# اعتبارسنجی فایل YAML
function Test-YamlFile {
    param([string]$FilePath)
    
    Write-ActivityLog -Message "اعتبارسنجی فایل YAML: $FilePath" -Level "INFO"
    
    try {
        if (-not (Test-Path $FilePath)) {
            throw "فایل وجود ندارد"
        }
        
        $content = Get-Content -Path $FilePath -Raw -Encoding UTF8
        $parsed = ConvertFrom-Yaml -YamlContent $content
        
        # بررسی ساختار مورد انتظار
        $requiredKeys = @("metadata", "tools")
        foreach ($key in $requiredKeys) {
            if (-not $parsed.ContainsKey($key)) {
                throw "کلید مورد انتظار '$key' وجود ندارد"
            }
        }
        
        Write-ActivityLog -Message "فایل YAML معتبر است" -Level "SUCCESS"
        return @{
            Valid = $true
            Content = $parsed
        }
    }
    catch {
        Write-ActivityLog -Message "فایل YAML نامعتبر است: $($_.Exception.Message)" -Level "ERROR"
        return @{
            Valid = $false
            Error = $_.Exception.Message
        }
    }
}

# Export functions
Export-ModuleMember -Function ConvertTo-Yaml, ConvertFrom-Yaml, Read-VersionDatabase, Update-VersionDatabase, Show-DatabaseSummary, Test-YamlFile