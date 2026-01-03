# دستورالعمل اصلاح workflow اصلی

## URL های معتبر پیدا شده

### SDK Platform API 33
URL جدید: `https://dl.google.com/android/repository/platform-33_r02.zip`

### Android M2Repository
URL جدید: `https://dl.google.com/android/repository/android_m2repository_r47.zip`

## نحوه اعمال تغییرات

1. فایل `.github/workflows/android-offline-complete.yml` را باز کنید
2. URL های ناکام را با URL های معتبر جایگزین کنید
3. workflow را مجدداً اجرا کنید
4. نتایج را بررسی کنید

## نکات مهم

- قبل از اعمال تغییرات، backup از workflow اصلی تهیه کنید
- پس از اعمال تغییرات، workflow را تست کنید
- در صورت بروز مشکل، به نسخه قبلی برگردید
