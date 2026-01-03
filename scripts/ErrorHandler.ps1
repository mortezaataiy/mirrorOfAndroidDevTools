# Error Handler and Logging System
# مسئول مدیریت خطاها و لاگ‌گذاری

# تعریف انواع خطا
enum ErrorType {
    NetworkError
    FileError
    InstallError
    BuildError
    ValidationError
    ConfigurationError
}

# کلاس اطلاعات خطا
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

# متغیر سراسری برای ذخیره لاگ‌ها
$Global:ErrorLog = @()
$Global:ActivityLog = @()

# تابع لاگ‌گذاری عمومی
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
    
    # نمایش در کنسول با رنگ مناسب
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

# مدیریت خطا با استراتژی مناسب
function Handle-Error {
    param(
        [ErrorType]$ErrorType,
        [string]$ErrorMessage,
        [string]$Context = "",
        [hashtable]$Details = @{}
    )
    
    $errorInfo = [ErrorInfo]::new($ErrorType, $ErrorMessage, $Context)
    $errorInfo.Details = $Details
    
    Write-ActivityLog -Message "خطا رخ داد: $ErrorMessage" -Level "ERROR" -Context $Context
    
    switch ($ErrorType) {
        ([ErrorType]::NetworkError) {
            $errorInfo.ActionTaken = "تلاش مجدد تا ۳ بار"
            Write-ActivityLog -Message "خطای شبکه - آماده تلاش مجدد" -Level "WARNING"
        }
        ([ErrorType]::FileError) {
            $errorInfo.ActionTaken = "متوقف کردن فرایند و گزارش خطا"
            Write-ActivityLog -Message "خطای فایل - فرایند متوقف می‌شود" -Level "ERROR"
        }
        ([ErrorType]::InstallError) {
            $errorInfo.ActionTaken = "بررسی وابستگی‌ها و تلاش مجدد"
            Write-ActivityLog -Message "خطای نصب - بررسی پیش‌نیازها" -Level "WARNING"
        }
        ([ErrorType]::BuildError) {
            $errorInfo.ActionTaken = "نمایش جزئیات خطای کامپایل"
            Write-ActivityLog -Message "خطای بیلد - نمایش جزئیات" -Level "ERROR"
        }
        ([ErrorType]::ValidationError) {
            $errorInfo.ActionTaken = "بررسی مجدد پارامترهای ورودی"
            Write-ActivityLog -Message "خطای اعتبارسنجی - بررسی ورودی‌ها" -Level "WARNING"
        }
        ([ErrorType]::ConfigurationError) {
            $errorInfo.ActionTaken = "بازنشانی تنظیمات به حالت پیش‌فرض"
            Write-ActivityLog -Message "خطای پیکربندی - بازنشانی تنظیمات" -Level "WARNING"
        }
    }
    
    $Global:ErrorLog += $errorInfo
    return $errorInfo
}

# تلاش مجدد عملیات
function Retry-Operation {
    param(
        [scriptblock]$Operation,
        [int]$MaxAttempts = 3,
        [int]$DelaySeconds = 2,
        [string]$OperationName = "عملیات"
    )
    
    $attempt = 1
    while ($attempt -le $MaxAttempts) {
        try {
            Write-ActivityLog -Message "تلاش $attempt از $MaxAttempts برای $OperationName" -Level "INFO"
            
            $result = & $Operation
            
            Write-ActivityLog -Message "$OperationName با موفقیت انجام شد" -Level "SUCCESS"
            return $result
        }
        catch {
            $errorMsg = $_.Exception.Message
            Write-ActivityLog -Message "تلاش $attempt ناموفق: $errorMsg" -Level "WARNING"
            
            if ($attempt -eq $MaxAttempts) {
                Handle-Error -ErrorType ([ErrorType]::NetworkError) -ErrorMessage "عملیات پس از $MaxAttempts تلاش ناموفق بود: $errorMsg" -Context $OperationName
                throw $_
            }
            
            $attempt++
            if ($DelaySeconds -gt 0) {
                Write-ActivityLog -Message "انتظار $DelaySeconds ثانیه قبل از تلاش مجدد..." -Level "INFO"
                Start-Sleep -Seconds $DelaySeconds
            }
        }
    }
}

# نمایش خلاصه خطاها
function Show-ErrorSummary {
    Write-ActivityLog -Message "=== خلاصه خطاها ===" -Level "INFO"
    
    if ($Global:ErrorLog.Count -eq 0) {
        Write-ActivityLog -Message "هیچ خطایی رخ نداده است" -Level "SUCCESS"
        return
    }
    
    $errorGroups = $Global:ErrorLog | Group-Object Type
    foreach ($group in $errorGroups) {
        Write-ActivityLog -Message "$($group.Name): $($group.Count) خطا" -Level "WARNING"
    }
    
    Write-ActivityLog -Message "جمع کل خطاها: $($Global:ErrorLog.Count)" -Level "ERROR"
}

# نمایش خلاصه فعالیت‌ها
function Show-ActivitySummary {
    Write-ActivityLog -Message "=== خلاصه فعالیت‌ها ===" -Level "INFO"
    
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

# ذخیره لاگ‌ها در فایل
function Save-LogsToFile {
    param([string]$OutputPath = "logs")
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
    }
    
    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    
    # ذخیره لاگ فعالیت‌ها
    $activityLogPath = Join-Path $OutputPath "activity-$timestamp.json"
    $Global:ActivityLog | ConvertTo-Json -Depth 3 | Out-File -FilePath $activityLogPath -Encoding UTF8
    
    # ذخیره لاگ خطاها
    if ($Global:ErrorLog.Count -gt 0) {
        $errorLogPath = Join-Path $OutputPath "errors-$timestamp.json"
        $Global:ErrorLog | ConvertTo-Json -Depth 3 | Out-File -FilePath $errorLogPath -Encoding UTF8
    }
    
    Write-ActivityLog -Message "لاگ‌ها در $OutputPath ذخیره شدند" -Level "SUCCESS"
}

# پاک کردن لاگ‌ها
function Clear-Logs {
    $Global:ErrorLog = @()
    $Global:ActivityLog = @()
    Write-Host "🧹 لاگ‌ها پاک شدند" -ForegroundColor Green
}

# Export functions
Export-ModuleMember -Function Write-ActivityLog, Handle-Error, Retry-Operation, Show-ErrorSummary, Show-ActivitySummary, Save-LogsToFile, Clear-Logs