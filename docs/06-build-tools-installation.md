# نصب Build Tools

## مقدمه

Android Build Tools مجموعه‌ای از ابزارهای ضروری برای کامپایل و بیلد پروژه‌های اندروید است. این ابزارها شامل aapt، dx، zipalign و سایر ابزارهای مورد نیاز برای تولید APK می‌شود. این راهنما شما را در فرآیند نصب آفلاین Build Tools 33.0.2 در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 200 مگابایت فضای خالی در هارد دیسک
- **Command Line Tools نصب شده** (مراجعه کنید به [راهنمای نصب Command Line Tools](04-commandline-tools-installation.md))
- متغیر محیطی ANDROID_HOME تنظیم شده
- فایل `build-tools-33.0.2.zip` در پوشه `downloaded/build-tools-33.0.2/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `build-tools-33.0.2.zip`
- **اندازه تقریبی**: حدود 60 مگابایت
- **نسخه**: Build Tools 33.0.2 (سازگار با API 33)

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

1. پوشه build-tools را در SDK ایجاد کنید (اگر وجود ندارد):
   ```cmd
   mkdir "%ANDROID_HOME%\build-tools"
   ```

2. پوشه نسخه 33.0.2 را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\build-tools\33.0.2"
   ```

### مرحله 3: استخراج فایل Build Tools

1. فایل `build-tools-33.0.2.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/build-tools-33.0.2/build-tools-33.0.2.zip
   ```

2. فایل ZIP را استخراج کنید.

3. محتویات استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\build-tools\33.0.2\
   ```

4. پس از کپی، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\build-tools\33.0.2\
   ├── aapt.exe
   ├── aapt2.exe
   ├── aidl.exe
   ├── apksigner.bat
   ├── d8.bat
   ├── dx.bat
   ├── lib\
   ├── renderscript\
   ├── zipalign.exe
   ├── NOTICE.txt
   └── source.properties
   ```

### مرحله 4: تنظیم متغیرهای محیطی (اختیاری)

Build Tools معمولاً از طریق Gradle یا Android Studio فراخوانی می‌شوند، اما برای استفاده مستقیم می‌توانید PATH را تنظیم کنید:

1. کلید `Windows + R` را فشار دهید و `sysdm.cpl` را تایپ کنید.
2. روی تب "Advanced" کلیک کنید.
3. روی "Environment Variables" کلیک کنید.
4. متغیر `PATH` را ویرایش کرده و مسیر زیر را اضافه کنید:
   ```
   %ANDROID_HOME%\build-tools\33.0.2
   ```

### مرحله 5: اعمال تغییرات

1. Command Prompt یا PowerShell را مجدداً باز کنید.

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب Build Tools قابل اجرا هستند:

#### 1. بررسی وجود فایل‌های ضروری

```cmd
dir "%ANDROID_HOME%\build-tools\33.0.2\aapt.exe"
dir "%ANDROID_HOME%\build-tools\33.0.2\aapt2.exe"
dir "%ANDROID_HOME%\build-tools\33.0.2\dx.bat"
dir "%ANDROID_HOME%\build-tools\33.0.2\zipalign.exe"
```

**نتیجه مورد انتظار**: تمام فایل‌های ضروری وجود داشته باشند.

#### 2. تست aapt (Android Asset Packaging Tool)
```cmd
"%ANDROID_HOME%\build-tools\33.0.2\aapt.exe" version
```

**نتیجه مورد انتظار**:
```
Android Asset Packaging Tool, v0.2-11156638
```

**در صورت خطا**: اگر فایل یافت نشد، استخراج و کپی درست انجام نشده است.

#### 3. تست aapt2
```cmd
"%ANDROID_HOME%\build-tools\33.0.2\aapt2.exe" version
```

**نتیجه مورد انتظار**:
```
Android Asset Packaging Tool 2 (aapt2) 8.0.2-10154469
```

#### 4. تست dx (DEX compiler)
```cmd
"%ANDROID_HOME%\build-tools\33.0.2\dx.bat" --version
```

**نتیجه مورد انتظار**:
```
dx version 1.16
```

#### 5. تست zipalign
```cmd
"%ANDROID_HOME%\build-tools\33.0.2\zipalign.exe"
```

