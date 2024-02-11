#!/bin/bash

# Function to display usage information
usage() {
  echo "Usage: $0 <volume_name>"
  exit 1
}

# Check if the correct number of arguments is provided
if [ "$#" -ne 1 ]; then
  usage
fi

# Get the current user
user=$(whoami)

# Set the volume name from the input argument
volume_name=$1

# Check if the backup folder exists, create it if not
backup_folder="/home/$user/backup"
if [ ! -d "$backup_folder" ]; then
  mkdir -p "$backup_folder"
fi

# Check if the volume folder exists
volume_folder="/var/lib/docker/volumes/$volume_name/_data"
if [ ! -d "$volume_folder" ]; then
  echo "Error: Volume folder '$volume_folder' not found."
  exit 1
fi

# Create a timestamp for the backup file
timestamp=$(date +"%Y%m%d%H%M%S")

# Compress and move the volume folder to the backup folder
backup_file="$backup_folder/${volume_name}_backup_$timestamp.tar.gz"
tar -czvf "$backup_file" -C "/var/lib/docker/volumes" "$volume_name"

echo "Backup completed successfully. Backup file: $backup_file"
