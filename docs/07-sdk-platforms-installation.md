# نصب SDK Platforms

## مقدمه

Android SDK Platforms شامل کتابخانه‌ها، API ها و ابزارهای مورد نیاز برای توسعه برنامه‌های اندروید برای نسخه‌های مختلف سیستم‌عامل است. این راهنما شما را در فرآیند نصب آفلاین SDK Platforms برای API 33، 30 و 27 در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 300 مگابایت فضای خالی در هارد دیسک
- **Command Line Tools نصب شده** (مراجعه کنید به [راهنمای نصب Command Line Tools](04-commandline-tools-installation.md))
- متغیر محیطی ANDROID_HOME تنظیم شده
- فایل‌های SDK Platform در پوشه `downloaded/`

## فایل‌های مورد نیاز

- **API 33**: `sdk-platform-33.zip` (حدود 70 مگابایت)
- **API 30**: `sdk-platform-30.zip` (حدود 65 مگابایت)  
- **API 27**: `sdk-platform-27.zip` (حدود 60 مگابایت)

## مراحل نصب

### مرحله 1: بررسی پیش‌نیازها

1. اطمینان حاصل کنید که ANDROID_HOME تنظیم شده است:
   ```cmd
   echo %ANDROID_HOME%
   ```

2. بررسی کنید که پوشه SDK وجود دارد:
   ```cmd
   dir "%ANDROID_HOME%"
   ```

### مرحله 2: آماده‌سازی پوشه نصب

1. پوشه platforms را در SDK ایجاد کنید (اگر وجود ندارد):
   ```cmd
   mkdir "%ANDROID_HOME%\platforms"
   ```

2. پوشه‌های مربوط به هر API را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\platforms\android-33"
   mkdir "%ANDROID_HOME%\platforms\android-30"
   mkdir "%ANDROID_HOME%\platforms\android-27"
   ```

### مرحله 3: نصب SDK Platform API 33

1. فایل `sdk-platform-33.zip` را پیدا کنید:
   ```
   downloaded/sdk-platform-33.zip
   ```

2. فایل ZIP را استخراج کنید.

3. محتویات استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\platforms\android-33\
   ```

4. ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\platforms\android-33\
   ├── android.jar
   ├── build.prop
   ├── data\
   ├── optional\
   ├── skins\
   ├── templates\
   ├── NOTICE.txt
   └── source.properties
   ```

### مرحله 4: نصب SDK Platform API 30

1. فایل `sdk-platform-30.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/sdk-platform-30/sdk-platform-30.zip
   ```

2. فایل ZIP را استخراج کنید.

3. محتویات استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\platforms\android-30\
   ```

### مرحله 5: نصب SDK Platform API 27

1. فایل `sdk-platform-27.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/extracted_SDK Platform android-27/sdk-platform-27.zip
   ```

2. فایل ZIP را استخراج کنید.

3. محتویات استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\platforms\android-27\
   ```

### مرحله 6: بررسی نهایی ساختار

پس از نصب تمام platforms، ساختار کلی باید به شکل زیر باشد:

```
D:\Android\Sdk\platforms\
├── android-33\
│   ├── android.jar
│   ├── build.prop
│   ├── data\
│   ├── optional\
│   ├── skins\
│   ├── templates\
│   ├── NOTICE.txt
│   └── source.properties
├── android-30\
│   ├── android.jar
│   ├── build.prop
│   ├── data\
│   ├── optional\
│   ├── skins\
│   ├── templates\
│   ├── NOTICE.txt
│   └── source.properties
└── android-27\
    ├── android.jar
    ├── build.prop
    ├── data\
    ├── optional\
    ├── skins\
    ├── templates\
    ├── NOTICE.txt
    └── source.properties
