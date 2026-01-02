# گردش کار توسعه پروژه

## مراحل توسعه

### فاز 1: دانلود و ذخیره‌سازی (فعلی)
1. **GitHub Actions** فایل‌های مورد نیاز را دانلود می‌کند
2. فایل‌ها به عنوان **Artifacts** ذخیره می‌شوند
3. اسکریپت PowerShell فایل‌ها را از پوشه `.ignoredDownloads` پیدا و نصب می‌کند

### فاز 2: انتقال به Releases (آینده)
1. فایل‌های دانلود شده به **GitHub Releases** منتقل می‌شوند
2. اسکریپت PowerShell مستقیماً از Releases دانلود می‌کند
3. حذف وابستگی به GitHub Actions artifacts

## ساختار فایل‌های دانلودی

### پوشه `.ignoredDownloads/`:
```
.ignoredDownloads/
├── android-studio-2022.3.1.20-windows.exe
├── build-tools-33.0.2.zip
├── cmake/
│   └── cmake-3.22.1.zip
├── commandlinetools-win-latest.zip
├── emulator/
│   └── emulator.zip
├── gradle/
│   └── gradle-8.0.2-bin.zip
├── jdk17/
│   └── jdk17.zip
├── licenses/
│   ├── android-sdk-license
│   ├── android-sdk-preview-license
│   └── google-gdk-license
├── platform-tools.zip
├── sdk-platform-33.zip
├── sources/
│   └── sources-33.zip
└── sysimage-google-apis-x86_64-33.zip
```

## الزامات کیفی

### اعتبارسنجی فایل‌ها:
- بررسی یکپارچگی ZIP
- بررسی اندازه فایل
- تست استخراج

### مدیریت خطا:
- پیام‌های واضح و فارسی
- توقف فوری در صورت خطا
- راهنمایی برای حل مشکل

### تست‌های نهایی:
- ایجاد پروژه Hello World
- کامپایل کامل آفلاین
- تولید APK معتبر

## دستورات مهم برای توسعه

### اجرای workflow:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" workflow run "download-android-offline.yml"
```

### تست اسکریپت نصب:
```powershell
.\auto-download-and-setup-android-offline.ps1
```

### بررسی نصب:
```powershell
java -version
gradle -v
adb version
```

## نکات مهم:
- همه تست‌ها باید در محیط آفلاین انجام شود
- هر تغییری باید کاملاً مستند شود
- فایل‌های MD همیشه فارسی باشند
- از GitHub CLI برای مدیریت releases استفاده شود