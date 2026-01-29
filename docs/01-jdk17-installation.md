# نصب JDK 17

## مقدمه

JDK 17 (Java Development Kit) یکی از اصلی‌ترین پیش‌نیازهای توسعه اندروید است. این راهنما شما را در فرآیند نصب آفلاین JDK 17 در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 500 مگابایت فضای خالی در هارد دیسک
- دسترسی مدیریت سیستم (Administrator) برای تنظیم متغیرهای محیطی
- فایل `jdk-17.zip` در پوشه `downloaded/extracted_jdk-17/`

## فایل‌های مورد نیاز

- **فایل اصلی**: `jdk-17.zip`
- **اندازه تقریبی**: حدود 180 مگابایت
- **محتویات**: JDK 17.0.13+11 برای ویندوز x64

## مراحل نصب

### مرحله 1: آماده‌سازی پوشه نصب

1. پوشه مقصد را ایجاد کنید:
   ```
   D:\Android\JDK17
   ```

2. اطمینان حاصل کنید که پوشه خالی است و دسترسی نوشتن دارید.

### مرحله 2: استخراج فایل JDK

1. فایل `jdk-17.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/extracted_jdk-17/jdk-17.zip
   ```

2. فایل ZIP را در مسیر `D:\Android\JDK17` استخراج کنید.

