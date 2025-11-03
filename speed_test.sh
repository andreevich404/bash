#!/bin/bash
FS_DIR=$1
FS_NAME=$2

echo "Testing $FS_NAME..."
for i in {1..3}; do
    echo "Run $i:"
    time (dd if=/dev/zero of=$FS_DIR/testfile bs=1M count=768 oflag=direct status=progress && sync)
    rm -f $FS_DIR/testfile
    echo "---"
done
