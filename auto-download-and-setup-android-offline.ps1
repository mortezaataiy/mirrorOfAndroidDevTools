$ErrorActionPreference = "Stop"

Write-Host "== نصب خودکار محیط آفلاین اندروید (تشخیص هوشمند) ==" -ForegroundColor Green

$ROOT = Split-Path -Parent $MyInvocation.MyCommand.Path
$INSTALL = "D:\Android"

$JAVA_HOME    = "$INSTALL\JDK17"
$GRADLE_HOME  = "$INSTALL\Gradle"
$SDK_ROOT     = "$INSTALL\Sdk"
$GRADLE_CACHE = "$INSTALL\.gradle"

# ---------------- توابع کمکی ----------------

function Fail($msg) {
    Write-Host "❌ خطا: $msg" -ForegroundColor Red
    exit 1
}

function Success($msg) {
    Write-Host "✅ $msg" -ForegroundColor Green
}

function Info($msg) {
    Write-Host "ℹ️  $msg" -ForegroundColor Cyan
}

function Ensure($p) {
    if (!(Test-Path $p)) { 
        New-Item -ItemType Directory -Path $p -Force | Out-Null
        Info "پوشه ایجاد شد: $p"
    }
}

function Valid-Zip($zip) {
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $fs = [IO.File]::OpenRead($zip)
        $z = New-Object IO.Compression.ZipArchive($fs)
        $entryCount = $z.Entries.Count
        $z.Dispose(); $fs.Close()
        return $entryCount -gt 0
    } catch { 
        return $false 
    }
}

function Expand-ZipSmart($zip, $destination) {
    if (!(Valid-Zip $zip)) { 
        Fail "فایل ZIP خراب است: $zip" 
    }
    
    $fileName = [IO.Path]::GetFileNameWithoutExtension($zip)
    if (!$destination) {
        $destination = Join-Path $ROOT "extracted_$fileName"
    }
    
    Info "در حال استخراج: $($zip | Split-Path -Leaf)"
    Expand-Archive $zip $destination -Force
    Success "استخراج کامل شد: $destination"
    return $destination
}

function Find-Or-Extract($predicate, $componentName) {
    Info "جستجو برای $componentName..."
    
    # 1️⃣ جستجو در پوشه‌های موجود
    $found = Get-ChildItem $ROOT -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object {
        & $predicate $_
    } | Select-Object -First 1
    
    if ($found) {
        Success "$componentName پیدا شد در: $($found.FullName)"
        return $found.FullName
    }

    # 2️⃣ جستجو در فایل‌های ZIP
    $zipFiles = Get-ChildItem $ROOT -Recurse -Filter "*.zip" -ErrorAction SilentlyContinue
    foreach ($zipFile in $zipFiles) {
        Info "بررسی فایل ZIP: $($zipFile.Name)"
        $extractPath = Expand-ZipSmart $zipFile.FullName
        
        $found = Get-ChildItem $extractPath -Recurse -Directory -ErrorAction SilentlyContinue | Where-Object {
            & $predicate $_
        } | Select-Object -First 1
        
        if ($found) {
            Success "$componentName پیدا شد در ZIP: $($found.FullName)"
            return $found.FullName
        }
    }

    return $null
}

# ---------------- آماده‌سازی پوشه‌ها ----------------

Info "آماده‌سازی پوشه‌های نصب..."
Ensure $INSTALL
Ensure $JAVA_HOME
Ensure $GRADLE_HOME
Ensure $SDK_ROOT
Ensure $GRADLE_CACHE

# ---------------- نصب JDK ----------------

Info "شروع نصب JDK 17..."
$jdkPath = Find-Or-Extract { 
    param($dir)
    Test-Path "$($dir.FullName)\bin\java.exe" 
} "JDK 17"

if (!$jdkPath) { 
    Fail "JDK 17 پیدا نشد. فایل java.exe در مسیر bin موجود نیست." 
}

Info "کپی JDK به مسیر نصب..."
Copy-Item "$jdkPath\*" $JAVA_HOME -Recurse -Force
Success "JDK 17 با موفقیت نصب شد"

# ---------------- نصب Gradle ----------------

