#!/bin/bash
# Script to display file or directory sizes

echo "=== Analyze Sizes in Directory ==="

read -p "Enter directory path: " directory

# Check if directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory $directory does not exist!"
    exit 1
fi

echo ""
echo "Choose option:"
echo "1 - Size of all files and folders in selected directory"
echo "2 - Total size of entire directory"
read -p "Your choice (1 or 2): " choice

case $choice in
    1)
        echo "=== Sizes of all items in $directory ==="
        if [ ! -r "$directory" ]; then
            echo "Error: No read permission for directory!"
            exit 1
        fi
        
        # File and folder sizes in human-readable format
        echo "File sizes:"
        find "$directory" -maxdepth 1 -type f -exec ls -lh {} \; 2>/dev/null | awk '{print $5, "\t", $9}'
        
        echo -e "\nDirectory sizes:"
        find "$directory" -maxdepth 1 -type d ! -path "$directory" -exec du -sh {} \; 2>/dev/null
        ;;
    2)
        echo "=== Total size of directory $directory ==="
        if [ ! -r "$directory" ]; then
            echo "Error: No read permission for directory!"
            exit 1
        fi
        
        total_size=$(du -sh "$directory" 2>/dev/null | cut -f1)
        if [ -n "$total_size" ]; then
            echo "Total size: $total_size"
        else
            echo "Failed to determine directory size!"
        fi
        ;;
    *)
        echo "Error: Invalid choice!"
        exit 1
        ;;
esac
