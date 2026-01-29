# نصب Android Studio

## مقدمه

Android Studio محیط توسعه یکپارچه (IDE) رسمی گوگل برای توسعه اندروید است. این راهنما شما را در فرآیند نصب آفلاین Android Studio 2022.3.1 در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 8 گیگابایت RAM (16 گیگابایت توصیه می‌شود)
- حداقل 4 گیگابایت فضای خالی در هارد دیسک
- **JDK 17 نصب شده** (مراجعه کنید به [راهنمای نصب JDK 17](01-jdk17-installation.md))
- فایل `android-studio-2022.3.1.20-windows.exe` در پوشه `downloaded/android-studio-2022.3.1/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `android-studio-2022.3.1.20-windows.exe`
- **اندازه تقریبی**: حدود 1.2 گیگابایت
- **نسخه**: Android Studio Flamingo 2022.3.1

## مراحل نصب

### مرحله 1: آماده‌سازی نصب

1. اطمینان حاصل کنید که JDK 17 نصب شده است:
   ```cmd
   java -version
   ```

2. فایل نصب را از مسیر زیر پیدا کنید:
   ```
   downloaded/android-studio-2022.3.1/android-studio-2022.3.1.20-windows.exe
   ```

### مرحله 2: اجرای نصب‌کننده

1. روی فایل `android-studio-2022.3.1.20-windows.exe` راست‌کلیک کنید.
2. "Run as administrator" را انتخاب کنید.
3. اگر پیام امنیتی ویندوز ظاهر شد، "Yes" را کلیک کنید.

### مرحله 3: تنظیمات نصب

#### صفحه خوش‌آمدگویی
1. روی "Next" کلیک کنید.

#### انتخاب کامپوننت‌ها
1. گزینه‌های زیر را انتخاب کنید:
   - ✅ Android Studio
   - ✅ Android Virtual Device (AVD)
2. روی "Next" کلیک کنید.

#### انتخاب مسیر نصب
1. مسیر پیشنهادی را بپذیرید یا مسیر دلخواه خود را انتخاب کنید:
   ```
   C:\Program Files\Android\Android Studio
   ```
2. روی "Next" کلیک کنید.

#### انتخاب پوشه Start Menu
1. نام پیشنهادی را بپذیرید: "Android Studio"
2. روی "Install" کلیک کنید.

### مرحله 4: تکمیل نصب

1. منتظر بمانید تا فرآیند نصب تکمیل شود (ممکن است چند دقیقه طول بکشد).
2. روی "Next" کلیک کنید.
3. گزینه "Start Android Studio" را انتخاب کنید.
4. روی "Finish" کلیک کنید.

## تنظیمات اولیه

### اولین اجرا

1. Android Studio باز می‌شود و صفحه "Welcome" نمایش داده می‌شود.
2. "Do not import settings" را انتخاب کنید.
3. روی "OK" کلیک کنید.

### Setup Wizard

#### صفحه خوش‌آمدگویی
1. روی "Next" کلیک کنید.

#### نوع نصب
1. "Custom" را انتخاب کنید تا کنترل بیشتری داشته باشید.
2. روی "Next" کلیک کنید.

#### انتخاب JDK
1. مطمئن شوید که JDK 17 شناسایی شده است:
   ```
   D:\Android\JDK17\jdk-17.0.13+11
   ```
2. اگر شناسایی نشده، روی "..." کلیک کرده و مسیر را دستی انتخاب کنید.
3. روی "Next" کلیک کنید.

#### انتخاب تم UI
1. تم دلخواه خود را انتخاب کنید (Light یا Darcula).
2. روی "Next" کلیک کنید.

#### تنظیمات SDK
1. مسیر SDK را تنظیم کنید:
   ```
   D:\Android\Sdk
   ```
2. کامپوننت‌های زیر را انتخاب کنید:
   - ✅ Android SDK
   - ✅ Android SDK Platform
   - ✅ Performance (Intel HAXM)
   - ✅ Android Virtual Device
3. روی "Next" کلیک کنید.

#### تأیید تنظیمات
1. تنظیمات را بررسی کنید.
2. روی "Finish" کلیک کنید.

### دانلود کامپوننت‌ها (اختیاری)

**نکته مهم**: در حالت آفلاین، این مرحله را رد کنید:

1. اگر پیام دانلود کامپوننت‌ها ظاهر شد، "Cancel" را کلیک کنید.
2. کامپوننت‌های مورد نیاز را به صورت دستی از فایل‌های دانلود شده نصب خواهیم کرد.

## تست عملکرد

### تست فوری

این تست‌ها بلافاصله پس از نصب Android Studio قابل اجرا هستند:

#### 1. بررسی اجرای Android Studio
```cmd
"C:\Program Files\Android\Android Studio\bin\studio64.exe"
```

**نتیجه مورد انتظار**: Android Studio بدون خطا باز می‌شود و صفحه Welcome نمایش داده می‌شود.

**در صورت خطا**: اگر Android Studio باز نشد، فایل‌های نصب آسیب دیده‌اند.

#### 2. بررسی تشخیص JDK
1. Android Studio را باز کنید
2. به `File > Project Structure > SDK Location` بروید
3. بررسی کنید که JDK Location درست تنظیم شده:
   ```
   D:\Android\JDK17\jdk-17.0.13+11
   ```

**در صورت خطا**: اگر JDK شناسایی نشده، متغیر JAVA_HOME درست تنظیم نشده است.

#### 3. بررسی تنظیمات SDK
1. به `File > Settings > Appearance & Behavior > System Settings > Android SDK` بروید
2. مطمئن شوید که SDK Path درست تنظیم شده:
   ```
   D:\Android\Sdk
   ```

#### 4. تست عدم اتصال به اینترنت
1. به `File > Settings > Appearance & Behavior > System Settings > HTTP Proxy` بروید
2. بررسی کنید که "No proxy" انتخاب شده است
3. Android Studio نباید سعی کند به اینترنت متصل شود

#### 5. بررسی حافظه و عملکرد
```cmd
tasklist | findstr studio64
```

**نتیجه مورد انتظار**: فرآیند studio64.exe در حال اجرا باشد و حافظه مناسب مصرف کند.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با SDK Tools (پیش‌نیاز: نصب Command Line Tools)
1. در Android Studio، به `Tools > SDK Manager` بروید
2. بررسی کنید که SDK Tools نصب شده نمایش داده می‌شوند

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست ایجاد پروژه (پیش‌نیاز: نصب کامل SDK)
1. "Create New Project" را کلیک کنید
2. یک template ساده (Empty Activity) انتخاب کنید
3. مطمئن شوید که پروژه بدون خطا ایجاد می‌شود

**کامپوننت‌های پیش‌نیاز**:
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب Build Tools](06-build-tools-installation.md)

#### تست Gradle Sync (پیش‌نیاز: نصب Gradle و SDK کامل)
1. پروژه جدید ایجاد کنید
2. "Sync Project with Gradle Files" را کلیک کنید
3. Sync باید بدون خطا تکمیل شود

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب Repositories](09-repositories-installation.md)

#### تست AVD Manager (پیش‌نیاز: نصب System Images)
1. به `Tools > AVD Manager` بروید
2. "Create Virtual Device" را کلیک کنید
3. System Images نصب شده باید نمایش داده شوند

**کامپوننت‌های پیش‌نیاز**:
- [نصب System Images](08-system-images-installation.md)

#### تست بیلد پروژه (پیش‌نیاز: محیط کامل)
1. پروژه Android ایجاد کنید
2. `Build > Make Project` را کلیک کنید
3. پروژه باید بدون خطا بیلد شود

**کامپوننت‌های پیش‌نیاز**:
- تمام کامپوننت‌های Android SDK

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "Unable to access Android SDK add-on list"

**علت**: Android Studio سعی می‌کند به اینترنت متصل شود.

**راه‌حل**:
1. به `File > Settings > Appearance & Behavior > System Settings > HTTP Proxy` بروید.
2. "No proxy" را انتخاب کنید.
3. گزینه "Automatic proxy configuration URL" را غیرفعال کنید.

#### خطای "JAVA_HOME is not set"

**علت**: متغیر JAVA_HOME درست تنظیم نشده است.

**راه‌حل**:
1. مراجعه کنید به [راهنمای نصب JDK 17](01-jdk17-installation.md).
2. متغیر JAVA_HOME را مجدداً تنظیم کنید.
3. Android Studio را مجدداً راه‌اندازی کنید.

#### خطای "SDK location not found"

**علت**: مسیر SDK درست تنظیم نشده است.

**راه‌حل**:
1. به `File > Project Structure > SDK Location` بروید.
2. مسیر SDK را به `D:\Android\Sdk` تغییر دهید.
3. "Apply" و سپس "OK" را کلیک کنید.

#### Android Studio کند اجرا می‌شود

**علت**: تنظیمات حافظه مناسب نیست.

**راه‌حل**:
1. فایل `studio64.exe.vmoptions` را در پوشه نصب پیدا کنید.
2. تنظیمات زیر را اضافه یا تغییر دهید:
   ```
   -Xms2048m
   -Xmx4096m
   ```

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد:

1. **بررسی فایل‌های نصب**:
   ```cmd
   dir "C:\Program Files\Android\Android Studio\bin\studio64.exe"
   ```

2. **بررسی لاگ‌های خطا**:
   - مسیر لاگ‌ها: `%USERPROFILE%\.AndroidStudio2022.3\system\log\`
   - فایل اصلی: `idea.log`

3. **تست اجرای مستقیم**:
   ```cmd
   "C:\Program Files\Android\Android Studio\bin\studio64.exe"
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. Android Studio را کاملاً ببندید.
2. از Control Panel، Android Studio را uninstall کنید.
3. پوشه‌های زیر را حذف کنید:
   - `%USERPROFILE%\.AndroidStudio2022.3`
   - `%USERPROFILE%\.android`
4. مراحل نصب را از ابتدا تکرار کنید.

## نکات مهم

- Android Studio نیاز به JDK 17 دارد، حتماً قبل از نصب آن را نصب کنید.
- در حالت آفلاین، از دانلود خودکار کامپوننت‌ها جلوگیری کنید.
- تنظیمات Proxy را غیرفعال کنید تا از خطاهای اتصال جلوگیری شود.
- حداقل 8 گیگابایت RAM برای عملکرد مناسب ضروری است.

## مرحله بعدی

پس از نصب موفق Android Studio، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب Gradle](03-gradle-installation.md)
- [نصب Command Line Tools](04-commandline-tools-installation.md)
- [نصب Platform Tools](05-platform-tools-installation.md)