#!/bin/bash
# Script to rename files with date addition

echo "=== Batch File Renaming ==="

read -p "Enter directory path: " directory

# Check if directory exists
if [ ! -d "$directory" ]; then
    echo "Error: Directory $directory does not exist!"
    exit 1
fi

# Check permissions
if [ ! -w "$directory" ]; then
    echo "Error: No write permission for directory $directory!"
    exit 1
fi

current_date=$(date '+%Y%m%d_%H%M%S')
echo "Renaming date: $current_date"
echo "Files to rename:"

# Show files before renaming
files=($(find "$directory" -maxdepth 1 -type f ! -name ".*" 2>/dev/null))

if [ ${#files[@]} -eq 0 ]; then
    echo "Error: No files to rename in directory!"
    exit 1
fi

for file in "${files[@]}"; do
    if [ -f "$file" ]; then
        echo "  - $(basename "$file")"
    fi
done

echo ""
read -p "Are you sure you want to rename these files? (y/n): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    success_count=0
    error_count=0
    
    for file in "${files[@]}"; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            dirpath=$(dirname "$file")
            extension="${filename##*.}"
            name_no_ext="${filename%.*}"
            
            # If file has no extension
            if [ "$extension" = "$filename" ]; then
                extension=""
                name_no_ext="$filename"
            fi
            
            new_name="${name_no_ext}.old_${current_date}"
            if [ -n "$extension" ] && [ "$extension" != "$filename" ]; then
                new_name="${new_name}.${extension}"
            fi
            
            new_path="$dirpath/$new_name"
            
            echo "Renaming: $filename -> $new_name"
            if mv "$file" "$new_path" 2>/dev/null; then
                echo " Success"
                ((success_count++))
            else
                echo " Error"
                ((error_count++))
            fi
        fi
    done
    
    echo ""
    echo "=== Result ==="
    echo "Successfully renamed: $success_count"
    echo "Errors: $error_count"
else
    echo "Operation cancelled."
fi
