# راهنمای عیب‌یابی Android Development Tools

## مقدمه

این راهنما شامل راه‌حل‌های رایج‌ترین مشکلات نصب و تنظیم Android Development Tools است. در صورت مواجهه با مشکل، ابتدا این راهنما را مطالعه کنید.

## خطاهای رایج و راه‌حل‌ها

### 1. خطاهای مربوط به JDK

#### مشکل: `java -version` کار نمی‌کند
**علت:** متغیر محیطی JAVA_HOME تنظیم نشده یا PATH اشتباه است

**راه‌حل:**
```powershell
# بررسی متغیر JAVA_HOME
echo $env:JAVA_HOME

# تنظیم مجدد JAVA_HOME
[Environment]::SetEnvironmentVariable("JAVA_HOME", "D:\Android\JDK17", "User")

# بررسی PATH
echo $env:PATH | Select-String "JDK17"
```

#### مشکل: خطای "JAVA_HOME is not set"
**علت:** متغیر JAVA_HOME تعریف نشده

**راه‌حل:**
1. کنترل پنل → System → Advanced System Settings
2. Environment Variables → New (User variables)
3. Variable name: `JAVA_HOME`
4. Variable value: `D:\Android\JDK17`

### 2. خطاهای مربوط به Gradle

#### مشکل: `gradle -v` کار نمی‌کند
**علت:** Gradle در PATH تنظیم نشده

**راه‌حل:**
```powershell
# بررسی PATH
echo $env:PATH | Select-String "Gradle"

# افزودن به PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$newPath = $currentPath + ";D:\Android\Gradle\bin"
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
```

#### مشکل: خطای "Could not find or load main class org.gradle.wrapper.GradleWrapperMain"
**علت:** فایل‌های Gradle کامل نیست یا مسیر اشتباه

**راه‌حل:**
1. بررسی وجود فایل `gradle-wrapper.jar`
2. بازنصب Gradle از فایل ZIP
3. تأیید مسیر صحیح در PATH

### 3. خطاهای مربوط به Android SDK

#### مشکل: `sdkmanager --list` کار نمی‌کند
**علت:** Command Line Tools نصب نشده یا ANDROID_HOME تنظیم نشده

**راه‌حل:**
```powershell
# تنظیم ANDROID_HOME
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "User")

# بررسی مسیر cmdline-tools
Test-Path "D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
```

#### مشکل: خطای "Warning: Could not create settings"
**علت:** پوشه .android در home directory وجود ندارد

**راه‌حل:**
```powershell
# ایجاد پوشه .android
New-Item -ItemType Directory -Path "$env:USERPROFILE\.android" -Force

# ایجاد فایل repositories.cfg
New-Item -ItemType File -Path "$env:USERPROFILE\.android\repositories.cfg" -Force
```

### 4. خطاهای مربوط به ADB

#### مشکل: `adb version` کار نمی‌کند
**علت:** Platform Tools در PATH نیست

**راه‌حل:**
```powershell
# افزودن platform-tools به PATH
$currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
$newPath = $currentPath + ";D:\Android\Sdk\platform-tools"
[Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
```

#### مشکل: "adb server didn't ACK"
**علت:** پورت ADB اشغال شده

**راه‌حل:**
```powershell
# متوقف کردن ADB server
adb kill-server

# راه‌اندازی مجدد
adb start-server
```

### 5. خطاهای مربوط به Build Tools

#### مشکل: "aapt not found"
**علت:** Build Tools نصب نشده یا مسیر اشتباه

**راه‌حل:**
1. بررسی وجود فایل aapt:
```powershell
Test-Path "D:\Android\Sdk\build-tools\33.0.2\aapt.exe"
```

2. در صورت عدم وجود، بازنصب Build Tools

### 6. خطاهای مربوط به Emulator

#### مشکل: "emulator: ERROR: x86 emulation currently requires hardware acceleration!"
**علت:** Intel HAXM نصب نشده یا فعال نیست

**راه‌حل:**
1. فعال کردن Virtualization در BIOS
2. نصب Intel HAXM از SDK Manager
3. استفاده از ARM system image

#### مشکل: "No AVDs available"
**علت:** هیچ Android Virtual Device ایجاد نشده

**راه‌حل:**
```powershell
# ایجاد AVD جدید
avdmanager create avd -n "TestAVD" -k "system-images;android-33;google_apis;x86_64"
```

### 7. خطاهای مربوط به Licenses

