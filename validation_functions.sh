#!/bin/bash

# تابع اعتبارسنجی اندازه فایل
validate_file_size() {
  local file_path=$1
  local min_size=$2
  local component_name=$3
  
  if [ ! -f "$file_path" ]; then
    echo "ERROR: $component_name - فایل وجود ندارد: $file_path"
    return 1
  fi
  
  file_size=$(stat -c%s "$file_path")
  
  if [ $file_size -lt $min_size ]; then
    echo "ERROR: $component_name - اندازه فایل کوچک است ($file_size bytes, حداقل: $min_size bytes)"
    return 1
  fi
  
  echo "SUCCESS: $component_name - اعتبارسنجی اندازه موفق ($file_size bytes)"
  return 0
}

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

# تابع اعتبارسنجی کامل کامپوننت
validate_component() {
  local file_path=$1
  local min_size=$2
  local component_name=$3
  local validation_type=$4
  
  echo "شروع اعتبارسنجی کامپوننت: $component_name"
  
  # بررسی اندازه فایل
  if ! validate_file_size "$file_path" "$min_size" "$component_name"; then
    return 1
  fi
  
  # تشخیص محتوای HTML
  if ! detect_html_content "$file_path" "$component_name"; then
    return 1
  fi
  
  # اعتبارسنجی بر اساس نوع فایل
  case "$validation_type" in
    "zip")
      if ! validate_zip_integrity "$file_path" "$component_name"; then
        return 1
      fi
      ;;
    "exe")
      # برای فایل‌های EXE فقط اندازه و محتوای HTML بررسی می‌شود
      echo "SUCCESS: $component_name - اعتبارسنجی EXE کامل شد"
      ;;
    *)
      echo "WARNING: نوع اعتبارسنجی ناشناخته: $validation_type"
      ;;
  esac
  
  echo "SUCCESS: $component_name - اعتبارسنجی کامل با موفقیت انجام شد"
  return 0
}

# تابع ثبت نتیجه اعتبارسنجی در JSON
log_validation_result() {
  local component_name=$1
  local status=$2
  local file_size=$3
  local error_message=$4
  local file_path=$5
  
  # محاسبه checksum
  local checksum=""
  if [ -f "$file_path" ]; then
    checksum=$(sha256sum "$file_path" | cut -d' ' -f1)
  fi
  
  # ایجاد JSON entry
  local json_entry=$(cat << EOF
{
  "component_name": "$component_name",
  "status": "$status",
  "file_size": $file_size,
  "error_message": "$error_message",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "checksum": "$checksum"
}
EOF
)
  
  # اضافه کردن به فایل JSON
  if [ -f "validation_results.json" ]; then
    # خواندن JSON موجود و اضافه کردن entry جدید
    jq ". += [$json_entry]" validation_results.json > temp.json && mv temp.json validation_results.json
  else
    echo "[$json_entry]" > validation_results.json
  fi
}