```

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب SDK Platforms قابل اجرا هستند:

#### 1. بررسی وجود فایل android.jar برای هر API

```cmd
dir "%ANDROID_HOME%\platforms\android-33\android.jar"
dir "%ANDROID_HOME%\platforms\android-30\android.jar"
dir "%ANDROID_HOME%\platforms\android-27\android.jar"
```

**نتیجه مورد انتظار**: تمام فایل‌های android.jar وجود داشته باشند.

**در صورت خطا**: اگر فایلی یافت نشد، استخراج و کپی درست انجام نشده است.

#### 2. بررسی فایل source.properties

```cmd
type "%ANDROID_HOME%\platforms\android-33\source.properties"
type "%ANDROID_HOME%\platforms\android-30\source.properties"
type "%ANDROID_HOME%\platforms\android-27\source.properties"
```

**نتیجه مورد انتظار برای API 33**:
```
Pkg.UserSrc=false
Platform.Version=13
AndroidVersion.ApiLevel=33
Layoutlib.Api=15
Layoutlib.Revision=1
```

#### 3. بررسی اندازه فایل‌های android.jar

```cmd
dir "%ANDROID_HOME%\platforms\android-33\android.jar" | findstr android.jar
dir "%ANDROID_HOME%\platforms\android-30\android.jar" | findstr android.jar
dir "%ANDROID_HOME%\platforms\android-27\android.jar" | findstr android.jar
```

**نتیجه مورد انتظار**: فایل‌ها باید اندازه مناسب داشته باشند (معمولاً چند مگابایت).

#### 4. بررسی فایل build.prop

```cmd
type "%ANDROID_HOME%\platforms\android-33\build.prop" | findstr "ro.build.version"
type "%ANDROID_HOME%\platforms\android-30\build.prop" | findstr "ro.build.version"
type "%ANDROID_HOME%\platforms\android-27\build.prop" | findstr "ro.build.version"
```

**نتیجه مورد انتظار**: اطلاعات نسخه Android برای هر API نمایش داده شود.

#### 5. بررسی ساختار پوشه‌ها

```cmd
dir "%ANDROID_HOME%\platforms\android-33" | findstr "data optional skins templates"
dir "%ANDROID_HOME%\platforms\android-30" | findstr "data optional skins templates"
dir "%ANDROID_HOME%\platforms\android-27" | findstr "data optional skins templates"
```

**نتیجه مورد انتظار**: پوشه‌های ضروری برای هر API وجود داشته باشند.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با SDK Manager (پیش‌نیاز: نصب Command Line Tools)

```cmd
sdkmanager --list --offline | findstr platforms
```

**نتیجه مورد انتظار**:
```
platforms;android-33 | 2 | Android SDK Platform 33 | platforms\android-33\
platforms;android-30 | 3 | Android SDK Platform 30 | platforms\android-30\
platforms;android-27 | 3 | Android SDK Platform 27 | platforms\android-27\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست با Android Studio (پیش‌نیاز: نصب Android Studio)

1. Android Studio را باز کنید
2. به `File > Project Structure > Modules` بروید
3. در قسمت "Compile Sdk Version" باید API های نصب شده نمایش داده شوند

**کامپوننت‌های پیش‌نیاز**:
- [نصب Android Studio](02-android-studio-installation.md)

#### تست با Gradle (پیش‌نیاز: پروژه Android)

در فایل `build.gradle` پروژه:

```gradle
android {
    compileSdkVersion 33  // یا 30 یا 27
    
    defaultConfig {
        targetSdkVersion 33  // یا 30 یا 27
        minSdkVersion 27
    }
}
```

**نتیجه مورد انتظار**: Gradle sync بدون خطا انجام شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)
- پروژه Android معتبر

#### تست با aapt (پیش‌نیاز: نصب Build Tools)

```cmd
"%ANDROID_HOME%\build-tools\33.0.2\aapt.exe" dump badging "%ANDROID_HOME%\platforms\android-33\android.jar"
```

**نتیجه مورد انتظار**: اطلاعات android.jar نمایش داده شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Build Tools](06-build-tools-installation.md)

#### تست بیلد پروژه (پیش‌نیاز: محیط کامل Android)

```cmd
gradle assembleDebug
```

**نتیجه مورد انتظار**: APK با موفقیت تولید شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب Repositories](09-repositories-installation.md)
- [نصب SDK Licenses](10-sdk-licenses-installation.md)
- پروژه Android کامل

#### تست target selection در AVD (پیش‌نیاز: نصب System Images)

```cmd
avdmanager list target
```

**نتیجه مورد انتظار**: تمام API های نصب شده به عنوان target نمایش داده شوند.

**کامپوننت‌های پیش‌نیاز**:
- [نصب System Images](08-system-images-installation.md)

## کاربردهای SDK Platforms

### استفاده در پروژه‌های Android

```gradle
android {
    // تنظیم API مورد استفاده برای کامپایل
    compileSdkVersion 33
    
    defaultConfig {
        // حداقل نسخه پشتیبانی شده
        minSdkVersion 27
        
        // نسخه هدف
        targetSdkVersion 33
    }
}
```

### بررسی API های موجود

```cmd
# لیست تمام platforms نصب شده
sdkmanager --list --offline | findstr platforms

# اطلاعات جزئی یک platform
type "%ANDROID_HOME%\platforms\android-33\build.prop"
```

