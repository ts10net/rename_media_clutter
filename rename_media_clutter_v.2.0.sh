#!/bin/bash

################################################################################
# Title: rename_media_clutter_v.2.0.sh
# Version: 2.0
# Description: This script renames media files in a directory based on their
#   creation date and time, and adds prefixes "P_" for pictures and "V_" for
#   audio/video files. It can also move files to a destination folder.
#
# Parameters: -s source_folder [-d destination_folder]
#
# Developer: Tushar Sharma
# Last Updated: 16-AUG-2023
#
# Change Notes: 
# - added source and destination directories as input parameters
# - included headers on main log
################################################################################

# Default values
source_dir=""
destination_dir=""
move_files=false

# Function to print script usage
print_usage() {
    echo "Usage: $0 -s source_folder [-d destination_folder]"
    echo "Options:"
    echo "  -s   Specify the source folder containing media files."
    echo "  -d   Specify a destination folder to move renamed files."
}

# Function to prompt user to create a directory
prompt_create_directory() {
    local dir="$1"
    read -p "The directory '$dir' does not exist. Create it? (y/n): " choice
    if [ "$choice" == "y" ]; then
        mkdir -p "$dir"
    else
        echo "Exiting script."
        exit 1
    fi
}

# Process command line options
while getopts ":s:d:" opt; do
    case $opt in
        s)
            source_dir="$OPTARG"
            ;;
        d)
            destination_dir="$OPTARG"
            move_files=true
            ;;
        \?)
            echo "Invalid option: -$OPTARG"
            print_usage
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument."
            print_usage
            exit 1
            ;;
    esac
done

# Check if source directory is provided
if [ -z "$source_dir" ]; then
    echo "Error: Source directory not provided."
    print_usage
    exit 1
fi

# Validate source directory
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' not found."
    exit 1
fi

# Validate destination directory if specified
if [ "$move_files" = true ]; then
    if [ -z "$destination_dir" ]; then
        echo "Error: Destination directory not provided."
        print_usage
        exit 1
    elif [ ! -d "$destination_dir" ]; then
        prompt_create_directory "$destination_dir"
    fi
fi

# Log file directory
log_dir="logs"

# Create the log directory if it doesn't exist
mkdir -p "$log_dir"

# Get current date and time for log and error log file names
current_datetime=$(date +'%Y%m%d_%H%M%S')
main_log="$log_dir/main_log_$current_datetime.txt"
error_log="$log_dir/error_logs_$current_datetime.txt"

# Write parameters to log files
echo "Script Parameters:" >> "$main_log"
echo "Timestamp: $(date +'%Y-%m-%d %H:%M:%S')" >> "$main_log"
echo "Source Directory: $source_dir" >> "$main_log"
echo "Destination Directory: $destination_dir" >> "$main_log"
echo "Move Files: $move_files" >> "$main_log"

# Arrays of allowed file extensions (case-insensitive)
allowed_picture_extensions=("heic" "jpg" "jpeg" "png" "gif")
allowed_av_extensions=("mov" "avi" "mp4" "mts" "mpg" "3gp")

# Function to rename a file with prefixed name
rename_file_with_prefix() {
    local old_name="$1"
    local new_name="$2"
    local extension="$3"
    local prefix="$4"
    
    if [[ -n "${new_name// }" ]]; then
        local new_path="${destination_dir:-$source_dir}/${prefix}${new_name}${extension}"  # Include extension
        
        # If a file with the new name already exists, add a sequence number prefix
        if [ -e "$new_path" ]; then
            local sequence_number=1
            while [ -e "${destination_dir:-$source_dir}/${prefix}${new_name}_$(printf '%04d' "$sequence_number")${extension}" ]; do
                sequence_number=$((sequence_number + 1))
            done
            new_path="${destination_dir:-$source_dir}/${prefix}${new_name}_$(printf '%04d' "$sequence_number")${extension}"
        fi
        
        mv "$old_name" "$new_path"
        echo "$(date +'%Y-%m-%d %H:%M:%S') - Renamed '$old_name' to '$(basename "$new_path")'" >> "$main_log"
    else
        log_error "$old_name" "Skipped renaming due to empty or whitespace new name"
    fi
}

# Function to log errors
log_error() {
    local filename="$1"
    local error_message="$2"
    echo "$(date +'%Y-%m-%d %H:%M:%S') - Error for '$filename': $error_message" >> "$error_log"
}

# Function to process a media file (common logic for both picture and audio/video)
process_file() {
    local file="$1"
    local old_name="$2"
    local extension="$3"
    local prefix="$4"
    
    local datetime=$(echo "$old_name" | grep -oP '\d{4}-\d{2}-\d{2} \d{2}.\d{2}.\d{2}')
    
    if [ -n "$datetime" ]; then
        # Replace dots with colons in the datetime string
        datetime=$(echo "$datetime" | tr '.' ':')
        
        local new_name=$(date -d "$datetime" +'%Y%m%d_%H%M%S')
        rename_file_with_prefix "$file" "$new_name" "$extension" "$prefix"
    else
        log_error "$old_name" "No date and time found"
    fi
}

# Function to process a media file
process_media_file() {
    local file="$1"
    local old_name=$(basename "$file")
    local extension=".${old_name##*.}"  # Include dot before extension
    
    # Convert extension to lowercase for case-insensitive comparison
    extension_lower=$(echo "$extension" | tr '[:upper:]' '[:lower:]')
    
    if [[ " ${allowed_picture_extensions[@]/#/.} " =~ " $extension_lower " ]]; then
        process_file "$file" "$old_name" "$extension_lower" "P_"
    elif [[ " ${allowed_av_extensions[@]/#/.} " =~ " $extension_lower " ]]; then
        process_file "$file" "$old_name" "$extension_lower" "V_"
    else
        log_error "$old_name" "Skipped due to unsupported extension '$extension_lower'"
    fi
}

# Main script
for file in "$source_dir"/*; do
    if [ -f "$file" ]; then
        process_media_file "$file"
    fi
done