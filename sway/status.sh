#!/usr/bin/zsh

date=$(date "+%Y-%m-%d %H:%M:%S")

cpu=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')%

ram=$(free -m | awk '/^Mem:/ {printf "%.1f%%", $3/$2 * 100}')

battery=$(acpi -b | awk '{print $4}')

echo "Battery: $battery | CPU: $cpu | RAM: $ram | $date"