#### مشکل: "You have not accepted the license agreements"
**علت:** لایسنس‌های SDK پذیرفته نشده

**راه‌حل:**
```powershell
# پذیرش خودکار لایسنس‌ها
echo y | sdkmanager --licenses
```

### 8. خطاهای مربوط به متغیرهای محیطی

#### مشکل: متغیرهای محیطی پس از restart از بین می‌روند
**علت:** متغیرها در سطح User تنظیم نشده‌اند

**راه‌حل:**
```powershell
# تنظیم دائمی متغیرها
[Environment]::SetEnvironmentVariable("JAVA_HOME", "D:\Android\JDK17", "User")
[Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "User")
[Environment]::SetEnvironmentVariable("GRADLE_HOME", "D:\Android\Gradle", "User")
```

### 9. خطاهای مربوط به دسترسی‌ها (Permissions)

#### مشکل: "Access denied" هنگام نصب
**علت:** عدم دسترسی Administrator

**راه‌حل:**
1. اجرای PowerShell به عنوان Administrator
2. تغییر مالکیت پوشه:
```powershell
takeown /f "D:\Android" /r /d y
icacls "D:\Android" /grant "$env:USERNAME:(OI)(CI)F" /t
```

### 10. خطاهای مربوط به فایل‌های ZIP

#### مشکل: "The archive is either in unknown format or damaged"
**علت:** فایل ZIP خراب یا ناقص دانلود شده

**راه‌حل:**
1. بررسی اندازه فایل با مقدار مورد انتظار
2. دانلود مجدد فایل
3. استفاده از ابزار تعمیر ZIP

## بررسی سیستماتیک مشکلات

### مرحله 1: بررسی پایه
```powershell
# بررسی وجود پوشه‌های اصلی
Test-Path "D:\Android\JDK17"
Test-Path "D:\Android\Gradle"
Test-Path "D:\Android\Sdk"

# بررسی متغیرهای محیطی
echo "JAVA_HOME: $env:JAVA_HOME"
echo "ANDROID_HOME: $env:ANDROID_HOME"
echo "GRADLE_HOME: $env:GRADLE_HOME"
```

### مرحله 2: بررسی دستورات پایه
```powershell
# تست دستورات اصلی
java -version
gradle -v
adb version
sdkmanager --version
```

### مرحله 3: بررسی PATH
```powershell
# نمایش PATH کامل
$env:PATH -split ';' | Where-Object { $_ -like "*Android*" -or $_ -like "*JDK*" -or $_ -like "*Gradle*" }
```

## ابزارهای تشخیص مشکل

### اسکریپت تشخیص خودکار
```powershell
# ایجاد اسکریپت تشخیص
function Test-AndroidEnvironment {
    Write-Host "=== بررسی محیط Android Development ===" -ForegroundColor Green
    
    # بررسی JDK
    if (Test-Path $env:JAVA_HOME) {
        Write-Host "✓ JAVA_HOME تنظیم شده: $env:JAVA_HOME" -ForegroundColor Green
        try {
            $javaVersion = java -version 2>&1 | Select-Object -First 1
            Write-Host "✓ Java Version: $javaVersion" -ForegroundColor Green
        } catch {
            Write-Host "✗ خطا در اجرای java -version" -ForegroundColor Red
        }
    } else {
        Write-Host "✗ JAVA_HOME تنظیم نشده" -ForegroundColor Red
    }
    
    # بررسی Android SDK
    if (Test-Path $env:ANDROID_HOME) {
        Write-Host "✓ ANDROID_HOME تنظیم شده: $env:ANDROID_HOME" -ForegroundColor Green
    } else {
        Write-Host "✗ ANDROID_HOME تنظیم نشده" -ForegroundColor Red
    }
    
    # بررسی Gradle
    try {
        $gradleVersion = gradle -v 2>&1 | Select-Object -First 1
        Write-Host "✓ Gradle: $gradleVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ Gradle در دسترس نیست" -ForegroundColor Red
    }
    
    # بررسی ADB
    try {
        $adbVersion = adb version 2>&1 | Select-Object -First 1
        Write-Host "✓ ADB: $adbVersion" -ForegroundColor Green
    } catch {
        Write-Host "✗ ADB در دسترس نیست" -ForegroundColor Red
    }
}

# اجرای تست
Test-AndroidEnvironment
```

## راهنمای بازنصب سریع

