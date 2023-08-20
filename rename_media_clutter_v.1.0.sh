#!/bin/bash

################################################################################
# Title: rename_media_clutter_v.1.0.sh
# Version: 1.0
# Description: This script renames media files in a directory based on their
#   creation date and time, and adds prefixes "P_" for pictures and "V_" for
#   audio/video files.
#
# Developer: Tushar Sharma
# Last Updated: 15-AUG-2023
#
# Change Notes: 
# - initial version to rename media files in a given directory
################################################################################

# Get source directory from command line argument or prompt the user
if [ $# -eq 1 ]; then
    source_dir="$1"
else
    read -p "Enter the source directory: " source_dir
fi

# Validate source directory
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' not found."
    exit 1
fi

# Log file directory
log_dir="logs"

# Create the log directory if it doesn't exist
mkdir -p "$log_dir"

# Get current date and time for log and error log file names
current_datetime=$(date +'%Y%m%d_%H%M%S')
main_log="$log_dir/main_log_$current_datetime.txt"
error_log="$log_dir/error_logs_$current_datetime.txt"

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
        local new_path="$source_dir/${prefix}${new_name}${extension}"  # Include extension
        
        # If a file with the new name already exists, add a sequence number prefix
        if [ -e "$new_path" ]; then
            local sequence_number=1
            while [ -e "${source_dir}/${prefix}${new_name}_$(printf '%04d' "$sequence_number")${extension}" ]; do
                sequence_number=$((sequence_number + 1))
            done
            new_path="${source_dir}/${prefix}${new_name}_$(printf '%04d' "$sequence_number")${extension}"
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
