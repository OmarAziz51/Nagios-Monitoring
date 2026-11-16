#!/usr/bin/env bash
# Nagios plugin: report Linux memory utilization using MemAvailable.
# Exit codes: 0=OK, 1=WARNING, 2=CRITICAL, 3=UNKNOWN.

set -u

WARN="${1:-80}"
CRIT="${2:-90}"

if ! [[ "$WARN" =~ ^[0-9]+$ && "$CRIT" =~ ^[0-9]+$ ]] ||
   (( WARN < 1 || CRIT > 100 || WARN >= CRIT )); then
    echo "UNKNOWN - invalid thresholds (usage: check_mem.sh [warning%] [critical%])"
    exit 3
fi

if [[ ! -r /proc/meminfo ]]; then
    echo "UNKNOWN - cannot read /proc/meminfo"
    exit 3
fi

read -r total_kb available_kb < <(
    awk '
        /^MemTotal:/     { total=$2 }
        /^MemAvailable:/ { available=$2 }
        END {
            if (total > 0 && available >= 0) print total, available
            else exit 1
        }
    ' /proc/meminfo
) || {
    echo "UNKNOWN - unable to determine memory totals"
    exit 3
}

used_pct=$(( (total_kb - available_kb) * 100 / total_kb ))

if (( used_pct >= CRIT )); then
    echo "CRITICAL - Memory usage ${used_pct}% | memory_used=${used_pct}%;${WARN};${CRIT};0;100"
    exit 2
elif (( used_pct >= WARN )); then
    echo "WARNING - Memory usage ${used_pct}% | memory_used=${used_pct}%;${WARN};${CRIT};0;100"
    exit 1
else
    echo "OK - Memory usage ${used_pct}% | memory_used=${used_pct}%;${WARN};${CRIT};0;100"
    exit 0
fi
