# نصب System Images

## مقدمه

Android System Images فایل‌های سیستم‌عامل اندروید هستند که برای اجرای شبیه‌ساز (Emulator) استفاده می‌شوند. این راهنما شما را در فرآیند نصب آفلاین System Image برای API 33 (Google APIs x86_64) در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 2 گیگابایت فضای خالی در هارد دیسک
- **Command Line Tools نصب شده** (مراجعه کنید به [راهنمای نصب Command Line Tools](04-commandline-tools-installation.md))
- **SDK Platform API 33 نصب شده** (مراجعه کنید به [راهنمای نصب SDK Platforms](07-sdk-platforms-installation.md))
- متغیر محیطی ANDROID_HOME تنظیم شده
- فایل `sysimage-google-apis-x86_64-33.zip` در پوشه `downloaded/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `sysimage-google-apis-x86_64-33.zip`
- **اندازه تقریبی**: حدود 1.5 گیگابایت
- **نوع**: Google APIs System Image برای x86_64
- **API Level**: 33 (Android 13)

## مراحل نصب

### مرحله 1: بررسی پیش‌نیازها

1. اطمینان حاصل کنید که ANDROID_HOME تنظیم شده است:
   ```cmd
   echo %ANDROID_HOME%
   ```

2. بررسی کنید که SDK Platform API 33 نصب شده است:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-33\android.jar"
   ```

### مرحله 2: آماده‌سازی پوشه نصب

1. پوشه system-images را در SDK ایجاد کنید (اگر وجود ندارد):
   ```cmd
   mkdir "%ANDROID_HOME%\system-images"
   ```

2. پوشه API 33 را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\system-images\android-33"
   ```

3. پوشه Google APIs را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\system-images\android-33\google_apis"
   ```

4. پوشه معماری x86_64 را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64"
   ```

### مرحله 3: استخراج فایل System Image

1. فایل `sysimage-google-apis-x86_64-33.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/sysimage-google-apis-x86_64-33/sysimage-google-apis-x86_64-33.zip
   ```

2. فایل ZIP را استخراج کنید.

3. محتویات استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\system-images\android-33\google_apis\x86_64\
   ```

4. پس از کپی، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\system-images\android-33\google_apis\x86_64\
   ├── advancedFeatures.ini
   ├── build.prop
   ├── data\
   ├── encryptionkey.img
   ├── kernel-ranchu
   ├── ramdisk.img
   ├── source.properties
   ├── system.img
   ├── userdata.img
   ├── vendor.img
   └── VerifiedBootParams.textproto
   ```

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب System Images قابل اجرا هستند:

#### 1. بررسی وجود فایل‌های ضروری

```cmd
dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\system.img"
dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\userdata.img"
dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\source.properties"
```

**نتیجه مورد انتظار**: تمام فایل‌های ضروری وجود داشته باشند.

**در صورت خطا**: اگر فایلی یافت نشد، استخراج و کپی درست انجام نشده است.

#### 2. بررسی فایل source.properties

```cmd
type "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\source.properties"
```

**نتیجه مورد انتظار**:
```
Addon.VendorId=google
Addon.VendorDisplay=Google Inc.
AndroidVersion.ApiLevel=33
SystemImage.Abi=x86_64
SystemImage.TagId=google_apis
SystemImage.TagDisplay=Google APIs
```

#### 3. بررسی اندازه فایل‌های اصلی

```cmd
dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\*.img"
```

**نتیجه مورد انتظار**: فایل‌های IMG باید اندازه مناسب داشته باشند (system.img معمولاً چند صد مگابایت).

#### 4. بررسی فایل kernel

```cmd
dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\kernel-ranchu"
```

**نتیجه مورد انتظار**: فایل kernel وجود داشته باشد.

#### 5. بررسی فایل build.prop

```cmd
type "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\build.prop" | findstr "ro.build.version"
```

**نتیجه مورد انتظار**: اطلاعات نسخه Android 13 نمایش داده شود.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با SDK Manager (پیش‌نیاز: نصب Command Line Tools)

```cmd
sdkmanager --list --offline | findstr system-images
```

**نتیجه مورد انتظار**:
```
system-images;android-33;google_apis;x86_64 | 9 | Google APIs Intel x86_64 Atom System Image | system-images\android-33\google_apis\x86_64\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست با AVD Manager (پیش‌نیاز: نصب SDK Platform)

