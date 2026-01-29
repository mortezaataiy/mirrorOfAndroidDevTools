# نصب Gradle

## مقدمه

Gradle ابزار اتوماسیون بیلد است که برای کامپایل و بسته‌بندی پروژه‌های اندروید استفاده می‌شود. این راهنما شما را در فرآیند نصب آفلاین Gradle 8.0.2 در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 200 مگابایت فضای خالی در هارد دیسک
- **JDK 17 نصب شده** (مراجعه کنید به [راهنمای نصب JDK 17](01-jdk17-installation.md))
- دسترسی مدیریت سیستم (Administrator) برای تنظیم متغیرهای محیطی
- فایل `gradle-8.0.2-bin.zip` در پوشه `downloaded/gradle-8.0.2/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `gradle-8.0.2-bin.zip`
- **اندازه تقریبی**: حدود 120 مگابایت
- **نسخه**: Gradle 8.0.2 (سازگار با Android Studio 2022.3.1)

## مراحل نصب

### مرحله 1: آماده‌سازی پوشه نصب

1. پوشه مقصد را ایجاد کنید:
   ```
   D:\Android\Gradle
   ```

2. اطمینان حاصل کنید که پوشه خالی است و دسترسی نوشتن دارید.

### مرحله 2: بررسی پیش‌نیازها

1. اطمینان حاصل کنید که JDK 17 نصب شده است:
   ```cmd
   java -version
   ```

2. بررسی کنید که متغیر JAVA_HOME تنظیم شده است:
   ```cmd
   echo %JAVA_HOME%
   ```

### مرحله 3: استخراج فایل Gradle

1. فایل `gradle-8.0.2-bin.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/gradle-8.0.2/gradle-8.0.2-bin.zip
   ```

2. فایل ZIP را در مسیر `D:\Android\Gradle` استخراج کنید.

3. پس از استخراج، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Gradle\
   └── gradle-8.0.2\
       ├── bin\
       │   ├── gradle.bat
       │   └── gradle
       ├── lib\
       ├── LICENSE
       ├── NOTICE
       └── README
   ```

### مرحله 4: تنظیم متغیرهای محیطی

#### تنظیم GRADLE_HOME

1. کلید `Windows + R` را فشار دهید و `sysdm.cpl` را تایپ کنید.
2. روی تب "Advanced" کلیک کنید.
3. روی "Environment Variables" کلیک کنید.
4. در بخش "System Variables" روی "New" کلیک کنید.
5. اطلاعات زیر را وارد کنید:
   - **Variable name**: `GRADLE_HOME`
   - **Variable value**: `D:\Android\Gradle\gradle-8.0.2`

#### تنظیم PATH

1. در همان پنجره "Environment Variables"، متغیر `PATH` را پیدا کنید.
2. روی `PATH` کلیک کرده و "Edit" را انتخاب کنید.
3. روی "New" کلیک کرده و مسیر زیر را اضافه کنید:
   ```
   %GRADLE_HOME%\bin
   ```

### مرحله 5: اعمال تغییرات

1. تمام پنجره‌ها را ببندید.
2. Command Prompt یا PowerShell را مجدداً باز کنید.

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب Gradle قابل اجرا هستند:

#### 1. بررسی نسخه Gradle
```cmd
gradle -v
```

**نتیجه مورد انتظار**:
```
------------------------------------------------------------
Gradle 8.0.2
------------------------------------------------------------

Build time:   2023-03-03 16:41:37 UTC
Revision:     7d6581558e226a580d91d399f7dfb9e3095c2b1d

Kotlin:       1.8.10
Groovy:       3.0.13
Ant:          Apache Ant(TM) version 1.10.11 compiled on July 10 2021
JVM:          17.0.13 (Eclipse Adoptium 17.0.13+11)
OS:           Windows 10 10.0 amd64
```

**در صورت خطا**: اگر پیام "gradle is not recognized" دریافت کردید، PATH درست تنظیم نشده است.

#### 2. بررسی متغیر GRADLE_HOME
```cmd
echo %GRADLE_HOME%
```

**نتیجه مورد انتظار**:
```
D:\Android\Gradle\gradle-8.0.2
```

#### 3. تست ساخت پروژه ساده
```cmd
mkdir test-gradle
cd test-gradle
gradle init --type basic --dsl groovy --project-name test-project
```

**نتیجه مورد انتظار**:
```
BUILD SUCCESSFUL in Xs
2 actionable tasks: 2 executed
```

#### 4. تست اجرای task ساده
```cmd
cd test-gradle
gradle tasks
```

**نتیجه مورد انتظار**: لیست task های موجود نمایش داده شود.

#### 5. تمیز کردن پروژه تست
```cmd
cd ..
rmdir /s /q test-gradle
```

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با Android Project (پیش‌نیاز: نصب Android SDK)
```cmd
gradle wrapper --gradle-version 8.0.2
```