3. پس از استخراج، ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\JDK17\
   └── jdk-17.0.13+11\
       ├── bin\
       ├── conf\
       ├── include\
       ├── jmods\
       ├── legal\
       ├── lib\
       ├── NOTICE
       └── release
   ```

### مرحله 3: تنظیم متغیرهای محیطی

#### تنظیم JAVA_HOME

1. کلید `Windows + R` را فشار دهید و `sysdm.cpl` را تایپ کنید.
2. روی تب "Advanced" کلیک کنید.
3. روی "Environment Variables" کلیک کنید.
4. در بخش "System Variables" روی "New" کلیک کنید.
5. اطلاعات زیر را وارد کنید:
   - **Variable name**: `JAVA_HOME`
   - **Variable value**: `D:\Android\JDK17\jdk-17.0.13+11`

#### تنظیم PATH

1. در همان پنجره "Environment Variables"، متغیر `PATH` را پیدا کنید.
2. روی `PATH` کلیک کرده و "Edit" را انتخاب کنید.
3. روی "New" کلیک کرده و مسیر زیر را اضافه کنید:
   ```
   %JAVA_HOME%\bin
   ```

### مرحله 4: اعمال تغییرات

1. تمام پنجره‌ها را ببندید.
2. Command Prompt یا PowerShell را مجدداً باز کنید.

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب JDK 17 قابل اجرا هستند و نیاز به هیچ کامپوننت اضافی ندارند:

#### 1. بررسی نسخه Java Runtime
```cmd
java -version
```

**نتیجه مورد انتظار**:
```
openjdk version "17.0.13" 2024-10-15
OpenJDK Runtime Environment (build 17.0.13+11)
OpenJDK 64-Bit Server VM (build 17.0.13+11, mixed mode, sharing)
```

**در صورت خطا**: اگر پیام "java is not recognized" دریافت کردید، PATH درست تنظیم نشده است.

#### 2. بررسی کامپایلر Java
```cmd
javac -version
```

**نتیجه مورد انتظار**:
```
javac 17.0.13
```

**در صورت خطا**: اگر پیام "javac is not recognized" دریافت کردید، JDK به جای JRE نصب نشده است.

#### 3. بررسی متغیر JAVA_HOME
```cmd
echo %JAVA_HOME%
```

**نتیجه مورد انتظار**:
```
D:\Android\JDK17\jdk-17.0.13+11
```

**در صورت خطا**: اگر مسیر نمایش داده نشد، متغیر JAVA_HOME تنظیم نشده است.

#### 4. تست کامپایل ساده Java
```cmd
echo public class Test { public static void main(String[] args) { System.out.println("JDK Works!"); } } > Test.java
javac Test.java
java Test
del Test.java Test.class
```

**نتیجه مورد انتظار**:
```
JDK Works!
```

#### 5. بررسی ابزارهای JDK
```cmd
jar --version
jlink --version
```

**نتیجه مورد انتظار**: نمایش نسخه 17.0.13 برای هر دو ابزار.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند و وابستگی‌های مشخصی دارند:

#### تست با Gradle (پیش‌نیاز: نصب Gradle)
```cmd
gradle -version
```

**نتیجه مورد انتظار**: نمایش اطلاعات Gradle همراه با JVM version 17.0.13

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)

#### تست با Android SDK (پیش‌نیاز: نصب Command Line Tools)
```cmd
sdkmanager --version
```

**نتیجه مورد انتظار**: نمایش نسخه SDK Manager بدون خطای JAVA_HOME

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست با Android Studio (پیش‌نیاز: نصب Android Studio)
1. Android Studio را اجرا کنید
2. به `File > Project Structure > SDK Location` بروید
3. بررسی کنید که JDK Location درست نمایش داده می‌شود

**کامپوننت‌های پیش‌نیاز**:
- [نصب Android Studio](02-android-studio-installation.md)

#### تست بیلد پروژه Android (پیش‌نیاز: محیط کامل Android)
```cmd
gradle assembleDebug
```

**نتیجه مورد انتظار**: بیلد موفق بدون خطای Java

**کامپوننت‌های پیش‌نیاز**:
- تمام کامپوننت‌های Android SDK
- پروژه Android معتبر

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "java is not recognized"

**علت**: متغیر PATH درست تنظیم نشده است.

**راه‌حل**:
1. مراحل تنظیم PATH را مجدداً بررسی کنید.
2. Command Prompt را مجدداً باز کنید.
3. دستور زیر را اجرا کنید:
   ```cmd
   set PATH=%PATH%;D:\Android\JDK17\jdk-17.0.13+11\bin
   ```

#### خطای "JAVA_HOME is not set"

**علت**: متغیر JAVA_HOME تنظیم نشده یا اشتباه است.

**راه‌حل**:
1. مراحل تنظیم JAVA_HOME را مجدداً انجام دهید.
2. مطمئن شوید مسیر صحیح است:
   ```
   D:\Android\JDK17\jdk-17.0.13+11
   ```

#### نسخه اشتباه Java نمایش داده می‌شود

**علت**: نسخه قدیمی Java در PATH قرار دارد.

**راه‌حل**:
1. در متغیر PATH، مسیر JDK 17 را به ابتدای لیست منتقل کنید.
2. نسخه‌های قدیمی Java را از PATH حذف کنید.

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود فایل‌ها**:
   ```cmd
   dir "D:\Android\JDK17\jdk-17.0.13+11\bin\java.exe"
   ```

2. **بررسی متغیرهای محیطی**:
   ```cmd
   echo %JAVA_HOME%
   echo %PATH%
   ```

3. **تست مستقیم**:
   ```cmd
   "D:\Android\JDK17\jdk-17.0.13+11\bin\java.exe" -version
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. متغیرهای محیطی JAVA_HOME و PATH را حذف کنید.
2. پوشه `D:\Android\JDK17` را کاملاً پاک کنید.
3. مراحل نصب را از ابتدا تکرار کنید.

## نکات مهم

- JDK 17 پیش‌نیاز اصلی برای تمام ابزارهای Android Development است.
- حتماً از نسخه 64 بیتی استفاده کنید.
- متغیرهای محیطی را دقیقاً مطابق راهنما تنظیم کنید.
- پس از هر تغییر در متغیرهای محیطی، Command Prompt را مجدداً باز کنید.

## مرحله بعدی

پس از نصب موفق JDK 17، می‌توانید به نصب سایر کامپوننت‌ها بپردازید:
- [نصب Android Studio](02-android-studio-installation.md)
- [نصب Gradle](03-gradle-installation.md)
- [نصب Command Line Tools](04-commandline-tools-installation.md)