```cmd
avdmanager list target
```

**نتیجه مورد انتظار**:
```
Available Android targets:
----------
id: 1 or "android-33"
     Name: Android 13
     Type: Platform
     API level: 33
     Revision: 2
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب SDK Platforms](07-sdk-platforms-installation.md)

#### لیست System Images موجود

```cmd
avdmanager list target -c
```

**نتیجه مورد انتظار**: لیست target های موجود نمایش داده شود.

#### تست ایجاد AVD (پیش‌نیاز: نصب کامل SDK)

```cmd
avdmanager create avd -n "Test_Pixel_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel"
```

**نتیجه مورد انتظار**:
```
Auto-selecting single ABI x86_64
AVD 'Test_Pixel_API_33' created successfully.
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب Platform Tools](05-platform-tools-installation.md)

#### تست لیست AVD های ایجاد شده

```cmd
avdmanager list avd
```

**نتیجه مورد انتظار**: AVD ایجاد شده نمایش داده شود.

#### تست اجرای Emulator (پیش‌نیاز: AVD ایجاد شده)

```cmd
emulator -list-avds
```

**نتیجه مورد انتظار**: لیست AVD های قابل اجرا نمایش داده شود.

#### تست راه‌اندازی Emulator (پیش‌نیاز: Intel HAXM یا AMD Hypervisor)

```cmd
emulator -avd "Test_Pixel_API_33" -no-window -no-audio
```

**نتیجه مورد انتظار**: Emulator بدون خطا راه‌اندازی شود.

**کامپوننت‌های پیش‌نیاز**:
- Intel HAXM یا AMD Hypervisor نصب شده
- AVD ایجاد شده

#### تست اتصال ADB به Emulator (پیش‌نیاز: Emulator در حال اجرا)

```cmd
adb devices
adb -e shell getprop ro.build.version.release
```

**نتیجه مورد انتظار**: اطلاعات نسخه Android در emulator نمایش داده شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Platform Tools](05-platform-tools-installation.md)
- Emulator در حال اجرا

#### تمیز کردن AVD تست

```cmd
avdmanager delete avd -n "Test_Pixel_API_33"
```

**نتیجه مورد انتظار**: AVD تست با موفقیت حذف شود.

## ایجاد و مدیریت AVD

### ایجاد AVD جدید

```cmd
avdmanager create avd -n "Pixel_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel"
```

**پارامترها**:
- `-n`: نام AVD
- `-k`: کلید System Image
- `-d`: نوع دستگاه (pixel, Nexus 5X, و غیره)

### لیست AVD های موجود

```cmd
avdmanager list avd
```

### حذف AVD

```cmd
avdmanager delete avd -n "Pixel_API_33"
```

### اجرای Emulator

```cmd
emulator -avd "Pixel_API_33"
```

## تنظیمات Emulator

### تنظیمات پیشرفته AVD

هنگام ایجاد AVD، می‌توانید تنظیمات اضافی اعمال کنید:

```cmd
avdmanager create avd -n "Pixel_API_33" -k "system-images;android-33;google_apis;x86_64" -d "pixel" -c 2048M
```

**پارامترهای اضافی**:
- `-c`: اندازه SD Card (مثال: 2048M)
- `-f`: اجبار به بازنویسی AVD موجود

### ویرایش تنظیمات AVD

فایل `config.ini` در پوشه AVD را ویرایش کنید:

```
%USERPROFILE%\.android\avd\Pixel_API_33.avd\config.ini
```

