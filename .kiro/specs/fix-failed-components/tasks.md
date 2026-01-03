# برنامه پیاده‌سازی: رفع کامپوننت‌های ناکام

## نمای کلی

این برنامه پیاده‌سازی یک workflow آزمایشی برای یافتن و تست URL های جایگزین کامپوننت‌های ناکام ایجاد می‌کند.

## وظایف

- [x] 1. ایجاد workflow آزمایشی
  - ایجاد فایل `.github/workflows/test-failed-components.yml`
  - تنظیم trigger های workflow (workflow_dispatch)
  - تعریف job اصلی با Ubuntu runner
  - _الزامات: ۲.۱، ۲.۲_

- [x] 2. پیاده‌سازی تست Platform Tools
  - [x] 2.1 تست URL های مختلف Platform Tools
    - تست platform-tools_r34.0.5-windows.zip
    - تست platform-tools_r33.0.2-windows.zip
    - تست platform-tools-latest-windows.zip
    - _الزامات: ۳.۱، ۳.۲، ۳.۳_

  - [x] 2.2 اعتبارسنجی Platform Tools
    - بررسی حداقل اندازه 15MB
    - بررسی یکپارچگی ZIP
    - محاسبه checksum
    - _الزامات: ۳.۲، ۶.۳، ۶.۴_

- [x] 3. پیاده‌سازی تست SDK Platform API 33
  - [x] 3.1 تست URL های مختلف SDK Platform API 33
    - تست platform-33_r02.zip
    - تست platform-33_r01.zip
    - تست URL های جایگزین
    - _الزامات: ۴.۱، ۴.۲، ۴.۳_

  - [x] 3.2 اعتبارسنجی SDK Platform API 33
    - بررسی حداقل اندازه 25MB
    - بررسی یکپارچگی ZIP
    - محاسبه checksum
    - _الزامات: ۴.۲، ۶.۳، ۶.۴_

- [x] 4. پیاده‌سازی تست M2Repository ها
  - [x] 4.1 تست Android M2Repository
    - تست android_m2repository_r57.zip
    - تست android_m2repository_r56.zip
    - تست android_m2repository_r47.zip
    - _الزامات: ۵.۱، ۵.۳، ۵.۴_

  - [x] 4.2 تست Google M2Repository
    - تست google_m2repository_r201.zip
    - تست google_m2repository_r200.zip
    - تست نسخه‌های جایگزین
    - _الزامات: ۵.۲، ۵.۳، ۵.۴_

  - [x] 4.3 اعتبارسنجی M2Repository ها
    - بررسی حداقل اندازه 50MB
    - بررسی یکپارچگی ZIP
    - محاسبه checksum
    - _الزامات: ۵.۳، ۶.۳، ۶.۴_

- [x] 5. پیاده‌سازی گزارش‌دهی نتایج
  - [x] 5.1 تولید گزارش JSON
    - ثبت نتایج تست هر URL
    - ثبت URL های معتبر
    - ثبت دلایل ناکامی
    - _الزامات: ۷.۱، ۷.۲، ۷.۳_

  - [x] 5.2 تولید دستورالعمل اصلاح
    - ایجاد فایل patch برای workflow اصلی
    - ارائه دستورالعمل جایگزینی URL ها
    - تولید script اصلاح خودکار
    - _الزامات: ۸.۱، ۸.۲_

- [x] 6. تست workflow آزمایشی
  - اجرای workflow آزمایشی
  - بررسی نتایج و گزارش‌ها
  - تأیید یافتن URL های معتبر
  - _الزامات: ۲.۳، ۲.۴_

- [x] 7. اصلاح workflow اصلی
  - جایگزینی URL های ناکام با URL های معتبر
  - تست workflow اصلی اصلاح شده
  - تأیید موفقیت تمام کامپوننت‌ها
  - _الزامات: ۸.۳، ۸.۴_

- [ ] 8. Checkpoint نهایی
  - اطمینان از موفقیت تمام کامپوننت‌ها در workflow اصلی
  - تولید گزارش نهایی
  - آرشیو workflow آزمایشی

## یادداشت‌ها

- هر وظیفه به الزامات خاص ارجاع می‌دهد تا قابلیت ردیابی فراهم شود
- workflow آزمایشی باید کاملاً جدا از workflow اصلی باشد
- تست عملی با GitHub CLI برای اطمینان از عملکرد واقعی ضروری است
- پس از یافتن URL های معتبر، workflow اصلی باید اصلاح شود