#!/bin/bash

# Feature: github-actions-workflow, Property 1: اعتبارسنجی اندازه فایل جامع
# **اعتبارسنجی: الزامات ۲.۱، ۶.۱-۶.۱۱**

# بارگذاری توابع اعتبارسنجی
source ./validation_functions.sh 2>/dev/null || source ../validation_functions.sh 2>/dev/null || {
    echo "ERROR: نمی‌توان فایل validation_functions.sh را پیدا کرد"
    exit 1
}

# تابع تولید فایل تصادفی با اندازه مشخص
generate_test_file() {
    local size=$1
    local filename=$2
    
    # تولید فایل با اندازه مشخص (در بایت)
    dd if=/dev/zero of="$filename" bs=1 count=$size 2>/dev/null
}

# تست خصوصیت ۱: اعتبارسنجی اندازه فایل جامع
test_file_size_validation_property() {
    echo "=== تست خصوصیت ۱: اعتبارسنجی اندازه فایل جامع ==="
    
    local test_count=0
    local passed_tests=0
    local failed_tests=0
    
    # ایجاد پوشه موقت برای تست‌ها
    local test_dir="temp_test_files"
    mkdir -p "$test_dir"
    
    # بررسی فایل‌های موجود در .ignoredDownloads
    if [ -d ".ignoredDownloads" ] && [ "$(ls -A .ignoredDownloads 2>/dev/null)" ]; then
        echo "استفاده از فایل‌های موجود در .ignoredDownloads برای تست..."
        
        for file in .ignoredDownloads/*; do
            if [ -f "$file" ]; then
                local filename=$(basename "$file")
                local file_size=$(stat -c%s "$file" 2>/dev/null || echo "0")
                
                # تست با حداقل اندازه‌های مختلف
                local min_sizes=(1000 10000 100000 1000000 10000000)
                
                for min_size in "${min_sizes[@]}"; do
                    ((test_count++))
                    local component_name="real-file-$filename-test-$test_count"
                    
                    # اجرای تست اعتبارسنجی
                    if validate_file_size "$file" "$min_size" "$component_name" >/dev/null 2>&1; then
                        validation_result=0
                    else
                        validation_result=1
                    fi
                    
                    # بررسی صحت نتیجه
                    if [ $file_size -ge $min_size ]; then
                        # فایل باید معتبر باشد
                        if [ $validation_result -eq 0 ]; then
                            ((passed_tests++))
                        else
                            echo "FAIL: تست $test_count - فایل معتبر به اشتباه رد شد ($filename: $file_size bytes, حداقل: $min_size bytes)"
                            ((failed_tests++))
                        fi
                    else
                        # فایل باید نامعتبر باشد
                        if [ $validation_result -eq 1 ]; then
                            ((passed_tests++))
                        else
                            echo "FAIL: تست $test_count - فایل نامعتبر به اشتباه پذیرفته شد ($filename: $file_size bytes, حداقل: $min_size bytes)"
                            ((failed_tests++))
                        fi
                    fi
                done
            fi
        done
    fi
    
    # اگر فایل واقعی وجود نداشت، تست‌های تصادفی انجام دهیم
    if [ $test_count -eq 0 ]; then
        echo "فایل واقعی یافت نشد، استفاده از تست‌های تصادفی..."
        
        for i in $(seq 1 10); do
            ((test_count++))
            # تولید اندازه‌های تصادفی
            local min_size=$((RANDOM % 1000000 + 100000))  # 100KB تا 1MB
            local actual_size=$((RANDOM % 2000000))         # 0 تا 2MB
            
            local test_file="$test_dir/test_file_$i.bin"
            local component_name="test-component-$i"
            
            # تولید فایل تست
            generate_test_file $actual_size "$test_file"
            
            # اجرای تست اعتبارسنجی
            if validate_file_size "$test_file" "$min_size" "$component_name" >/dev/null 2>&1; then
                validation_result=0
            else
                validation_result=1
            fi
            
            # بررسی صحت نتیجه
            if [ $actual_size -ge $min_size ]; then
                # فایل باید معتبر باشد
                if [ $validation_result -eq 0 ]; then
                    ((passed_tests++))
                else
                    echo "FAIL: تست $test_count - فایل معتبر به اشتباه رد شد (اندازه: $actual_size, حداقل: $min_size)"
                    ((failed_tests++))
                fi
            else
                # فایل باید نامعتبر باشد
                if [ $validation_result -eq 1 ]; then
                    ((passed_tests++))
                else
                    echo "FAIL: تست $test_count - فایل نامعتبر به اشتباه پذیرفته شد (اندازه: $actual_size, حداقل: $min_size)"
                    ((failed_tests++))
                fi
            fi
            
            # پاک کردن فایل تست
            rm -f "$test_file"
        done
    fi
    
    # پاک کردن پوشه موقت
    rmdir "$test_dir" 2>/dev/null
    
    echo "نتایج تست خصوصیت ۱:"
    echo "  تعداد کل تست‌ها: $test_count"
    echo "  تست‌های موفق: $passed_tests"
    echo "  تست‌های ناکام: $failed_tests"
    echo "  درصد موفقیت: $(( passed_tests * 100 / test_count ))%"
    
    if [ $failed_tests -eq 0 ]; then
        echo "SUCCESS: تمام تست‌های خصوصیت ۱ موفق بودند"
        return 0
    else
        echo "FAILURE: $failed_tests تست از $test_count ناکام بودند"
        return 1
    fi
}

# اجرای تست اصلی
main() {
    echo "شروع تست‌های خصوصیت برای اعتبارسنجی اندازه فایل"
    echo "=================================================="
    
    if test_file_size_validation_property; then
        echo "✓ تست خصوصیت ۱ موفق بود"
        exit 0
    else
        echo "✗ تست خصوصیت ۱ ناکام بود"
        exit 1
    fi
}

# اجرای تست اگر اسکریپت مستقیماً اجرا شود
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    main "$@"
fi