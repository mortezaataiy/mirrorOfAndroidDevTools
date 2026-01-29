# EnvironmentManager.ps1 - سیستم مدیریت متغیرهای محیطی
# این فایل توابع مشترک برای مدیریت متغیرهای محیطی و PATH فراهم می‌کند

# وارد کردن Logger
. "$PSScriptRoot\Logger.ps1"

function Add-ToPath {
    param(
        [string]$NewPath,
        [string]$Scope = "User",  # User یا Machine
        [string]$ComponentName = ""
    )
    
    if (-not (Test-Path $NewPath)) {
        Write-ErrorLog "مسیر برای اضافه کردن به PATH وجود ندارد: $NewPath" $ComponentName
        return $false
    }
    
    try {
        # دریافت PATH فعلی
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Scope)
        
        # بررسی اینکه آیا مسیر قبلاً اضافه شده یا نه
        $pathArray = $currentPath -split ';' | Where-Object { $_ -ne '' }
        
        if ($NewPath -in $pathArray) {
            Write-InfoLog "مسیر قبلاً در PATH موجود است: $NewPath" $ComponentName
            return $true
        }
        
        # اضافه کردن مسیر جدید
        $newPathValue = $currentPath + ";" + $NewPath
        [Environment]::SetEnvironmentVariable("PATH", $newPathValue, $Scope)
        
        Write-InfoLog "مسیر به PATH اضافه شد: $NewPath" $ComponentName
        return $true
    }
    catch {
        Write-ErrorLog "خطا در اضافه کردن مسیر به PATH: $($_.Exception.Message)" $ComponentName
        return $false
    }
}

function Remove-FromPath {
    param(
        [string]$PathToRemove,
        [string]$Scope = "User",
        [string]$ComponentName = ""
    )
    
    try {
        # دریافت PATH فعلی
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Scope)
        
        # حذف مسیر از PATH
        $pathArray = $currentPath -split ';' | Where-Object { $_ -ne '' -and $_ -ne $PathToRemove }
        $newPathValue = $pathArray -join ';'
        
        [Environment]::SetEnvironmentVariable("PATH", $newPathValue, $Scope)
        
        Write-InfoLog "مسیر از PATH حذف شد: $PathToRemove" $ComponentName
        return $true
    }
    catch {
        Write-ErrorLog "خطا در حذف مسیر از PATH: $($_.Exception.Message)" $ComponentName
        return $false
    }
}

function Set-EnvironmentVariable {
    param(
        [string]$Name,
        [string]$Value,
        [string]$Scope = "User",
        [string]$ComponentName = ""
    )
    
    try {
        [Environment]::SetEnvironmentVariable($Name, $Value, $Scope)
        Write-InfoLog "متغیر محیطی تنظیم شد: $Name = $Value" $ComponentName
        return $true
    }
    catch {
        Write-ErrorLog "خطا در تنظیم متغیر محیطی: $($_.Exception.Message)" $ComponentName
        return $false
    }
}

function Get-EnvironmentVariable {
    param(
        [string]$Name,
        [string]$Scope = "User",
        [string]$ComponentName = ""
    )
    
    try {
        $value = [Environment]::GetEnvironmentVariable($Name, $Scope)
        if ($value) {
            Write-InfoLog "متغیر محیطی خوانده شد: $Name = $value" $ComponentName
        } else {
            Write-WarnLog "متغیر محیطی یافت نشد: $Name" $ComponentName
        }
        return $value
    }
    catch {
        Write-ErrorLog "خطا در خواندن متغیر محیطی: $($_.Exception.Message)" $ComponentName
        return $null
    }
}

function Test-PathExists {
    param(
        [string]$PathToCheck,
        [string]$Scope = "User",
        [string]$ComponentName = ""
    )
    
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", $Scope)
    $pathArray = $currentPath -split ';' | Where-Object { $_ -ne '' }
    
    $exists = $PathToCheck -in $pathArray
    
    if ($exists) {
        Write-InfoLog "مسیر در PATH موجود است: $PathToCheck" $ComponentName
    } else {
        Write-InfoLog "مسیر در PATH موجود نیست: $PathToCheck" $ComponentName
    }
    
    return $exists
}

