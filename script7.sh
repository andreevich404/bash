#!/bin/bash
# Script to kill processes

echo "=== Kill Process ==="

echo "Choose process search method:"
echo "1 - By process name"
echo "2 - By PID (Process ID)"
read -p "Your choice (1 or 2): " choice

case $choice in
    1)
        read -p "Enter process name: " process_name
        if [ -z "$process_name" ]; then
            echo "Error: Process name cannot be empty!"
            exit 1
        fi
        
        # Search processes by name
        pids=$(pgrep "$process_name" 2>/dev/null)
        if [ -z "$pids" ]; then
            echo "Error: Processes with name '$process_name' not found!"
            exit 1
        fi
        
        echo "Found processes:"
        for pid in $pids; do
            process_info=$(ps -p "$pid" -o pid,user,comm,cmd --no-headers 2>/dev/null)
            echo "PID: $pid | $process_info"
        done
        
        read -p "Enter PID to kill (or 'all' for all): " pid_choice
        
        if [ "$pid_choice" = "all" ]; then
            echo "Killing all processes with name '$process_name'..."
            if pkill "$process_name"; then
                echo "All '$process_name' processes killed!"
            else
                echo "Error killing processes!"
            fi
        else
            if echo "$pids" | grep -w "$pid_choice" &>/dev/null; then
                echo "Killing process with PID $pid_choice..."
                if kill "$pid_choice"; then
                    echo "Process $pid_choice killed!"
                else
                    echo "Error killing process!"
                fi
            else
                echo "Error: PID $pid_choice doesn't belong to process '$process_name'!"
            fi
        fi
        ;;
    2)
        read -p "Enter process PID: " pid
        if ! [[ "$pid" =~ ^[0-9]+$ ]]; then
            echo "Error: PID must be a number!"
            exit 1
        fi
        
        # Check if process exists
        if ! ps -p "$pid" &>/dev/null; then
            echo "Error: Process with PID $pid doesn't exist!"
            exit 1
        fi
        
        echo "Process information:"
        ps -p "$pid" -o pid,user,comm,cmd --no-headers
        
        read -p "Are you sure you want to kill this process? (y/n): " confirm
        if [ "$confirm" = "y" ] || [ "$confirm" = "Y" ]; then
            if kill "$pid"; then
                echo "Process $pid killed!"
            else
                echo "Error killing process!"
            fi
        else
            echo "Operation cancelled."
        fi
        ;;
    *)
        echo "Error: Invalid choice!"
        exit 1
        ;;
esac