**نتیجه مورد انتظار** (پیام help):
```
Zip alignment utility
Copyright (C) 2009 The Android Open Source Project
...
```

#### 6. تست d8 (جایگزین dx)
```cmd
"%ANDROID_HOME%\build-tools\33.0.2\d8.bat" --help
```

**نتیجه مورد انتظار**: راهنمای استفاده از d8 نمایش داده شود.

#### 7. بررسی فایل source.properties
```cmd
type "%ANDROID_HOME%\build-tools\33.0.2\source.properties"
```

**نتیجه مورد انتظار**:
```
Pkg.UserSrc=false
Pkg.Revision=33.0.2
```

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با SDK Manager (پیش‌نیاز: نصب Command Line Tools)
```cmd
sdkmanager --list --offline | findstr build-tools
```

**نتیجه مورد انتظار**:
```
build-tools;33.0.2 | 33.0.2 | Android SDK Build-Tools 33.0.2 | build-tools\33.0.2\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست با Gradle (پیش‌نیاز: پروژه Android)
در فایل `build.gradle` پروژه:
```gradle
android {
    compileSdkVersion 33
    buildToolsVersion "33.0.2"
}
```

**نتیجه مورد انتظار**: Gradle sync بدون خطا انجام شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- پروژه Android معتبر

#### تست بیلد ساده (پیش‌نیاز: پروژه Android کامل)
```cmd
gradle assembleDebug
```

**نتیجه مورد انتظار**: APK با موفقیت تولید شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب Repositories](09-repositories-installation.md)
- [نصب SDK Licenses](10-sdk-licenses-installation.md)
- پروژه Android کامل

#### تست aapt با android.jar (پیش‌نیاز: نصب SDK Platform)
```cmd
"%ANDROID_HOME%\build-tools\33.0.2\aapt.exe" dump badging "%ANDROID_HOME%\platforms\android-33\android.jar"
```

**نتیجه مورد انتظار**: اطلاعات android.jar نمایش داده شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب SDK Platforms](07-sdk-platforms-installation.md)

#### تست dx با فایل JAR (پیش‌نیاز: فایل JAR موجود)
```cmd
echo class Test {} > Test.java
javac Test.java
jar cf test.jar Test.class
"%ANDROID_HOME%\build-tools\33.0.2\dx.bat" --dex --output=classes.dex test.jar
del Test.java Test.class test.jar classes.dex
```

**نتیجه مورد انتظار**: فایل DEX با موفقیت تولید شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب JDK 17](01-jdk17-installation.md)

## کاربردهای Build Tools

### aapt (Android Asset Packaging Tool)

```cmd
# نمایش اطلاعات APK
aapt dump badging app.apk

# نمایش منابع APK
aapt dump resources app.apk

# نمایش مجوزهای APK
aapt dump permissions app.apk

# ایجاد فایل resources.arsc
aapt package -f -m -J gen -S res -M AndroidManifest.xml -I android.jar
```

### aapt2 (نسخه جدید aapt)

```cmd
# کامپایل منابع
aapt2 compile --dir res -o compiled.zip

# لینک کردن منابع
aapt2 link -I android.jar --manifest AndroidManifest.xml -o app.apk compiled.zip
```

### dx (DEX Compiler)

```cmd
# تبدیل JAR به DEX
dx --dex --output=classes.dex input.jar

# تبدیل چندین JAR
dx --dex --output=classes.dex lib1.jar lib2.jar

# تنظیمات حافظه
dx --dex --output=classes.dex --max-memory=2048m input.jar
```

### zipalign (بهینه‌سازی APK)

```cmd
# بررسی alignment
zipalign -c -v 4 app.apk

# اعمال alignment
zipalign -v 4 app-unaligned.apk app-aligned.apk

# بررسی و نمایش جزئیات
zipalign -c -v 4 app.apk
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "aapt is not recognized"

**علت**: PATH تنظیم نشده یا فایل وجود ندارد.

**راه‌حل**:
1. بررسی وجود فایل:
   ```cmd
   dir "%ANDROID_HOME%\build-tools\33.0.2\aapt.exe"
   ```