function Backup-EnvironmentVariables {
    param(
        [string[]]$VariableNames,
        [string]$BackupPath,
        [string]$ComponentName = ""
    )
    
    try {
        $backup = @{}
        
        foreach ($varName in $VariableNames) {
            $userValue = [Environment]::GetEnvironmentVariable($varName, "User")
            $machineValue = [Environment]::GetEnvironmentVariable($varName, "Machine")
            
            $backup[$varName] = @{
                User = $userValue
                Machine = $machineValue
            }
        }
        
        # ذخیره PATH جداگانه
        $backup["PATH"] = @{
            User = [Environment]::GetEnvironmentVariable("PATH", "User")
            Machine = [Environment]::GetEnvironmentVariable("PATH", "Machine")
        }
        
        # تبدیل به JSON و ذخیره
        $backupJson = $backup | ConvertTo-Json -Depth 3
        $backupJson | Out-File -FilePath $BackupPath -Encoding UTF8
        
        Write-InfoLog "پشتیبان‌گیری از متغیرهای محیطی انجام شد: $BackupPath" $ComponentName
        return $true
    }
    catch {
        Write-ErrorLog "خطا در پشتیبان‌گیری از متغیرهای محیطی: $($_.Exception.Message)" $ComponentName
        return $false
    }
}

function Restore-EnvironmentVariables {
    param(
        [string]$BackupPath,
        [string]$ComponentName = ""
    )
    
    if (-not (Test-Path $BackupPath)) {
        Write-ErrorLog "فایل پشتیبان یافت نشد: $BackupPath" $ComponentName
        return $false
    }
    
    try {
        $backupContent = Get-Content $BackupPath -Raw | ConvertFrom-Json
        
        foreach ($varName in $backupContent.PSObject.Properties.Name) {
            $varData = $backupContent.$varName
            
            # بازیابی User scope
            if ($varData.User) {
                [Environment]::SetEnvironmentVariable($varName, $varData.User, "User")
            } else {
                [Environment]::SetEnvironmentVariable($varName, $null, "User")
            }
            
            # بازیابی Machine scope (نیاز به مجوز Administrator)
            try {
                if ($varData.Machine) {
                    [Environment]::SetEnvironmentVariable($varName, $varData.Machine, "Machine")
                } else {
                    [Environment]::SetEnvironmentVariable($varName, $null, "Machine")
                }
            }
            catch {
                Write-WarnLog "نتوانست متغیر Machine scope را بازیابی کند: $varName (نیاز به مجوز Administrator)" $ComponentName
            }
        }
        
        Write-InfoLog "بازیابی متغیرهای محیطی انجام شد: $BackupPath" $ComponentName
        return $true
    }
    catch {
        Write-ErrorLog "خطا در بازیابی متغیرهای محیطی: $($_.Exception.Message)" $ComponentName
        return $false
    }
}

function Get-EnvironmentReport {
    param(
        [string[]]$VariableNames = @("JAVA_HOME", "ANDROID_HOME", "ANDROID_SDK_ROOT", "GRADLE_HOME"),
        [string]$ComponentName = ""
    )
    
    $report = @{
        Variables = @{}
        PathEntries = @()
        Timestamp = Get-Date
    }
    
    # بررسی متغیرهای مشخص شده
    foreach ($varName in $VariableNames) {
        $userValue = [Environment]::GetEnvironmentVariable($varName, "User")
        $machineValue = [Environment]::GetEnvironmentVariable($varName, "Machine")
        
        $report.Variables[$varName] = @{
            User = $userValue
            Machine = $machineValue
            Effective = if ($userValue) { $userValue } else { $machineValue }
        }
    }
    
    # بررسی PATH
    $userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $machinePath = [Environment]::GetEnvironmentVariable("PATH", "Machine")
    
    $allPathEntries = @()
    if ($machinePath) { $allPathEntries += $machinePath -split ';' }
    if ($userPath) { $allPathEntries += $userPath -split ';' }
    
    $report.PathEntries = $allPathEntries | Where-Object { $_ -ne '' } | Sort-Object -Unique
    
    return $report
}

function Test-AdminPrivileges {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Export functions
Export-ModuleMember -Function Add-ToPath, Remove-FromPath, Set-EnvironmentVariable, Get-EnvironmentVariable, Test-PathExists, Backup-EnvironmentVariables, Restore-EnvironmentVariables, Get-EnvironmentReport, Test-AdminPrivileges