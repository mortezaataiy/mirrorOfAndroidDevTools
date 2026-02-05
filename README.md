# Mirror Android Dev Tools - آینه ابزارهای توسعه اندروید

## درباره پروژه
این پروژه یک **mirror کامل و آفلاین** از تمامی ابزارهای مورد نیاز برای توسعه اندروید در ویندوز است. هدف اصلی ایجاد یک محیط توسعه کاملاً مستقل از اینترنت پس از دانلود اولیه است.

## فلو پروژه

پروژه شامل سه بخش اصلی است:

### 1. فلو تست URL و آماده‌سازی دانلود
- **GitHub Actions Workflow** (`android-offline-complete.yml`) - 842 خط
- دانلود و اعتبارسنجی 13 کامپوننت اندروید
- ذخیره‌سازی به عنوان artifacts جداگانه
- اعتبارسنجی یکپارچگی ZIP و اندازه فایل‌ها

### 2. اسکریپت نصب اتومات ویندوز
- **PowerShell Script** (`auto-download-and-setup-android-offline.ps1`) - 3000+ خط
- نصب آفلاین تمام کامپوننت‌ها در `D:\Android\`
- جستجوی هوشمند فایل‌ها در `.ignoredDownloads`
- تنظیم متغیرهای محیطی سیستم
- تست بیلد پروژه Hello World

### 3. فلو تست در ویندوز (GitHub Actions)
- اجرای همین اسکریپت در ویندوز runner
- اعتبارسنجی کامل محیط توسعه آفلاین
- تولید APK معتبر

## ابزارهای شامل شده
- **JDK 17** (Windows x64)
- **Gradle** (سازگار با Android Studio 2022.3.1)
- **Android SDK Command-line Tools**
- **Platform-tools** (شامل ADB)
- **Build-tools 33.x**
- **SDK Platforms**: API 33, API 30, API 27
- **Android Emulator System Images** (API 33 x86_64 Google APIs)
- **AndroidX و Google Maven Repositories**

## ساختار پروژه

### فایل‌های اصلی
- `goal.md` - مستندات کامل اهداف و الزامات پروژه (فارسی)
- `README.md` - توضیحات اولیه پروژه (فارسی)
- `ROADMAP.md` - نقشه راه توسعه پروژه (فارسی)
- `implementation-summary.md` - خلاصه پیاده‌سازی و وضعیت تکمیل
- `fix-failed-components-summary.md` - گزارش رفع کامپوننت‌های ناکام
- `auto-download-and-setup-android-offline.ps1` - اسکریپت نصب آفلاین ویندوز (3000+ خط)
- `.gitignore` - شامل پوشه `.ignoredDownloads`

### پوشه‌ها

#### `.github/workflows/` - GitHub Actions
- `android-offline-complete.yml` - workflow اصلی دانلود و اعتبارسنجی (842 خط)
  - دانلود 13 کامپوننت اندروید
  - اعتبارسنجی یکپارچگی فایل‌ها
  - آپلود به عنوان artifacts جداگانه

#### `installation-scripts/` - سیستم نصب کامپوننت‌ها
- سیستم منظم نصب، بررسی و تست کامپوننت‌های Android Development Tools
- 9 کامپوننت اصلی با الگوی یکسان (JDK17, Android Studio, Gradle, و غیره)
- هر کامپوننت شامل 3 اسکریپت: بررسی پیش‌نیازها، نصب، تست
- ماژول‌های مشترک برای لاگ‌گذاری، اعتبارسنجی فایل، و مدیریت محیط
- اسکریپت‌های اجرای کلی برای نصب خودکار تمام کامپوننت‌ها

#### `downloaded/` - فایل‌های دانلود شده
- فایل‌های دانلود شده از GitHub Actions (در git ignore)
- محل جستجوی اسکریپت‌های نصب برای فایل‌ها

#### `.kiro/steering/` - راهنماهای توسعه
- `project-overview.md` - نمای کلی پروژه و فلسفه آن
- `workflow-usage.md` - راهنمای استفاده از workflow جدید
- `github-cli-usage.md` - راهنمای تست GitHub CLI (موقت)
- `development-workflow.md` - گردش کار توسعه پروژه

#### `.kiro/specs/` - مستندات طراحی
- `android-installation-docs/` - spec مستندات نصب کامپوننت‌ها
- `android-component-installer/` - spec سیستم نصب کامپوننت‌ها

#### `docs/` - مستندات نصب
- راهنماهای گام‌به‌گام نصب هر کامپوننت (11 فایل)
- مستندات troubleshooting و حل مشکلات

#### `tests/` - تست‌های اعتبارسنجی
- `run-workflow-test.ps1` - تست اجرای workflow با GitHub CLI
- `test-workflow-simple.ps1` - اسکریپت ساده تست workflow
- `README.md` - راهنمای تست‌ها

#### `logs/` - لاگ‌های عملیات
- لاگ‌های نصب و عملیات سیستم

#### `Deleted/` - فایل‌های منتقل شده
- فایل‌های قدیمی و اضافی که از پروژه حذف شدند

## نحوه استفاده

### مرحله 1: دانلود فایل‌ها
1. GitHub Actions را اجرا کنید تا فایل‌های مورد نیاز دانلود شوند
2. فایل‌ها به عنوان Artifacts ذخیره می‌شوند
3. Artifacts را دانلود و در پوشه `.ignoredDownloads` قرار دهید

### مرحله 2: نصب آفلاین
```powershell
.\auto-download-and-setup-android-offline.ps1
```

### مرحله 3: تست نصب
```powershell
java -version
gradle -v
adb version
```

## ویژگی‌های کلیدی

### کاملاً آفلاین
پس از دانلود اولیه، تمام فرآیند نصب و توسعه بدون نیاز به اینترنت انجام می‌شود.

### اعتبارسنجی هوشمند
- بررسی یکپارچگی فایل‌های ZIP
- تشخیص خودکار فایل‌های خراب
- مدیریت خطای دفاعی

### نصب انعطاف‌پذیر
- عدم وابستگی به نام‌های خاص فایل یا پوشه
- جستجوی هوشمند فایل‌ها
- پشتیبانی از ساختارهای مختلف آرشیو

### تست خودکار
- ایجاد پروژه Hello World
- کامپایل کامل آفلاین
- تولید APK معتبر

## مسیر نصب
همه ابزارها در مسیر زیر نصب می‌شوند:
```
D:\Android\
├── JDK17\
├── Gradle\
├── Sdk\
└── .gradle\
```

## متغیرهای محیطی
اسکریپت نصب این متغیرها را به صورت خودکار تنظیم می‌کند:
- `JAVA_HOME`
- `ANDROID_HOME`
- `ANDROID_SDK_ROOT`
- `GRADLE_HOME`
- `PATH`

## دستورات مهم

### اجرای workflow با GitHub CLI:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" workflow run "android-offline-complete.yml"
```

### بررسی وضعیت workflow:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" run list
```

### دانلود artifacts:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" run download [run-id]
```

### تست اسکریپت‌های workflow:
```powershell
.\run-workflow-test.ps1
.\test-workflow-simple.ps1
```

## مراحل توسعه

### فاز فعلی
استفاده از GitHub Actions Artifacts برای ذخیره‌سازی فایل‌ها

### فاز آینده
انتقال به GitHub Releases برای دانلود مستقیم و خودکار

## مشارکت در توسعه
- همه فایل‌های مستندات باید فارسی باشند
- تست‌ها باید در محیط آفلاین انجام شوند
- از PowerShell برای اسکریپت‌نویسی استفاده شود
- مدیریت خطا با پیام‌های واضح و فارسی

## لایسنس
این پروژه تحت لایسنس MIT منتشر شده است.