### بازنصب کامل
1. حذف پوشه `D:\Android`
2. پاک کردن متغیرهای محیطی
3. اجرای مجدد اسکریپت نصب

### بازنصب جزئی
```powershell
# بازنصب فقط JDK
Remove-Item "D:\Android\JDK17" -Recurse -Force
# سپس نصب مجدد از فایل ZIP

# بازنصب فقط SDK
Remove-Item "D:\Android\Sdk" -Recurse -Force
# سپس نصب مجدد کامپوننت‌های SDK
```

## تماس برای پشتیبانی

در صورت ادامه مشکل پس از اجرای راه‌حل‌های فوق:

1. اسکریپت تشخیص را اجرا کنید
2. خروجی کامل را ذخیره کنید
3. فایل لاگ خطا را ضمیمه کنید
4. مشخصات سیستم‌عامل را اعلام کنید

## نکات پیشگیری

### قبل از نصب
- Antivirus را موقتاً غیرفعال کنید
- فضای کافی روی دیسک داشته باشید (حداقل 10GB)
- دسترسی Administrator داشته باشید

### بعد از نصب
- Backup از متغیرهای محیطی بگیرید
- تست کامل محیط توسعه انجام دهید
- مستندات نصب را نگه دارید

---

*این راهنما بر اساس تجربیات رایج کاربران تهیه شده و به‌روزرسانی خواهد شد.*

## راهنمای بررسی لاگ‌ها

### مکان‌های مهم لاگ‌ها

#### 1. لاگ‌های Android Studio
```
%USERPROFILE%\.AndroidStudio2022.3\system\log\
```

فایل‌های مهم:
- `idea.log` - لاگ اصلی Android Studio
- `build.log` - لاگ‌های بیلد پروژه

#### 2. لاگ‌های Gradle
```
%USERPROFILE%\.gradle\daemon\
%PROJECT_DIR%\build\reports\
```

فایل‌های مهم:
- `daemon-*.out.log` - لاگ‌های Gradle daemon
- `build/reports/` - گزارش‌های بیلد

#### 3. لاگ‌های SDK Manager
```powershell
# اجرای SDK Manager با لاگ کامل
sdkmanager --verbose --list > sdkmanager.log 2>&1
```

#### 4. لاگ‌های ADB
```powershell
# فعال کردن لاگ‌های ADB
set ADB_TRACE=all
adb logcat > adb.log
```

### نحوه بررسی لاگ‌های خطا

#### بررسی لاگ‌های PowerShell
```powershell
# نمایش آخرین خطاها
Get-EventLog -LogName Application -EntryType Error -Newest 10

# جستجوی خطاهای مربوط به Java
Get-EventLog -LogName Application | Where-Object {$_.Message -like "*java*"}
```

#### بررسی لاگ‌های Windows Event
1. باز کردن Event Viewer
2. Windows Logs → Application
3. فیلتر بر اساس Error و Warning
4. جستجو برای کلمات کلیدی: Java, Android, Gradle

### ابزارهای تشخیص مشکل

#### 1. اسکریپت جمع‌آوری لاگ
```powershell
function Collect-AndroidLogs {
    param(
        [string]$OutputPath = "AndroidLogs_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
    )
    
    New-Item -ItemType Directory -Path $OutputPath -Force
    
    Write-Host "جمع‌آوری لاگ‌ها..." -ForegroundColor Yellow
    
    # لاگ‌های سیستم
    Get-ComputerInfo | Out-File "$OutputPath\system-info.txt"
    Get-EventLog -LogName Application -EntryType Error -Newest 50 | Out-File "$OutputPath\windows-errors.txt"
    
    # متغیرهای محیطی
    Get-ChildItem Env: | Where-Object {$_.Name -like "*JAVA*" -or $_.Name -like "*ANDROID*" -or $_.Name -like "*GRADLE*"} | Out-File "$OutputPath\environment-vars.txt"
    
    # تست دستورات
    "=== Java Version ===" | Out-File "$OutputPath\command-tests.txt"
    java -version 2>&1 | Out-File "$OutputPath\command-tests.txt" -Append
    
    "=== Gradle Version ===" | Out-File "$OutputPath\command-tests.txt" -Append
    gradle -v 2>&1 | Out-File "$OutputPath\command-tests.txt" -Append
    
    "=== ADB Version ===" | Out-File "$OutputPath\command-tests.txt" -Append
    adb version 2>&1 | Out-File "$OutputPath\command-tests.txt" -Append
    
    # لاگ‌های Android Studio (در صورت وجود)
    $studioLogPath = "$env:USERPROFILE\.AndroidStudio2022.3\system\log\idea.log"
    if (Test-Path $studioLogPath) {
        Copy-Item $studioLogPath "$OutputPath\android-studio.log"
    }
    
    Write-Host "لاگ‌ها در پوشه $OutputPath ذخیره شدند" -ForegroundColor Green
}

# استفاده
Collect-AndroidLogs
```