2. استفاده از مسیر کامل:
   ```cmd
   "%ANDROID_HOME%\build-tools\33.0.2\aapt.exe" version
   ```

#### خطای "dx: command not found"

**علت**: فایل dx.bat وجود ندارد یا PATH تنظیم نشده.

**راه‌حل**:
1. بررسی وجود فایل:
   ```cmd
   dir "%ANDROID_HOME%\build-tools\33.0.2\dx.bat"
   ```
2. استفاده از مسیر کامل:
   ```cmd
   "%ANDROID_HOME%\build-tools\33.0.2\dx.bat" --version
   ```

#### خطای "Java heap space" در dx

**علت**: حافظه کافی برای dx تخصیص نیافته.

**راه‌حل**:
1. افزایش حافظه:
   ```cmd
   dx --dex --output=classes.dex --max-memory=4096m input.jar
   ```
2. یا تنظیم متغیر محیطی:
   ```cmd
   set _JAVA_OPTIONS=-Xmx4096m
   ```

#### خطای "aapt: error: resource not found"

**علت**: فایل android.jar یا منابع مورد نیاز وجود ندارد.

**راه‌حل**:
1. اطمینان از نصب SDK Platform مربوطه.
2. بررسی مسیر android.jar:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-33\android.jar"
   ```

#### خطای "zipalign: Unable to open"

**علت**: فایل APK وجود ندارد یا دسترسی نوشتن نیست.

**راه‌حل**:
1. بررسی وجود فایل ورودی.
2. اطمینان از دسترسی نوشتن به پوشه خروجی.

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود تمام فایل‌های ضروری**:
   ```cmd
   dir "%ANDROID_HOME%\build-tools\33.0.2\aapt.exe"
   dir "%ANDROID_HOME%\build-tools\33.0.2\aapt2.exe"
   dir "%ANDROID_HOME%\build-tools\33.0.2\dx.bat"
   dir "%ANDROID_HOME%\build-tools\33.0.2\zipalign.exe"
   dir "%ANDROID_HOME%\build-tools\33.0.2\lib\*.jar"
   ```

2. **بررسی فایل source.properties**:
   ```cmd
   type "%ANDROID_HOME%\build-tools\33.0.2\source.properties"
   ```

3. **تست تمام ابزارها**:
   ```cmd
   "%ANDROID_HOME%\build-tools\33.0.2\aapt.exe" version
   "%ANDROID_HOME%\build-tools\33.0.2\aapt2.exe" version
   "%ANDROID_HOME%\build-tools\33.0.2\dx.bat" --version
   "%ANDROID_HOME%\build-tools\33.0.2\zipalign.exe"
   ```

4. **بررسی وابستگی‌های Java**:
   ```cmd
   java -version
   echo %JAVA_HOME%
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. پوشه `%ANDROID_HOME%\build-tools\33.0.2` را کاملاً پاک کنید.
2. مراحل نصب را از ابتدا تکرار کنید.
3. در صورت مشکل، کل پوشه `build-tools` را پاک کرده و مجدداً ایجاد کنید.

## تنظیمات پیشرفته

### تنظیم حافظه برای dx

فایل `dx.bat` را ویرایش کرده و تنظیمات حافظه را تغییر دهید:

```batch
set defaultXmx=-Xmx4096M
set defaultXss=-Xss1m
```

### استفاده از d8 به جای dx

d8 جایگزین جدیدتر dx است:

```cmd
# استفاده از d8
"%ANDROID_HOME%\build-tools\33.0.2\d8.bat" --output classes.dex input.jar
```

## نکات مهم

- Build Tools برای کامپایل و بیلد پروژه‌های اندروید ضروری است.
- نسخه Build Tools باید با compileSdkVersion پروژه سازگار باشد.
- aapt2 نسخه جدیدتر و بهتر aapt است.
- dx در حال deprecated شدن است و d8 جایگزین آن می‌شود.
- zipalign برای بهینه‌سازی APK ضروری است.

## مرحله بعدی

پس از نصب موفق Build Tools، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب System Images](08-system-images-installation.md)
- [نصب Repositories](09-repositories-installation.md)