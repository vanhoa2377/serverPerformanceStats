#!/bin/bash

echo "==================================================="
echo "             SERVER PERFORMANCE STATS              "
echo "==================================================="

# 1. Total CPU usage
# Sử dụng /proc/stat để tính toán phần trăm CPU chính xác, tránh lỗi format từ lệnh top
echo -e "\n[1] --- CPU Usage ---"
grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "Total CPU Usage: %.2f%%\n", usage}'

# 2. Total memory usage (Free vs Used & Percentage)
echo -e "\n[2] --- Memory Usage ---"
free -m | awk 'NR==2{printf "Total: %s MB | Used: %s MB (%.2f%%) | Free: %s MB\n", $2, $3, $3*100/$2, $4}'

# 3. Total disk usage (Tính cho phân vùng root /)
echo -e "\n[3] --- Disk Usage ---"
df -h / | awk 'NR==2{printf "Total: %s | Used: %s (%s) | Free: %s\n", $2, $3, $5, $4}'

# 4. Top 5 processes by CPU usage
echo -e "\n[4] --- Top 5 Processes by CPU Usage ---"
ps -eo pid,user,comm,%cpu,%mem --sort=-%cpu | head -n 6

# 5. Top 5 processes by Memory usage
echo -e "\n[5] --- Top 5 Processes by Memory Usage ---"
ps -eo pid,user,comm,%cpu,%mem --sort=-%mem | head -n 6

# ===================================================
# STRETCH GOALS (Tính năng mở rộng)
# ===================================================
echo -e "\n==================================================="
echo "                 EXTRA SYSTEM INFO                 "
echo "==================================================="

# OS Version
if [ -f /etc/os-release ]; then
    os_version=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d '"' -f 2)
    echo "OS Version:            $os_version"
fi

# Uptime
echo "Uptime:                $(uptime -p)"

# Load Average
echo "Load Average:          $(cat /proc/loadavg | awk '{print $1, $2, $3}')"

# Logged in users
echo "Logged in users:       $(who | wc -l)"

# Failed login attempts
# Lưu ý: Cần chạy script bằng quyền root (sudo) để đọc được file log này
if [ -r /var/log/auth.log ]; then
    # Hệ thống Debian/Ubuntu
    failed_logins=$(grep -c "Failed password" /var/log/auth.log)
    echo "Failed login attempts: $failed_logins"
elif [ -r /var/log/secure ]; then
    # Hệ thống RHEL/CentOS
    failed_logins=$(grep -c "Failed password" /var/log/secure)
    echo "Failed login attempts: $failed_logins"
else
    echo "Failed login attempts: (Requires sudo privileges to read logs)"
fi

echo "==================================================="