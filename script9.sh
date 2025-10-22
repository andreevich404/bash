#!/bin/bash
# Script to change owner and permissions

echo "=== Change Owner and Permissions ==="

read -p "Enter file or directory path: " target

# Check if exists
if [ ! -e "$target" ]; then
    echo "Error: File or directory '$target' doesn't exist!"
    exit 1
fi

echo ""
echo "Current information:"
ls -ld "$target"

echo ""
echo "Choose action:"
echo "1 - Change owner (user and group)"
echo "2 - Change permissions"
echo "3 - Change both owner and permissions"
read -p "Your choice (1-3): " action

case $action in
    1|3)
        echo ""
        echo "=== Change Owner ==="
        read -p "Enter new owner (user): " new_owner
        read -p "Enter new group: " new_group
        
        if [ -n "$new_owner" ] && [ -n "$new_group" ]; then
            echo "Changing owner to $new_owner:$new_group..."
            if sudo chown "$new_owner:$new_group" "$target" 2>/dev/null; then
                echo "Owner successfully changed!"
            else
                echo "Error: Failed to change owner!"
            fi
        elif [ -n "$new_owner" ]; then
            echo "Changing owner to $new_owner..."
            if sudo chown "$new_owner" "$target" 2>/dev/null; then
                echo "Owner successfully changed!"
            else
                echo "Error: Failed to change owner!"
            fi
        elif [ -n "$new_group" ]; then
            echo "Changing group to $new_group..."
            if sudo chgrp "$new_group" "$target" 2>/dev/null; then
                echo "Group successfully changed!"
            else
                echo "Error: Failed to change group!"
            fi
        else
            echo "Neither user nor group specified."
        fi
        ;;
esac

case $action in
    2|3)
        echo ""
        echo "=== Change Permissions ==="
        echo "Current permissions: $(stat -c %A "$target")"
        echo ""
        echo "Permission examples:"
        echo "755 - rwxr-xr-x (owner: all, others: read+execute)"
        echo "644 - rw-r--r-- (owner: read+write, others: read)"
        echo "700 - rwx------ (owner only)"
        echo ""
        read -p "Enter new permissions (numeric format, e.g. 755): " new_perms
        
        if [[ "$new_perms" =~ ^[0-7]{3,4}$ ]]; then
            echo "Changing permissions to $new_perms..."
            if sudo chmod "$new_perms" "$target" 2>/dev/null; then
                echo "Permissions successfully changed!"
                echo "New permissions: $(stat -c %A "$target")"
            else
                echo "Error: Failed to change permissions!"
            fi
        else
            echo "Error: Invalid permission format!"
        fi
        ;;
esac

if [ $action -ge 1 ] && [ $action -le 3 ]; then
    echo ""
    echo "=== Final Information ==="
    ls -ld "$target"
else
    echo "Error: Invalid action choice!"
    exit 1
fi
