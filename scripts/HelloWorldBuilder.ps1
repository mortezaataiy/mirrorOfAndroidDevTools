# Hello World Project Builder
# مسئول ایجاد و بیلد پروژه تست Hello World

# Import required modules
. "$PSScriptRoot\ErrorHandler.ps1"

# تنظیمات پروژه Hello World
$Global:HelloWorldConfig = @{
    ProjectName = "HelloWorldTest"
    PackageName = "com.example.helloworld"
    ActivityName = "MainActivity"
    MinSdkVersion = 21
    TargetSdkVersion = 33
    CompileSdkVersion = 33
}

# ایجاد ساختار پروژه اندروید
function New-AndroidProjectStructure {
    param(
        [string]$ProjectPath,
        [string]$ProjectName = $Global:HelloWorldConfig.ProjectName
    )
    
    Write-ActivityLog -Message "ایجاد ساختار پروژه اندروید: $ProjectName" -Level "INFO"
    
    try {
        $fullProjectPath = Join-Path $ProjectPath $ProjectName
        
        # ایجاد دایرکتوری‌های اصلی
        $directories = @(
            "$fullProjectPath\app\src\main\java\com\example\helloworld",
            "$fullProjectPath\app\src\main\res\layout",
            "$fullProjectPath\app\src\main\res\values",
            "$fullProjectPath\app\src\main\res\mipmap-hdpi",
            "$fullProjectPath\app\src\main\res\mipmap-mdpi",
            "$fullProjectPath\app\src\main\res\mipmap-xhdpi",
            "$fullProjectPath\app\src\main\res\mipmap-xxhdpi",
            "$fullProjectPath\app\src\main\res\mipmap-xxxhdpi",
            "$fullProjectPath\gradle\wrapper"
        )
        
        foreach ($dir in $directories) {
            if (-not (Test-Path $dir)) {
                New-Item -ItemType Directory -Path $dir -Force | Out-Null
            }
        }
        
        Write-ActivityLog -Message "ساختار دایرکتوری ایجاد شد" -Level "SUCCESS"
        return $fullProjectPath
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::FileError) -ErrorMessage $_.Exception.Message -Context "Project Structure Creation"
        return $null
    }
}

# ایجاد فایل AndroidManifest.xml
function New-AndroidManifest {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد AndroidManifest.xml..." -Level "INFO"
    
    $manifestContent = @"
<?xml version="1.0" encoding="utf-8"?>
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="$($Global:HelloWorldConfig.PackageName)">

    <application
        android:allowBackup="true"
        android:icon="@mipmap/ic_launcher"
        android:label="@string/app_name"
        android:theme="@style/AppTheme">
        <activity
            android:name=".$($Global:HelloWorldConfig.ActivityName)"
            android:exported="true">
            <intent-filter>
                <action android:name="android.intent.action.MAIN" />
                <category android:name="android.intent.category.LAUNCHER" />
            </intent-filter>
        </activity>
    </application>

</manifest>
"@

    $manifestPath = Join-Path $ProjectPath "app\src\main\AndroidManifest.xml"
    $manifestContent | Out-File -FilePath $manifestPath -Encoding UTF8
    
    Write-ActivityLog -Message "AndroidManifest.xml ایجاد شد" -Level "SUCCESS"
}

# ایجاد MainActivity.java
function New-MainActivity {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد MainActivity.java..." -Level "INFO"
    
    $activityContent = @"
package $($Global:HelloWorldConfig.PackageName);

import android.app.Activity;
import android.os.Bundle;

public class $($Global:HelloWorldConfig.ActivityName) extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);
    }
}
"@

    $activityPath = Join-Path $ProjectPath "app\src\main\java\com\example\helloworld\$($Global:HelloWorldConfig.ActivityName).java"
    $activityContent | Out-File -FilePath $activityPath -Encoding UTF8
    
    Write-ActivityLog -Message "MainActivity.java ایجاد شد" -Level "SUCCESS"
}

# ایجاد activity_main.xml
function New-MainLayout {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد activity_main.xml..." -Level "INFO"
    
    $layoutContent = @"
<?xml version="1.0" encoding="utf-8"?>
<LinearLayout xmlns:android="http://schemas.android.com/apk/res/android"
    android:layout_width="match_parent"
    android:layout_height="match_parent"
    android:orientation="vertical"
    android:gravity="center"
    android:padding="16dp">

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/hello_world"
        android:textSize="24sp"
        android:textStyle="bold"
        android:textColor="#333333" />

    <TextView
        android:layout_width="wrap_content"
        android:layout_height="wrap_content"
        android:text="@string/app_description"
        android:textSize="16sp"
        android:textColor="#666666"
        android:layout_marginTop="16dp" />

</LinearLayout>
"@

    $layoutPath = Join-Path $ProjectPath "app\src\main\res\layout\activity_main.xml"
    $layoutContent | Out-File -FilePath $layoutPath -Encoding UTF8
    
    Write-ActivityLog -Message "activity_main.xml ایجاد شد" -Level "SUCCESS"
}

