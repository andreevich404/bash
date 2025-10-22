#!/bin/bash
# Script to create and edit text file

echo "=== Create and Edit Text File ==="

# Choose editor
echo ""
echo "Choose text editor:"
echo "1 - nano (simple)"
echo "2 - vim (advanced)"
echo "3 - mcedit (from mc)"
echo "4 - Other (specify manually)"
read -p "Your choice (1-4): " editor_choice

case $editor_choice in
    1) editor="nano" ;;
    2) editor="vim" ;;
    3) editor="mcedit" ;;
    4) 
        read -p "Enter editor command: " editor
        if ! command -v "$editor" &>/dev/null; then
            echo "Error: Editor '$editor' not found!"
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid choice!"
        exit 1
        ;;
esac

# Check if editor is installed
if ! command -v "$editor" &>/dev/null; then
    echo "Error: Editor '$editor' not installed in system!"
    echo "Install it with: sudo yum install $editor"
    exit 1
fi

# Choose file location
echo ""
read -p "Enter path to save file: " file_path

# If path is not absolute, make it absolute relative to home directory
if [[ "$file_path" != /* ]]; then
    file_path="$HOME/$file_path"
fi

# Create directory if it doesn't exist
dir_path=$(dirname "$file_path")
if [ ! -d "$dir_path" ]; then
    echo "Creating directory $dir_path..."
    mkdir -p "$dir_path" 2>/dev/null || {
        echo "Error: Failed to create directory!"
        exit 1
    }
fi

# Check permissions
if [ -e "$file_path" ] && [ ! -w "$file_path" ]; then
    echo "Error: No write permission for file $file_path!"
    exit 1
fi

if [ ! -w "$dir_path" ]; then
    echo "Error: No write permission for directory $dir_path!"
    exit 1
fi

echo ""
echo "=== Creating File ==="
echo "Editor: $editor"
echo "File: $file_path"
echo ""

# Create temporary file with initial content
temp_file=$(mktemp)
cat > "$temp_file" << EOF
File created: $(date)
User: $(whoami)
Editor: $editor

Start entering text below this line:
--------------------------------------------------
EOF

# Open file in editor
echo "Opening editor $editor..."
if "$editor" "$temp_file"; then
    # Copy temporary file to target location
    if cp "$temp_file" "$file_path" 2>/dev/null; then
        echo "File successfully saved: $file_path"
        echo ""
        echo "=== File Information ==="
        ls -la "$file_path"
        echo ""
        echo "=== File Content ==="
        cat "$file_path"
    else
        echo "Error: Failed to save file to $file_path!"
        exit 1
    fi
else
    echo "Error: Failed to open editor $editor!"
    exit 1
fi

# Remove temporary file
rm -f "$temp_file"
