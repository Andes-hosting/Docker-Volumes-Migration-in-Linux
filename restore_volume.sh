#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 <backup_file> <volume_name>"
  exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 2 ]; then
  usage
fi

# Set the backup file and volume name from the input arguments
backup_file=$1
volume_name=$2

# Check if the backup file exists
if [ ! -f "$backup_file" ]; then
  echo "Error: Backup file '$backup_file' not found."
  exit 1
fi

# Check if the volume folder exists
volume_folder="/var/lib/docker/volumes/$volume_name"
if [ ! -d "$volume_folder" ]; then
  echo "Error: Volume folder '$volume_folder' not found."
  exit 1
fi

# Extract the contents of the backup file to a temporary directory
temp_dir=$(mktemp -d)
tar -xzvf "$backup_file" -C "$temp_dir"

# Delete the volume folder
rm -rf "$volume_folder/_data"

# Move the contents of the temporary directory to the volume folder, replacing existing files
backupname=$(basename "$backup_file" | sed 's/\(.*\)_backup_.*\.tar\.gz/\1/')
cp -rf "$temp_dir/$backupname/_data" "$volume_folder/_data"

# Clean up the temporary directory
rm -r "$temp_dir"

echo "Restore completed successfully. Volume '$volume_name' has been replaced with the contents of the backup."
