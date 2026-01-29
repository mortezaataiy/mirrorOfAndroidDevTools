# ایجاد و بیلد پروژه Hello World

## مقدمه

پروژه Hello World تست نهایی و جامع برای تأیید صحت نصب تمام کامپوننت‌های Android Development Tools است. این راهنما شما را در فرآیند کامل ایجاد، بیلد و تست یک اپلیکیشن Android ساده راهنمایی می‌کند.

## پیش‌نیازها

قبل از شروع، اطمینان حاصل کنید که کامپوننت‌های زیر نصب و تست شده‌اند:
- JDK 17
- Gradle 8.0.2
- Command Line Tools
- Platform Tools
- Build Tools 33.0.2
- SDK Platform (حداقل API 33)
- SDK Licenses

## ایجاد پروژه

### 1. ایجاد ساختار پروژه

ابتدا پوشه پروژه را ایجاد کنید:

```cmd
mkdir D:\AndroidProjects\HelloWorld
cd D:\AndroidProjects\HelloWorld
```

### 2. ایجاد فایل‌های پروژه

#### 2.1 ایجاد فایل build.gradle (پروژه)

فایل `build.gradle` را در ریشه پروژه ایجاد کنید:

```gradle
// Top-level build file where you can add configuration options common to all sub-projects/modules.
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

task clean(type: Delete) {
    delete rootProject.buildDir
}
```

#### 2.2 ایجاد فایل settings.gradle

```gradle
include ':app'
rootProject.name = "HelloWorld"
```

#### 2.3 ایجاد فایل gradle.properties

```properties
# Project-wide Gradle settings.
android.useAndroidX=true
android.enableJetifier=true
org.gradle.jvmargs=-Xmx2048m -Dfile.encoding=UTF-8
org.gradle.parallel=true
```

### 3. ایجاد ماژول app

#### 3.1 ایجاد ساختار پوشه‌ها

```cmd
mkdir app
mkdir app\src
mkdir app\src\main
mkdir app\src\main\java
mkdir app\src\main\java\com
mkdir app\src\main\java\com\example
mkdir app\src\main\java\com\example\helloworld
mkdir app\src\main\res
mkdir app\src\main\res\layout
mkdir app\src\main\res\values
```

#### 3.2 ایجاد فایل build.gradle (app)

فایل `app\build.gradle` را ایجاد کنید:

```gradle
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
    implementation 'com.google.android.material:material:1.8.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
```

#### 3.3 ایجاد AndroidManifest.xml

فایل `app\src\main\AndroidManifest.xml` را ایجاد کنید:

```xml
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
```

#### 3.4 ایجاد MainActivity.java

فایل `app\src\main\java\com\example\helloworld\MainActivity.java` را ایجاد کنید:

```java
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
```

#### 3.5 ایجاد Layout

فایل `app\src\main\res\layout\activity_main.xml` را ایجاد کنید:

```xml
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
        android:textSize="24sp"
        android:textStyle="bold"
        app:layout_constraintBottom_toBottomOf="parent"
        app:layout_constraintEnd_toEndOf="parent"
        app:layout_constraintStart_toStartOf="parent"
        app:layout_constraintTop_toTopOf="parent" />

</androidx.constraintlayout.widget.ConstraintLayout>
```

#### 3.6 ایجاد Resources

فایل `app\src\main\res\values\strings.xml` را ایجاد کنید:

```xml
<resources>
    <string name="app_name">Hello World</string>
</resources>
```

فایل `app\src\main\res\values\themes.xml` را ایجاد کنید:

```xml
<resources xmlns:tools="http://schemas.android.com/tools">
    <!-- Base application theme. -->
    <style name="Theme.HelloWorld" parent="Theme.MaterialComponents.DayNight.DarkActionBar">
        <!-- Primary brand color. -->
        <item name="colorPrimary">@color/purple_500</item>
        <item name="colorPrimaryVariant">@color/purple_700</item>
        <item name="colorOnPrimary">@color/white</item>
        <!-- Secondary brand color. -->
        <item name="colorSecondary">@color/teal_200</item>
        <item name="colorSecondaryVariant">@color/teal_700</item>
        <item name="colorOnSecondary">@color/black</item>
        <!-- Status bar color. -->
        <item name="android:statusBarColor" tools:targetApi="l">?attr/colorPrimaryVariant</item>
        <!-- Customize your theme here. -->
    </style>
</resources>
```

فایل `app\src\main\res\values\colors.xml` را ایجاد کنید:

```xml
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="purple_200">#FFBB86FC</color>
    <color name="purple_500">#FF6200EE</color>
    <color name="purple_700">#FF3700B3</color>
    <color name="teal_200">#FF03DAC5</color>
    <color name="teal_700">#FF018786</color>
    <color name="black">#FF000000</color>
    <color name="white">#FFFFFFFF</color>
</resources>
```

## بیلد پروژه

### 1. تنظیم متغیرهای محیطی

