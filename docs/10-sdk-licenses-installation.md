# نصب SDK Licenses

## مقدمه

Android SDK Licenses فایل‌های مجوز هستند که برای استفاده از کامپوننت‌های Android SDK ضروری هستند. بدون این فایل‌ها، ممکن است هنگام بیلد پروژه یا استفاده از SDK Manager با خطاهای مجوز مواجه شوید. این راهنما شما را در فرآیند نصب آفلاین SDK Licenses در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 10 مگابایت فضای خالی در هارد دیسک
- **Command Line Tools نصب شده** (مراجعه کنید به [راهنمای نصب Command Line Tools](04-commandline-tools-installation.md))
- متغیر محیطی ANDROID_HOME تنظیم شده
- فایل‌های License در پوشه `downloaded/sdk-licenses/`

## فایل‌های مورد نیاز

- **android-sdk-license**: مجوز اصلی Android SDK
- **android-sdk-preview-license**: مجوز برای نسخه‌های Preview
- **google-gdk-license**: مجوز Google Development Kit

## مراحل نصب

### مرحله 1: بررسی پیش‌نیازها

1. اطمینان حاصل کنید که ANDROID_HOME تنظیم شده است:
   ```cmd
   echo %ANDROID_HOME%
   ```

2. بررسی کنید که پوشه SDK وجود دارد:
   ```cmd
   dir "%ANDROID_HOME%"
   ```

### مرحله 2: آماده‌سازی پوشه نصب

1. پوشه licenses را در SDK ایجاد کنید (اگر وجود ندارد):
   ```cmd
   mkdir "%ANDROID_HOME%\licenses"
   ```

### مرحله 3: کپی فایل‌های License

1. فایل‌های license را از مسیر زیر پیدا کنید:
   ```
   downloaded/sdk-licenses/
   ├── android-sdk-license
   ├── android-sdk-preview-license
   └── google-gdk-license
   ```

2. تمام فایل‌های license را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\licenses\
   ```

3. پس از کپی، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\licenses\
   ├── android-sdk-license
   ├── android-sdk-preview-license
   └── google-gdk-license
   ```

### مرحله 4: بررسی محتویات فایل‌ها

فایل‌های license شامل hash های مجوز هستند:

#### android-sdk-license
```cmd
type "%ANDROID_HOME%\licenses\android-sdk-license"
```

**محتوای نمونه**:
```
24333f8a63b6825ea9c5514f83c2829b004d1fee
```

#### android-sdk-preview-license
```cmd
type "%ANDROID_HOME%\licenses\android-sdk-preview-license"
```

#### google-gdk-license
```cmd
type "%ANDROID_HOME%\licenses\google-gdk-license"
```

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب SDK Licenses قابل اجرا هستند:

#### 1. بررسی وجود فایل‌های license

```cmd
dir "%ANDROID_HOME%\licenses\android-sdk-license"
dir "%ANDROID_HOME%\licenses\android-sdk-preview-license"
dir "%ANDROID_HOME%\licenses\google-gdk-license"
```

**نتیجه مورد انتظار**: تمام فایل‌های license وجود داشته باشند.

**در صورت خطا**: اگر فایلی یافت نشد، کپی درست انجام نشده است.

#### 2. بررسی محتویات فایل‌ها

```cmd
type "%ANDROID_HOME%\licenses\android-sdk-license"
type "%ANDROID_HOME%\licenses\android-sdk-preview-license"
type "%ANDROID_HOME%\licenses\google-gdk-license"
```

**نتیجه مورد انتظار**: هر فایل باید شامل hash مجوز باشد (رشته‌ای از اعداد و حروف).

#### 3. بررسی فرمت فایل‌ها

```cmd
wc -l "%ANDROID_HOME%\licenses\android-sdk-license" 2>nul || echo "File exists"
```

**نتیجه مورد انتظار**: فایل‌ها باید فاقد extension و شامل فقط hash باشند.

#### 4. تست دسترسی نوشتن

```cmd
icacls "%ANDROID_HOME%\licenses"
```

**نتیجه مورد انتظار**: پوشه licenses باید دسترسی نوشتن داشته باشد.

#### 5. بررسی اندازه فایل‌ها

