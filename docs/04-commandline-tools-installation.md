# نصب Command Line Tools

## مقدمه

Android Command Line Tools مجموعه‌ای از ابزارهای خط فرمان برای مدیریت Android SDK است. این ابزارها شامل sdkmanager، avdmanager و سایر ابزارهای ضروری برای توسعه اندروید هستند. این راهنما شما را در فرآیند نصب آفلاین Command Line Tools در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 500 مگابایت فضای خالی در هارد دیسک
- **JDK 17 نصب شده** (مراجعه کنید به [راهنمای نصب JDK 17](01-jdk17-installation.md))
- دسترسی مدیریت سیستم (Administrator) برای تنظیم متغیرهای محیطی
- فایل `commandlinetools-win-latest.zip` در پوشه `downloaded/commandlinetools-win-latest/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `commandlinetools-win-latest.zip`
- **اندازه تقریبی**: حدود 150 مگابایت
- **محتویات**: Android SDK Command Line Tools (latest version)

## مراحل نصب

### مرحله 1: آماده‌سازی پوشه SDK

1. پوشه اصلی SDK را ایجاد کنید:
   ```
   D:\Android\Sdk
   ```

2. پوشه Command Line Tools را ایجاد کنید:
   ```
   D:\Android\Sdk\cmdline-tools
   ```

3. پوشه نسخه latest را ایجاد کنید:
   ```
   D:\Android\Sdk\cmdline-tools\latest
   ```

### مرحله 2: بررسی پیش‌نیازها

1. اطمینان حاصل کنید که JDK 17 نصب شده است:
   ```cmd
   java -version
   ```

2. بررسی کنید که متغیر JAVA_HOME تنظیم شده است:
   ```cmd
   echo %JAVA_HOME%
   ```

### مرحله 3: استخراج فایل Command Line Tools

1. فایل `commandlinetools-win-latest.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/commandlinetools-win-latest/commandlinetools-win-latest.zip
   ```

2. فایل ZIP را استخراج کنید. محتویات استخراج شده شامل پوشه `cmdline-tools` است.

3. محتویات پوشه `cmdline-tools` استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\cmdline-tools\latest\
   ```

4. پس از کپی، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\
   └── cmdline-tools\
       └── latest\
           ├── bin\
           │   ├── sdkmanager.bat
           │   ├── avdmanager.bat
           │   └── ...
           ├── lib\
           ├── NOTICE.txt
           └── source.properties
   ```

### مرحله 4: تنظیم متغیرهای محیطی

#### تنظیم ANDROID_HOME

1. کلید `Windows + R` را فشار دهید و `sysdm.cpl` را تایپ کنید.
2. روی تب "Advanced" کلیک کنید.
3. روی "Environment Variables" کلیک کنید.
4. در بخش "System Variables" روی "New" کلیک کنید.
5. اطلاعات زیر را وارد کنید:
   - **Variable name**: `ANDROID_HOME`
   - **Variable value**: `D:\Android\Sdk`

#### تنظیم PATH

1. در همان پنجره "Environment Variables"، متغیر `PATH` را پیدا کنید.
2. روی `PATH` کلیک کرده و "Edit" را انتخاب کنید.
3. مسیرهای زیر را اضافه کنید:
   ```
   %ANDROID_HOME%\cmdline-tools\latest\bin
   %ANDROID_HOME%\platform-tools
   %ANDROID_HOME%\tools
   ```

### مرحله 5: اعمال تغییرات

1. تمام پنجره‌ها را ببندید.
2. Command Prompt یا PowerShell را مجدداً باز کنید.

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب Command Line Tools قابل اجرا هستند:

#### 1. بررسی sdkmanager
```cmd
sdkmanager --version
```

**نتیجه مورد انتظار**:
```
9.0
```

**در صورت خطا**: اگر پیام "sdkmanager is not recognized" دریافت کردید، PATH درست تنظیم نشده است.

#### 2. بررسی avdmanager
```cmd
avdmanager --version
```

**نتیجه مورد انتظار**:
```
30.0.5
```

#### 3. بررسی متغیر ANDROID_HOME
```cmd
echo %ANDROID_HOME%
```

**نتیجه مورد انتظار**:
```
D:\Android\Sdk
```

#### 4. لیست کردن SDK packages (در حالت آفلاین)
```cmd
sdkmanager --list --offline
```

**نتیجه مورد انتظار**:
```
Installed packages:
  Path                 | Version | Description                    | Location
  -------              | ------- | -------                        | -------
  cmdline-tools;latest | 9.0     | Android SDK Command-line Tools | cmdline-tools\latest\
```

#### 5. تست help دستورات
```cmd
sdkmanager --help
avdmanager --help
```

**نتیجه مورد انتظار**: راهنمای استفاده از هر دستور نمایش داده شود.

#### 6. بررسی فایل‌های ضروری
```cmd
dir "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat"
dir "%ANDROID_HOME%\cmdline-tools\latest\lib\*.jar"
```

**نتیجه مورد انتظار**: تمام فایل‌های ضروری وجود داشته باشند.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با Platform Tools (پیش‌نیاز: نصب Platform Tools)
```cmd
sdkmanager --list --offline | findstr platform-tools
```

**نتیجه مورد انتظار**:
```
platform-tools | 34.0.5 | Android SDK Platform-Tools | platform-tools\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Platform Tools](05-platform-tools-installation.md)

#### تست با Build Tools (پیش‌نیاز: نصب Build Tools)
```cmd
sdkmanager --list --offline | findstr build-tools
```

