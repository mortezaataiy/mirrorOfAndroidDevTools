# نمای کلی پروژه Mirror Android Dev Tools

## هدف اصلی پروژه
این پروژه یک **mirror کامل و آفلاین** از تمامی ابزارهای مورد نیاز برای توسعه اندروید است که شامل:

- JDK 17 (Windows x64)
- Gradle (سازگار با Android Studio 2022.3.1)
- Android SDK Command-line Tools
- Platform-tools
- Build-tools 33.x
- SDK Platforms (API 33, 30, 27)
- Android Emulator system images
- AndroidX و Google Maven repositories

## ساختار پروژه

### فایل‌های اصلی:
- `goal.md` - مستندات کامل اهداف و الزامات پروژه (فارسی)
- `README.md` - توضیحات اولیه پروژه (فارسی)
- `auto-download-and-setup-android-offline.ps1` - اسکریپت نصب آفلاین ویندوز

### پوشه‌ها:
- `.github/workflows/` - فایل‌های GitHub Actions برای دانلود خودکار
- `downloaded/` - فایل‌های دانلود شده (در .gitignore قرار دارد)
- `installation-scripts/` - سیستم منظم نصب کامپوننت‌های Android Development Tools

### GitHub Actions Workflows:
- `android-offline-complete.yml` - workflow کامل دانلود و اعتبارسنجی

## فلسفه پروژه
- **کاملاً آفلاین**: همه چیز باید بدون اتصال اینترنت کار کند
- **قابل اعتماد**: هر فایل دانلودی باید اعتبارسنجی شود
- **دفاعی**: مدیریت خطا با پیام‌های واضح
- **بدون فرضیات**: هیچ فرضی درباره نام پوشه‌ها یا ساختار فایل‌ها

## مراحل توسعه
1. **فاز فعلی**: استفاده از GitHub Actions artifacts
2. **فاز آینده**: انتقال به GitHub Releases برای دانلود خودکار

## نکات مهم برای توسعه‌دهندگان
- **همه فایل‌های MD باید فارسی باشند** - شامل تمام مستندات، spec ها، requirements، design و tasks
- **فایل‌های spec** در `.kiro/specs/` باید کاملاً فارسی نوشته شوند
- از GitHub CLI برای مدیریت releases استفاده نکنید بلکه فقط برای اجرای ورکفلوها و بررسی خروجی آنها و دانلود آرتیفکت ها استفاده کنید.
- هر تغییری باید کاملاً آفلاین تست شود
- اسکریپت‌ها باید در ویندوز PowerShell اجرا شوند