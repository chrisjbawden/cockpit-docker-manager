#!/bin/bash

# Suppress command output
exec &> /dev/null

# Check if the OS is Ubuntu
if [ "$(lsb_release -si)" != "Ubuntu" ]; then
  echo ""
  echo "This script was created for Ubuntu"
  echo ""

  read -p "This script is intended for Ubuntu - Do you want to continue? (y/n): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Script aborted."
    sleep 5
    exit 1
  fi
fi

# Define the install target
target_directory="/usr/share/cockpit/dockermanager"

# Handle upgrade logic
if [ "$1" = "upgrade" ]; then
  if [ -d "$target_directory" ]; then
    rm -rf "$target_directory" || { echo "Failed to delete existing directory."; sleep 5; exit 1; }
  fi
fi

# Backup existing directory if it exists
if [ -d "$target_directory" ]; then
  mv "$target_directory" "${target_directory}.old" || { echo "Failed to rename existing directory."; sleep 5; exit 1; }
fi

# Download .tar file from GitHub
tar_url="https://github.com/chrisjbawden/cockpit-docker-manager/raw/refs/heads/main/dockermanager.tar"
wget "$tar_url" -O dockermanager.tar

# Create target directory and extract contents into it
mkdir -p "$target_directory"
tar -xf dockermanager.tar -C "$target_directory"

# Clean up tar file
rm dockermanager.tar

echo ""
echo ""
echo "Docker Manager deployed successfully to $target_directory"
echo ""
echo ""
