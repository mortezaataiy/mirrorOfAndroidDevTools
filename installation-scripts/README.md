# سیستم نصب و تست کامپوننت‌های Android Development Tools

## نمای کلی

این سیستم یک راه‌حل کامل برای نصب و تست تمامی کامپوننت‌های مورد نیاز برای توسعه Android ارائه می‌دهد. تمام عملیات به صورت کاملاً آفلاین و بدون نیاز به اتصال اینترنت انجام می‌شود.

## ساختار سیستم

### کامپوننت‌های پشتیبانی شده

1. **JDK 17** - محیط اجرای Java
2. **Android Studio** - محیط توسعه یکپارچه
3. **Gradle** - ابزار build automation
4. **Command Line Tools** - ابزارهای خط فرمان Android SDK
5. **Platform Tools** - ابزارهای پلتفرم (adb, fastboot)
6. **Build Tools** - ابزارهای build (aapt, dx)
7. **SDK Platforms** - پلتفرم‌های Android (API 27, 30, 33)
8. **System Images** - تصاویر سیستم برای emulator
9. **Repositories** - مخازن Maven (Android, Google)

### ساختار پوشه‌ها

```
installation-scripts/
├── common/                          # اسکریپت‌های مشترک
│   ├── Logger.ps1                   # سیستم لاگ‌گیری
│   ├── FileValidator.ps1            # اعتبارسنجی فایل‌ها
│   └── EnvironmentManager.ps1       # مدیریت متغیرهای محیطی
├── jdk17/                          # اسکریپت‌های JDK 17
├── android-studio/                 # اسکریپت‌های Android Studio
├── gradle/                         # اسکریپت‌های Gradle
├── commandline-tools/              # اسکریپت‌های Command Line Tools
├── platform-tools/                # اسکریپت‌های Platform Tools
├── build-tools/                    # اسکریپت‌های Build Tools
├── sdk-platforms/                  # اسکریپت‌های SDK Platforms
├── system-images/                  # اسکریپت‌های System Images
├── repositories/                   # اسکریپت‌های Repositories
├── run-all-checks.ps1              # اجرای تمام بررسی‌های پیش‌نیاز
├── run-all-installations.ps1       # اجرای تمام نصب‌ها
├── run-all-tests.ps1               # اجرای تمام تست‌ها
├── test-complete-installation.ps1  # تست نصب کامل
└── test-offline-functionality.ps1  # تست عملکرد آفلاین
```

### الگوی اسکریپت‌ها

هر کامپوننت دارای سه اسکریپت مستقل است:

1. **01-check-prerequisites.ps1** - بررسی پیش‌نیازها
2. **02-install-component.ps1** - نصب کامپوننت
3. **03-test-installation.ps1** - تست نصب

## نحوه استفاده

### نصب کامل (توصیه شده)

```powershell
# بررسی تمام پیش‌نیازها
.\run-all-checks.ps1 -DownloadPath "downloaded" -Verbose

# نصب تمام کامپوننت‌ها
.\run-all-installations.ps1 -DownloadPath "downloaded" -Verbose

# تست تمام کامپوننت‌ها
.\run-all-tests.ps1 -Verbose

# تست نصب کامل با ایجاد پروژه Hello World
.\test-complete-installation.ps1 -DownloadPath "downloaded" -Verbose
```

### نصب کامپوننت خاص

```powershell
# مثال: نصب JDK 17
cd jdk17
.\01-check-prerequisites.ps1 -DownloadPath "..\downloaded" -Verbose
.\02-install-component.ps1 -DownloadPath "..\downloaded" -Verbose
.\03-test-installation.ps1 -Verbose
```

### تست عملکرد آفلاین

```powershell
# تست کامل بدون اتصال اینترنت
.\test-offline-functionality.ps1 -DownloadPath "downloaded" -Verbose
```

## پیش‌نیازها

### فایل‌های مورد نیاز

تمام فایل‌های زیر باید در پوشه `downloaded` موجود باشند:

- `jdk-17.zip`
- `android-studio-2022.3.1.20-windows.exe`
- `gradle-8.0.2-bin.zip`
- `commandlinetools-win-latest.zip`
- `platform-tools.zip`
- `build-tools-33.0.2.zip`
- `sdk-platform-33.zip`
- `sdk-platform-30.zip`
- `sdk-platform-27.zip`
- `sysimage-google-apis-x86_64-33.zip`
- `android-m2repository.zip`

### سیستم‌عامل

- Windows 10/11 (x64)
- PowerShell 5.1 یا بالاتر
- حداقل 10 گیگابایت فضای خالی دیسک

## ویژگی‌های کلیدی

### عملکرد کاملاً آفلاین

- هیچ درخواست شبکه‌ای ارسال نمی‌شود
- تمام فایل‌ها از منابع محلی خوانده می‌شوند
- اعتبارسنجی کامل بدون اتصال اینترنت

### اعتبارسنجی جامع

- بررسی یکپارچگی فایل‌های ZIP
- تست اندازه فایل‌ها
- اعتبارسنجی محتویات فایل‌ها

### مدیریت خطای پیشرفته

- پیام‌های خطای واضح به زبان فارسی
- لاگ‌گیری کامل تمام عملیات
- توقف فوری در صورت بروز خطا

### استقلال اسکریپت‌ها

- هر اسکریپت قابل اجرای مستقل است
- عدم وابستگی به وضعیت سایر اسکریپت‌ها
- امکان اجرا در هر ترتیبی (با رعایت وابستگی‌ها)

## مسیرهای نصب پیش‌فرض

- **JDK 17**: `C:\Program Files\Java\jdk-17`
- **Android Studio**: `C:\Program Files\Android\Android Studio`
- **Gradle**: `C:\Program Files\Gradle\gradle-8.0.2`
- **Android SDK**: `C:\Android\Sdk`

## متغیرهای محیطی

اسکریپت‌ها متغیرهای زیر را تنظیم می‌کنند:

- `JAVA_HOME`
- `GRADLE_HOME`
- `ANDROID_SDK_ROOT`
- `ANDROID_HOME`
- `PATH` (شامل تمام ابزارها)

## عیب‌یابی

### مشکلات رایج

1. **فایل یافت نشد**: بررسی وجود فایل در پوشه `downloaded`
2. **خطای مجوز**: اجرای PowerShell به عنوان Administrator
3. **فایل خراب**: دانلود مجدد فایل از منبع معتبر

### لاگ‌ها

تمام لاگ‌ها در پوشه `logs` ذخیره می‌شوند:

- `logs/[ComponentName]_[Timestamp].log`

### تست سلامت سیستم

```powershell
# بررسی نصب تمام کامپوننت‌ها
java -version
gradle -v
adb version
```

## مشارکت در توسعه

### اضافه کردن کامپوننت جدید

1. ایجاد پوشه جدید در `installation-scripts`
2. ایجاد سه اسکریپت اصلی
3. به‌روزرسانی اسکریپت‌های اجرای کلی
4. اضافه کردن تست‌های مربوطه

### استانداردهای کدنویسی

- استفاده از زبان فارسی برای پیام‌ها و کامنت‌ها
- رعایت الگوی سه اسکریپت برای هر کامپوننت
- استفاده از ماژول‌های مشترک
- لاگ‌گیری کامل تمام عملیات

## مجوز

این پروژه تحت مجوز MIT منتشر شده است.

## پشتیبانی

برای گزارش مشکلات یا درخواست ویژگی‌های جدید، لطفاً از بخش Issues استفاده کنید.