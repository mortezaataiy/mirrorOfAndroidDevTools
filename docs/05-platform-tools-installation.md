# نصب Platform Tools

## مقدمه

Android Platform Tools مجموعه‌ای از ابزارهای ضروری برای توسعه اندروید است که شامل ADB (Android Debug Bridge)، Fastboot و سایر ابزارهای debugging می‌شود. این راهنما شما را در فرآیند نصب آفلاین Platform Tools در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 50 مگابایت فضای خالی در هارد دیسک
- **Command Line Tools نصب شده** (مراجعه کنید به [راهنمای نصب Command Line Tools](04-commandline-tools-installation.md))
- متغیر محیطی ANDROID_HOME تنظیم شده
- فایل `platform-tools.zip` در پوشه `downloaded/platform-tools/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `platform-tools.zip`
- **اندازه تقریبی**: حدود 15 مگابایت
- **محتویات**: ADB، Fastboot، و سایر ابزارهای platform

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

1. اطمینان حاصل کنید که پوشه platform-tools در SDK وجود دارد:
   ```
   D:\Android\Sdk\platform-tools
   ```

2. اگر پوشه وجود ندارد، آن را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\platform-tools"
   ```

### مرحله 3: استخراج فایل Platform Tools

1. فایل `platform-tools.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/platform-tools/platform-tools.zip
   ```

2. فایل ZIP را استخراج کنید. محتویات استخراج شده شامل پوشه `platform-tools` است.

3. محتویات پوشه `platform-tools` استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\platform-tools\
   ```

4. پس از کپی، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\platform-tools\
   ├── adb.exe
   ├── AdbWinApi.dll
   ├── AdbWinUsbApi.dll
   ├── fastboot.exe
   ├── mke2fs.exe
   ├── e2fsdroid.exe
   ├── NOTICE.txt
   └── source.properties
   ```

### مرحله 4: بررسی تنظیمات PATH

متغیر PATH باید قبلاً در مرحله نصب Command Line Tools تنظیم شده باشد. برای اطمینان:

1. بررسی کنید که مسیر platform-tools در PATH وجود دارد:
   ```cmd
   echo %PATH% | findstr platform-tools
   ```

2. اگر وجود ندارد، آن را اضافه کنید:
   - کلید `Windows + R` را فشار دهید و `sysdm.cpl` را تایپ کنید
   - روی تب "Advanced" کلیک کنید
   - روی "Environment Variables" کلیک کنید
   - متغیر `PATH` را ویرایش کرده و مسیر زیر را اضافه کنید:
     ```
     %ANDROID_HOME%\platform-tools
     ```

### مرحله 5: اعمال تغییرات

1. Command Prompt یا PowerShell را مجدداً باز کنید.

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب Platform Tools قابل اجرا هستند:

#### 1. بررسی نسخه ADB
```cmd
adb version
```

**نتیجه مورد انتظار**:
```
Android Debug Bridge version 1.0.41
Version 34.0.5-10900879
Installed as D:\Android\Sdk\platform-tools\adb.exe
```

**در صورت خطا**: اگر پیام "adb is not recognized" دریافت کردید، PATH درست تنظیم نشده است.

#### 2. بررسی نسخه Fastboot
```cmd
fastboot --version
```

**نتیجه مورد انتظار**:
```
fastboot version 34.0.5-10900879
Installed as D:\Android\Sdk\platform-tools\fastboot.exe
```

#### 3. تست اتصال ADB (بدون دستگاه)
```cmd
adb devices
```

**نتیجه مورد انتظار**:
```
List of devices attached

```

**توضیح**: لیست خالی نشان‌دهنده عملکرد صحیح ADB است (هیچ دستگاهی متصل نیست).

#### 4. بررسی وجود فایل‌های ضروری
```cmd
dir "%ANDROID_HOME%\platform-tools\adb.exe"
dir "%ANDROID_HOME%\platform-tools\fastboot.exe"
dir "%ANDROID_HOME%\platform-tools\*.dll"
```

**نتیجه مورد انتظار**: تمام فایل‌های ضروری وجود داشته باشند.

#### 5. تست help دستورات
```cmd
adb help
fastboot help
```

**نتیجه مورد انتظار**: راهنمای استفاده از هر دستور نمایش داده شود.

#### 6. تست ADB server
```cmd
adb start-server
adb kill-server
```

**نتیجه مورد انتظار**: ADB server بدون خطا راه‌اندازی و متوقف شود.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها یا اتصال دستگاه قابل اجرا هستند:

#### تست با دستگاه Android (پیش‌نیاز: دستگاه متصل)
```cmd
adb devices
adb shell getprop ro.build.version.release
```

**نتیجه مورد انتظار**: اطلاعات دستگاه متصل نمایش داده شود.

**کامپوننت‌های پیش‌نیاز**:
- دستگاه Android با USB Debugging فعال
- درایور USB مناسب

#### تست با Emulator (پیش‌نیاز: نصب System Images و AVD)
```cmd
adb devices
adb -e shell echo "Emulator connected"
```

**نتیجه مورد انتظار**: اتصال به emulator و اجرای دستور shell.

**کامپوننت‌های پیش‌نیاز**:
- [نصب System Images](08-system-images-installation.md)
- AVD ایجاد شده و در حال اجرا

#### تست با SDK Manager (پیش‌نیاز: نصب Command Line Tools)
```cmd
sdkmanager --list --offline | findstr platform-tools
```