Info "شروع نصب Gradle..."
$gradlePath = Find-Or-Extract { 
    param($dir)
    Test-Path "$($dir.FullName)\bin\gradle.bat" 
} "Gradle"

if (!$gradlePath) { 
    Fail "Gradle پیدا نشد. فایل gradle.bat در مسیر bin موجود نیست." 
}

Info "کپی Gradle به مسیر نصب..."
Copy-Item "$gradlePath\*" $GRADLE_HOME -Recurse -Force
Success "Gradle با موفقیت نصب شد"

# ---------------- نصب Android SDK ----------------

Info "شروع نصب Android SDK..."
$sdkPath = Find-Or-Extract { 
    param($dir)
    # جستجو برای cmdline-tools یا platforms
    (Test-Path "$($dir.FullName)\cmdline-tools") -or 
    (Test-Path "$($dir.FullName)\platforms") -or
    (Test-Path "$($dir.FullName)\platform-tools")
} "Android SDK"

if (!$sdkPath) { 
    Fail "Android SDK پیدا نشد. پوشه‌های cmdline-tools، platforms یا platform-tools موجود نیست." 
}

Info "کپی Android SDK به مسیر نصب..."
Copy-Item "$sdkPath\*" $SDK_ROOT -Recurse -Force
Success "Android SDK با موفقیت نصب شد"

# ---------------- بررسی Platform Tools ----------------

if (!(Test-Path "$SDK_ROOT\platform-tools\adb.exe")) {
    # جستجوی جداگانه برای platform-tools
    Info "جستجوی جداگانه برای Platform Tools..."
    $platformToolsPath = Find-Or-Extract { 
        param($dir)
        Test-Path "$($dir.FullName)\adb.exe" 
    } "Platform Tools"
    
    if ($platformToolsPath) {
        $platformToolsTarget = "$SDK_ROOT\platform-tools"
        Ensure $platformToolsTarget
        Copy-Item "$platformToolsPath\*" $platformToolsTarget -Recurse -Force
        Success "Platform Tools جداگانه نصب شد"
    } else {
        Fail "Platform Tools پیدا نشد. فایل adb.exe موجود نیست."
    }
}

# ---------------- تنظیم متغیرهای محیطی ----------------

Info "تنظیم متغیرهای محیطی سیستم..."

try {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $JAVA_HOME, "Machine")
    [Environment]::SetEnvironmentVariable("ANDROID_HOME", $SDK_ROOT, "Machine")
    [Environment]::SetEnvironmentVariable("ANDROID_SDK_ROOT", $SDK_ROOT, "Machine")
    [Environment]::SetEnvironmentVariable("GRADLE_HOME", $GRADLE_HOME, "Machine")

    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    $pathsToAdd = @(
        "$JAVA_HOME\bin",
        "$GRADLE_HOME\bin",
        "$SDK_ROOT\platform-tools",
        "$SDK_ROOT\cmdline-tools\latest\bin"
    )

    foreach ($pathToAdd in $pathsToAdd) {
        if ($currentPath -notlike "*$pathToAdd*") {
            $currentPath += ";$pathToAdd"
            Info "مسیر اضافه شد: $pathToAdd"
        }
    }

    [Environment]::SetEnvironmentVariable("Path", $currentPath, "Machine")
    Success "متغیرهای محیطی تنظیم شدند"
} catch {
    Fail "خطا در تنظیم متغیرهای محیطی: $($_.Exception.Message)"
}

# ---------------- تست نصب ----------------

Info "تست صحت نصب..."

# تست Java
try {
    $javaVersion = & "$JAVA_HOME\bin\java.exe" -version 2>&1
    if ($javaVersion -match "17\.") {
        Success "Java 17 به درستی نصب شده"
    } else {
        Fail "نسخه Java صحیح نیست"
    }
} catch {
    Fail "خطا در تست Java: $($_.Exception.Message)"
}

# تست Gradle
try {
    $gradleVersion = & "$GRADLE_HOME\bin\gradle.bat" --version 2>&1
    if ($gradleVersion -match "Gradle") {
        Success "Gradle به درستی نصب شده"
    } else {
        Fail "Gradle به درستی کار نمی‌کند"
    }
} catch {
    Fail "خطا در تست Gradle: $($_.Exception.Message)"
}

