# پوشه تست‌ها

این پوشه شامل اسکریپت‌های تست و ابزارهای کمکی برای توسعه است.

## فایل‌های موجود:

### اسکریپت‌های PowerShell:
- `run-workflow-test.ps1` - تست اجرای workflow
- `test-workflow-simple.ps1` - تست ساده workflow
- `test-error-handling.ps1` - تست مدیریت خطا (در صورت وجود)

### اسکریپت‌های Shell:
- `test_direct_urls_property.sh` - تست URL های مستقیم
- `test_zip_property.sh` - تست خصوصیات فایل‌های ZIP
- `validation_tests.sh` - تست‌های اعتبارسنجی

## نکته مهم:
این فایل‌ها فقط برای توسعه و تست استفاده می‌شوند و بخشی از فرایند نصب اصلی نیستند.

برای استفاده از اسکریپت اصلی، از فایل `auto-download-and-setup-android-offline.ps1` در پوشه اصلی استفاده کنید.