#### 2. تحلیل خطاهای رایج

##### خطای "Command not found"
```powershell
# بررسی PATH
$env:PATH -split ';' | ForEach-Object {
    if (Test-Path $_) {
        Write-Host "✓ $_" -ForegroundColor Green
    } else {
        Write-Host "✗ $_" -ForegroundColor Red
    }
}
```

##### خطای "Access Denied"
```powershell
# بررسی دسترسی‌ها
Get-Acl "D:\Android" | Format-List

# بررسی فرآیندهای قفل‌کننده
Get-Process | Where-Object {$_.Path -like "*Android*"}
```

##### خطای "Out of Memory"
```powershell
# بررسی حافظه سیستم
Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize, FreePhysicalMemory

# بررسی فضای دیسک
Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, Size, FreeSpace
```

### تحلیل لاگ‌های خاص

#### لاگ‌های بیلد Gradle
```powershell
# جستجوی خطاها در لاگ بیلد
Select-String -Path "build.log" -Pattern "ERROR|FAILED|Exception"

# نمایش خطاهای کامپایل
Select-String -Path "build.log" -Pattern "compilation failed"
```

#### لاگ‌های SDK Manager
```powershell
# بررسی مشکلات دانلود
Select-String -Path "sdkmanager.log" -Pattern "failed|error|timeout"

# بررسی مشکلات لایسنس
Select-String -Path "sdkmanager.log" -Pattern "license"
```

#### لاگ‌های ADB
```powershell
# بررسی مشکلات اتصال دستگاه
adb logcat | Select-String "error|failed"

# بررسی وضعیت daemon
adb nodaemon server
```

### ابزارهای پیشرفته تشخیص

#### 1. Process Monitor (ProcMon)
- دانلود از Microsoft Sysinternals
- مانیتورینگ دسترسی فایل‌ها
- تشخیص مشکلات دسترسی

#### 2. Dependency Walker
- بررسی وابستگی‌های DLL
- تشخیص کتابخانه‌های گم‌شده

#### 3. PowerShell ISE Debugger
```powershell
# فعال کردن debug mode
Set-PSDebug -Trace 2

# اجرای اسکریپت با trace
.\your-script.ps1
```

### الگوهای رایج خطا

#### 1. خطاهای مسیر (Path)
```
Pattern: "is not recognized as an internal or external command"
Solution: بررسی PATH و JAVA_HOME
```

#### 2. خطاهای دسترسی (Permission)
```
Pattern: "Access denied" یا "Permission denied"
Solution: اجرای به عنوان Administrator
```

#### 3. خطاهای وابستگی (Dependency)
```
Pattern: "Could not find" یا "No such file"
Solution: بررسی نصب کامپوننت‌های پیش‌نیاز
```

#### 4. خطاهای شبکه (Network)
```
Pattern: "Connection timeout" یا "Unable to resolve host"
Solution: بررسی تنظیمات proxy و firewall
```

### تولید گزارش خطا