```cmd
dir "%ANDROID_HOME%\licenses\*" | findstr "android-sdk-license"
```

**نتیجه مورد انتظار**: فایل‌ها باید اندازه کوچک داشته باشند (چند بایت).

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با SDK Manager (پیش‌نیاز: نصب Command Line Tools)

```cmd
sdkmanager --licenses
```

**نتیجه مورد انتظار**:
```
All SDK package licenses accepted.
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست نصب package جدید (پیش‌نیاز: اتصال اینترنت - فقط برای تست)

```cmd
sdkmanager --list --offline
```

**نتیجه مورد انتظار**: لیست packages بدون پیام خطای license نمایش داده شود.

#### تست بیلد پروژه (پیش‌نیاز: پروژه Android کامل)

```cmd
gradle assembleDebug
```

**نتیجه مورد انتظار**: پروژه بدون خطای مربوط به license بیلد شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب Repositories](09-repositories-installation.md)
- پروژه Android کامل

#### تست Android Studio (پیش‌نیاز: نصب Android Studio)

1. Android Studio را باز کنید
2. SDK Manager را باز کنید (`Tools > SDK Manager`)
3. نباید پیام "Accept License" نمایش داده شود

**کامپوننت‌های پیش‌نیاز**:
- [نصب Android Studio](02-android-studio-installation.md)

#### تست Gradle Dependencies (پیش‌نیاز: پروژه با Google Services)

```cmd
gradle dependencies --configuration implementation
```

**نتیجه مورد انتظار**: تمام dependencies بدون خطای license resolve شوند.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Repositories](09-repositories-installation.md)
- پروژه Android با Google Services

#### تست AVD Creation (پیش‌نیاز: نصب System Images)

```cmd
avdmanager create avd -n "License_Test_AVD" -k "system-images;android-33;google_apis;x86_64" -d "pixel"
```

**نتیجه مورد انتظار**: AVD بدون خطای license ایجاد شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب System Images](08-system-images-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)

#### تست کامل SDK Operations (پیش‌نیاز: تمام کامپوننت‌ها)

```cmd
sdkmanager --list --offline
avdmanager list target
gradle --version
```

**نتیجه مورد انتظار**: تمام دستورات بدون خطای license اجرا شوند.

**کامپوننت‌های پیش‌نیاز**:
- تمام کامپوننت‌های Android SDK

#### تمیز کردن AVD تست

```cmd
avdmanager delete avd -n "License_Test_AVD"
```

**نتیجه مورد انتظار**: AVD تست با موفقیت حذف شود.

## مدیریت Licenses

### بررسی وضعیت Licenses

```cmd
# نمایش تمام licenses
sdkmanager --licenses

# بررسی licenses خاص
sdkmanager --licenses | findstr "android-sdk-license"
```

### اضافه کردن License جدید

اگر در آینده نیاز به license جدیدی داشتید:

1. فایل license را در پوشه `%ANDROID_HOME%\licenses` قرار دهید.
2. محتوای فایل باید hash مجوز باشد.

### حذف Licenses

```cmd
# حذف تمام licenses
rmdir /s /q "%ANDROID_HOME%\licenses"

# حذف license خاص
del "%ANDROID_HOME%\licenses\android-sdk-license"
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "You have not accepted the license agreements"

**علت**: فایل‌های license وجود ندارند یا محتوای اشتباه دارند.

**راه‌حل**:
1. بررسی وجود فایل‌ها:
   ```cmd
   dir "%ANDROID_HOME%\licenses"
   ```
2. بررسی محتویات:
   ```cmd
   type "%ANDROID_HOME%\licenses\android-sdk-license"
   ```
3. در صورت نیاز، فایل‌ها را مجدداً کپی کنید.

#### خطای "License for package not accepted"

**علت**: license مربوط به package خاص وجود ندارد.

**راه‌حل**:
1. شناسایی package مورد نیاز:
   ```cmd
   sdkmanager --licenses
   ```
2. اضافه کردن license مربوطه.

#### خطای "Failed to read or create install properties file"

**علت**: دسترسی نوشتن به پوشه licenses وجود ندارد.

**راه‌حل**:
1. Command Prompt را به عنوان Administrator اجرا کنید.
2. دسترسی‌های پوشه را بررسی کنید:
   ```cmd
   icacls "%ANDROID_HOME%\licenses"
   ```

