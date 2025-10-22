#!/bin/bash
# Script to find file by name in directory

echo "=== Find File by Name ==="

read -p "Enter directory to search: " search_dir
read -p "Enter filename to search: " filename

# Check if directory exists
if [ ! -d "$search_dir" ]; then
    echo "❌ Error: Directory $search_dir does not exist!"
    exit 1
fi

# Check directory permissions
if [ ! -r "$search_dir" ]; then
    echo "❌ Error: No read permission for directory $search_dir!"
    exit 1
fi

echo "Searching for file '$filename' in directory '$search_dir'..."
echo ""

# Search for file
result=$(find "$search_dir" -name "$filename" -type f 2>/dev/null)

if [ -n "$result" ]; then
    echo "✅ File found:"
    echo "$result"
    
    # Additional information about found files
    echo -e "\n=== Additional Information ==="
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            echo "File: $file"
            echo "Size: $(ls -lh "$file" | awk '{print $5}')"
            echo "Permissions: $(ls -l "$file" | awk '{print $1}')"
            echo "Owner: $(ls -l "$file" | awk '{print $3}')"
            echo "---"
        fi
    done <<< "$result"
else
    echo "❌ Error: File '$filename' not found in directory '$search_dir'!"
    exit 1
fi
