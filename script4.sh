#!/bin/bash
# Script to list files or directories

echo "=== List Directory Contents ==="

read -p "Enter directory path: " directory

# Check if directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory $directory does not exist!"
    exit 1
fi

# Check permissions
if [ ! -r "$directory" ]; then
    echo "Error: No read permission for directory $directory!"
    exit 1
fi

echo ""
echo "Choose what to display:"
echo "1 - All files"
echo "2 - All directories"
read -p "Your choice (1 or 2): " choice

case $choice in
    1)
        echo "=== FILES in directory $directory ==="
        files=$(find "$directory" -maxdepth 1 -type f 2>/dev/null)
        if [ -n "$files" ]; then
            echo "$files"
        else
            echo "No files in directory!"
        fi
        ;;
    2)
        echo "=== DIRECTORIES in directory $directory ==="
        # Exclude current directory (.)
        dirs=$(find "$directory" -maxdepth 1 -type d 2>/dev/null | tail -n +2)
        if [ -n "$dirs" ]; then
            echo "$dirs"
        else
            echo "No subdirectories in directory!"
        fi
        ;;
    *)
        echo "Error: Invalid choice!"
        exit 1
        ;;
esac
