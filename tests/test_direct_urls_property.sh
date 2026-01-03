#!/bin/bash

# تابع تشخیص محتوای HTML
detect_html_content() {
  local file_path=$1
  local component_name=$2
  
  if [ ! -f "$file_path" ]; then
    echo "ERROR: $component_name - فایل وجود ندارد: $file_path"
    return 1
  fi
  
  # بررسی 1024 بایت اول فایل برای تگ‌های HTML
  head_content=$(head -c 1024 "$file_path")
  
  if echo "$head_content" | grep -qi -E '(<html|<!DOCTYPE|<head|<body)'; then
    echo "ERROR: $component_name - محتوای HTML تشخیص داده شد به جای فایل باینری"
    return 1
  fi
  
  echo "SUCCESS: $component_name - محتوای باینری تأیید شد"
  return 0
}

echo "=== تست خصوصیت ۵: URL های مستقیم باینری ==="
echo "Feature: github-actions-workflow, Property 5: URL های مستقیم باینری"

mkdir -p test_files

# تست 1: بررسی URL مستقیم با دانلود کوچک
echo "تست 1: بررسی URL مستقیم Gradle"
test_url="https://services.gradle.org/distributions/gradle-8.1-bin.zip"

# دانلود فقط header برای بررسی نوع محتوا
if curl -I -L "$test_url" 2>/dev/null | grep -i "content-type" | grep -q "application"; then
  echo "✓ تست URL مستقیم موفق: URL باینری مستقیم برمی‌گرداند"
  direct_url_result="pass"
else
  echo "✗ تست URL مستقیم ناکام: URL محتوای غیرباینری برمی‌گرداند"
  direct_url_result="fail"
fi

# تست 2: بررسی عدم وجود redirect HTML
echo "تست 2: بررسی عدم وجود HTML redirect"
# دانلود 1KB اول برای بررسی محتوا
if curl -L -r 0-1023 "$test_url" -o test_files/header_test.bin 2>/dev/null; then
  if detect_html_content "test_files/header_test.bin" "header-test" >/dev/null 2>&1; then
    echo "✓ تست عدم HTML موفق: محتوای باینری تشخیص داده شد"
    no_html_result="pass"
  else
    echo "✗ تست عدم HTML ناکام: محتوای HTML تشخیص داده شد"
    no_html_result="fail"
  fi
else
  echo "✗ تست عدم HTML ناکام: دانلود header ناکام"
  no_html_result="fail"
fi

# تست 3: بررسی اندازه مناسب (حداقل برای Gradle)
echo "تست 3: بررسی اندازه مناسب فایل"
if curl -I -L "$test_url" 2>/dev/null | grep -i "content-length" | awk '{print $2}' | tr -d '\r' | {
  read content_length
  if [ "$content_length" -gt 52428800 ]; then  # 50MB
    echo "✓ تست اندازه موفق: فایل اندازه مناسب دارد ($content_length bytes)"
    size_result="pass"
  else
    echo "✗ تست اندازه ناکام: فایل کوچک است ($content_length bytes)"
    size_result="fail"
  fi
  echo "$size_result" > test_files/size_result.txt
}; then
  size_result=$(cat test_files/size_result.txt)
else
  echo "✗ تست اندازه ناکام: نتوانست اندازه فایل را بررسی کند"
  size_result="fail"
fi

# پاک کردن فایل‌های تست
rm -rf test_files

# بررسی نتایج
if [[ "$direct_url_result" == "pass" && "$no_html_result" == "pass" && "$size_result" == "pass" ]]; then
  echo "SUCCESS: تمام تست‌های خصوصیت ۵ موفق بودند"
  exit 0
else
  echo "FAILURE: برخی تست‌ها ناکام بودند"
  echo "تست URL مستقیم: $direct_url_result"
  echo "تست عدم HTML: $no_html_result"
  echo "تست اندازه: $size_result"
  exit 1
fi