#### SDK Manager نمی‌تواند licenses را بخواند

**علت**: فرمت فایل‌های license اشتباه است.

**راه‌حل**:
1. اطمینان حاصل کنید که فایل‌ها فاقد extension هستند.
2. محتوای فایل‌ها باید فقط hash باشد (بدون خط اضافی).
3. encoding فایل‌ها باید UTF-8 باشد.

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود تمام فایل‌های ضروری**:
   ```cmd
   dir "%ANDROID_HOME%\licenses\android-sdk-license"
   dir "%ANDROID_HOME%\licenses\android-sdk-preview-license"
   dir "%ANDROID_HOME%\licenses\google-gdk-license"
   ```

2. **بررسی محتویات فایل‌ها**:
   ```cmd
   type "%ANDROID_HOME%\licenses\android-sdk-license"
   type "%ANDROID_HOME%\licenses\android-sdk-preview-license"
   type "%ANDROID_HOME%\licenses\google-gdk-license"
   ```

3. **تست SDK Manager**:
   ```cmd
   sdkmanager --licenses --verbose
   ```

4. **بررسی دسترسی‌ها**:
   ```cmd
   icacls "%ANDROID_HOME%\licenses"
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. پوشه licenses را پاک کنید:
   ```cmd
   rmdir /s /q "%ANDROID_HOME%\licenses"
   ```

2. پوشه را مجدداً ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\licenses"
   ```

3. فایل‌های license را مجدداً کپی کنید.

4. تست کنید:
   ```cmd
   sdkmanager --licenses
   ```

## تنظیمات پیشرفته

### ایجاد License به صورت دستی

اگر فایل license در دسترس نیست، می‌توانید آن را به صورت دستی ایجاد کنید:

```cmd
# ایجاد android-sdk-license
echo 24333f8a63b6825ea9c5514f83c2829b004d1fee > "%ANDROID_HOME%\licenses\android-sdk-license"

# ایجاد android-sdk-preview-license  
echo 84831b9409646a918e30573bab4c9c91346d8abd > "%ANDROID_HOME%\licenses\android-sdk-preview-license"
```

### بررسی Hash های License

```cmd
# نمایش hash فعلی
certutil -hashfile "%ANDROID_HOME%\licenses\android-sdk-license" MD5
```

### تنظیم Gradle برای License

در فایل `build.gradle` پروژه:

```gradle
android {
    lintOptions {
        abortOnError false
        checkReleaseBuilds false
    }
}
```

## اطلاعات License ها

### android-sdk-license

- **کاربرد**: مجوز اصلی برای استفاده از Android SDK
- **ضروری برای**: تمام کامپوننت‌های SDK
- **بدون آن**: امکان بیلد پروژه وجود ندارد

### android-sdk-preview-license

- **کاربرد**: مجوز برای نسخه‌های Preview و Beta
- **ضروری برای**: API های Preview
- **بدون آن**: نمی‌توان از نسخه‌های Preview استفاده کرد

### google-gdk-license

- **کاربرد**: مجوز برای Google Development Kit
- **ضروری برای**: Google Play Services، Firebase
- **بدون آن**: کتابخانه‌های گوگل کار نمی‌کنند

## نکات مهم

- License ها برای استفاده قانونی از Android SDK ضروری هستند.
- فایل‌های license باید دقیقاً در پوشه `licenses` قرار گیرند.
- محتوای فایل‌ها باید hash های صحیح باشند.
- بدون license ها، بیلد پروژه با خطا مواجه می‌شود.
- License ها یک بار نصب شده و برای همیشه معتبر هستند.

## مرحله بعدی

پس از نصب موفق SDK Licenses، تمام کامپوننت‌های ضروری نصب شده‌اند. اکنون می‌توانید:
- [ایجاد پروژه Hello World](11-hello-world-project.md) برای تست کامل سیستم
- شروع توسعه پروژه‌های اندروید
- استفاده از تمام ویژگی‌های Android SDK

## تبریک!

شما با موفقیت تمام کامپوننت‌های Android Development Tools را نصب کردید. محیط توسعه شما آماده استفاده است!