قبل از بیلد، اطمینان حاصل کنید که متغیرهای محیطی درست تنظیم شده‌اند:

```cmd
echo %JAVA_HOME%
echo %ANDROID_HOME%
echo %PATH%
```

### 2. دستورات بیلد

#### 2.1 بیلد کامل پروژه

```cmd
cd D:\AndroidProjects\HelloWorld
gradle build
```

#### 2.2 بیلد Debug

```cmd
gradle assembleDebug
```

#### 2.3 بیلد Release

```cmd
gradle assembleRelease
```

### 3. تولید APK

#### 3.1 تولید APK Debug

```cmd
gradle assembleDebug
```

فایل APK در مسیر زیر تولید می‌شود:
```
app\build\outputs\apk\debug\app-debug.apk
```

#### 3.2 تولید APK Release

```cmd
gradle assembleRelease
```

فایل APK در مسیر زیر تولید می‌شود:
```
app\build\outputs\apk\release\app-release-unsigned.apk
```

### 4. بررسی خروجی بیلد

پس از بیلد موفق، باید پیام‌های زیر را مشاهده کنید:

```
BUILD SUCCESSFUL in Xs
```

## تست APK

### 1. نصب APK روی دستگاه

#### 1.1 اتصال دستگاه Android

دستگاه Android را به کامپیوتر وصل کنید و USB Debugging را فعال کنید.

#### 1.2 تست اتصال

```cmd
adb devices
```

باید دستگاه شما در لیست نمایش داده شود.

#### 1.3 نصب APK

```cmd
adb install app\build\outputs\apk\debug\app-debug.apk
```

### 2. تست عملکرد

#### 2.1 اجرای اپلیکیشن

اپلیکیشن "Hello World" را از منوی دستگاه اجرا کنید.

#### 2.2 تأیید عملکرد

باید صفحه‌ای با متن "Hello World!" نمایش داده شود.

### 3. تست با شبیه‌ساز (اختیاری)

#### 3.1 ایجاد AVD

```cmd
avdmanager create avd -n test_avd -k "system-images;android-33;google_apis;x86_64"
```

#### 3.2 اجرای شبیه‌ساز

```cmd
emulator -avd test_avd
```

#### 3.3 نصب روی شبیه‌ساز

```cmd
adb install app\build\outputs\apk\debug\app-debug.apk
```

## تأیید عملکرد کامپوننت‌ها

این پروژه تأیید می‌کند که:

### ✅ JDK 17
- کامپایل کد Java
- اجرای Gradle

### ✅ Gradle 8.0.2
- مدیریت وابستگی‌ها
- اجرای تسک‌های بیلد

### ✅ Command Line Tools
- دسترسی به SDK Manager
- مدیریت پکیج‌ها

### ✅ Platform Tools
- اتصال به دستگاه (ADB)
- نصب APK

### ✅ Build Tools 33.0.2
- کامپایل منابع (AAPT)
- تولید DEX فایل‌ها

### ✅ SDK Platform API 33
- دسترسی به Android APIs
- کامپایل با Target SDK

### ✅ SDK Licenses
- دانلود وابستگی‌ها
- دسترسی به Google APIs

## عیب‌یابی

### مشکلات رایج

#### 1. خطای "JAVA_HOME not set"

**راه‌حل:**
```cmd
set JAVA_HOME=D:\Android\JDK17
```

#### 2. خطای "SDK location not found"

**راه‌حل:**
فایل `local.properties` را در ریشه پروژه ایجاد کنید:
```properties
sdk.dir=D:\\Android\\Sdk
```

#### 3. خطای "License not accepted"

**راه‌حل:**
```cmd
sdkmanager --licenses
```

#### 4. خطای "Build Tools not found"

**راه‌حل:**
بررسی نصب Build Tools:
```cmd
sdkmanager --list | findstr build-tools
```

#### 5. خطای "Platform not found"

**راه‌حل:**
بررسی نصب SDK Platform:
```cmd
sdkmanager --list | findstr platforms
```

### لاگ‌های مفید

#### بررسی جزئیات بیلد

```cmd
gradle build --info
```

#### بررسی وابستگی‌ها

```cmd
gradle dependencies
```

#### بررسی تسک‌های موجود

```cmd
gradle tasks
```

### تست‌های اضافی

#### تست کامپایل

```cmd
gradle compileDebugJava
```

#### تست منابع

```cmd
gradle processDebugResources
```

#### تست پکیج

```cmd
gradle packageDebug
```

---

## نتیجه‌گیری

اگر تمام مراحل بالا با موفقیت انجام شد و APK تولید و نصب شد، تبریک! محیط Android Development شما کاملاً آماده است.

این پروژه Hello World تأیید می‌کند که:
- تمام کامپوننت‌های ضروری نصب شده‌اند
- تنظیمات محیطی درست است
- فرآیند کامل توسعه Android قابل اجرا است

حالا می‌توانید پروژه‌های پیچیده‌تری ایجاد کنید!