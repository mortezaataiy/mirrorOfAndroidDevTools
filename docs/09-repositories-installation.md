# نصب Repositories

## مقدمه

Android Repositories شامل کتابخانه‌های Maven برای توسعه اندروید هستند که برای استفاده از AndroidX، Google Play Services و سایر کتابخانه‌های گوگل ضروری هستند. این راهنما شما را در فرآیند نصب آفلاین Android M2Repository و Google M2Repository در ویندوز راهنمایی می‌کند.

## پیش‌نیازها

- سیستم‌عامل ویندوز 10 یا بالاتر (64 بیت)
- حداقل 500 مگابایت فضای خالی در هارد دیسک
- **Command Line Tools نصب شده** (مراجعه کنید به [راهنمای نصب Command Line Tools](04-commandline-tools-installation.md))
- متغیر محیطی ANDROID_HOME تنظیم شده
- فایل‌های Repository در پوشه `downloaded/`

## فایل‌های مورد نیاز

- **Android M2Repository**: `android-m2repository.zip` (حدود 400 مگابایت)
- **Google M2Repository**: `google-m2repository.zip` (حدود 300 مگابایت)

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

1. پوشه extras را در SDK ایجاد کنید (اگر وجود ندارد):
   ```cmd
   mkdir "%ANDROID_HOME%\extras"
   ```

2. پوشه‌های مربوط به repositories را ایجاد کنید:
   ```cmd
   mkdir "%ANDROID_HOME%\extras\android"
   mkdir "%ANDROID_HOME%\extras\google"
   ```

### مرحله 3: نصب Android M2Repository

1. فایل `android-m2repository.zip` را از مسیر زیر پیدا کنید:
   ```
   downloaded/android-m2repository/android-m2repository.zip
   ```

2. فایل ZIP را استخراج کنید.

3. محتویات پوشه `m2repository` استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\extras\android\m2repository\
   ```

4. ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\extras\android\m2repository\
   ├── com\
   │   └── android\
   │       ├── support\
   │       ├── databinding\
   │       └── ...
   ├── NOTICE.txt
   └── source.properties
   ```

### مرحله 4: نصب Google M2Repository

1. فایل `google-m2repository.zip` را پیدا کنید (معمولاً در همان پوشه android-m2repository).

2. فایل ZIP را استخراج کنید.

3. محتویات پوشه `m2repository` استخراج شده را به مسیر زیر کپی کنید:
   ```
   D:\Android\Sdk\extras\google\m2repository\
   ```

4. ساختار پوشه باید به شکل زیر باشد:
   ```
   D:\Android\Sdk\extras\google\m2repository\
   ├── com\
   │   └── google\
   │       ├── android\
   │       ├── firebase\
   │       └── ...
   ├── NOTICE.txt
   └── source.properties
   ```

### مرحله 5: بررسی نهایی ساختار

پس از نصب تمام repositories، ساختار کلی باید به شکل زیر باشد:

```
D:\Android\Sdk\extras\
├── android\
│   └── m2repository\
│       ├── com\
│       ├── NOTICE.txt
│       └── source.properties
└── google\
    └── m2repository\
        ├── com\
        ├── NOTICE.txt
        └── source.properties
```

## تست نصب

### تست فوری

این تست‌ها بلافاصله پس از نصب Repositories قابل اجرا هستند:

#### 1. بررسی وجود پوشه‌های اصلی

```cmd
dir "%ANDROID_HOME%\extras\android\m2repository"
dir "%ANDROID_HOME%\extras\google\m2repository"
```

**نتیجه مورد انتظار**: هر دو پوشه وجود داشته باشند.

**در صورت خطا**: اگر پوشه‌ای یافت نشد، کپی درست انجام نشده است.

#### 2. بررسی فایل‌های source.properties

```cmd
type "%ANDROID_HOME%\extras\android\m2repository\source.properties"
type "%ANDROID_HOME%\extras\google\m2repository\source.properties"
```

