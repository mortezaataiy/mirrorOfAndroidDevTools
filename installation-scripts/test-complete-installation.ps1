# تست نصب کامل در محیط تمیز
# این اسکریپت تمام فرایند نصب را تست می‌کند و پروژه Hello World ایجاد می‌کند

param(
    [string]$DownloadPath = "downloaded",
    [switch]$Verbose,
    [switch]$SkipOptional,
    [string]$TestProjectPath = "HelloWorldTest"
)

# وارد کردن ماژول‌های مشترک
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CommonDir = Join-Path $ScriptDir "common"

. (Join-Path $CommonDir "Logger.ps1")

# تنظیم لاگر
Initialize-Logger -ComponentName "Complete-Installation-Test" -Verbose:$Verbose

try {
    Write-LogInfo "شروع تست نصب کامل Android Development Tools..."
    Write-LogInfo "این تست شامل بررسی، نصب، تست و ایجاد پروژه Hello World است"
    
    $StartTime = Get-Date
    
    # مرحله 1: بررسی پیش‌نیازها
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 1: بررسی پیش‌نیازها"
    Write-LogInfo "=" * 60
    
    $CheckScript = Join-Path $ScriptDir "run-all-checks.ps1"
    if (-not (Test-Path $CheckScript)) {
        Write-LogError "اسکریپت بررسی پیش‌نیازها یافت نشد: $CheckScript"
        exit 1
    }
    
    $CheckParams = @("-DownloadPath", $DownloadPath)
    if ($Verbose) { $CheckParams += "-Verbose" }
    
    Write-LogInfo "اجرای بررسی پیش‌نیازها..."
    $CheckOutput = & PowerShell -File $CheckScript @CheckParams 2>&1
    $CheckExitCode = $LASTEXITCODE
    
    if ($CheckExitCode -ne 0) {
        Write-LogError "بررسی پیش‌نیازها ناموفق بود (Exit Code: $CheckExitCode)"
        $CheckOutput | ForEach-Object { Write-LogError "  $_" }
        exit 1
    }
    
    Write-LogSuccess "بررسی پیش‌نیازها موفقیت‌آمیز بود"
    
    # مرحله 2: نصب کامپوننت‌ها
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 2: نصب کامپوننت‌ها"
    Write-LogInfo "=" * 60
    
    $InstallScript = Join-Path $ScriptDir "run-all-installations.ps1"
    if (-not (Test-Path $InstallScript)) {
        Write-LogError "اسکریپت نصب یافت نشد: $InstallScript"
        exit 1
    }
    
    $InstallParams = @("-DownloadPath", $DownloadPath)
    if ($Verbose) { $InstallParams += "-Verbose" }
    if ($SkipOptional) { $InstallParams += "-SkipOptional" }
    
    Write-LogInfo "اجرای نصب کامپوننت‌ها..."
    $InstallOutput = & PowerShell -File $InstallScript @InstallParams 2>&1
    $InstallExitCode = $LASTEXITCODE
    
    if ($InstallExitCode -ne 0) {
        Write-LogError "نصب کامپوننت‌ها ناموفق بود (Exit Code: $InstallExitCode)"
        $InstallOutput | ForEach-Object { Write-LogError "  $_" }
        exit 1
    }
    
    Write-LogSuccess "نصب کامپوننت‌ها موفقیت‌آمیز بود"
    
    # مرحله 3: تست کامپوننت‌ها
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 3: تست کامپوننت‌ها"
    Write-LogInfo "=" * 60
    
    $TestScript = Join-Path $ScriptDir "run-all-tests.ps1"
    if (-not (Test-Path $TestScript)) {
        Write-LogError "اسکریپت تست یافت نشد: $TestScript"
        exit 1
    }
    
    $TestParams = @()
    if ($Verbose) { $TestParams += "-Verbose" }
    
    Write-LogInfo "اجرای تست کامپوننت‌ها..."
    $TestOutput = & PowerShell -File $TestScript @TestParams 2>&1
    $TestExitCode = $LASTEXITCODE
    
    if ($TestExitCode -ne 0) {
        Write-LogError "تست کامپوننت‌ها ناموفق بود (Exit Code: $TestExitCode)"
        $TestOutput | ForEach-Object { Write-LogError "  $_" }
        exit 1
    }
    
    Write-LogSuccess "تست کامپوننت‌ها موفقیت‌آمیز بود"
    
    # مرحله 4: ایجاد پروژه Hello World
    Write-LogInfo "=" * 60
    Write-LogInfo "مرحله 4: ایجاد پروژه Hello World"
    Write-LogInfo "=" * 60
    
    # حذف پروژه قبلی در صورت وجود
    if (Test-Path $TestProjectPath) {
        Write-LogInfo "حذف پروژه قبلی: $TestProjectPath"
        Remove-Item -Path $TestProjectPath -Recurse -Force
    }
    
    # بررسی دسترسی به ابزارها
    Write-LogInfo "بررسی دسترسی به ابزارهای مورد نیاز..."
    
    # تست Java
    try {
        $JavaVersion = & java -version 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogSuccess "Java در دسترس است"
        } else {
            Write-LogError "Java در دسترس نیست"
            exit 1
        }
    } catch {
        Write-LogError "خطا در اجرای Java: $($_.Exception.Message)"
        exit 1
    }
    
    # تست Gradle
    try {
        $GradleVersion = & gradle -v 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-LogSuccess "Gradle در دسترس است"
        } else {
            Write-LogError "Gradle در دسترس نیست"
            exit 1
        }
    } catch {
        Write-LogError "خطا در اجرای Gradle: $($_.Exception.Message)"
        exit 1
    }
    
    # تست Android SDK
    $AndroidSdkRoot = $env:ANDROID_SDK_ROOT
    if (-not $AndroidSdkRoot) {
        $AndroidSdkRoot = $env:ANDROID_HOME
    }
    
    if (-not $AndroidSdkRoot) {
        Write-LogError "ANDROID_SDK_ROOT تنظیم نشده است"
        exit 1
    }
    
    Write-LogSuccess "Android SDK در دسترس است: $AndroidSdkRoot"
    
    # ایجاد پروژه Android با Gradle
    Write-LogInfo "ایجاد پروژه Hello World Android..."
    
    New-Item -ItemType Directory -Path $TestProjectPath -Force | Out-Null
    Set-Location $TestProjectPath
    
    try {
        # ایجاد build.gradle
        $BuildGradleContent = @"
plugins {
    id 'com.android.application' version '8.1.0'
}

android {
    namespace 'com.example.helloworld'
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
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
"@
        
        $BuildGradleContent | Out-File -FilePath "build.gradle" -Encoding UTF8
        Write-LogSuccess "فایل build.gradle ایجاد شد"
        
        # ایجاد gradle.properties
        $GradlePropsContent = @"
android.useAndroidX=true
android.enableJetifier=true
"@
        
        $GradlePropsContent | Out-File -FilePath "gradle.properties" -Encoding UTF8
        Write-LogSuccess "فایل gradle.properties ایجاد شد"
        
        # ایجاد settings.gradle
        $SettingsGradleContent = @"
pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "HelloWorld"
include ':app'
"@
        
        $SettingsGradleContent | Out-File -FilePath "settings.gradle" -Encoding UTF8
        Write-LogSuccess "فایل settings.gradle ایجاد شد"
        
        # ایجاد ساختار پوشه‌ها
        $AppDir = "app"
        $SrcDir = Join-Path $AppDir "src\main"
        $JavaDir = Join-Path $SrcDir "java\com\example\helloworld"
        $ResDir = Join-Path $SrcDir "res"
        $LayoutDir = Join-Path $ResDir "layout"
        $ValuesDir = Join-Path $ResDir "values"
        
        New-Item -ItemType Directory -Path $JavaDir -Force | Out-Null
        New-Item -ItemType Directory -Path $LayoutDir -Force | Out-Null
        New-Item -ItemType Directory -Path $ValuesDir -Force | Out-Null
        
        Write-LogSuccess "ساختار پوشه‌های پروژه ایجاد شد"
        
        # ایجاد AndroidManifest.xml
        $ManifestContent = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools">

    <application
        android:allowBackup="true"
        android:dataExtractionRules="@xml/data_extraction_rules"
        android:fullBackupContent="@xml/backup_rules"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/Theme.HelloWorld"
        tools:targetApi="31">
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
"@
        
        $ManifestPath = Join-Path $SrcDir "AndroidManifest.xml"
        $ManifestContent | Out-File -FilePath $ManifestPath -Encoding UTF8
        Write-LogSuccess "فایل AndroidManifest.xml ایجاد شد"
        
        # ایجاد MainActivity.java
        $MainActivityContent = @"
package com.example.helloworld;

import androidx.appcompat.app.AppCompatActivity;
import android.os.Bundle;

public class MainActivity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}
"@
        
        $MainActivityPath = Join-Path $JavaDir "MainActivity.java"
        $MainActivityContent | Out-File -FilePath $MainActivityPath -Encoding UTF8
        Write-LogSuccess "فایل MainActivity.java ایجاد شد"
        
        # ایجاد activity_main.xml
        $LayoutContent = @"
<?xml version="1.0" encoding="utf-8"?>
<androidx.constraintlayout.widget.ConstraintLayout xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:app="http://schemas.android.com/apk/res-auto"
    xmlns:tools="http://schemas.android.com/tools"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    tools:context=".MainActivity">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="Hello World!"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
"@
        
        $LayoutPath = Join-Path $LayoutDir "activity_main.xml"
        $LayoutContent | Out-File -FilePath $LayoutPath -Encoding UTF8
        Write-LogSuccess "فایل activity_main.xml ایجاد شد"
        
        # ایجاد strings.xml
        $StringsContent = @"
<resources>
    <string name="app_name">Hello World</string>
</resources>
"@
        
        $StringsPath = Join-Path $ValuesDir "strings.xml"
        $StringsContent | Out-File -FilePath $StringsPath -Encoding UTF8
        Write-LogSuccess "فایل strings.xml ایجاد شد"
        
        # ایجاد app/build.gradle
        $AppBuildGradleContent = @"
plugins {
    id 'com.android.application'
}

android {
    namespace 'com.example.helloworld'
    compileSdk 33

    defaultConfig {
        applicationId "com.example.helloworld"
        minSdk 21
        targetSdk 33
        versionCode 1
        versionName "1.0"

        testInstrumentationRunner "androidx.test.runner.AndroidJUnitRunner"
    }

    buildTypes {
        release {
            minifyEnabled false
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}

dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
"@
        
        $AppBuildGradlePath = Join-Path $AppDir "build.gradle"
        $AppBuildGradleContent | Out-File -FilePath $AppBuildGradlePath -Encoding UTF8
        Write-LogSuccess "فایل app/build.gradle ایجاد شد"
        
        Write-LogSuccess "پروژه Hello World ایجاد شد"
        
        # تست build پروژه
        Write-LogInfo "تست build پروژه..."
        
        $BuildOutput = & gradle build 2>&1
        $BuildExitCode = $LASTEXITCODE
        
        if ($BuildExitCode -eq 0) {
            Write-LogSuccess "Build پروژه موفقیت‌آمیز بود"
        } else {
            Write-LogWarning "Build پروژه با خطا مواجه شد (Exit Code: $BuildExitCode)"
            Write-LogInfo "خروجی build:"
            $BuildOutput | ForEach-Object { Write-LogInfo "  $_" }
        }
        
    } finally {
        # بازگشت به پوشه اصلی
        Set-Location ..
    }
    
    $EndTime = Get-Date
    $TotalDuration = ($EndTime - $StartTime).TotalMinutes
    
    # گزارش نهایی
    Write-LogInfo "=" * 60
    Write-LogInfo "خلاصه تست نصب کامل:"
    Write-LogInfo "مدت زمان کل: $([math]::Round($TotalDuration, 1)) دقیقه"
    Write-LogSuccess "✓ بررسی پیش‌نیازها"
    Write-LogSuccess "✓ نصب کامپوننت‌ها"
    Write-LogSuccess "✓ تست کامپوننت‌ها"
    Write-LogSuccess "✓ ایجاد پروژه Hello World"
    
    if ($BuildExitCode -eq 0) {
        Write-LogSuccess "✓ Build پروژه"
        Write-LogSuccess "تست نصب کامل با موفقیت تکمیل شد!"
        Write-LogInfo "پروژه Hello World در پوشه '$TestProjectPath' ایجاد شد"
    } else {
        Write-LogWarning "⚠ Build پروژه با مشکل مواجه شد"
        Write-LogInfo "پروژه Hello World ایجاد شد اما build کامل نشد"
        Write-LogInfo "پروژه در پوشه '$TestProjectPath' موجود است"
    }
    
    exit 0
    
} catch {
    Write-LogError "خطا در تست نصب کامل: $($_.Exception.Message)"
    Write-LogError "جزئیات خطا: $($_.Exception.StackTrace)"
    
    # بازگشت به پوشه اصلی در صورت خطا
    try {
        Set-Location $ScriptDir
    } catch {}
    
    exit 1
}