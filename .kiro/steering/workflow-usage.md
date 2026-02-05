# راهنمای استفاده از Workflow جدید

## فایل Workflow
- `android-offline-complete.yml` - workflow اصلی برای دانلود و اعتبارسنجی (842 خط)

## کامپوننت‌های دانلودی

### فایل‌های اصلی:
1. **Android Studio 2022.3.1** - `android-studio-2022.3.1.20-windows.exe`
2. **JDK 17** - `jdk-17.zip`
3. **Gradle 8.0.2** - `gradle-8.0.2-bin.zip`
4. **Command Line Tools** - `commandlinetools-win-latest.zip`
5. **Platform Tools** - `platform-tools.zip`
6. **Build Tools 33.0.2** - `build-tools-33.0.2.zip`

### SDK Platforms:
7. **API 33** - `sdk-platform-33.zip`
8. **API 30** - `sdk-platform-30.zip`
9. **API 27** - `sdk-platform-27.zip`

### سایر کامپوننت‌ها:
10. **System Image API 33** - `sysimage-google-apis-x86_64-33.zip`
11. **Android M2Repository** - `android-m2repository.zip`
12. **Google M2Repository** - `google-m2repository.zip`
13. **SDK Licenses** - فایل‌های لایسنس خودکار

## اعتبارسنجی فایل‌ها

### بررسی‌های انجام شده:
- **اندازه فایل**: حداقل اندازه مورد انتظار
- **یکپارچگی ZIP**: تست صحت فایل فشرده
- **محتویات**: بررسی وجود فایل‌های ضروری

### حداقل اندازه‌های مورد انتظار:
- JDK 17: 100MB
- Gradle: 50MB
- Command Line Tools: 50MB
- Platform Tools: 5MB
- Build Tools: 30MB
- SDK Platforms: 25-30MB
- System Image: 500MB
- Repositories: 50-100MB

## نحوه اجرا

### با GitHub CLI:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" workflow run "android-offline-complete.yml"
```

### بررسی وضعیت:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" run list
```

### دانلود artifacts:
```powershell
& "C:\Program Files\GitHub CLI\gh.exe" run download [run-id]
```

## مدیریت خطا

### خطاهای محتمل:
- **فایل کوچک**: اندازه کمتر از حد انتظار
- **ZIP خراب**: فایل فشرده معتبر نیست
- **دانلود ناقص**: اتصال اینترنت قطع شده

### راه‌حل‌ها:
- اجرای مجدد workflow
- بررسی لینک‌های دانلود
- تست دستی فایل‌های دانلود شده

## نکات مهم:
- هر فایل به عنوان artifact جداگانه آپلود می‌شود
- تمام فایل‌ها قبل از آپلود اعتبارسنجی می‌شوند
- در صورت خطا در هر فایل، کل workflow متوقف می‌شود
- فایل‌ها باید در پوشه `downloaded` قرار گیرند
- سیستم `installation-scripts` فایل‌ها را از پوشه `downloaded` پیدا و نصب می‌کند