# تست ADB
try {
    if (Test-Path "$SDK_ROOT\platform-tools\adb.exe") {
        $adbVersion = & "$SDK_ROOT\platform-tools\adb.exe" version 2>&1
        Success "ADB به درستی نصب شده"
    } else {
        Fail "ADB پیدا نشد"
    }
} catch {
    Fail "خطا در تست ADB: $($_.Exception.Message)"
}

# ---------------- ایجاد پروژه تست ----------------

Info "ایجاد پروژه Hello World برای تست..."
$TEST_PROJECT = "$INSTALL\HelloWorldTest"

if (Test-Path $TEST_PROJECT) {
    Info "حذف پروژه تست قبلی..."
    Remove-Item $TEST_PROJECT -Recurse -Force
}

try {
    # ایجاد ساختار پروژه ساده
    Ensure $TEST_PROJECT
    Ensure "$TEST_PROJECT\app\src\main\java\com\example\helloworld"
    Ensure "$TEST_PROJECT\app\src\main\res\layout"
    Ensure "$TEST_PROJECT\app\src\main\res\values"

    # فایل build.gradle اصلی
    @"
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.0.2'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
"@ | Out-File "$TEST_PROJECT\build.gradle" -Encoding UTF8

    # فایل settings.gradle
    @"
include ':app'
"@ | Out-File "$TEST_PROJECT\settings.gradle" -Encoding UTF8

    # فایل build.gradle برای app
    @"
plugins {
    id 'com.android.application'
}

android {
    compileSdk 33
    
    defaultConfig {
        applicationId "com.example.helloworld"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"
    }
    
    buildTypes {
        release {
            minifyEnabled false
        }
    }
}
"@ | Out-File "$TEST_PROJECT\app\build.gradle" -Encoding UTF8

    # فایل AndroidManifest.xml
    @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="com.example.helloworld">
    
    <application
        android:label="Hello World"
        android:theme="@android:style/Theme.Material.Light">
        <activity
            android:name=".MainActivity"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>
</manifest>
"@ | Out-File "$TEST_PROJECT\app\src\main\AndroidManifest.xml" -Encoding UTF8

    # فایل MainActivity.java
    @"
package com.example.helloworld;

import android.app.Activity;
import android.os.Bundle;
import android.widget.TextView;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        TextView textView = new TextView(this);
        textView.setText("Hello World - Android Offline Setup Success!");
        setContentView(textView);
    }
}
"@ | Out-File "$TEST_PROJECT\app\src\main\java\com\example\helloworld\MainActivity.java" -Encoding UTF8

    Success "پروژه Hello World ایجاد شد"

    # تست build آفلاین
    Info "تست build آفلاین..."
    Set-Location $TEST_PROJECT
    
    $buildResult = & "$GRADLE_HOME\bin\gradle.bat" assembleDebug --offline --stacktrace 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $apkPath = "$TEST_PROJECT\app\build\outputs\apk\debug\app-debug.apk"
        if (Test-Path $apkPath) {
            Success "✅ موفقیت کامل! APK تولید شد در: $apkPath"
            Success "محیط آفلاین اندروید آماده است!"
        } else {
            Fail "Build موفق بود اما APK پیدا نشد"
        }
    } else {
        Fail "Build ناموفق بود. خروجی: $buildResult"
    }

} catch {
    Fail "خطا در ایجاد یا build پروژه تست: $($_.Exception.Message)"
} finally {
    Set-Location $ROOT
}

# ---------------- خلاصه نهایی ----------------

Write-Host ""
Write-Host "===========================================" -ForegroundColor Green
Write-Host "✅ نصب محیط آفلاین اندروید کامل شد!" -ForegroundColor Green
Write-Host "===========================================" -ForegroundColor Green
Write-Host ""
Write-Host "مسیرهای نصب:" -ForegroundColor Yellow
Write-Host "- JDK 17: $JAVA_HOME" -ForegroundColor White
Write-Host "- Gradle: $GRADLE_HOME" -ForegroundColor White
Write-Host "- Android SDK: $SDK_ROOT" -ForegroundColor White
Write-Host ""
Write-Host "برای اعمال تغییرات، ویندوز را یک بار restart کنید." -ForegroundColor Cyan
Write-Host ""