#### گزارش خودکار
```powershell
function Generate-ErrorReport {
    $reportPath = "ErrorReport_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    
    "=== Android Development Environment Error Report ===" | Out-File $reportPath
    "Generated: $(Get-Date)" | Out-File $reportPath -Append
    "" | Out-File $reportPath -Append
    
    "=== System Information ===" | Out-File $reportPath -Append
    Get-ComputerInfo | Select-Object WindowsProductName, WindowsVersion, TotalPhysicalMemory | Out-File $reportPath -Append
    
    "=== Environment Variables ===" | Out-File $reportPath -Append
    @("JAVA_HOME", "ANDROID_HOME", "GRADLE_HOME", "PATH") | ForEach-Object {
        "$_`: $([Environment]::GetEnvironmentVariable($_, 'User'))" | Out-File $reportPath -Append
    }
    
    "=== Command Tests ===" | Out-File $reportPath -Append
    @("java -version", "gradle -v", "adb version") | ForEach-Object {
        "--- $_ ---" | Out-File $reportPath -Append
        try {
            Invoke-Expression $_ 2>&1 | Out-File $reportPath -Append
        } catch {
            "ERROR: $($_.Exception.Message)" | Out-File $reportPath -Append
        }
    }
    
    "=== Recent Errors ===" | Out-File $reportPath -Append
    Get-EventLog -LogName Application -EntryType Error -Newest 10 | 
        Select-Object TimeGenerated, Source, Message | Out-File $reportPath -Append
    
    Write-Host "گزارش خطا در $reportPath ذخیره شد" -ForegroundColor Green
}
```

### نکات مهم بررسی لاگ

1. **همیشه از آخرین لاگ‌ها شروع کنید**
2. **به timestamp‌ها توجه کنید**
3. **خطاهای مرتبط را گروه‌بندی کنید**
4. **Stack trace کامل را بررسی کنید**
5. **متغیرهای محیطی را در نظر بگیرید**

### خلاصه دستورات مفید

```powershell
# مشاهده لاگ‌های real-time
Get-EventLog -LogName Application -Newest 1 -Wait

# جستجوی خطاهای خاص
Get-EventLog -LogName Application | Where-Object {$_.EntryType -eq "Error" -and $_.Message -like "*Android*"}

# صادرات لاگ‌ها
Get-EventLog -LogName Application -EntryType Error | Export-Csv "errors.csv"

# پاک کردن لاگ‌ها
Clear-EventLog -LogName Application
```
## راهنمای بازنصب کامپوننت‌ها

### قبل از بازنصب

#### 1. پشتیبان‌گیری از تنظیمات
```powershell
# ایجاد پشتیبان از متغیرهای محیطی
function Backup-EnvironmentVariables {
    $backupPath = "env_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    
    "=== Environment Variables Backup ===" | Out-File $backupPath
    "Created: $(Get-Date)" | Out-File $backupPath -Append
    "" | Out-File $backupPath -Append
    
    @("JAVA_HOME", "ANDROID_HOME", "GRADLE_HOME", "PATH") | ForEach-Object {
        $value = [Environment]::GetEnvironmentVariable($_, 'User')
        "$_=$value" | Out-File $backupPath -Append
    }
    
    Write-Host "پشتیبان متغیرهای محیطی در $backupPath ذخیره شد" -ForegroundColor Green
}

Backup-EnvironmentVariables
```

#### 2. بررسی فرآیندهای در حال اجرا
```powershell
# متوقف کردن فرآیندهای مرتبط
Get-Process | Where-Object {$_.ProcessName -like "*java*" -or $_.ProcessName -like "*gradle*" -or $_.ProcessName -like "*adb*"} | Stop-Process -Force

