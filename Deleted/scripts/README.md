# راهنمای استفاده از Android Version Compatibility Checker

## نمای کلی

این مجموعه اسکریپت‌های PowerShell برای شناسایی، تست و به‌روزرسانی آخرین ورژن‌های سازگار ابزارهای توسعه اندروید طراحی شده است.

## ساختار فایل‌ها

### اسکریپت‌های اصلی
- `Main.ps1` - اسکریپت اصلی که تمام فرایند را اجرا می‌کند
- `VersionDiscovery.ps1` - شناسایی آخرین ورژن‌های ابزارها
- `DownloadValidator.ps1` - اعتبارسنجی لینک‌های دانلود
- `ToolInstaller.ps1` - دانلود و نصب ابزارها
- `HelloWorldBuilder.ps1` - ایجاد و بیلد پروژه تست
- `YamlDatabaseManager.ps1` - مدیریت پایگاه داده ورژن‌ها
- `ErrorHandler.ps1` - مدیریت خطا و لاگ‌گذاری

### فایل‌های پیکربندی
- `.github/workflows/android-version-checker.yml` - GitHub Action workflow
- `test-workflow.ps1` - اسکریپت تست workflow

## نحوه استفاده

### اجرای محلی

```powershell
# اجرای کامل
.\scripts\Main.ps1

# اجرای با پارامترها
.\scripts\Main.ps1 -OutputPath "C:\Results" -Verbose

# رد کردن نصب ابزارها
.\scripts\Main.ps1 -SkipInstall

# رد کردن بیلد Hello World
.\scripts\Main.ps1 -SkipBuild
```

### اجرای GitHub Action

```powershell
# تست workflow
.\test-workflow.ps1

# تست با انتظار برای تکمیل
.\test-workflow.ps1 -WaitForCompletion -TimeoutMinutes 30
```

## ابزارهای پشتیبانی شده

1. **JDK 17** - Java Development Kit
2. **Gradle** - سیستم بیلد
3. **Android Command Line Tools** - ابزارهای خط فرمان اندروید
4. **Platform Tools** - ADB و سایر ابزارها
5. **Build Tools** - ابزارهای بیلد اندروید

## خروجی‌ها

### فایل‌های تولید شده
- `android-tools-versions.yml` - پایگاه داده ورژن‌ها
- `execution-summary.json` - خلاصه اجرا
- `summary-report.md` - گزارش خلاصه
- `logs/` - فایل‌های لاگ
- `hello-world-test.apk` - فایل APK تست (در صورت موفقیت)

### ساختار فایل YAML

```yaml
metadata:
  last_updated: "2024-01-03 10:30:00"
  tested_on: "windows-latest"
  test_result: "success"
  hello_world_build: true
  total_tools: 5
  successful_installs: 5

tools:
  jdk:
    name: "JDK"
    version: "17.0.8"
    download_url: "https://..."
    file_type: "zip"
    file_size: 104857600
    install_path: "C:\\AndroidDevTools\\jdk\\..."
    test_status: "installed"
    test_date: "2024-01-03 10:25:00"
    last_successful_test: "2024-01-03 10:25:00"

statistics:
  total_tests_run: 1
  successful_tests: 1
  last_success_date: "2024-01-03 10:30:00"
```

## مدیریت خطا

سیستم انواع مختلف خطا را مدیریت می‌کند:

- **NetworkError** - خطاهای شبکه و دانلود
- **FileError** - خطاهای فایل و دسترسی
- **InstallError** - خطاهای نصب
- **BuildError** - خطاهای بیلد
- **ValidationError** - خطاهای اعتبارسنجی
- **ConfigurationError** - خطاهای پیکربندی

## لاگ‌گذاری

سیستم لاگ‌گذاری جامع شامل:

- **INFO** - اطلاعات عمومی
- **SUCCESS** - عملیات موفق
- **WARNING** - هشدارها
- **ERROR** - خطاها

## الزامات سیستم

- **سیستم عامل**: Windows 10/11
- **PowerShell**: 5.1 یا بالاتر
- **اتصال اینترنت**: برای دانلود ابزارها
- **فضای دیسک**: حداقل 2GB برای نصب ابزارها
- **GitHub CLI**: برای تست workflow (اختیاری)

## نکات مهم

1. **مجوزهای اجرا**: اطمینان حاصل کنید که PowerShell execution policy مناسب تنظیم شده است
2. **فضای دیسک**: ابزارهای اندروید فضای زیادی اشغال می‌کنند
3. **اتصال اینترنت**: برای دانلود ابزارها نیاز به اتصال پایدار است
4. **زمان اجرا**: فرایند کامل ممکن است 30-60 دقیقه طول بکشد

## عیب‌یابی

### مشکلات رایج

1. **خطای دانلود**
   ```
   راه‌حل: بررسی اتصال اینترنت و تلاش مجدد
   ```

2. **خطای نصب**
   ```
   راه‌حل: اجرای PowerShell به عنوان Administrator
   ```

3. **خطای بیلد Hello World**
   ```
   راه‌حل: بررسی نصب صحیح JDK و Android SDK
   ```

### دستورات مفید

```powershell
# بررسی لاگ‌ها
Get-Content "logs\activity-*.json" | ConvertFrom-Json

# پاک کردن فایل‌های موقت
Remove-Item "C:\AndroidDevTools" -Recurse -Force

# تست دستی ابزارها
java -version
gradle -v
adb version
```

## مشارکت

برای گزارش مشکلات یا پیشنهاد بهبود، لطفاً issue ایجاد کنید.

## مجوز

این پروژه تحت مجوز MIT منتشر شده است.