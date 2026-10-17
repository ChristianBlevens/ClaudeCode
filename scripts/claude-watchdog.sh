#!/bin/bash
DEBUG_DIR="/root/.claude/debug"
mkdir -p "$DEBUG_DIR"
rm -f "$DEBUG_DIR"/*.txt

while true; do
    for file in "$DEBUG_DIR"/*.txt; do
        [ -f "$file" ] || continue
        size1=$(stat -c%s "$file" 2>/dev/null || echo 0)
        sleep 2
        size2=$(stat -c%s "$file" 2>/dev/null || echo 0)
        
        growth=$((size2 - size1))
        if [ "$growth" -gt 10000000 ]; then
            echo "$(date): Runaway debug file detected (grew ${growth} bytes), deleting..."
            rm -f "$file"
        fi
    done
done