**نتیجه مورد انتظار**:
```
platform-tools | 34.0.5 | Android SDK Platform-Tools | platform-tools\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست نصب APK (پیش‌نیاز: دستگاه متصل و APK فایل)
```cmd
adb install test.apk
```

**نتیجه مورد انتظار**: APK با موفقیت نصب شود.

**کامپوننت‌های پیش‌نیاز**:
- دستگاه Android متصل
- فایل APK معتبر

#### تست logcat (پیش‌نیاز: دستگاه متصل)
```cmd
adb logcat -d | findstr "ActivityManager"
```

**نتیجه مورد انتظار**: لاگ‌های سیستم نمایش داده شوند.

**کامپوننت‌های پیش‌نیاز**:
- دستگاه Android متصل یا emulator در حال اجرا

## کاربردهای ADB

### دستورات پایه ADB

```cmd
# نمایش دستگاه‌های متصل
adb devices

# نصب APK
adb install app.apk

# حذف برنامه
adb uninstall com.example.app

# کپی فایل به دستگاه
adb push local_file.txt /sdcard/

# کپی فایل از دستگاه
adb pull /sdcard/remote_file.txt

# اجرای shell command
adb shell ls /system/bin

# مشاهده لاگ‌ها
adb logcat

# راه‌اندازی مجدد دستگاه
adb reboot
```

### دستورات پایه Fastboot

```cmd
# نمایش دستگاه‌های در حالت fastboot
fastboot devices

# فلش کردن recovery
fastboot flash recovery recovery.img

# فلش کردن boot
fastboot flash boot boot.img

# راه‌اندازی مجدد
fastboot reboot

# ورود به حالت download
fastboot oem unlock
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "adb is not recognized"

**علت**: متغیر PATH درست تنظیم نشده یا Command Prompt مجدداً باز نشده است.

**راه‌حل**:
1. Command Prompt را مجدداً باز کنید.
2. بررسی کنید که PATH شامل platform-tools است:
   ```cmd
   echo %PATH% | findstr platform-tools
   ```
3. در صورت نیاز، PATH را دستی تنظیم کنید:
   ```cmd
   set PATH=%PATH%;%ANDROID_HOME%\platform-tools
   ```

#### خطای "device not found"

**علت**: دستگاه متصل نیست یا USB Debugging فعال نیست.

**راه‌حل**:
1. USB Debugging را در دستگاه فعال کنید:
   - Settings > Developer Options > USB Debugging
2. کابل USB را بررسی کنید.
3. درایور USB دستگاه را نصب کنید.

#### خطای "unauthorized device"

**علت**: دستگاه اجازه debugging را نداده است.

**راه‌حل**:
1. در دستگاه، پیام "Allow USB Debugging" را تأیید کنید.
2. گزینه "Always allow from this computer" را انتخاب کنید.

#### خطای "ADB server didn't ACK"

**علت**: ADB server مشکل دارد.

**راه‌حل**:
1. ADB server را مجدداً راه‌اندازی کنید:
   ```cmd
   adb kill-server
   adb start-server
   ```

#### خطای "fastboot is not recognized"

**علت**: مشابه مشکل ADB، PATH درست تنظیم نشده است.

**راه‌حل**:
1. مراحل مشابه ADB را دنبال کنید.
2. بررسی کنید که فایل fastboot.exe وجود دارد:
   ```cmd
   dir "%ANDROID_HOME%\platform-tools\fastboot.exe"
   ```

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود فایل‌ها**:
   ```cmd
   dir "%ANDROID_HOME%\platform-tools\adb.exe"
   dir "%ANDROID_HOME%\platform-tools\fastboot.exe"
   dir "%ANDROID_HOME%\platform-tools\*.dll"
   ```

2. **بررسی متغیرهای محیطی**:
   ```cmd
   echo %ANDROID_HOME%
   echo %PATH%
   ```

3. **تست مستقیم**:
   ```cmd
   "%ANDROID_HOME%\platform-tools\adb.exe" version
   "%ANDROID_HOME%\platform-tools\fastboot.exe" --version
   ```

4. **بررسی لاگ‌های ADB**:
   ```cmd
   adb kill-server
   adb start-server
   adb devices -l
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. ADB server را متوقف کنید:
   ```cmd
   adb kill-server
   ```
2. پوشه `%ANDROID_HOME%\platform-tools` را کاملاً پاک کنید.
3. مراحل نصب را از ابتدا تکرار کنید.

## تنظیمات پیشرفته

### تنظیم ADB برای شبکه

```cmd
# فعال‌سازی ADB over TCP/IP
adb tcpip 5555

# اتصال به دستگاه از طریق شبکه
adb connect 192.168.1.100:5555

# بازگشت به حالت USB
adb usb
```

### تنظیم متغیرهای محیطی ADB

```cmd
# تنظیم timeout برای ADB
set ADB_TRACE=all

# تنظیم پورت ADB
set ANDROID_ADB_SERVER_PORT=5037
```

## نکات مهم

- Platform Tools شامل ابزارهای ضروری برای debugging و testing است.
- ADB برای ارتباط با دستگاه‌های Android ضروری است.
- Fastboot برای فلش کردن firmware استفاده می‌شود.
- حتماً USB Debugging را در دستگاه فعال کنید.
- درایورهای USB دستگاه باید نصب باشند.

## مرحله بعدی

پس از نصب موفق Platform Tools، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب System Images](08-system-images-installation.md)