**نتیجه مورد انتظار**: فایل‌های Gradle Wrapper ایجاد شوند.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)

#### تست بیلد Android (پیش‌نیاز: پروژه Android کامل)
```cmd
gradle assembleDebug
```

**نتیجه مورد انتظار**: APK فایل با موفقیت تولید شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب Repositories](09-repositories-installation.md)
- پروژه Android معتبر

#### تست Dependencies Resolution (پیش‌نیاز: نصب Repositories)
```cmd
gradle dependencies
```

**نتیجه مورد انتظار**: تمام dependencies بدون خطا resolve شوند.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Repositories](09-repositories-installation.md)

#### تست با Android Studio (پیش‌نیاز: نصب Android Studio)
1. Android Studio را باز کنید
2. پروژه Android ایجاد کنید
3. Gradle sync باید بدون خطا انجام شود

**کامپوننت‌های پیش‌نیاز**:
- [نصب Android Studio](02-android-studio-installation.md)

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "gradle is not recognized"

**علت**: متغیر PATH درست تنظیم نشده است.

**راه‌حل**:
1. مراحل تنظیم PATH را مجدداً بررسی کنید.
2. Command Prompt را مجدداً باز کنید.
3. دستور زیر را اجرا کنید:
   ```cmd
   set PATH=%PATH%;D:\Android\Gradle\gradle-8.0.2\bin
   ```

#### خطای "JAVA_HOME is not set"

**علت**: متغیر JAVA_HOME تنظیم نشده یا اشتباه است.

**راه‌حل**:
1. مراجعه کنید به [راهنمای نصب JDK 17](01-jdk17-installation.md).
2. مطمئن شوید که JAVA_HOME درست تنظیم شده:
   ```
   D:\Android\JDK17\jdk-17.0.13+11
   ```

#### خطای "Could not determine java version"

**علت**: نسخه Java سازگار نیست یا JDK درست نصب نشده.

**راه‌حل**:
1. بررسی کنید که JDK 17 نصب شده است:
   ```cmd
   java -version
   ```
2. اگر نسخه اشتباه است، JDK 17 را مجدداً نصب کنید.

#### خطای "Permission denied"

**علت**: دسترسی نوشتن به پوشه پروژه وجود ندارد.

**راه‌حل**:
1. Command Prompt را به عنوان Administrator اجرا کنید.
2. یا پوشه پروژه را در مسیری با دسترسی کامل ایجاد کنید.

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود فایل‌ها**:
   ```cmd
   dir "D:\Android\Gradle\gradle-8.0.2\bin\gradle.bat"
   ```

2. **بررسی متغیرهای محیطی**:
   ```cmd
   echo %GRADLE_HOME%
   echo %JAVA_HOME%
   echo %PATH%
   ```

3. **تست مستقیم**:
   ```cmd
   "D:\Android\Gradle\gradle-8.0.2\bin\gradle.bat" -v
   ```

4. **بررسی لاگ‌های خطا**:
   ```cmd
   gradle -v --debug
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. متغیرهای محیطی GRADLE_HOME و PATH را حذف کنید.
2. پوشه `D:\Android\Gradle` را کاملاً پاک کنید.
3. مراحل نصب را از ابتدا تکرار کنید.

## تنظیمات پیشرفته

### تنظیم Gradle Daemon

برای بهبود عملکرد، Gradle Daemon را فعال کنید:

1. فایل `gradle.properties` را در مسیر زیر ایجاد کنید:
   ```
   %USERPROFILE%\.gradle\gradle.properties
   ```

2. محتویات زیر را اضافه کنید:
   ```properties
   org.gradle.daemon=true
   org.gradle.parallel=true
   org.gradle.configureondemand=true
   org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8
   ```

### تنظیم Proxy (در صورت نیاز)

اگر در آینده نیاز به استفاده از proxy داشتید:

```properties
systemProp.http.proxyHost=proxy.company.com
systemProp.http.proxyPort=8080
systemProp.https.proxyHost=proxy.company.com
systemProp.https.proxyPort=8080
```

## نکات مهم

- Gradle نیاز به JDK 17 دارد، نه فقط JRE.
- نسخه Gradle 8.0.2 با Android Studio 2022.3.1 سازگار است.
- متغیرهای محیطی را دقیقاً مطابق راهنما تنظیم کنید.
- Gradle Daemon عملکرد را بهبود می‌بخشد اما حافظه بیشتری مصرف می‌کند.

## مرحله بعدی

پس از نصب موفق Gradle، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب Command Line Tools](04-commandline-tools-installation.md)
- [نصب Platform Tools](05-platform-tools-installation.md)
- [نصب Build Tools](06-build-tools-installation.md)