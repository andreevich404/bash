#!/bin/bash
FS_DIR=$1
FS_NAME=$2

echo "Testing $FS_NAME..."
for i in {1..3}; do
    echo "Run $i:"
    # Используем dd без oflag=direct для tmpfs
    time (dd if=/dev/zero of=$FS_DIR/testfile.$i bs=1M count=768 status=progress && sync)
    echo "---"
    # Удаляем файл после каждого теста
    rm -f $FS_DIR/testfile.$i
done