**تنظیمات مفید**:
```ini
hw.ramSize=4096
hw.heap=512
vm.heapSize=256
hw.gpu.enabled=yes
hw.gpu.mode=auto
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "System image not found"

**علت**: فایل‌های System Image درست کپی نشده‌اند.

**راه‌حل**:
1. بررسی ساختار پوشه‌ها:
   ```cmd
   dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64"
   ```
2. اطمینان از وجود فایل‌های ضروری:
   ```cmd
   dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\system.img"
   ```

#### خطای "AVD creation failed"

**علت**: SDK Platform مربوطه نصب نشده یا System Image یافت نمی‌شود.

**راه‌حل**:
1. بررسی نصب SDK Platform:
   ```cmd
   dir "%ANDROID_HOME%\platforms\android-33"
   ```
2. بررسی System Image:
   ```cmd
   avdmanager list target
   ```

#### خطای "Emulator: PANIC: Cannot find AVD system path"

**علت**: مسیر AVD اشتباه است یا فایل‌های AVD آسیب دیده‌اند.

**راه‌حل**:
1. بررسی وجود AVD:
   ```cmd
   avdmanager list avd
   ```
2. مجدداً ایجاد AVD:
   ```cmd
   avdmanager delete avd -n "Pixel_API_33"
   avdmanager create avd -n "Pixel_API_33" -k "system-images;android-33;google_apis;x86_64"
   ```

#### خطای "Intel HAXM is not installed"

**علت**: Intel Hardware Accelerated Execution Manager نصب نشده است.

**راه‌حل**:
1. Intel HAXM را از سایت Intel دانلود و نصب کنید.
2. یا از AMD Hypervisor استفاده کنید (برای پردازنده‌های AMD).

#### Emulator کند اجرا می‌شود

**علت**: تنظیمات حافظه یا GPU مناسب نیست.

**راه‌حل**:
1. RAM بیشتری اختصاص دهید:
   ```ini
   hw.ramSize=4096
   ```
2. GPU acceleration را فعال کنید:
   ```ini
   hw.gpu.enabled=yes
   hw.gpu.mode=auto
   ```

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود تمام فایل‌های ضروری**:
   ```cmd
   dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\system.img"
   dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\userdata.img"
   dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\kernel-ranchu"
   ```

2. **بررسی اندازه فایل‌ها**:
   ```cmd
   dir "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64\*.img"
   ```

3. **تست SDK Manager**:
   ```cmd
   sdkmanager --list --offline
   ```

4. **بررسی لاگ‌های Emulator**:
   ```cmd
   emulator -avd "Pixel_API_33" -verbose
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. تمام AVD های مربوطه را حذف کنید:
   ```cmd
   avdmanager list avd
   avdmanager delete avd -n "AVD_NAME"
   ```

2. پوشه System Image را پاک کنید:
   ```cmd
   rmdir /s /q "%ANDROID_HOME%\system-images\android-33\google_apis\x86_64"
   ```

3. مراحل نصب را از ابتدا تکرار کنید.

## تنظیمات پیشرفته

### بهینه‌سازی عملکرد Emulator

```ini
# تنظیمات config.ini برای بهترین عملکرد
hw.ramSize=4096
vm.heapSize=512
hw.gpu.enabled=yes
hw.gpu.mode=auto
hw.keyboard=yes
hw.cpu.ncore=4
```

### استفاده از Snapshot

```cmd
# ایجاد AVD با قابلیت Snapshot
avdmanager create avd -n "Pixel_API_33_Fast" -k "system-images;android-33;google_apis;x86_64" -d "pixel"

# اجرای Emulator با Snapshot
emulator -avd "Pixel_API_33_Fast" -snapshot-save
```

## دستورات مفید Emulator

```cmd
# اجرای Emulator در حالت headless
emulator -avd "Pixel_API_33" -no-window

# اجرای با پورت خاص
emulator -avd "Pixel_API_33" -port 5556

# اجرای با تنظیمات شبکه
emulator -avd "Pixel_API_33" -netdelay none -netspeed full

# نمایش لیست Emulator های در حال اجرا
adb devices
```

## نکات مهم

- System Images برای اجرای شبیه‌ساز ضروری هستند.
- نسخه x86_64 عملکرد بهتری نسبت به ARM دارد.
- Google APIs شامل سرویس‌های گوگل مانند Google Play Services است.
- حداقل 4 گیگابایت RAM برای اجرای مناسب Emulator توصیه می‌شود.
- Intel HAXM یا AMD Hypervisor برای شتاب‌دهی ضروری است.

## مرحله بعدی

پس از نصب موفق System Images، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب Repositories](09-repositories-installation.md)
- [نصب SDK Licenses](10-sdk-licenses-installation.md)
- [ایجاد پروژه Hello World](11-hello-world-project.md)