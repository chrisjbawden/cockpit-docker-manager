#!/bin/bash

# Suppress command output
exec &> /dev/null

# Check if the OS is Ubuntu 22 or higher
if [ "$(lsb_release -si)" != "Ubuntu" ]; then
  echo ""
  echo "This script was created for Ubuntu"
  echo ""
  
# Confirm before continuing
  read -p "This script is intended for Ubuntu - Do you want to continue? (y/n): " confirm
  if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
    echo ""
    echo "Script aborted."
    sleep 5
    exit 1
  fi
fi

# Check if the upgrade option is provided
if [ "$1" = "upgrade" ]; then
  # Check if the target directory exists
  if [ -d "/usr/share/cockpit/dockermanager" ]; then
    # Delete existing directory
    rm -rf "/usr/share/cockpit/dockermanager" || echo "Failed to delete existing directory." ; sleep 5 ; exit
  fi
fi

# Check if the target directory exists
if [ -d "$target_directory" ]; then
  # Rename existing directory to 'old'
  mv "$target_directory" "$target_directory.old" || echo "Failed to rename existing directory." ; sleep 5 ; exit
fi

# Download the .tar file
tar_url=""  # Replace with the actual URL
wget https://github.com/chrisjbawden/cockpit-portainer-application/releases/download/v1.1-beta/cockpit-portainer-application-1.1-beta.tar

# Extract the .tar file to the target directory
tar -xf cockpit-portainer-application-1.1-beta.tar

sudo mv portainer /usr/share/cockpit

# Cleanup: Remove the downloaded .tar file
rm cockpit-portainer-application-1.1-beta.tar

echo ""
echo ""
echo "Script executed successfully."
echo ""
echo ""
