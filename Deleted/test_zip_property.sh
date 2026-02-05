#!/bin/bash

# ایجاد فایل‌های تست برای تست خصوصیت ۳
mkdir -p test_files

# تابع اعتبارسنجی یکپارچگی ZIP
validate_zip_integrity() {
  local file_path=$1
  local component_name=$2
  
  if [ ! -f "$file_path" ]; then
    echo "ERROR: $component_name - فایل وجود ندارد: $file_path"
    return 1
  fi
  
  if ! unzip -t "$file_path" > /dev/null 2>&1; then
    echo "ERROR: $component_name - بررسی یکپارچگی ZIP ناکام"
    return 1
  fi
  
  echo "SUCCESS: $component_name - یکپارچگی ZIP تأیید شد"
  return 0
}

echo "=== تست خصوصیت ۳: یکپارچگی فایل‌های ZIP ==="
echo "Feature: github-actions-workflow, Property 3: یکپارچگی فایل‌های ZIP"

# تست 1: ایجاد فایل ZIP معتبر
echo "تست 1: ایجاد و تست فایل ZIP معتبر"
echo "test content for zip" > test_files/test_content.txt
(cd test_files && zip -q valid_test.zip test_content.txt)

if validate_zip_integrity "test_files/valid_test.zip" "valid-zip-test" >/dev/null 2>&1; then
  echo "✓ تست ZIP معتبر موفق: فایل ZIP معتبر به درستی پذیرفته شد"
  valid_zip_result="pass"
else
  echo "✗ تست ZIP معتبر ناکام: فایل ZIP معتبر به اشتباه رد شد"
  valid_zip_result="fail"
fi

# تست 2: ایجاد فایل ZIP خراب
echo "تست 2: ایجاد و تست فایل ZIP خراب"
echo "This is not a valid ZIP file content" > "test_files/invalid_test.zip"

if validate_zip_integrity "test_files/invalid_test.zip" "invalid-zip-test" >/dev/null 2>&1; then
  echo "✗ تست ZIP خراب ناکام: فایل ZIP خراب به اشتباه پذیرفته شد"
  invalid_zip_result="fail"
else
  echo "✓ تست ZIP خراب موفق: فایل ZIP خراب به درستی رد شد"
  invalid_zip_result="pass"
fi

# تست 3: فایل ZIP خالی
echo "تست 3: ایجاد و تست فایل ZIP خالی"
touch test_files/empty_test.zip

if validate_zip_integrity "test_files/empty_test.zip" "empty-zip-test" >/dev/null 2>&1; then
  echo "✗ تست ZIP خالی ناکام: فایل ZIP خالی به اشتباه پذیرفته شد"
  empty_zip_result="fail"
else
  echo "✓ تست ZIP خالی موفق: فایل ZIP خالی به درستی رد شد"
  empty_zip_result="pass"
fi

# پاک کردن فایل‌های تست
rm -rf test_files

# بررسی نتایج
if [[ "$valid_zip_result" == "pass" && "$invalid_zip_result" == "pass" && "$empty_zip_result" == "pass" ]]; then
  echo "SUCCESS: تمام تست‌های خصوصیت ۳ موفق بودند"
  exit 0
else
  echo "FAILURE: برخی تست‌ها ناکام بودند"
  echo "تست ZIP معتبر: $valid_zip_result"
  echo "تست ZIP خراب: $invalid_zip_result"
  echo "تست ZIP خالی: $empty_zip_result"
  exit 1
fi