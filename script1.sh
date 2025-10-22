#!/bin/bash
# Script to change user home directory and password

echo "=== Change User Parameters ==="

read -p "Enter username: " username

# Check if user exists
if ! id "$username" &>/dev/null; then
    echo "Error: User $username does not exist!"
    exit 1
fi

echo "Current user information:"
echo "=== Basic Information ==="
id "$username"

echo -e "\n=== Detailed information from /etc/passwd ==="
if grep "^$username:" /etc/passwd &>/dev/null; then
    user_info=$(grep "^$username:" /etc/passwd)
    IFS=':' read -r user_name password uid gid gecos home shell <<< "$user_info"
    echo "Username: $user_name"
    echo "UID: $uid"
    echo "GID: $gid"
    echo "Comment: $gecos"
    echo "Home directory: $home"
    echo "Shell: $shell"
else
    echo "Information not found in /etc/passwd"
fi

echo -e "\n=== User groups ==="
groups "$username"

echo -e "\n=== Home directory ==="
echo "$(eval echo ~$username)"

# Check if home directory exists
if [ -d "$(eval echo ~$username)" ]; then
    echo "Status: Exists"
else
    echo "Status: Does not exist"
fi

# Change home directory
echo -e "\n=== Change Home Directory ==="
read -p "Enter new home directory (or press Enter to skip): " new_home
if [ -n "$new_home" ]; then
    echo "Changing home directory to $new_home..."
    
    # Check if new directory exists
    if [ ! -d "$new_home" ]; then
        read -p "Directory does not exist. Create it? (y/n): " create_dir
        if [ "$create_dir" = "y" ] || [ "$create_dir" = "Y" ]; then
            sudo mkdir -p "$new_home" 2>/dev/null
            if [ $? -eq 0 ]; then
                echo "Directory created."
            else
                echo "Error: Failed to create directory!"
            fi
        fi
    fi
    
    if sudo usermod -d "$new_home" "$username" 2>/dev/null; then
        echo "Home directory successfully changed!"
        
        # Copy files from old home to new home
        old_home=$(eval echo ~$username)
        if [ -d "$old_home" ] && [ "$old_home" != "$new_home" ]; then
            read -p "Copy files from old home directory? (y/n): " copy_files
            if [ "$copy_files" = "y" ] || [ "$copy_files" = "Y" ]; then
                sudo cp -r "$old_home"/. "$new_home"/ 2>/dev/null && \
                sudo chown -R "$username:$username" "$new_home" 2>/dev/null
                if [ $? -eq 0 ]; then
                    echo "Files successfully copied."
                else
                    echo "Error copying files."
                fi
            fi
        fi
    else
        echo "Error: Failed to change home directory!"
    fi
fi

# Change password
echo -e "\n=== Change Password ==="
read -p "Do you want to change user password? (y/n): " change_pass
if [ "$change_pass" = "y" ] || [ "$change_pass" = "Y" ]; then
    echo "Changing password for user $username..."
    if sudo passwd "$username"; then
        echo "Password successfully changed!"
    else
        echo "Error: Failed to change password!"
    fi
fi

# Display updated information
echo -e "\n=== Updated User Information ==="
id "$username"
echo -e "\nHome directory: $(eval echo ~$username)"

# Check if new home directory exists
if [ -n "$new_home" ]; then
    if [ -d "$new_home" ]; then
        echo "Home directory status: Exists"
        echo "Permissions: $(ls -ld "$new_home" | awk '{print $1}')"
        echo "Owner: $(ls -ld "$new_home" | awk '{print $3}')"
    else
        echo "Home directory status: Does not exist"
    fi
fi

echo -e "\n=== Additional Information ==="
echo "Last login:"
last "$username" | head -1 2>/dev/null || echo "Information unavailable"

echo -e "\nCurrent sessions:"
who | grep "$username" 2>/dev/null || echo "No active sessions"
