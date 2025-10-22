#!/bin/bash
# Script to create user with specified parameters

echo "=== Create New User ==="

read -p "Enter username: " username

# Check if user exists
if id "$username" &>/dev/null; then
    echo "Error: User $username already exists!"
    exit 1
fi

echo ""
echo "Fill user parameters (can be skipped):"

read -p "Comment/user information: " comment
read -p "Home directory: " home_dir
read -p "UID (User ID): " uid
read -p "GID (Group ID): " gid

# Password with verification
while true; do
    read -s -p "Password: " password
    echo
    read -s -p "Repeat password: " password_confirm
    echo
    
    if [ "$password" != "$password_confirm" ]; then
        echo "Passwords don't match! Try again."
    else
        break
    fi
done

echo ""
echo "=== User Parameters ==="
echo "Name: $username"
echo "Comment: ${comment:-not specified}"
echo "Home directory: ${home_dir:-/home/$username}"
echo "UID: ${uid:-auto}"
echo "GID: ${gid:-auto}"
echo ""

read -p "Create user with these parameters? (y/n): " confirm

if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
    # Build useradd command
    useradd_cmd="sudo useradd"
    
    [ -n "$comment" ] && useradd_cmd="$useradd_cmd -c \"$comment\""
    [ -n "$home_dir" ] && useradd_cmd="$useradd_cmd -d \"$home_dir\""
    [ -n "$uid" ] && useradd_cmd="$useradd_cmd -u \"$uid\""
    [ -n "$gid" ] && useradd_cmd="$useradd_cmd -g \"$gid\""
    
    useradd_cmd="$useradd_cmd -m \"$username\""
    
    echo "Executing: $useradd_cmd"
    
    # Create user
    if eval "$useradd_cmd" 2>/dev/null; then
        echo "User $username successfully created!"
        
        # Set password
        if [ -n "$password" ]; then
            echo "Setting password..."
            echo "$username:$password" | sudo chpasswd
            if [ $? -eq 0 ]; then
                echo "Password set!"
            else
                echo "Warning: Failed to set password!"
            fi
        fi
        
        # Display created user information
        echo ""
        echo "=== Created User Information ==="
        id "$username"
        echo "Home directory: $(eval echo ~$username)"
        
    else
        echo "Error: Failed to create user $username!"
        exit 1
    fi
else
    echo "Operation cancelled."
fi