**نتیجه مورد انتظار**:
```
build-tools;33.0.2 | 33.0.2 | Android SDK Build-Tools 33.0.2 | build-tools\33.0.2\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Build Tools](06-build-tools-installation.md)

#### تست ایجاد AVD (پیش‌نیاز: نصب System Images)
```cmd
avdmanager list avd
avdmanager list target
```

**نتیجه مورد انتظار**: لیست AVD ها و target های موجود نمایش داده شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب System Images](08-system-images-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)

#### تست licenses (پیش‌نیاز: نصب SDK Licenses)
```cmd
sdkmanager --licenses
```

**نتیجه مورد انتظار**:
```
All SDK package licenses accepted.
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب SDK Licenses](10-sdk-licenses-installation.md)

#### تست کامل SDK (پیش‌نیاز: نصب تمام کامپوننت‌ها)
```cmd
sdkmanager --list --offline
```

**نتیجه مورد انتظار**: تمام کامپوننت‌های نصب شده نمایش داده شوند.

**کامپوننت‌های پیش‌نیاز**:
- تمام کامپوننت‌های Android SDK

## تنظیم SDK Manager

### تنظیم حالت آفلاین

برای جلوگیری از تلاش برای اتصال به اینترنت:

1. فایل `repositories.cfg` را در مسیر زیر ایجاد کنید:
   ```
   %USERPROFILE%\.android\repositories.cfg
   ```

2. محتویات زیر را اضافه کنید:
   ```
   # Offline mode configuration
   count=0
   ```

### تنظیم Proxy (غیرفعال)

برای غیرفعال کردن تنظیمات proxy:

```cmd
sdkmanager --no_https --proxy=none
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "sdkmanager is not recognized"

**علت**: متغیر PATH درست تنظیم نشده است.

**راه‌حل**:
1. مراحل تنظیم PATH را مجدداً بررسی کنید.
2. Command Prompt را مجدداً باز کنید.
3. دستور زیر را اجرا کنید:
   ```cmd
   set PATH=%PATH%;D:\Android\Sdk\cmdline-tools\latest\bin
   ```

#### خطای "JAVA_HOME is not set"

**علت**: متغیر JAVA_HOME تنظیم نشده یا اشتباه است.

**راه‌حل**:
1. مراجعه کنید به [راهنمای نصب JDK 17](01-jdk17-installation.md).
2. مطمئن شوید که JAVA_HOME درست تنظیم شده:
   ```
   D:\Android\JDK17\jdk-17.0.13+11
   ```

#### خطای "Could not find or load main class"

**علت**: ساختار پوشه‌ها اشتباه است یا فایل‌ها کامل کپی نشده‌اند.

**راه‌حل**:
1. بررسی کنید که ساختار پوشه مطابق راهنما باشد.
2. مطمئن شوید که تمام فایل‌ها در مسیر صحیح کپی شده‌اند:
   ```cmd
   dir "D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
   ```

#### خطای "Warning: Could not create settings"

**علت**: دسترسی نوشتن به پوشه کاربر وجود ندارد.

**راه‌حل**:
1. Command Prompt را به عنوان Administrator اجرا کنید.
2. یا دسترسی‌های پوشه `%USERPROFILE%\.android` را بررسی کنید.

#### خطای "Repository not found"

**علت**: sdkmanager سعی می‌کند به اینترنت متصل شود.

**راه‌حل**:
1. از فلگ `--offline` استفاده کنید:
   ```cmd
   sdkmanager --list --offline
   ```
2. فایل `repositories.cfg` را مطابق راهنما تنظیم کنید.

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود فایل‌ها**:
   ```cmd
   dir "D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat"
   dir "D:\Android\Sdk\cmdline-tools\latest\lib\*.jar"
   ```

2. **بررسی متغیرهای محیطی**:
   ```cmd
   echo %ANDROID_HOME%
   echo %JAVA_HOME%
   echo %PATH%
   ```

3. **تست مستقیم**:
   ```cmd
   "D:\Android\Sdk\cmdline-tools\latest\bin\sdkmanager.bat" --version
   ```

4. **بررسی لاگ‌های خطا**:
   ```cmd
   sdkmanager --list --verbose
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. متغیرهای محیطی ANDROID_HOME و PATH را حذف کنید.
2. پوشه `D:\Android\Sdk\cmdline-tools` را کاملاً پاک کنید.
3. پوشه `%USERPROFILE%\.android` را حذف کنید.
4. مراحل نصب را از ابتدا تکرار کنید.

## دستورات مفید

### مدیریت SDK Packages

```cmd
# لیست تمام packages نصب شده
sdkmanager --list --offline

# نصب package جدید (در حالت آنلاین)
sdkmanager "platform-tools"

# بروزرسانی تمام packages (در حالت آنلاین)
sdkmanager --update

# حذف package
sdkmanager --uninstall "package-name"
```

### مدیریت AVD

```cmd
# لیست تمام AVD های موجود
avdmanager list avd

# ایجاد AVD جدید
avdmanager create avd -n "MyAVD" -k "system-images;android-33;google_apis;x86_64"

# حذف AVD
avdmanager delete avd -n "MyAVD"
```

## نکات مهم

- Command Line Tools پایه و اساس مدیریت Android SDK است.
- حتماً ساختار پوشه‌ها را دقیقاً مطابق راهنما ایجاد کنید.
- در حالت آفلاین، همیشه از فلگ `--offline` استفاده کنید.
- متغیر ANDROID_HOME برای تمام ابزارهای Android ضروری است.

## مرحله بعدی

پس از نصب موفق Command Line Tools، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب Platform Tools](05-platform-tools-installation.md)
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)