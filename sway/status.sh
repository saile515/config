#!/usr/bin/zsh

date=$(date "+%Y-%m-%d %H:%M:%S")
cpu=$(vmstat 1 2 | tail -1 | awk '{print 100 - $15}')%
ram=$(free -m | awk '/^Mem:/ {printf "%.1f%%", $3/$2 * 100}')

if command -v acpi >/dev/null 2>&1; then
    battery="Battery: $(acpi -b | grep -oE '[0-9]+%') | "
else
    battery=""
fi

echo "${battery}CPU: $cpu | RAM: $ram | $date"