# ایجاد strings.xml
function New-StringsResource {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد strings.xml..." -Level "INFO"
    
    $stringsContent = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">Hello World Test</string>
    <string name="hello_world">Hello World!</string>
    <string name="app_description">این یک پروژه تست برای بررسی سازگاری ابزارهای اندروید است</string>
</resources>
"@

    $stringsPath = Join-Path $ProjectPath "app\src\main\res\values\strings.xml"
    $stringsContent | Out-File -FilePath $stringsPath -Encoding UTF8
    
    Write-ActivityLog -Message "strings.xml ایجاد شد" -Level "SUCCESS"
}

# ایجاد styles.xml
function New-StylesResource {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد styles.xml..." -Level "INFO"
    
    $stylesContent = @"
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <style name="AppTheme" parent="android:Theme.Material.Light.DarkActionBar">
        <item name="android:colorPrimary">#2196F3</item>
        <item name="android:colorPrimaryDark">#1976D2</item>
        <item name="android:colorAccent">#FF4081</item>
    </style>
</resources>
"@

    $stylesPath = Join-Path $ProjectPath "app\src\main\res\values\styles.xml"
    $stylesContent | Out-File -FilePath $stylesPath -Encoding UTF8
    
    Write-ActivityLog -Message "styles.xml ایجاد شد" -Level "SUCCESS"
}

