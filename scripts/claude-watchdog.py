#!/usr/bin/env python3
import os
import time
from collections import defaultdict

DEBUG_DIR = "/root/.claude/debug"
os.makedirs(DEBUG_DIR, exist_ok=True)

buffers = defaultdict(list)

i = 0
while True:
    for filename in os.listdir(DEBUG_DIR):
        if not filename.endswith(".txt"):
            continue
        
        filepath = os.path.join(DEBUG_DIR, filename)
        try:
            size = os.path.getsize(filepath)
        except:
            continue
        
        # Add to buffer, keep last 5
        buffers[filename].append(size)
        buffers[filename] = buffers[filename][-5:]
        
        sizes = buffers[filename]
        
        # Check 1: All 5 strictly increasing (continuous write for 5s)
        if len(sizes) == 5:
            if all(sizes[j] < sizes[j+1] for j in range(4)):
                print(f"{time.ctime()}: {filename} written to for 5s straight, deleting...")
                os.remove(filepath)
                del buffers[filename]
                continue
        
        # Check 2: Every 2nd frame, >2MB growth over 2 seconds
        if i % 2 == 0 and len(sizes) >= 3:
            diff = sizes[-1] - sizes[-3]
            if diff > 2_000_000:
                print(f"{time.ctime()}: {filename} grew {diff} bytes in 2s, deleting...")
                os.remove(filepath)
                del buffers[filename]
                continue
    
    # Clean up buffers for deleted files
    for filename in list(buffers.keys()):
        if not os.path.exists(os.path.join(DEBUG_DIR, filename)):
            del buffers[filename]
    
    i += 1
    time.sleep(1)