**نتیجه مورد انتظار برای Android M2Repository**:
```
Extra.VendorId=android
Extra.VendorDisplay=Android
Extra.NameDisplay=Android Support Repository
Extra.Path=m2repository
Pkg.Revision=47.0.0
```

#### 3. بررسی وجود کتابخانه‌های مهم

```cmd
dir "%ANDROID_HOME%\extras\android\m2repository\com\android\support"
dir "%ANDROID_HOME%\extras\google\m2repository\com\google\android\gms"
dir "%ANDROID_HOME%\extras\google\m2repository\com\google\firebase"
```

**نتیجه مورد انتظار**: پوشه‌های کتابخانه‌های اصلی وجود داشته باشند.

#### 4. بررسی ساختار AndroidX

```cmd
dir "%ANDROID_HOME%\extras\android\m2repository\androidx" /s | findstr "appcompat core"
```

**نتیجه مورد انتظار**: کتابخانه‌های AndroidX نمایش داده شوند.

#### 5. بررسی Material Design Components

```cmd
dir "%ANDROID_HOME%\extras\google\m2repository\com\google\android\material" /s
```

**نتیجه مورد انتظار**: کتابخانه‌های Material Design وجود داشته باشند.

#### 6. بررسی اندازه repositories

```cmd
dir "%ANDROID_HOME%\extras\android\m2repository" /s | findstr "File(s)"
dir "%ANDROID_HOME%\extras\google\m2repository" /s | findstr "File(s)"
```

**نتیجه مورد انتظار**: تعداد زیادی فایل (هزاران فایل) وجود داشته باشد.

### تست ترکیبی

این تست‌ها پس از نصب سایر کامپوننت‌ها قابل اجرا هستند:

#### تست با SDK Manager (پیش‌نیاز: نصب Command Line Tools)

```cmd
sdkmanager --list --offline | findstr m2repository
```

**نتیجه مورد انتظار**:
```
extras;android;m2repository | 47.0.0 | Android Support Repository | extras\android\m2repository\
extras;google;m2repository | 58.0.0 | Google Repository | extras\google\m2repository\
```

**کامپوننت‌های پیش‌نیاز**:
- [نصب Command Line Tools](04-commandline-tools-installation.md)

#### تست با Gradle (پیش‌نیاز: پروژه Android)

در فایل `build.gradle` پروژه، کتابخانه‌های زیر باید بدون خطا resolve شوند:

```gradle
dependencies {
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
}
```

**نتیجه مورد انتظار**: Gradle sync بدون خطا انجام شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)
- پروژه Android معتبر

#### تست Gradle Dependencies (پیش‌نیاز: پروژه Android کامل)

```cmd
gradle dependencies --configuration implementation
```

