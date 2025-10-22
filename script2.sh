#!/bin/bash
# Script to find user in system

echo "=== Find User in System ==="

read -p "Enter username to search: " username

# Search for user
if id "$username" &>/dev/null; then
    echo "User $username exists in system!"
    echo ""
    echo "=== System Information About User ==="
    
    # Basic information
    echo "1. Basic information:"
    id "$username"
    
    # Information from /etc/passwd
    echo -e "\n2. Detailed information from /etc/passwd:"
    if grep "^$username:" /etc/passwd &>/dev/null; then
        user_info=$(grep "^$username:" /etc/passwd)
        IFS=':' read -r user_name password uid gid gecos home shell <<< "$user_info"
        echo "   Username: $user_name"
        echo "   UID: $uid"
        echo "   GID: $gid"
        echo "   Full name/Comment: $gecos"
        echo "   Home directory: $home"
        echo "   Default shell: $shell"
    fi
    
    # Home directory
    echo -e "\n3. Home directory:"
    home_dir=$(eval echo ~$username)
    echo "   Path: $home_dir"
    if [ -d "$home_dir" ]; then
        echo "   Status: Exists"
        echo "   Size: $(du -sh "$home_dir" 2>/dev/null | cut -f1) (approximate)"
    else
        echo "   Status: Does not exist"
    fi
    
    # User groups
    echo -e "\n4. User groups:"
    groups "$username"
    
    # Last login time
    echo -e "\n5. Last login time:"
    last_output=$(last "$username" 2>/dev/null | head -1)
    if [ -n "$last_output" ]; then
        echo "   $last_output"
    else
        echo "   Information unavailable or user never logged in"
    fi
    
    # Current user processes
    echo -e "\n6. Current user processes:"
    process_count=$(ps -u "$username" 2>/dev/null | wc -l)
    echo "   Number of processes: $((process_count - 1))"  # Subtract header
    
else
    echo "Error: User $username does not exist in system!"
    
    # Search for similar users
    echo -e "\nSimilar users in system:"
    grep -i "$username" /etc/passwd | cut -d: -f1 | while read -r similar_user; do
        echo "   - $similar_user"
    done
    exit 1
fi
