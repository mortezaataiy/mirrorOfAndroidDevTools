# راهنمای تست GitHub CLI (موقت)

## هدف استفاده از GitHub CLI
GitHub CLI فقط برای **تست موقت** workflows استفاده می‌شود و در فرایند نهایی جایگاهی ندارد.

## مسیر نصب در ویندوز:
```
"C:\Program Files\GitHub CLI\gh.exe"
```

## دستورات تست (فقط برای توسعه):

### تست و اجرای workflows:
```powershell
# اجرای workflow برای تست
& "C:\Program Files\GitHub CLI\gh.exe" workflow run "download-android-offline.yml"

# بررسی وضعیت اجرا
& "C:\Program Files\GitHub CLI\gh.exe" run list

# دانلود artifacts برای تست
& "C:\Program Files\GitHub CLI\gh.exe" run download [run-id]
```

## نکات مهم:
- GitHub CLI فقط برای تست workflows است
- در فرایند نهایی استفاده نمی‌شود
- فقط برای بررسی خروجی actions و دانلود artifacts
- هیچ کار دیگری با CLI انجام نمی‌شود