### استفاده از aapt برای بررسی

```cmd
# بررسی منابع یک APK با API خاص
"%ANDROID_HOME%\build-tools\33.0.2\aapt.exe" dump badging app.apk
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "Android SDK Platform not found"

**علت**: فایل android.jar وجود ندارد یا مسیر اشتباه است.

**راه‌حل**:
1. بررسی وجود فایل:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-33\android.jar"
   ```
2. بررسی ساختار پوشه‌ها.
3. در صورت نیاز، مجدداً استخراج و کپی کنید.

#### خطای "compileSdkVersion not found"

**علت**: نسخه SDK مشخص شده در Gradle نصب نشده است.

**راه‌حل**:
1. بررسی کنید که API مورد نظر نصب شده:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-XX"
   ```
2. نسخه را در `build.gradle` تغییر دهید.

#### خطای "Failed to find target with hash string"

**علت**: Android Studio نمی‌تواند SDK Platform را پیدا کند.

**راه‌حل**:
1. Android Studio را مجدداً راه‌اندازی کنید.
2. SDK Path را در Android Studio بررسی کنید:
   `File > Project Structure > SDK Location`
3. "Sync Project with Gradle Files" را اجرا کنید.

#### فایل android.jar خراب است

**علت**: فایل در حین کپی آسیب دیده است.

**راه‌حل**:
1. فایل ZIP اصلی را مجدداً استخراج کنید.
2. android.jar را مجدداً کپی کنید.
3. یکپارچگی فایل را بررسی کنید:
   ```cmd
   java -jar "%ANDROID_HOME%\platforms\android-33\android.jar"
   ```

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود تمام فایل‌های ضروری**:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-33\android.jar"
   dir "%ANDROID_HOME%\platforms\android-33\source.properties"
   dir "%ANDROID_HOME%\platforms\android-33\build.prop"
   ```

2. **بررسی اندازه فایل‌ها**:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-*\android.jar"
   ```

3. **بررسی محتویات source.properties**:
   ```cmd
   type "%ANDROID_HOME%\platforms\android-33\source.properties"
   ```

4. **تست با SDK Manager**:
   ```cmd
   sdkmanager --list --offline
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. پوشه مربوط به API مشکل‌دار را پاک کنید:
   ```cmd
   rmdir /s /q "%ANDROID_HOME%\platforms\android-33"
   ```
2. پوشه را مجدداً ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\platforms\android-33"
   ```
3. مراحل نصب را از ابتدا تکرار کنید.

## تنظیمات پیشرفته

### انتخاب API مناسب برای پروژه

```gradle
android {
    // جدیدترین API برای دسترسی به آخرین ویژگی‌ها
    compileSdkVersion 33
    
    defaultConfig {
        // حداقل API برای پشتیبانی از دستگاه‌های قدیمی‌تر
        minSdkVersion 27
        
        // API هدف (معمولاً مشابه compileSdkVersion)
        targetSdkVersion 33
    }
}
```

### استفاده از Support Library

```gradle
dependencies {
    // برای پشتیبانی از API های قدیمی‌تر
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.core:core:1.10.1'
}
```

## اطلاعات API ها

### Android API 33 (Android 13)

- **نام کدی**: Tiramisu
- **تاریخ انتشار**: 2022
- **ویژگی‌های کلیدی**: 
  - Themed app icons
  - Per-app language preferences
  - Notification runtime permission

### Android API 30 (Android 11)

- **نام کدی**: Red Velvet Cake
- **تاریخ انتشار**: 2020
- **ویژگی‌های کلیدی**:
  - Scoped storage enforcement
  - One-time permissions
  - Bubbles API

### Android API 27 (Android 8.1)

- **نام کدی**: Oreo
- **تاریخ انتشار**: 2017
- **ویژگی‌های کلیدی**:
  - Neural Networks API
  - Autofill framework
  - Notification channels

## نکات مهم

- هر API شامل کتابخانه‌های مخصوص آن نسخه اندروید است.
- فایل android.jar شامل تمام کلاس‌ها و متدهای API است.
- compileSdkVersion باید با جدیدترین API نصب شده تنظیم شود.
- minSdkVersion تعیین می‌کند که پروژه روی کدام نسخه‌های اندروید اجرا می‌شود.

## مرحله بعدی

پس از نصب موفق SDK Platforms، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب System Images](08-system-images-installation.md)
- [نصب Repositories](09-repositories-installation.md)
- [نصب SDK Licenses](10-sdk-licenses-installation.md)