# ایجاد build.gradle (app level)
function New-AppBuildGradle {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد app/build.gradle..." -Level "INFO"
    
    $buildGradleContent = @"
apply plugin: 'com.android.application'

android {
    compileSdkVersion $($Global:HelloWorldConfig.CompileSdkVersion)
    
    defaultConfig {
        applicationId "$($Global:HelloWorldConfig.PackageName)"
        minSdkVersion $($Global:HelloWorldConfig.MinSdkVersion)
        targetSdkVersion $($Global:HelloWorldConfig.TargetSdkVersion)
        versionCode 1
        versionName "1.0"
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
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
"@

    $buildGradlePath = Join-Path $ProjectPath "app\build.gradle"
    $buildGradleContent | Out-File -FilePath $buildGradlePath -Encoding UTF8
    
    Write-ActivityLog -Message "app/build.gradle ایجاد شد" -Level "SUCCESS"
}

# ایجاد build.gradle (project level)
function New-ProjectBuildGradle {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد project build.gradle..." -Level "INFO"
    
    $projectBuildGradleContent = @"
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

task clean(type: Delete) {
    delete rootProject.buildDir
}
"@

    $projectBuildGradlePath = Join-Path $ProjectPath "build.gradle"
    $projectBuildGradleContent | Out-File -FilePath $projectBuildGradlePath -Encoding UTF8
    
    Write-ActivityLog -Message "project build.gradle ایجاد شد" -Level "SUCCESS"
}

# ایجاد settings.gradle
function New-SettingsGradle {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد settings.gradle..." -Level "INFO"
    
    $settingsContent = @"
include ':app'
rootProject.name = "$($Global:HelloWorldConfig.ProjectName)"
"@

    $settingsPath = Join-Path $ProjectPath "settings.gradle"
    $settingsContent | Out-File -FilePath $settingsPath -Encoding UTF8
    
    Write-ActivityLog -Message "settings.gradle ایجاد شد" -Level "SUCCESS"
}

# ایجاد gradle.properties
function New-GradleProperties {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد gradle.properties..." -Level "INFO"
    
    $propertiesContent = @"
# Project-wide Gradle settings.
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.parallel=true
org.gradle.caching=true
android.useAndroidX=true
android.enableJetifier=true
"@

    $propertiesPath = Join-Path $ProjectPath "gradle.properties"
    $propertiesContent | Out-File -FilePath $propertiesPath -Encoding UTF8
    
    Write-ActivityLog -Message "gradle.properties ایجاد شد" -Level "SUCCESS"
}

# ایجاد Gradle Wrapper
function New-GradleWrapper {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "ایجاد Gradle Wrapper..." -Level "INFO"
    
    # gradle-wrapper.properties
    $wrapperPropertiesContent = @"
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.0-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
"@

    $wrapperPropertiesPath = Join-Path $ProjectPath "gradle\wrapper\gradle-wrapper.properties"
    $wrapperPropertiesContent | Out-File -FilePath $wrapperPropertiesPath -Encoding UTF8
    
    # gradlew.bat
    $gradlewBatContent = @"
@rem
@rem Copyright 2015 the original author or authors.
@rem
@rem Licensed under the Apache License, Version 2.0 (the "License");
@rem you may not use this file except in compliance with the License.
@rem You may obtain a copy of the License at
@rem
@rem      https://www.apache.org/licenses/LICENSE-2.0
@rem
@rem Unless required by applicable law or agreed to in writing, software
@rem distributed under the License is distributed on an "AS IS" BASIS,
@rem WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
@rem See the License for the specific language governing permissions and
@rem limitations under the License.
@rem

@if "%DEBUG%" == "" @echo off
@rem ##########################################################################
@rem
@rem  Gradle startup script for Windows
@rem
@rem ##########################################################################

@rem Set local scope for the variables with windows NT shell
if "%OS%"=="Windows_NT" setlocal

set DIRNAME=%~dp0
if "%DIRNAME%" == "" set DIRNAME=.
set APP_BASE_NAME=%~n0
set APP_HOME=%DIRNAME%

@rem Resolve any "." and ".." in APP_HOME to make it shorter.
for %%i in ("%APP_HOME%") do set APP_HOME=%%~fi

@rem Add default JVM options here. You can also use JAVA_OPTS and GRADLE_OPTS to pass JVM options to this script.
set DEFAULT_JVM_OPTS="-Xmx64m" "-Xms64m"

@rem Find java.exe
if defined JAVA_HOME goto findJavaFromJavaHome

set JAVA_EXE=java.exe
%JAVA_EXE% -version >NUL 2>&1
if "%ERRORLEVEL%" == "0" goto execute

echo.
echo ERROR: JAVA_HOME is not set and no 'java' command could be found in your PATH.
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:findJavaFromJavaHome
set JAVA_HOME=%JAVA_HOME:"=%
set JAVA_EXE=%JAVA_HOME%/bin/java.exe

if exist "%JAVA_EXE%" goto execute

echo.
echo ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME%
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.

goto fail

:execute
@rem Setup the command line

set CLASSPATH=%APP_HOME%\gradle\wrapper\gradle-wrapper.jar


@rem Execute Gradle
"%JAVA_EXE%" %DEFAULT_JVM_OPTS% %JAVA_OPTS% %GRADLE_OPTS% "-Dorg.gradle.appname=%APP_BASE_NAME%" -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

:end
@rem End local scope for the variables with windows NT shell
if "%ERRORLEVEL%"=="0" goto mainEnd

:fail
rem Set variable GRADLE_EXIT_CONSOLE if you need the _script_ return code instead of
rem the _cmd_ return code when the batch returns a non-zero return code.
if not "" == "%GRADLE_EXIT_CONSOLE%" exit 1
exit /b 1

:mainEnd
if "%OS%"=="Windows_NT" endlocal

:omega
"@

    $gradlewBatPath = Join-Path $ProjectPath "gradlew.bat"
    $gradlewBatContent | Out-File -FilePath $gradlewBatPath -Encoding UTF8
    
    Write-ActivityLog -Message "Gradle Wrapper ایجاد شد" -Level "SUCCESS"
}

# بیلد پروژه Hello World
function Build-HelloWorldProject {
    param([string]$ProjectPath)
    
    Write-ActivityLog -Message "شروع بیلد پروژه Hello World..." -Level "INFO"
    
    try {
        # تغییر دایرکتوری به پروژه
        $currentLocation = Get-Location
        Set-Location $ProjectPath
        
        # اجرای Gradle build
        Write-ActivityLog -Message "اجرای gradle assembleDebug..." -Level "INFO"
        
        $buildCommand = ".\gradlew.bat assembleDebug --stacktrace"
        $buildResult = Invoke-Expression $buildCommand 2>&1
        
        # بررسی نتیجه بیلد
        if ($LASTEXITCODE -eq 0) {
            Write-ActivityLog -Message "بیلد با موفقیت انجام شد" -Level "SUCCESS"
            
            # بررسی وجود فایل APK
            $apkPath = Join-Path $ProjectPath "app\build\outputs\apk\debug\app-debug.apk"
            if (Test-Path $apkPath) {
                $apkSize = (Get-Item $apkPath).Length
                Write-ActivityLog -Message "فایل APK تولید شد: $([math]::Round($apkSize/1MB, 2)) MB" -Level "SUCCESS"
                
                # اعتبارسنجی APK
                $apkValidation = Test-ApkFile -ApkPath $apkPath
                
                # بازگشت به دایرکتوری قبلی
                Set-Location $currentLocation
                
                return @{
                    Success = $true
                    ApkPath = $apkPath
                    ApkSize = $apkSize
                    ApkValid = $apkValidation.Valid
                    BuildOutput = $buildResult
                }
            }
            else {
                throw "فایل APK تولید نشد"
            }
        }
        else {
            throw "بیلد ناموفق بود. Exit Code: $LASTEXITCODE`n$buildResult"
        }
    }
    catch {
        # بازگشت به دایرکتوری قبلی در صورت خطا
        Set-Location $currentLocation
        
        Handle-Error -ErrorType ([ErrorType]::BuildError) -ErrorMessage $_.Exception.Message -Context "Hello World Build" -Details @{ BuildOutput = $buildResult }
        return @{
            Success = $false
            Error = $_.Exception.Message
            BuildOutput = $buildResult
        }
    }
}

# اعتبارسنجی فایل APK
function Test-ApkFile {
    param([string]$ApkPath)
    
    Write-ActivityLog -Message "اعتبارسنجی فایل APK..." -Level "INFO"
    
    try {
        if (-not (Test-Path $ApkPath)) {
            throw "فایل APK وجود ندارد"
        }
        
        $fileInfo = Get-Item $ApkPath
        
        # بررسی اندازه فایل (حداقل 1MB)
        if ($fileInfo.Length -lt 1MB) {
            throw "فایل APK کوچک‌تر از حد مورد انتظار است"
        }
        
        # بررسی پسوند فایل
        if ($fileInfo.Extension -ne ".apk") {
            throw "پسوند فایل صحیح نیست"
        }
        
        # تست یکپارچگی ZIP (APK در واقع یک فایل ZIP است)
        try {
            Add-Type -AssemblyName System.IO.Compression.FileSystem
            $zip = [System.IO.Compression.ZipFile]::OpenRead($ApkPath)
            $entryCount = $zip.Entries.Count
            $zip.Dispose()
            
            if ($entryCount -eq 0) {
                throw "فایل APK خالی است"
            }
            
            Write-ActivityLog -Message "فایل APK معتبر است - $entryCount فایل داخلی" -Level "SUCCESS"
            return @{
                Valid = $true
                FileSize = $fileInfo.Length
                EntryCount = $entryCount
            }
        }
        catch {
            throw "فایل APK خراب است: $($_.Exception.Message)"
        }
    }
    catch {
        Write-ActivityLog -Message "خطا در اعتبارسنجی APK: $($_.Exception.Message)" -Level "ERROR"
        return @{
            Valid = $false
            Error = $_.Exception.Message
        }
    }
}

# ایجاد کامل پروژه Hello World
function New-CompleteHelloWorldProject {
    param(
        [string]$ProjectPath,
        [string]$ProjectName = $Global:HelloWorldConfig.ProjectName
    )
    
    Write-ActivityLog -Message "شروع ایجاد پروژه کامل Hello World..." -Level "INFO"
    
    try {
        # ایجاد ساختار پروژه
        $fullProjectPath = New-AndroidProjectStructure -ProjectPath $ProjectPath -ProjectName $ProjectName
        if (-not $fullProjectPath) {
            throw "ایجاد ساختار پروژه ناموفق بود"
        }
        
        # ایجاد فایل‌های پروژه
        New-AndroidManifest -ProjectPath $fullProjectPath
        New-MainActivity -ProjectPath $fullProjectPath
        New-MainLayout -ProjectPath $fullProjectPath
        New-StringsResource -ProjectPath $fullProjectPath
        New-StylesResource -ProjectPath $fullProjectPath
        New-AppBuildGradle -ProjectPath $fullProjectPath
        New-ProjectBuildGradle -ProjectPath $fullProjectPath
        New-SettingsGradle -ProjectPath $fullProjectPath
        New-GradleProperties -ProjectPath $fullProjectPath
        New-GradleWrapper -ProjectPath $fullProjectPath
        
        Write-ActivityLog -Message "پروژه Hello World با موفقیت ایجاد شد" -Level "SUCCESS"
        
        # بیلد پروژه
        $buildResult = Build-HelloWorldProject -ProjectPath $fullProjectPath
        
        return @{
            Success = $buildResult.Success
            ProjectPath = $fullProjectPath
            BuildResult = $buildResult
        }
    }
    catch {
        Handle-Error -ErrorType ([ErrorType]::BuildError) -ErrorMessage $_.Exception.Message -Context "Complete Hello World Project Creation"
        return @{
            Success = $false
            Error = $_.Exception.Message
        }
    }
}

# Export functions
Export-ModuleMember -Function New-AndroidProjectStructure, New-CompleteHelloWorldProject, Build-HelloWorldProject, Test-ApkFile