**نتیجه مورد انتظار**: تمام dependencies از repositories محلی resolve شوند.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Gradle](03-gradle-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- پروژه Android کامل

#### تست بیلد با AndroidX (پیش‌نیاز: محیط کامل Android)

```cmd
gradle assembleDebug
```

**نتیجه مورد انتظار**: پروژه با استفاده از کتابخانه‌های AndroidX بیلد شود.

**کامپوننت‌های پیش‌نیاز**:
- [نصب Build Tools](06-build-tools-installation.md)
- [نصب SDK Platforms](07-sdk-platforms-installation.md)
- [نصب SDK Licenses](10-sdk-licenses-installation.md)
- پروژه Android کامل

#### تست Google Play Services (پیش‌نیاز: پروژه با Google Services)

در فایل `build.gradle`:
```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-maps:18.1.0'
    implementation 'com.google.firebase:firebase-analytics:21.3.0'
}
```

**نتیجه مورد انتظار**: کتابخانه‌های Google بدون خطا resolve شوند.

**کامپوننت‌های پیش‌نیاز**:
- پروژه Android با Google Services تنظیم شده

#### تست Offline Repository (پیش‌نیاز: تنظیم Gradle آفلاین)

در فایل `build.gradle`:
```gradle
allprojects {
    repositories {
        maven { url "$System.env.ANDROID_HOME/extras/android/m2repository" }
        maven { url "$System.env.ANDROID_HOME/extras/google/m2repository" }
        // حذف google() و mavenCentral() برای تست آفلاین
    }
}
```

**نتیجه مورد انتظار**: پروژه کاملاً آفلاین بیلد شود.

#### تست Android Studio Integration (پیش‌نیاز: نصب Android Studio)

1. Android Studio را باز کنید
2. پروژه جدید ایجاد کنید
3. کتابخانه‌های AndroidX و Material Design باید در suggestions نمایش داده شوند

**کامپوننت‌های پیش‌نیاز**:
- [نصب Android Studio](02-android-studio-installation.md)

## کاربردهای Repositories

### استفاده از AndroidX Libraries

```gradle
dependencies {
    // Core AndroidX libraries
    implementation 'androidx.core:core:1.10.1'
    implementation 'androidx.appcompat:appcompat:1.6.1'
    implementation 'androidx.activity:activity:1.7.2'
    implementation 'androidx.fragment:fragment:1.6.1'
    
    // UI Components
    implementation 'com.google.android.material:material:1.9.0'
    implementation 'androidx.constraintlayout:constraintlayout:2.1.4'
    implementation 'androidx.recyclerview:recyclerview:1.3.1'
    
    // Architecture Components
    implementation 'androidx.lifecycle:lifecycle-viewmodel:2.6.2'
    implementation 'androidx.lifecycle:lifecycle-livedata:2.6.2'
    implementation 'androidx.room:room-runtime:2.5.0'
}
```

### استفاده از Google Play Services

```gradle
dependencies {
    // Google Play Services
    implementation 'com.google.android.gms:play-services-maps:18.1.0'
    implementation 'com.google.android.gms:play-services-location:21.0.1'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
    
    // Firebase
    implementation 'com.google.firebase:firebase-analytics:21.3.0'
    implementation 'com.google.firebase:firebase-auth:22.1.2'
    implementation 'com.google.firebase:firebase-firestore:24.7.1'
}
```

### تنظیم Repository در Gradle

```gradle
allprojects {
    repositories {
        google()
        mavenCentral()
        
        // Local repositories (آفلاین)
        maven {
            url "$rootDir/../Sdk/extras/android/m2repository"
        }
        maven {
            url "$rootDir/../Sdk/extras/google/m2repository"
        }
    }
}
```

## عیب‌یابی

### مشکلات رایج و راه‌حل‌ها

#### خطای "Could not resolve dependency"

**علت**: کتابخانه در repositories محلی یافت نمی‌شود.

**راه‌حل**:
1. بررسی وجود کتابخانه در repository:
   ```cmd
   dir "%ANDROID_HOME%\extras\android\m2repository\com\android\support" /s
   ```
2. بررسی نسخه کتابخانه در `build.gradle`.
3. اطمینان از تنظیم صحیح repositories در Gradle.

#### خطای "Repository not found"

**علت**: مسیر repositories در Gradle اشتباه است.

**راه‌حل**:
1. بررسی مسیر در `build.gradle`:
   ```gradle
   maven {
       url "$System.env.ANDROID_HOME/extras/android/m2repository"
   }
   ```
2. یا استفاده از مسیر مطلق:
   ```gradle
   maven {
       url "D:/Android/Sdk/extras/android/m2repository"
   }
   ```

#### خطای "Gradle sync failed"

**علت**: تنظیمات repository یا نسخه کتابخانه‌ها اشتباه است.

**راه‌حل**:
1. بررسی فایل `build.gradle` پروژه.
2. اطمینان از وجود repositories:
   ```cmd
   dir "%ANDROID_HOME%\extras\android\m2repository"
   dir "%ANDROID_HOME%\extras\google\m2repository"
   ```
3. تمیز کردن cache Gradle:
   ```cmd
   gradle clean
   ```

#### کتابخانه‌های قدیمی Support Library

**علت**: استفاده از Support Library به جای AndroidX.

**راه‌حل**:
1. مهاجرت به AndroidX:
   ```gradle
   // قدیمی
   implementation 'com.android.support:appcompat-v7:28.0.0'
   
   // جدید
   implementation 'androidx.appcompat:appcompat:1.6.1'
   ```
2. یا اضافه کردن تنظیمات زیر به `gradle.properties`:
   ```properties
   android.useAndroidX=true
   android.enableJetifier=true
   ```

### بررسی سیستماتیک

اگر مشکل همچنان ادامه دارد، مراحل زیر را دنبال کنید:

1. **بررسی وجود فایل‌های ضروری**:
   ```cmd
   dir "%ANDROID_HOME%\extras\android\m2repository\source.properties"
   dir "%ANDROID_HOME%\extras\google\m2repository\source.properties"
   ```

2. **بررسی ساختار پوشه‌ها**:
   ```cmd
   dir "%ANDROID_HOME%\extras\android\m2repository\com\android" /s
   dir "%ANDROID_HOME%\extras\google\m2repository\com\google" /s
   ```

3. **تست SDK Manager**:
   ```cmd
   sdkmanager --list --offline | findstr extras
   ```

4. **بررسی تنظیمات Gradle**:
   ```cmd
   gradle dependencies --configuration implementation
   ```

### راهنمای بازنصب

در صورت نیاز به بازنصب:

1. پوشه‌های repository را پاک کنید:
   ```cmd
   rmdir /s /q "%ANDROID_HOME%\extras\android\m2repository"
   rmdir /s /q "%ANDROID_HOME%\extras\google\m2repository"
   ```

2. Cache Gradle را پاک کنید:
   ```cmd
   rmdir /s /q "%USERPROFILE%\.gradle\caches"
   ```

3. مراحل نصب را از ابتدا تکرار کنید.

## تنظیمات پیشرفته

### تنظیم Offline Repository

برای کار کاملاً آفلاین، تنظیمات زیر را در `build.gradle` اضافه کنید:

```gradle
allprojects {
    repositories {
        // فقط repositories محلی
        maven {
            url "$System.env.ANDROID_HOME/extras/android/m2repository"
        }
        maven {
            url "$System.env.ANDROID_HOME/extras/google/m2repository"
        }
        
        // غیرفعال کردن repositories آنلاین
        // google()
        // mavenCentral()
    }
}
```

### کش کردن Dependencies

```gradle
configurations.all {
    resolutionStrategy.cacheChangingModulesFor 0, 'seconds'
    resolutionStrategy.cacheDynamicVersionsFor 0, 'seconds'
}
```

## اطلاعات کتابخانه‌های مهم

### AndroidX Core Libraries

- **androidx.core:core**: ویژگی‌های اصلی Android
- **androidx.appcompat:appcompat**: سازگاری با نسخه‌های قدیمی
- **androidx.activity:activity**: مدیریت Activity ها
- **androidx.fragment:fragment**: مدیریت Fragment ها

### Material Design Components

- **com.google.android.material:material**: کامپوننت‌های Material Design
- **androidx.constraintlayout:constraintlayout**: Layout پیشرفته
- **androidx.recyclerview:recyclerview**: لیست‌های قابل اسکرول

### Architecture Components

- **androidx.lifecycle:lifecycle-***: مدیریت چرخه حیات
- **androidx.room:room-***: پایگاه داده محلی
- **androidx.navigation:navigation-***: ناوبری بین صفحات

## نکات مهم

- Repositories شامل کتابخانه‌های ضروری برای توسعه اندروید هستند.
- AndroidX جایگزین Support Library است و توصیه می‌شود.
- در حالت آفلاین، فقط از repositories محلی استفاده کنید.
- نسخه کتابخانه‌ها باید با compileSdkVersion سازگار باشند.

## مرحله بعدی

پس از نصب موفق Repositories، می‌توانید به نصب آخرین کامپوننت بپردازید:
- [نصب SDK Licenses](10-sdk-licenses-installation.md)
- [ایجاد پروژه Hello World](11-hello-world-project.md)