# بررسی قفل فایل‌ها
function Check-FileLocks {
    param([string]$Path)
    
    try {
        $files = Get-ChildItem $Path -Recurse -File
        $lockedFiles = @()
        
        foreach ($file in $files) {
            try {
                $stream = [System.IO.File]::Open($file.FullName, 'Open', 'Write')
                $stream.Close()
            } catch {
                $lockedFiles += $file.FullName
            }
        }
        
        if ($lockedFiles.Count -gt 0) {
            Write-Host "فایل‌های قفل شده:" -ForegroundColor Yellow
            $lockedFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        }
    } catch {
        Write-Host "خطا در بررسی قفل فایل‌ها: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Check-FileLocks "D:\Android"
```

### بازنصب کامل سیستم

#### مرحله 1: حذف کامل
```powershell
function Complete-Uninstall {
    Write-Host "شروع حذف کامل Android Development Environment..." -ForegroundColor Yellow
    
    # متوقف کردن فرآیندها
    $processes = @("java", "javaw", "gradle", "adb", "emulator", "studio64")
    foreach ($proc in $processes) {
        Get-Process -Name $proc -ErrorAction SilentlyContinue | Stop-Process -Force
        Write-Host "فرآیند $proc متوقف شد" -ForegroundColor Green
    }
    
    # حذف پوشه‌های اصلی
    $folders = @(
        "D:\Android",
        "$env:USERPROFILE\.android",
        "$env:USERPROFILE\.gradle",
        "$env:USERPROFILE\.AndroidStudio2022.3"
    )
    
    foreach ($folder in $folders) {
        if (Test-Path $folder) {
            Write-Host "حذف $folder..." -ForegroundColor Yellow
            Remove-Item $folder -Recurse -Force -ErrorAction SilentlyContinue
            if (!(Test-Path $folder)) {
                Write-Host "✓ $folder حذف شد" -ForegroundColor Green
            } else {
                Write-Host "✗ خطا در حذف $folder" -ForegroundColor Red
            }
        }
    }
    
    # پاک کردن متغیرهای محیطی
    $envVars = @("JAVA_HOME", "ANDROID_HOME", "GRADLE_HOME")
    foreach ($var in $envVars) {
        [Environment]::SetEnvironmentVariable($var, $null, "User")
        Write-Host "متغیر $var پاک شد" -ForegroundColor Green
    }
    
    # پاک کردن PATH
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = ($currentPath -split ';' | Where-Object { 
        $_ -notlike "*Android*" -and $_ -notlike "*JDK*" -and $_ -notlike "*Gradle*" 
    }) -join ';'
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    
    Write-Host "حذف کامل تکمیل شد. لطفاً سیستم را restart کنید." -ForegroundColor Green
}

Complete-Uninstall
```

#### مرحله 2: نصب مجدد
```powershell
# پس از restart سیستم، اجرای اسکریپت نصب
.\auto-download-and-setup-android-offline.ps1
```

### بازنصب جزئی کامپوننت‌ها

#### بازنصب JDK 17
```powershell
function Reinstall-JDK {
    Write-Host "بازنصب JDK 17..." -ForegroundColor Yellow
    
    # متوقف کردن فرآیندهای Java
    Get-Process -Name "java*" -ErrorAction SilentlyContinue | Stop-Process -Force
    
    # حذف پوشه JDK
    if (Test-Path "D:\Android\JDK17") {
        Remove-Item "D:\Android\JDK17" -Recurse -Force
        Write-Host "پوشه JDK17 حذف شد" -ForegroundColor Green
    }
    
    # استخراج مجدد
    if (Test-Path "downloaded\jdk-17.zip") {
        Expand-Archive -Path "downloaded\jdk-17.zip" -DestinationPath "D:\Android\extracted_jdk-17" -Force
        
        # پیدا کردن پوشه JDK
        $jdkFolder = Get-ChildItem "D:\Android\extracted_jdk-17" -Directory | Select-Object -First 1
        Move-Item $jdkFolder.FullName "D:\Android\JDK17"
        Remove-Item "D:\Android\extracted_jdk-17" -Recurse -Force
        
        # تنظیم متغیر محیطی
        [Environment]::SetEnvironmentVariable("JAVA_HOME", "D:\Android\JDK17", "User")
        
        # تست
        & "D:\Android\JDK17\bin\java.exe" -version
        Write-Host "JDK 17 با موفقیت بازنصب شد" -ForegroundColor Green
    } else {
        Write-Host "فایل jdk-17.zip یافت نشد" -ForegroundColor Red
    }
}

Reinstall-JDK
```

#### بازنصب Gradle
```powershell
function Reinstall-Gradle {
    Write-Host "بازنصب Gradle..." -ForegroundColor Yellow
    
    # متوقف کردن daemon های Gradle
    & gradle --stop 2>$null
    
    # حذف پوشه Gradle
    if (Test-Path "D:\Android\Gradle") {
        Remove-Item "D:\Android\Gradle" -Recurse -Force
        Write-Host "پوشه Gradle حذف شد" -ForegroundColor Green
    }
    
    # حذف cache Gradle
    if (Test-Path "$env:USERPROFILE\.gradle") {
        Remove-Item "$env:USERPROFILE\.gradle" -Recurse -Force
        Write-Host "Cache Gradle پاک شد" -ForegroundColor Green
    }
    
    # استخراج مجدد
    if (Test-Path "downloaded\gradle-8.0.2.zip") {
        Expand-Archive -Path "downloaded\gradle-8.0.2.zip" -DestinationPath "D:\Android\" -Force
        
        # تغییر نام پوشه
        $gradleFolder = Get-ChildItem "D:\Android\" -Directory -Name "gradle-*" | Select-Object -First 1
        Rename-Item "D:\Android\$gradleFolder" "Gradle"
        
        # تنظیم PATH
        $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
        $newPath = $currentPath + ";D:\Android\Gradle\bin"
        [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        
        # تست
        & "D:\Android\Gradle\bin\gradle.bat" -v
        Write-Host "Gradle با موفقیت بازنصب شد" -ForegroundColor Green
    } else {
        Write-Host "فایل gradle-8.0.2.zip یافت نشد" -ForegroundColor Red
    }
}

Reinstall-Gradle
```

#### بازنصب Android SDK
```powershell
function Reinstall-AndroidSDK {
    Write-Host "بازنصب Android SDK..." -ForegroundColor Yellow
    
    # متوقف کردن ADB
    & adb kill-server 2>$null
    
    # حذف پوشه SDK
    if (Test-Path "D:\Android\Sdk") {
        Remove-Item "D:\Android\Sdk" -Recurse -Force
        Write-Host "پوشه SDK حذف شد" -ForegroundColor Green
    }
    
    # ایجاد ساختار پوشه‌ها
    New-Item -ItemType Directory -Path "D:\Android\Sdk" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\cmdline-tools" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\platform-tools" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\build-tools" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\platforms" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\system-images" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\extras" -Force
    New-Item -ItemType Directory -Path "D:\Android\Sdk\licenses" -Force
    
    # نصب Command Line Tools
    if (Test-Path "downloaded\commandlinetools-win-latest.zip") {
        Expand-Archive -Path "downloaded\commandlinetools-win-latest.zip" -DestinationPath "D:\Android\Sdk\cmdline-tools\" -Force
        Rename-Item "D:\Android\Sdk\cmdline-tools\cmdline-tools" "latest"
    }
    
    # نصب Platform Tools
    if (Test-Path "downloaded\platform-tools.zip") {
        Expand-Archive -Path "downloaded\platform-tools.zip" -DestinationPath "D:\Android\Sdk\" -Force
    }
    
    # نصب Build Tools
    if (Test-Path "downloaded\build-tools-33.0.2.zip") {
        Expand-Archive -Path "downloaded\build-tools-33.0.2.zip" -DestinationPath "D:\Android\Sdk\build-tools\" -Force
        Rename-Item "D:\Android\Sdk\build-tools\android-13" "33.0.2"
    }
    
    # تنظیم متغیرهای محیطی
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", "D:\Android\Sdk", "User")
    $currentPath = [Environment]::GetEnvironmentVariable("PATH", "User")
    $newPath = $currentPath + ";D:\Android\Sdk\platform-tools;D:\Android\Sdk\cmdline-tools\latest\bin"
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
    
    Write-Host "Android SDK با موفقیت بازنصب شد" -ForegroundColor Green
}

Reinstall-AndroidSDK
```

### حل مشکلات رایج بازنصب

#### مشکل: فایل‌ها قفل هستند
```powershell
# استفاده از Unlocker یا Handle
# دانلود Handle از Microsoft Sysinternals
handle.exe D:\Android

# یا استفاده از PowerShell
function Unlock-Files {
    param([string]$Path)
    
    $processes = Get-Process | Where-Object {
        try {
            $_.Modules | Where-Object { $_.FileName -like "$Path*" }
        } catch { }
    }
    
    $processes | ForEach-Object {
        Write-Host "متوقف کردن فرآیند: $($_.ProcessName)" -ForegroundColor Yellow
        $_ | Stop-Process -Force
    }
}

Unlock-Files "D:\Android"
```

#### مشکل: دسترسی رد شده
```powershell
# تغییر مالکیت پوشه
takeown /f "D:\Android" /r /d y

# تنظیم دسترسی‌ها
icacls "D:\Android" /grant "$env:USERNAME:(OI)(CI)F" /t

# یا استفاده از PowerShell
function Fix-Permissions {
    param([string]$Path)
    
    $acl = Get-Acl $Path
    $accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $env:USERNAME, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.SetAccessRule($accessRule)
    Set-Acl $Path $acl
    
    Write-Host "دسترسی‌های $Path تنظیم شد" -ForegroundColor Green
}

Fix-Permissions "D:\Android"
```

#### مشکل: فضای ناکافی
```powershell
# بررسی فضای دیسک
function Check-DiskSpace {
    $disk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='D:'"
    $freeSpaceGB = [math]::Round($disk.FreeSpace / 1GB, 2)
    $totalSpaceGB = [math]::Round($disk.Size / 1GB, 2)
    
    Write-Host "فضای آزاد: $freeSpaceGB GB از $totalSpaceGB GB" -ForegroundColor Cyan
    
    if ($freeSpaceGB -lt 10) {
        Write-Host "هشدار: فضای ناکافی! حداقل 10GB فضای آزاد نیاز است." -ForegroundColor Red
        return $false
    }
    return $true
}

if (!(Check-DiskSpace)) {
    Write-Host "لطفاً فضای بیشتری آزاد کنید و دوباره تلاش کنید." -ForegroundColor Yellow
    exit
}
```

### اسکریپت بازنصب خودکار

```powershell
function Auto-Reinstall {
    param(
        [string[]]$Components = @("all"),
        [switch]$SkipBackup = $false
    )
    
    Write-Host "=== شروع بازنصب خودکار ===" -ForegroundColor Green
    
    # پشتیبان‌گیری
    if (!$SkipBackup) {
        Backup-EnvironmentVariables
    }
    
    # بررسی فضای دیسک
    if (!(Check-DiskSpace)) {
        return
    }
    
    # بازنصب بر اساس کامپوننت‌های انتخابی
    if ($Components -contains "all" -or $Components -contains "jdk") {
        Reinstall-JDK
    }
    
    if ($Components -contains "all" -or $Components -contains "gradle") {
        Reinstall-Gradle
    }
    
    if ($Components -contains "all" -or $Components -contains "sdk") {
        Reinstall-AndroidSDK
    }
    
    Write-Host "=== بازنصب تکمیل شد ===" -ForegroundColor Green
    Write-Host "لطفاً PowerShell را بسته و دوباره باز کنید تا تغییرات اعمال شود." -ForegroundColor Yellow
}

# استفاده:
# Auto-Reinstall                          # بازنصب همه
# Auto-Reinstall -Components @("jdk")     # فقط JDK
# Auto-Reinstall -SkipBackup              # بدون پشتیبان‌گیری
```

### تست پس از بازنصب

```powershell
function Test-Installation {
    Write-Host "=== تست نصب پس از بازنصب ===" -ForegroundColor Green
    
    $tests = @(
        @{ Name = "Java"; Command = "java -version"; Path = $env:JAVA_HOME },
        @{ Name = "Gradle"; Command = "gradle -v"; Path = "D:\Android\Gradle" },
        @{ Name = "ADB"; Command = "adb version"; Path = "D:\Android\Sdk\platform-tools" },
        @{ Name = "SDK Manager"; Command = "sdkmanager --version"; Path = "D:\Android\Sdk\cmdline-tools\latest" }
    )
    
    $results = @()
    
    foreach ($test in $tests) {
        Write-Host "تست $($test.Name)..." -ForegroundColor Yellow
        
        $result = @{
            Component = $test.Name
            PathExists = Test-Path $test.Path
            CommandWorks = $false
            Error = ""
        }
        
        try {
            $output = Invoke-Expression $test.Command 2>&1
            $result.CommandWorks = $true
            Write-Host "✓ $($test.Name) کار می‌کند" -ForegroundColor Green
        } catch {
            $result.Error = $_.Exception.Message
            Write-Host "✗ $($test.Name) کار نمی‌کند: $($_.Exception.Message)" -ForegroundColor Red
        }
        
        $results += $result
    }
    
    # خلاصه نتایج
    Write-Host "`n=== خلاصه نتایج ===" -ForegroundColor Cyan
    $results | Format-Table -AutoSize
    
    $failedTests = $results | Where-Object { !$_.CommandWorks }
    if ($failedTests.Count -eq 0) {
        Write-Host "همه تست‌ها موفق بودند! 🎉" -ForegroundColor Green
    } else {
        Write-Host "تعداد $($failedTests.Count) تست ناموفق" -ForegroundColor Red
    }
}

Test-Installation
```

### نکات مهم بازنصب

1. **همیشه پشتیبان بگیرید** قبل از شروع بازنصب
2. **تمام فرآیندها را متوقف کنید** قبل از حذف فایل‌ها
3. **دسترسی Administrator داشته باشید**
4. **فضای کافی روی دیسک داشته باشید** (حداقل 10GB)
5. **پس از بازنصب سیستم را restart کنید**
6. **تست کامل انجام دهید** قبل از شروع توسعه

### خلاصه دستورات سریع

```powershell
# بازنصب سریع همه کامپوننت‌ها
Complete-Uninstall
# Restart سیستم
.\auto-download-and-setup-android-offline.ps1

# بازنصب فقط JDK
Reinstall-JDK

# بازنصب فقط Gradle  
Reinstall-Gradle

# بازنصب فقط SDK
Reinstall-AndroidSDK

# تست نهایی
Test-Installation
```